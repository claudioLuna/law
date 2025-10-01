-- Migración inicial para el sistema de soporte WhatsApp
-- Crea las tablas necesarias para reclamos, devoluciones y logs

-- Tabla de reclamos
CREATE TABLE IF NOT EXISTS reclamos (
    id BIGSERIAL PRIMARY KEY,
    ticket_id VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    producto VARCHAR(500) NOT NULL,
    motivo VARCHAR(500) NOT NULL,
    descripcion TEXT NOT NULL,
    conversation_id VARCHAR(100),
    user_phone VARCHAR(20),
    status VARCHAR(50) DEFAULT 'nuevo' CHECK (status IN ('nuevo', 'en_proceso', 'resuelto', 'cerrado')),
    priority VARCHAR(20) DEFAULT 'media' CHECK (priority IN ('baja', 'media', 'alta', 'critica')),
    source VARCHAR(50) DEFAULT 'whatsapp_kapso',
    jira_ticket_id VARCHAR(50),
    assigned_to VARCHAR(100),
    resolution TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    resolved_at TIMESTAMPTZ
);

-- Tabla de devoluciones
CREATE TABLE IF NOT EXISTS devoluciones (
    id BIGSERIAL PRIMARY KEY,
    devolucion_id VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    numero_orden VARCHAR(100) NOT NULL,
    producto VARCHAR(500) NOT NULL,
    motivo VARCHAR(500) NOT NULL,
    estado_producto VARCHAR(100) NOT NULL CHECK (estado_producto IN ('nuevo', 'usado', 'defectuoso')),
    elegible BOOLEAN DEFAULT true,
    dias_transcurridos INTEGER,
    status VARCHAR(50) DEFAULT 'pendiente_revision' CHECK (status IN ('pendiente_revision', 'aprobada', 'rechazada', 'procesada', 'completada')),
    tracking_number VARCHAR(100),
    refund_amount DECIMAL(10,2),
    refund_method VARCHAR(50),
    conversation_id VARCHAR(100),
    user_phone VARCHAR(20),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    processed_at TIMESTAMPTZ
);

-- Tabla de consultas generales
CREATE TABLE IF NOT EXISTS consultas (
    id BIGSERIAL PRIMARY KEY,
    consulta_id VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(255),
    email VARCHAR(255),
    tipo_consulta VARCHAR(100) NOT NULL,
    pregunta TEXT NOT NULL,
    respuesta TEXT,
    conversation_id VARCHAR(100),
    user_phone VARCHAR(20),
    status VARCHAR(50) DEFAULT 'nueva' CHECK (status IN ('nueva', 'respondida', 'cerrada')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    responded_at TIMESTAMPTZ
);

-- Tabla de logs de conversaciones
CREATE TABLE IF NOT EXISTS conversation_logs (
    id BIGSERIAL PRIMARY KEY,
    conversation_id VARCHAR(100) NOT NULL,
    user_phone VARCHAR(20) NOT NULL,
    message_type VARCHAR(50) NOT NULL CHECK (message_type IN ('user_message', 'bot_response', 'system_event')),
    content TEXT NOT NULL,
    metadata JSONB,
    node_name VARCHAR(100),
    flow_name VARCHAR(100),
    timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla de métricas y analytics
CREATE TABLE IF NOT EXISTS metrics (
    id BIGSERIAL PRIMARY KEY,
    metric_type VARCHAR(100) NOT NULL,
    metric_name VARCHAR(100) NOT NULL,
    value DECIMAL(15,4) NOT NULL,
    dimensions JSONB,
    date_recorded DATE DEFAULT CURRENT_DATE,
    timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para optimizar consultas
CREATE INDEX IF NOT EXISTS idx_reclamos_ticket_id ON reclamos(ticket_id);
CREATE INDEX IF NOT EXISTS idx_reclamos_status ON reclamos(status);
CREATE INDEX IF NOT EXISTS idx_reclamos_created_at ON reclamos(created_at);
CREATE INDEX IF NOT EXISTS idx_reclamos_email ON reclamos(email);

CREATE INDEX IF NOT EXISTS idx_devoluciones_devolucion_id ON devoluciones(devolucion_id);
CREATE INDEX IF NOT EXISTS idx_devoluciones_status ON devoluciones(status);
CREATE INDEX IF NOT EXISTS idx_devoluciones_numero_orden ON devoluciones(numero_orden);

CREATE INDEX IF NOT EXISTS idx_consultas_consulta_id ON consultas(consulta_id);
CREATE INDEX IF NOT EXISTS idx_consultas_status ON consultas(status);

CREATE INDEX IF NOT EXISTS idx_conversation_logs_conversation_id ON conversation_logs(conversation_id);
CREATE INDEX IF NOT EXISTS idx_conversation_logs_user_phone ON conversation_logs(user_phone);
CREATE INDEX IF NOT EXISTS idx_conversation_logs_timestamp ON conversation_logs(timestamp);

CREATE INDEX IF NOT EXISTS idx_metrics_type_name ON metrics(metric_type, metric_name);
CREATE INDEX IF NOT EXISTS idx_metrics_date ON metrics(date_recorded);

-- Triggers para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_reclamos_updated_at 
    BEFORE UPDATE ON reclamos 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_devoluciones_updated_at 
    BEFORE UPDATE ON devoluciones 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_consultas_updated_at 
    BEFORE UPDATE ON consultas 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Función para generar IDs únicos
CREATE OR REPLACE FUNCTION generate_ticket_id(prefix TEXT DEFAULT 'TKT')
RETURNS TEXT AS $$
BEGIN
    RETURN prefix || '-' || EXTRACT(EPOCH FROM NOW())::BIGINT || '-' || 
           UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 5));
END;
$$ LANGUAGE plpgsql;

-- Vistas para reportes y analytics
CREATE OR REPLACE VIEW reclamos_summary AS
SELECT 
    status,
    priority,
    COUNT(*) as total,
    COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE) as today,
    COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE - INTERVAL '7 days') as this_week,
    COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE - INTERVAL '30 days') as this_month,
    AVG(EXTRACT(EPOCH FROM (COALESCE(resolved_at, NOW()) - created_at))/3600) as avg_resolution_hours
FROM reclamos
GROUP BY status, priority;

CREATE OR REPLACE VIEW devoluciones_summary AS
SELECT 
    status,
    elegible,
    COUNT(*) as total,
    COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE) as today,
    AVG(dias_transcurridos) as avg_days_elapsed,
    COUNT(*) FILTER (WHERE elegible = true) as eligible_count,
    COUNT(*) FILTER (WHERE elegible = false) as ineligible_count
FROM devoluciones
GROUP BY status, elegible;

-- Políticas de seguridad RLS (Row Level Security)
ALTER TABLE reclamos ENABLE ROW LEVEL SECURITY;
ALTER TABLE devoluciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE consultas ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversation_logs ENABLE ROW LEVEL SECURITY;

-- Política para permitir acceso completo a usuarios autenticados
CREATE POLICY "Allow full access to authenticated users" ON reclamos
    FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Allow full access to authenticated users" ON devoluciones
    FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Allow full access to authenticated users" ON consultas
    FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Allow full access to authenticated users" ON conversation_logs
    FOR ALL USING (auth.role() = 'authenticated');

-- Comentarios para documentación
COMMENT ON TABLE reclamos IS 'Almacena todos los reclamos recibidos vía WhatsApp';
COMMENT ON TABLE devoluciones IS 'Gestiona solicitudes de devolución y reembolsos';
COMMENT ON TABLE consultas IS 'Registra consultas generales de clientes';
COMMENT ON TABLE conversation_logs IS 'Log completo de conversaciones para auditoría';
COMMENT ON TABLE metrics IS 'Métricas y analytics del sistema';

COMMENT ON COLUMN reclamos.ticket_id IS 'ID único del ticket generado automáticamente';
COMMENT ON COLUMN reclamos.jira_ticket_id IS 'ID del ticket en Jira si se integra';
COMMENT ON COLUMN devoluciones.elegible IS 'Si cumple con la política de 30 días';
COMMENT ON COLUMN conversation_logs.metadata IS 'Datos adicionales en formato JSON';