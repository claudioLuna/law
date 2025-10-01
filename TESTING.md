# 🧪 Guía de Testing - Sistema de Soporte WhatsApp

## 📋 Testing del MVP

### 1. Testing de Flujos Kapso

#### Orquestador Central
```python
# Ejecutar desde kapso/flows/
python orquestador_central.py

# Verificar que se crean los nodos:
# - start_orquestador
# - saludo_inicial  
# - wait_solicitud
# - clasificar_tipo_caso
```

#### Agente de Reclamos
```python
# Ejecutar desde kapso/flows/
python agente_reclamos.py

# Verificar que se crean los flujos:
# - agente_reclamos (con webhook a n8n)
# - agente_devoluciones
# - agente_consultas
```

### 2. Testing de Workflows n8n

#### Importar Workflows
1. Acceder a n8n: `https://n8n.tu-dominio.com`
2. Ir a **Workflows** > **Import from File**
3. Importar `n8n/workflows/reclamos-processor.json`
4. Importar `n8n/workflows/devoluciones-processor.json`

#### Test de Webhook de Reclamos
```bash
# Test básico del webhook
curl -X POST https://n8n.tu-dominio.com/webhook/reclamos-processor \
  -H "Content-Type: application/json" \
  -d '{
    "timestamp": "2024-01-01T10:00:00Z",
    "source": "kapso_whatsapp",
    "reclamo_data": {
      "nombre": "Juan Pérez Test",
      "email": "juan.test@email.com",
      "producto": "Smartphone Test",
      "motivo": "Producto defectuoso test",
      "descripcion": "Test de integración webhook",
      "conversation_id": "test_conv_001",
      "user_phone": "+5491123456789"
    }
  }'

# Respuesta esperada:
# {
#   "success": true,
#   "reclamo_id": "REC-...",
#   "message": "Reclamo procesado exitosamente"
# }
```

#### Test de Webhook de Devoluciones
```bash
curl -X POST https://n8n.tu-dominio.com/webhook/devoluciones-processor \
  -H "Content-Type: application/json" \
  -d '{
    "tipo": "devolucion",
    "data": {
      "nombre": "María Test",
      "email": "maria.test@email.com",
      "numero_orden": "ORD-TEST-001",
      "producto": "Camiseta Test",
      "motivo": "Talla incorrecta",
      "estado_producto": "nuevo",
      "fecha_compra": "2024-01-01"
    }
  }'
```

### 3. Testing de Base de Datos

#### Verificar Conexión
```bash
# Conectar a PostgreSQL
docker-compose exec postgres psql -U n8n -d n8n

# Verificar tablas
\dt

# Verificar datos de prueba
SELECT COUNT(*) FROM reclamos;
SELECT COUNT(*) FROM devoluciones;
SELECT COUNT(*) FROM consultas;
```

#### Verificar Funciones
```sql
-- Test de estadísticas
SELECT get_reclamos_stats();
SELECT get_devoluciones_stats();

-- Test de métricas
SELECT * FROM dashboard_metrics;

-- Test de generación de IDs
SELECT generate_ticket_id('TEST');
```

### 4. Testing de Integración Completa

#### Flujo de Reclamo Completo
1. **Kapso** recibe mensaje WhatsApp
2. **Clasificador** identifica como "reclamo"
3. **Agente Reclamos** captura datos
4. **Webhook** envía a n8n
5. **n8n** procesa y guarda en Supabase
6. **Jira** crea ticket (si configurado)
7. **Slack** envía notificación
8. **Respuesta** vuelve a Kapso con ID

#### Script de Test Automático
```bash
#!/bin/bash
# test-integration.sh

echo "🧪 Testing integración completa..."

# 1. Test de salud de servicios
echo "1. Verificando servicios..."
./health-check.sh

# 2. Test de webhook reclamos
echo "2. Testing webhook reclamos..."
RESPONSE=$(curl -s -X POST https://n8n.tu-dominio.com/webhook/reclamos-processor \
  -H "Content-Type: application/json" \
  -d '{
    "reclamo_data": {
      "nombre": "Test User",
      "email": "test@example.com",
      "producto": "Test Product",
      "motivo": "Test Issue",
      "descripcion": "Automated test"
    }
  }')

if echo "$RESPONSE" | grep -q "success.*true"; then
    echo "✅ Webhook reclamos: OK"
else
    echo "❌ Webhook reclamos: FAIL"
    echo "$RESPONSE"
fi

# 3. Test de base de datos
echo "3. Testing base de datos..."
DB_COUNT=$(docker-compose exec -T postgres psql -U n8n -d n8n -t -c "SELECT COUNT(*) FROM reclamos WHERE nombre = 'Test User';")
if [ "$DB_COUNT" -gt 0 ]; then
    echo "✅ Base de datos: OK"
else
    echo "❌ Base de datos: FAIL"
fi

echo "🎉 Testing completado"
```

### 5. Testing de Monitoreo

#### Verificar Métricas en Prometheus
```bash
# Acceder a Prometheus
curl http://localhost:9090/metrics

# Verificar métricas específicas
curl 'http://localhost:9090/api/v1/query?query=up'
```

#### Verificar Dashboards en Grafana
1. Acceder a `https://grafana.tu-dominio.com`
2. Login: admin / (ver .env)
3. Verificar dashboards automáticos
4. Comprobar que llegan métricas

### 6. Testing de Performance

#### Load Testing de Webhooks
```bash
# Usar Apache Bench
ab -n 100 -c 10 -p test-payload.json -T application/json \
  https://n8n.tu-dominio.com/webhook/reclamos-processor

# Usar curl en loop
for i in {1..50}; do
  curl -X POST https://n8n.tu-dominio.com/webhook/reclamos-processor \
    -H "Content-Type: application/json" \
    -d '{"test": '$i'}' &
done
wait
```

#### Monitoreo Durante Load Test
```bash
# Ver recursos en tiempo real
docker stats

# Ver logs durante carga
docker-compose logs -f n8n postgres
```

### 7. Testing de Seguridad

#### Verificar SSL/TLS
```bash
# Test de certificados
curl -I https://n8n.tu-dominio.com
openssl s_client -connect n8n.tu-dominio.com:443 -servername n8n.tu-dominio.com

# Verificar headers de seguridad
curl -I https://n8n.tu-dominio.com | grep -i security
```

#### Test de Rate Limiting
```bash
# Enviar muchas requests rápidamente
for i in {1..100}; do
  curl -s https://n8n.tu-dominio.com/webhook/test
done
```

### 8. Testing de Backup y Recovery

#### Test de Backup
```bash
# Ejecutar backup manual
./backup.sh

# Verificar archivos generados
ls -la backups/

# Test de restauración (en ambiente de test)
docker-compose exec postgres psql -U n8n -d n8n < backups/postgres_latest.sql
```

### 9. Casos de Test Específicos

#### Test de Clasificación IA
```json
// Casos para probar el clasificador
{
  "casos_reclamo": [
    "Mi producto llegó defectuoso",
    "El servicio no funciona bien",
    "Estoy muy insatisfecho con la compra"
  ],
  "casos_devolucion": [
    "Quiero devolver mi pedido",
    "Necesito un reembolso",
    "El producto no es lo que esperaba"
  ],
  "casos_consulta": [
    "¿Cómo funciona este producto?",
    "¿Cuáles son los horarios de atención?",
    "Necesito información sobre garantías"
  ]
}
```

#### Test de Validaciones
```bash
# Test con datos incompletos
curl -X POST https://n8n.tu-dominio.com/webhook/reclamos-processor \
  -H "Content-Type: application/json" \
  -d '{
    "reclamo_data": {
      "nombre": "Test"
      // Faltan campos requeridos
    }
  }'

# Debe retornar error de validación
```

### 10. Checklist de Testing Pre-Producción

- [ ] ✅ Todos los servicios inician correctamente
- [ ] ✅ Webhooks responden con 200 OK
- [ ] ✅ Base de datos acepta inserts/updates
- [ ] ✅ Clasificación IA funciona correctamente
- [ ] ✅ Notificaciones llegan a Slack
- [ ] ✅ Tickets se crean en Jira (si configurado)
- [ ] ✅ Métricas aparecen en Grafana
- [ ] ✅ SSL/TLS configurado correctamente
- [ ] ✅ Backups se ejecutan sin errores
- [ ] ✅ Logs no muestran errores críticos
- [ ] ✅ Performance aceptable bajo carga
- [ ] ✅ Rate limiting funciona
- [ ] ✅ Health checks pasan

### 11. Debugging Common Issues

#### n8n Workflow Errors
```bash
# Ver executions fallidas
# En n8n UI: Executions > Failed

# Verificar logs detallados
docker-compose logs n8n | grep ERROR
```

#### Database Connection Issues
```bash
# Verificar conectividad
docker-compose exec n8n nc -z postgres 5432

# Ver conexiones activas
docker-compose exec postgres psql -U n8n -c "SELECT * FROM pg_stat_activity;"
```

#### Webhook Timeout Issues
```bash
# Verificar timeout settings en n8n
# Aumentar timeout si es necesario en docker-compose.yml
```

### 12. Automatización de Tests

#### GitHub Actions / CI/CD
```yaml
# .github/workflows/test.yml
name: Test Sistema Soporte
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run Tests
        run: |
          docker-compose up -d
          sleep 30
          ./test-integration.sh
```

Este sistema de testing asegura que todos los componentes funcionen correctamente tanto individualmente como en conjunto, proporcionando confianza para el despliegue en producción.