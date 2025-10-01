-- Datos de prueba para el sistema de soporte WhatsApp
-- Ejecutar después de la migración inicial

-- Insertar algunos reclamos de ejemplo
INSERT INTO reclamos (
    ticket_id, nombre, email, producto, motivo, descripcion, 
    conversation_id, user_phone, status, priority, source
) VALUES 
(
    'REC-1704067200-ABC12',
    'Juan Pérez',
    'juan.perez@email.com',
    'Smartphone Galaxy S23',
    'Producto defectuoso',
    'El teléfono se apaga solo después de 2 horas de uso. Ya intenté reiniciarlo varias veces pero el problema persiste.',
    'conv_001',
    '+5491123456789',
    'nuevo',
    'alta',
    'whatsapp_kapso'
),
(
    'REC-1704067300-DEF34',
    'María González',
    'maria.gonzalez@email.com', 
    'Auriculares Bluetooth Sony',
    'No funciona correctamente',
    'Los auriculares no se conectan por Bluetooth y cuando lo hacen el sonido se corta constantemente.',
    'conv_002',
    '+5491123456790',
    'en_proceso',
    'media',
    'whatsapp_kapso'
),
(
    'REC-1704067400-GHI56',
    'Carlos Rodríguez',
    'carlos.rodriguez@email.com',
    'Laptop Dell Inspiron 15',
    'Pantalla con líneas',
    'Aparecieron líneas verticales en la pantalla después de una semana de uso. La garantía debería cubrir este defecto.',
    'conv_003', 
    '+5491123456791',
    'resuelto',
    'alta',
    'whatsapp_kapso'
);

-- Insertar algunas devoluciones de ejemplo
INSERT INTO devoluciones (
    devolucion_id, nombre, email, numero_orden, producto, motivo, 
    estado_producto, elegible, dias_transcurridos, status
) VALUES
(
    'DEV-1704067500-JKL78',
    'Ana Martínez',
    'ana.martinez@email.com',
    'ORD-2024-001234',
    'Camiseta Nike Talla M',
    'Talla incorrecta',
    'nuevo',
    true,
    15,
    'aprobada'
),
(
    'DEV-1704067600-MNO90',
    'Luis Fernández',
    'luis.fernandez@email.com',
    'ORD-2024-001235',
    'Zapatillas Adidas Talla 42',
    'No me gustó el color',
    'usado',
    false,
    35,
    'rechazada'
),
(
    'DEV-1704067700-PQR12',
    'Sofia López',
    'sofia.lopez@email.com',
    'ORD-2024-001236',
    'Mochila Samsonite',
    'Producto defectuoso',
    'defectuoso',
    true,
    10,
    'procesada'
);

-- Insertar consultas de ejemplo
INSERT INTO consultas (
    consulta_id, nombre, email, tipo_consulta, pregunta, respuesta, 
    conversation_id, user_phone, status
) VALUES
(
    'CON-1704067800-STU34',
    'Roberto Silva',
    'roberto.silva@email.com',
    'Información de producto',
    '¿Cuáles son las especificaciones técnicas del iPhone 15 Pro?',
    'El iPhone 15 Pro cuenta con chip A17 Pro, cámara principal de 48MP, pantalla Super Retina XDR de 6.1 pulgadas...',
    'conv_004',
    '+5491123456792',
    'respondida'
),
(
    'CON-1704067900-VWX56',
    'Elena Morales',
    'elena.morales@email.com',
    'Soporte técnico',
    '¿Cómo configuro el WiFi en mi smart TV Samsung?',
    NULL,
    'conv_005',
    '+5491123456793',
    'nueva'
),
(
    'CON-1704068000-YZA78',
    'Diego Castro',
    'diego.castro@email.com',
    'Horarios y contacto',
    '¿Cuál es el horario de atención al cliente?',
    'Nuestro horario de atención es de lunes a viernes de 9:00 a 18:00 hs, y sábados de 9:00 a 13:00 hs.',
    'conv_006',
    '+5491123456794',
    'respondida'
);

-- Insertar logs de conversación de ejemplo
INSERT INTO conversation_logs (
    conversation_id, user_phone, message_type, content, metadata, node_name, flow_name
) VALUES
(
    'conv_001',
    '+5491123456789',
    'user_message',
    'Hola, tengo un problema con mi teléfono',
    '{"timestamp": "2024-01-01T10:00:00Z", "platform": "whatsapp"}',
    'wait_solicitud',
    'orquestador_central'
),
(
    'conv_001',
    '+5491123456789',
    'bot_response',
    '¡Hola! Bienvenido al soporte de nuestra empresa...',
    '{"node_type": "SendTextNode", "response_time_ms": 150}',
    'saludo_inicial',
    'orquestador_central'
),
(
    'conv_001',
    '+5491123456789',
    'system_event',
    'Clasificado como: reclamo',
    '{"classification_confidence": 0.95, "model": "claude-3-5-sonnet-20241022"}',
    'clasificar_tipo_caso',
    'orquestador_central'
),
(
    'conv_002',
    '+5491123456790',
    'user_message',
    'Quiero devolver unos auriculares que compré',
    '{"timestamp": "2024-01-01T11:00:00Z", "platform": "whatsapp"}',
    'wait_solicitud',
    'orquestador_central'
);

-- Insertar métricas de ejemplo
INSERT INTO metrics (metric_type, metric_name, value, dimensions) VALUES
('conversation', 'total_conversations', 100, '{"period": "daily", "date": "2024-01-01"}'),
('conversation', 'avg_resolution_time_minutes', 45.5, '{"period": "daily", "date": "2024-01-01"}'),
('classification', 'reclamos_percentage', 35.2, '{"period": "daily", "date": "2024-01-01"}'),
('classification', 'devoluciones_percentage', 28.7, '{"period": "daily", "date": "2024-01-01"}'),
('classification', 'consultas_percentage', 36.1, '{"period": "daily", "date": "2024-01-01"}'),
('satisfaction', 'avg_rating', 4.2, '{"period": "weekly", "week": "2024-W01"}'),
('performance', 'webhook_success_rate', 99.8, '{"period": "daily", "date": "2024-01-01"}'),
('performance', 'avg_response_time_ms', 250, '{"period": "hourly", "hour": "2024-01-01T10"}');

-- Actualizar algunos registros para simular progreso
UPDATE reclamos SET 
    status = 'en_proceso',
    assigned_to = 'soporte@empresa.com',
    jira_ticket_id = 'SUP-123'
WHERE ticket_id = 'REC-1704067300-DEF34';

UPDATE reclamos SET 
    status = 'resuelto',
    resolution = 'Se envió producto de reemplazo. Cliente confirmó funcionamiento correcto.',
    resolved_at = NOW() - INTERVAL '2 days',
    assigned_to = 'soporte@empresa.com',
    jira_ticket_id = 'SUP-124'
WHERE ticket_id = 'REC-1704067400-GHI56';

UPDATE devoluciones SET 
    status = 'procesada',
    tracking_number = 'TRK123456789',
    refund_amount = 89.99,
    refund_method = 'tarjeta_credito',
    processed_at = NOW() - INTERVAL '1 day'
WHERE devolucion_id = 'DEV-1704067700-PQR12';

-- Crear algunos usuarios de ejemplo para testing (opcional)
-- Nota: Esto es solo para desarrollo, en producción los usuarios se crean via auth
INSERT INTO conversation_logs (
    conversation_id, user_phone, message_type, content, metadata
) VALUES
(
    'test_conv_001',
    '+5491199999999',
    'system_event',
    'Usuario de prueba creado para testing',
    '{"test_user": true, "created_for": "development"}'
);

-- Verificar que los datos se insertaron correctamente
DO $$
BEGIN
    RAISE NOTICE 'Datos de prueba insertados exitosamente:';
    RAISE NOTICE '- Reclamos: %', (SELECT COUNT(*) FROM reclamos);
    RAISE NOTICE '- Devoluciones: %', (SELECT COUNT(*) FROM devoluciones);
    RAISE NOTICE '- Consultas: %', (SELECT COUNT(*) FROM consultas);
    RAISE NOTICE '- Logs de conversación: %', (SELECT COUNT(*) FROM conversation_logs);
    RAISE NOTICE '- Métricas: %', (SELECT COUNT(*) FROM metrics);
END $$;