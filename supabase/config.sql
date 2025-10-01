-- Configuración adicional de Supabase para el sistema de soporte
-- Incluye funciones personalizadas, triggers y configuraciones de seguridad

-- Función para obtener estadísticas de reclamos
CREATE OR REPLACE FUNCTION get_reclamos_stats(
    start_date DATE DEFAULT CURRENT_DATE - INTERVAL '30 days',
    end_date DATE DEFAULT CURRENT_DATE
)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_build_object(
        'total_reclamos', COUNT(*),
        'nuevos', COUNT(*) FILTER (WHERE status = 'nuevo'),
        'en_proceso', COUNT(*) FILTER (WHERE status = 'en_proceso'),
        'resueltos', COUNT(*) FILTER (WHERE status = 'resuelto'),
        'cerrados', COUNT(*) FILTER (WHERE status = 'cerrado'),
        'por_prioridad', json_build_object(
            'alta', COUNT(*) FILTER (WHERE priority = 'alta'),
            'media', COUNT(*) FILTER (WHERE priority = 'media'),
            'baja', COUNT(*) FILTER (WHERE priority = 'baja'),
            'critica', COUNT(*) FILTER (WHERE priority = 'critica')
        ),
        'tiempo_promedio_resolucion_horas', 
        ROUND(AVG(EXTRACT(EPOCH FROM (COALESCE(resolved_at, NOW()) - created_at))/3600)::numeric, 2),
        'periodo', json_build_object(
            'desde', start_date,
            'hasta', end_date
        )
    ) INTO result
    FROM reclamos
    WHERE created_at::date BETWEEN start_date AND end_date;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para obtener métricas de devoluciones
CREATE OR REPLACE FUNCTION get_devoluciones_stats(
    start_date DATE DEFAULT CURRENT_DATE - INTERVAL '30 days',
    end_date DATE DEFAULT CURRENT_DATE
)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_build_object(
        'total_devoluciones', COUNT(*),
        'aprobadas', COUNT(*) FILTER (WHERE status = 'aprobada'),
        'rechazadas', COUNT(*) FILTER (WHERE status = 'rechazada'),
        'procesadas', COUNT(*) FILTER (WHERE status = 'procesada'),
        'tasa_elegibilidad', ROUND((COUNT(*) FILTER (WHERE elegible = true)::float / NULLIF(COUNT(*), 0) * 100)::numeric, 2),
        'dias_promedio_solicitud', ROUND(AVG(dias_transcurridos)::numeric, 1),
        'por_motivo', (
            SELECT json_object_agg(motivo, cnt)
            FROM (
                SELECT motivo, COUNT(*) as cnt
                FROM devoluciones
                WHERE created_at::date BETWEEN start_date AND end_date
                GROUP BY motivo
                ORDER BY cnt DESC
                LIMIT 10
            ) motivos
        )
    ) INTO result
    FROM devoluciones
    WHERE created_at::date BETWEEN start_date AND end_date;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para registrar métricas automáticamente
CREATE OR REPLACE FUNCTION record_daily_metrics()
RETURNS VOID AS $$
BEGIN
    -- Métricas de reclamos
    INSERT INTO metrics (metric_type, metric_name, value, dimensions)
    SELECT 
        'reclamos',
        'total_nuevos',
        COUNT(*),
        json_build_object('date', CURRENT_DATE)
    FROM reclamos
    WHERE created_at::date = CURRENT_DATE;
    
    INSERT INTO metrics (metric_type, metric_name, value, dimensions)
    SELECT 
        'reclamos',
        'tiempo_promedio_resolucion_horas',
        COALESCE(AVG(EXTRACT(EPOCH FROM (resolved_at - created_at))/3600), 0),
        json_build_object('date', CURRENT_DATE)
    FROM reclamos
    WHERE resolved_at::date = CURRENT_DATE;
    
    -- Métricas de devoluciones
    INSERT INTO metrics (metric_type, metric_name, value, dimensions)
    SELECT 
        'devoluciones',
        'total_nuevas',
        COUNT(*),
        json_build_object('date', CURRENT_DATE)
    FROM devoluciones
    WHERE created_at::date = CURRENT_DATE;
    
    INSERT INTO metrics (metric_type, metric_name, value, dimensions)
    SELECT 
        'devoluciones',
        'tasa_aprobacion',
        CASE 
            WHEN COUNT(*) > 0 THEN (COUNT(*) FILTER (WHERE status = 'aprobada')::float / COUNT(*) * 100)
            ELSE 0
        END,
        json_build_object('date', CURRENT_DATE)
    FROM devoluciones
    WHERE created_at::date = CURRENT_DATE;
    
    -- Métricas de conversaciones
    INSERT INTO metrics (metric_type, metric_name, value, dimensions)
    SELECT 
        'conversaciones',
        'total_activas',
        COUNT(DISTINCT conversation_id),
        json_build_object('date', CURRENT_DATE)
    FROM conversation_logs
    WHERE timestamp::date = CURRENT_DATE;
    
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para limpiar logs antiguos (mantener solo 90 días)
CREATE OR REPLACE FUNCTION cleanup_old_logs()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM conversation_logs 
    WHERE timestamp < NOW() - INTERVAL '90 days';
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    
    -- Registrar la limpieza
    INSERT INTO metrics (metric_type, metric_name, value, dimensions)
    VALUES (
        'maintenance',
        'logs_cleaned',
        deleted_count,
        json_build_object('cleanup_date', CURRENT_DATE)
    );
    
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para validar datos de webhook
CREATE OR REPLACE FUNCTION validate_webhook_payload(payload JSON)
RETURNS BOOLEAN AS $$
BEGIN
    -- Validar que tenga los campos requeridos para reclamos
    IF payload->>'tipo' = 'reclamo' THEN
        RETURN (
            payload->'reclamo_data'->>'nombre' IS NOT NULL AND
            payload->'reclamo_data'->>'email' IS NOT NULL AND
            payload->'reclamo_data'->>'producto' IS NOT NULL AND
            payload->'reclamo_data'->>'motivo' IS NOT NULL AND
            payload->'reclamo_data'->>'descripcion' IS NOT NULL
        );
    END IF;
    
    -- Validar que tenga los campos requeridos para devoluciones
    IF payload->>'tipo' = 'devolucion' THEN
        RETURN (
            payload->'data'->>'nombre' IS NOT NULL AND
            payload->'data'->>'email' IS NOT NULL AND
            payload->'data'->>'numero_orden' IS NOT NULL AND
            payload->'data'->>'producto' IS NOT NULL
        );
    END IF;
    
    RETURN false;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para log automático de cambios en reclamos
CREATE OR REPLACE FUNCTION log_reclamo_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        -- Solo loguear si cambió el status o se asignó
        IF OLD.status != NEW.status OR OLD.assigned_to != NEW.assigned_to THEN
            INSERT INTO conversation_logs (
                conversation_id,
                user_phone,
                message_type,
                content,
                metadata,
                node_name,
                flow_name
            ) VALUES (
                COALESCE(NEW.conversation_id, 'system'),
                COALESCE(NEW.user_phone, 'system'),
                'system_event',
                format('Reclamo %s: %s → %s', NEW.ticket_id, OLD.status, NEW.status),
                json_build_object(
                    'old_status', OLD.status,
                    'new_status', NEW.status,
                    'old_assigned', OLD.assigned_to,
                    'new_assigned', NEW.assigned_to,
                    'trigger', 'status_change'
                ),
                'system_update',
                'reclamos_tracking'
            );
        END IF;
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER reclamos_change_log
    AFTER UPDATE ON reclamos
    FOR EACH ROW
    EXECUTE FUNCTION log_reclamo_changes();

-- Crear índices adicionales para optimizar consultas comunes
CREATE INDEX IF NOT EXISTS idx_reclamos_status_created ON reclamos(status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_devoluciones_elegible_status ON devoluciones(elegible, status);
CREATE INDEX IF NOT EXISTS idx_conversation_logs_timestamp_type ON conversation_logs(timestamp DESC, message_type);
CREATE INDEX IF NOT EXISTS idx_metrics_type_date ON metrics(metric_type, date_recorded DESC);

-- Vista para dashboard de métricas en tiempo real
CREATE OR REPLACE VIEW dashboard_metrics AS
SELECT 
    'reclamos' as categoria,
    json_build_object(
        'total', (SELECT COUNT(*) FROM reclamos),
        'nuevos_hoy', (SELECT COUNT(*) FROM reclamos WHERE created_at::date = CURRENT_DATE),
        'pendientes', (SELECT COUNT(*) FROM reclamos WHERE status IN ('nuevo', 'en_proceso')),
        'resueltos_semana', (SELECT COUNT(*) FROM reclamos WHERE status = 'resuelto' AND resolved_at >= CURRENT_DATE - INTERVAL '7 days')
    ) as datos
UNION ALL
SELECT 
    'devoluciones' as categoria,
    json_build_object(
        'total', (SELECT COUNT(*) FROM devoluciones),
        'nuevas_hoy', (SELECT COUNT(*) FROM devoluciones WHERE created_at::date = CURRENT_DATE),
        'pendientes', (SELECT COUNT(*) FROM devoluciones WHERE status = 'pendiente_revision'),
        'tasa_aprobacion', (
            SELECT ROUND(
                (COUNT(*) FILTER (WHERE status = 'aprobada')::float / NULLIF(COUNT(*), 0) * 100)::numeric, 2
            )
            FROM devoluciones 
            WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
        )
    ) as datos
UNION ALL
SELECT 
    'conversaciones' as categoria,
    json_build_object(
        'activas_hoy', (SELECT COUNT(DISTINCT conversation_id) FROM conversation_logs WHERE timestamp::date = CURRENT_DATE),
        'mensajes_hoy', (SELECT COUNT(*) FROM conversation_logs WHERE timestamp::date = CURRENT_DATE AND message_type = 'user_message'),
        'tiempo_respuesta_promedio', (
            SELECT COALESCE(AVG(
                EXTRACT(EPOCH FROM (
                    LEAD(timestamp) OVER (PARTITION BY conversation_id ORDER BY timestamp) - timestamp
                ))/60
            ), 0)
            FROM conversation_logs 
            WHERE timestamp::date = CURRENT_DATE AND message_type = 'user_message'
        )
    ) as datos;

-- Configurar extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

-- Función para generar reportes automáticos
CREATE OR REPLACE FUNCTION generate_daily_report(report_date DATE DEFAULT CURRENT_DATE)
RETURNS JSON AS $$
DECLARE
    report JSON;
BEGIN
    SELECT json_build_object(
        'fecha', report_date,
        'resumen', json_build_object(
            'reclamos', get_reclamos_stats(report_date, report_date),
            'devoluciones', get_devoluciones_stats(report_date, report_date)
        ),
        'metricas_clave', (
            SELECT json_object_agg(metric_name, value)
            FROM metrics 
            WHERE date_recorded = report_date 
            AND metric_type IN ('reclamos', 'devoluciones', 'conversaciones')
        ),
        'generado_en', NOW()
    ) INTO report;
    
    RETURN report;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Programar tareas automáticas (requiere pg_cron extension en producción)
-- SELECT cron.schedule('daily-metrics', '0 1 * * *', 'SELECT record_daily_metrics();');
-- SELECT cron.schedule('weekly-cleanup', '0 2 * * 0', 'SELECT cleanup_old_logs();');

COMMENT ON FUNCTION get_reclamos_stats IS 'Obtiene estadísticas completas de reclamos para un período';
COMMENT ON FUNCTION get_devoluciones_stats IS 'Obtiene estadísticas completas de devoluciones para un período';
COMMENT ON FUNCTION record_daily_metrics IS 'Registra métricas diarias automáticamente';
COMMENT ON FUNCTION cleanup_old_logs IS 'Limpia logs antiguos para mantener la base de datos optimizada';
COMMENT ON FUNCTION validate_webhook_payload IS 'Valida que los payloads de webhook tengan la estructura correcta';
COMMENT ON VIEW dashboard_metrics IS 'Vista optimizada para mostrar métricas en tiempo real en dashboards';