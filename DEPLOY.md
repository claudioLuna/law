# 🚀 Sistema de Soporte WhatsApp - Guía de Despliegue

## 📋 Descripción del Sistema

Sistema completo de soporte al cliente vía WhatsApp que integra:
- **Kapso**: Orquestador de conversación con IA (Claude Sonnet)
- **n8n**: Motor de automatización y procesamiento de tickets
- **Supabase**: Base de datos PostgreSQL con API REST
- **Monitoreo**: Prometheus + Grafana para métricas en tiempo real

## 🏗️ Arquitectura del Sistema

```
WhatsApp → Kapso (Clasificación IA) → n8n (Webhooks) → Supabase + Jira + Slack
                                    ↓
                              Prometheus + Grafana (Monitoreo)
```

## 🔧 Pre-requisitos

### Servidor
- **Dokploy** instalado y configurado
- **Docker** y **Docker Compose** v2+
- **Mínimo**: 4GB RAM, 2 CPU cores, 20GB storage
- **Recomendado**: 8GB RAM, 4 CPU cores, 50GB storage

### Servicios Externos
- **Dominio** con DNS configurado
- **OpenAI API Key** (para modelos Claude)
- **Cuenta de WhatsApp Business** (opcional para producción)
- **Slack Workspace** (para notificaciones)
- **Jira Cloud** (para tickets, opcional)

## 🚀 Instalación Rápida

### 1. Clonar y Configurar
```bash
# Clonar el repositorio
git clone <tu-repositorio>
cd soporte-whatsapp

# Ejecutar configuración automática
./deploy/dokploy-setup.sh
```

### 2. Configurar Variables de Entorno
```bash
# Copiar template y editar
cp .env.example .env
nano .env
```

**Variables críticas a configurar:**
```bash
# Dominio principal
DOKPLOY_DOMAIN=tu-dominio.com
DOKPLOY_SSL_EMAIL=admin@tu-dominio.com

# OpenAI/Claude
OPENAI_API_KEY=sk-...

# Base de datos
POSTGRES_PASSWORD=password_super_seguro_123

# n8n
N8N_BASIC_AUTH_PASSWORD=admin_password_seguro

# Supabase
SUPABASE_SERVICE_KEY=tu_service_key_aqui

# Notificaciones
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/...
```

### 3. Desplegar en Dokploy

#### Opción A: Interfaz Web
1. Abrir Dokploy dashboard
2. Crear nuevo proyecto: "soporte-whatsapp"
3. Subir archivos del proyecto
4. Configurar variables de entorno
5. Hacer deploy

#### Opción B: CLI (si disponible)
```bash
dokploy deploy --config dokploy.config.yml
```

## 🔍 Verificación del Despliegue

### Health Check Automático
```bash
# Ejecutar verificación
./health-check.sh
```

### Verificación Manual
```bash
# Ver estado de servicios
docker-compose ps

# Ver logs en tiempo real
docker-compose logs -f

# Verificar conectividad
curl https://n8n.tu-dominio.com/healthz
curl https://supabase.tu-dominio.com/health
```

## 🌐 URLs de Acceso

Después del despliegue exitoso:

| Servicio | URL | Credenciales |
|----------|-----|--------------|
| **n8n** | `https://n8n.tu-dominio.com` | Ver `.env` |
| **Supabase** | `https://supabase.tu-dominio.com` | Dashboard incluido |
| **Grafana** | `https://grafana.tu-dominio.com` | admin / ver `.env` |
| **Traefik** | `https://traefik.tu-dominio.com` | Dashboard SSL |

## ⚙️ Configuración Post-Despliegue

### 1. Importar Workflows de n8n
```bash
# Acceder a n8n dashboard
# Ir a: https://n8n.tu-dominio.com
# Importar workflows desde: n8n/workflows/
```

### 2. Configurar Webhooks
Los webhooks de n8n estarán disponibles en:
- **Reclamos**: `https://n8n.tu-dominio.com/webhook/reclamos-processor`
- **Devoluciones**: `https://n8n.tu-dominio.com/webhook/devoluciones-processor`

### 3. Configurar Kapso
```python
# Los flujos de Kapso deben apuntar a:
webhook_url = "https://n8n.tu-dominio.com/webhook/reclamos-processor"
```

### 4. Configurar WhatsApp (Producción)
1. Configurar webhook en Meta Developer Console
2. Apuntar a: `https://kapso.tu-dominio.com/webhook/whatsapp`
3. Configurar tokens en `.env`

## 📊 Monitoreo y Métricas

### Grafana Dashboards
- **Sistema**: CPU, memoria, disco
- **Aplicación**: Reclamos, devoluciones, conversaciones
- **n8n**: Ejecuciones de workflows, errores
- **Base de datos**: Conexiones, queries, performance

### Alertas Automáticas
- CPU > 80% por 5 minutos
- Memoria > 85% por 5 minutos
- Disco > 90% por 2 minutos
- Servicios caídos (inmediato)

## 🔧 Mantenimiento

### Backups Automáticos
```bash
# Backup manual
./backup.sh

# Los backups automáticos se ejecutan diariamente a las 2 AM
# Ubicación: ./backups/
```

### Logs y Debugging
```bash
# Ver logs específicos
docker-compose logs -f n8n
docker-compose logs -f postgres
docker-compose logs -f kapso-app

# Ver métricas en tiempo real
docker stats

# Acceder a contenedor
docker-compose exec n8n bash
```

### Actualizaciones
```bash
# Actualizar imágenes
docker-compose pull

# Reiniciar servicios
docker-compose up -d

# Verificar después de actualización
./health-check.sh
```

## 🛠️ Troubleshooting

### Problemas Comunes

#### 1. n8n no inicia
```bash
# Verificar logs
docker-compose logs n8n

# Problemas comunes:
# - Variables de entorno incorrectas
# - Base de datos no disponible
# - Permisos de volúmenes
```

#### 2. Webhooks no funcionan
```bash
# Verificar conectividad
curl -X POST https://n8n.tu-dominio.com/webhook/reclamos-processor \
  -H "Content-Type: application/json" \
  -d '{"test": true}'

# Verificar logs de n8n
docker-compose logs -f n8n
```

#### 3. Base de datos lenta
```bash
# Verificar conexiones
docker-compose exec postgres psql -U n8n -c "SELECT * FROM pg_stat_activity;"

# Optimizar si es necesario
docker-compose exec postgres psql -U n8n -c "VACUUM ANALYZE;"
```

### Contacto de Soporte
Para problemas específicos:
1. Revisar logs: `docker-compose logs`
2. Verificar configuración: `docker-compose config`
3. Ejecutar health check: `./health-check.sh`
4. Consultar documentación de Dokploy

## 📈 Escalamiento

### Horizontal (Múltiples Instancias)
- Usar load balancer (Traefik configurado)
- Escalar servicios específicos:
  ```bash
  docker-compose up -d --scale kapso-app=3
  ```

### Vertical (Más Recursos)
- Editar `dokploy.config.yml`
- Aumentar límites de CPU/memoria
- Reiniciar servicios

### Base de Datos
- Configurar réplicas de lectura
- Implementar particionado por fecha
- Configurar índices adicionales según uso

## 🔒 Seguridad

### SSL/TLS
- Certificados automáticos con Let's Encrypt
- Renovación automática configurada
- HSTS headers habilitados

### Firewall
- Solo puertos 80, 443, 22 expuestos
- Rate limiting configurado
- Acceso a servicios internos restringido

### Secrets Management
- Variables sensibles en `.env`
- Rotación periódica recomendada
- No commitear secrets en git

## 📝 Notas Adicionales

### Desarrollo vs Producción
- En desarrollo: usar `COMPOSE_PROFILES=dev`
- En producción: configurar backups S3
- Monitoreo: configurar alertas por email/Slack

### Personalización
- Modificar flujos de Kapso en `kapso/flows/`
- Personalizar workflows de n8n según necesidades
- Ajustar métricas y dashboards de Grafana

### Integración con Otros Sistemas
- CRM: Modificar webhooks en n8n
- ERP: Agregar nodos específicos
- Analytics: Configurar eventos personalizados