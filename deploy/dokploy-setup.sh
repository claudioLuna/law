#!/bin/bash

# Script de configuración y despliegue para Dokploy
# Sistema de soporte WhatsApp - Kapso + n8n

set -e  # Salir en caso de error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para logging
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

# Verificar que estamos en el directorio correcto
if [ ! -f "docker-compose.yml" ]; then
    error "No se encontró docker-compose.yml. Ejecuta este script desde la raíz del proyecto."
fi

log "🚀 Iniciando configuración para Dokploy..."

# 1. Verificar variables de entorno requeridas
log "📋 Verificando variables de entorno..."

REQUIRED_VARS=(
    "DOKPLOY_DOMAIN"
    "DOKPLOY_SSL_EMAIL"
    "OPENAI_API_KEY"
    "POSTGRES_PASSWORD"
    "N8N_BASIC_AUTH_PASSWORD"
    "SUPABASE_SERVICE_KEY"
)

for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        error "Variable de entorno requerida no configurada: $var"
    fi
done

log "✅ Variables de entorno verificadas"

# 2. Crear archivo .env desde template si no existe
if [ ! -f ".env" ]; then
    log "📝 Creando archivo .env desde template..."
    cp .env.example .env
    warn "⚠️  Recuerda configurar las variables en .env antes del despliegue"
else
    log "✅ Archivo .env ya existe"
fi

# 3. Generar secretos si no están configurados
log "🔐 Generando secretos faltantes..."

# Generar JWT secret si no existe
if grep -q "your-super-secret-jwt-token" .env; then
    JWT_SECRET=$(openssl rand -base64 32)
    sed -i "s/your-super-secret-jwt-token-with-at-least-32-characters-long-for-security/$JWT_SECRET/" .env
    log "✅ JWT_SECRET generado"
fi

# Generar API keys si no existen
if grep -q "your-api-secret-key" .env; then
    API_SECRET=$(openssl rand -hex 32)
    sed -i "s/your-api-secret-key-for-internal-auth/$API_SECRET/" .env
    log "✅ API_SECRET_KEY generado"
fi

# 4. Validar configuración de Docker Compose
log "🐳 Validando configuración de Docker Compose..."
if ! docker-compose config > /dev/null 2>&1; then
    error "Error en la configuración de Docker Compose"
fi
log "✅ Configuración de Docker Compose válida"

# 5. Crear directorios necesarios
log "📁 Creando directorios necesarios..."
mkdir -p {logs,backups,data/{postgres,n8n,grafana,redis}}
mkdir -p monitoring/grafana/dashboards
chmod 755 logs backups data
log "✅ Directorios creados"

# 6. Configurar permisos
log "🔒 Configurando permisos..."
# Grafana necesita permisos específicos
sudo chown -R 472:472 data/grafana 2>/dev/null || warn "No se pudieron configurar permisos de Grafana (ejecutar como root si es necesario)"
log "✅ Permisos configurados"

# 7. Validar conectividad a servicios externos
log "🌐 Validando conectividad..."

# Verificar conectividad a OpenAI
if command -v curl > /dev/null; then
    if curl -s --head https://api.openai.com | head -n 1 | grep -q "200 OK"; then
        log "✅ Conectividad a OpenAI OK"
    else
        warn "⚠️  No se pudo verificar conectividad a OpenAI"
    fi
fi

# 8. Preparar base de datos
log "🗄️  Preparando configuración de base de datos..."

# Verificar que los archivos SQL existen
if [ ! -f "supabase/migrations/001_initial_schema.sql" ]; then
    error "No se encontró el archivo de migración inicial"
fi

log "✅ Archivos de base de datos listos"

# 9. Configurar n8n workflows
log "⚙️  Preparando workflows de n8n..."

# Verificar que los workflows existen
if [ ! -f "n8n/workflows/reclamos-processor.json" ]; then
    error "No se encontró el workflow de reclamos"
fi

if [ ! -f "n8n/workflows/devoluciones-processor.json" ]; then
    error "No se encontró el workflow de devoluciones"
fi

log "✅ Workflows de n8n listos"

# 10. Generar configuración específica para Dokploy
log "📋 Generando configuración para Dokploy..."

# Reemplazar variables en dokploy.config.yml
sed -i "s/\${DOKPLOY_DOMAIN}/$DOKPLOY_DOMAIN/g" dokploy.config.yml
sed -i "s/\${DOKPLOY_SSL_EMAIL}/$DOKPLOY_SSL_EMAIL/g" dokploy.config.yml

log "✅ Configuración de Dokploy actualizada"

# 11. Crear script de health check
log "🏥 Creando script de health check..."

cat > health-check.sh << 'EOF'
#!/bin/bash
# Health check para el sistema de soporte

echo "Verificando servicios..."

# Verificar n8n
if curl -f -s http://localhost:5678/healthz > /dev/null; then
    echo "✅ n8n: OK"
else
    echo "❌ n8n: FAIL"
    exit 1
fi

# Verificar Supabase
if curl -f -s http://localhost:3000/health > /dev/null; then
    echo "✅ Supabase: OK"
else
    echo "❌ Supabase: FAIL"
    exit 1
fi

# Verificar PostgreSQL
if pg_isready -h localhost -p 5432 > /dev/null 2>&1; then
    echo "✅ PostgreSQL: OK"
else
    echo "❌ PostgreSQL: FAIL"
    exit 1
fi

echo "🎉 Todos los servicios están funcionando correctamente"
EOF

chmod +x health-check.sh
log "✅ Health check creado"

# 12. Crear script de backup
log "💾 Creando script de backup..."

cat > backup.sh << 'EOF'
#!/bin/bash
# Script de backup para el sistema de soporte

BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d_%H%M%S)

echo "Iniciando backup: $DATE"

# Backup de PostgreSQL
docker-compose exec -T postgres pg_dump -U $POSTGRES_USER $POSTGRES_DB > "$BACKUP_DIR/postgres_$DATE.sql"

# Backup de n8n data
docker-compose exec -T n8n tar czf - /home/node/.n8n > "$BACKUP_DIR/n8n_data_$DATE.tar.gz"

# Backup de configuraciones
tar czf "$BACKUP_DIR/config_$DATE.tar.gz" .env dokploy.config.yml docker-compose.yml

echo "Backup completado: $BACKUP_DIR"

# Limpiar backups antiguos (mantener solo los últimos 7)
find "$BACKUP_DIR" -name "*.sql" -mtime +7 -delete
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +7 -delete

echo "Limpieza de backups antiguos completada"
EOF

chmod +x backup.sh
log "✅ Script de backup creado"

# 13. Crear documentación de despliegue
log "📚 Creando documentación de despliegue..."

cat > DEPLOY.md << 'EOF'
# Guía de Despliegue en Dokploy

## Pre-requisitos
1. Servidor con Dokploy instalado
2. Docker y Docker Compose
3. Dominio configurado apuntando al servidor
4. Certificados SSL (Let's Encrypt automático)

## Pasos de Despliegue

### 1. Preparación
```bash
# Clonar repositorio
git clone <repository-url>
cd soporte-whatsapp

# Ejecutar configuración
./deploy/dokploy-setup.sh
```

### 2. Configurar Variables
Editar `.env` con tus valores específicos:
- DOKPLOY_DOMAIN: tu dominio
- OPENAI_API_KEY: tu API key de OpenAI
- Credenciales de base de datos
- Tokens de integración (Slack, WhatsApp, etc.)

### 3. Desplegar en Dokploy
```bash
# Subir configuración a Dokploy
dokploy deploy --config dokploy.config.yml

# O usar la interfaz web de Dokploy
```

### 4. Verificar Despliegue
```bash
# Ejecutar health check
./health-check.sh

# Verificar logs
docker-compose logs -f
```

## URLs de Acceso
- n8n: https://n8n.tu-dominio.com
- Supabase: https://supabase.tu-dominio.com
- Grafana: https://grafana.tu-dominio.com
- Traefik Dashboard: https://traefik.tu-dominio.com

## Mantenimiento
```bash
# Backup manual
./backup.sh

# Ver logs
docker-compose logs -f [servicio]

# Reiniciar servicios
docker-compose restart [servicio]
```
EOF

log "✅ Documentación creada"

# 14. Resumen final
log "🎉 Configuración completada exitosamente!"
echo ""
echo -e "${BLUE}📋 RESUMEN DE CONFIGURACIÓN:${NC}"
echo "  ✅ Variables de entorno verificadas"
echo "  ✅ Secretos generados automáticamente"
echo "  ✅ Directorios y permisos configurados"
echo "  ✅ Workflows de n8n preparados"
echo "  ✅ Configuración de Dokploy lista"
echo "  ✅ Scripts de mantenimiento creados"
echo ""
echo -e "${YELLOW}📝 PRÓXIMOS PASOS:${NC}"
echo "  1. Revisar y completar configuración en .env"
echo "  2. Subir proyecto a Dokploy"
echo "  3. Ejecutar despliegue"
echo "  4. Importar workflows en n8n"
echo "  5. Configurar webhooks de WhatsApp"
echo ""
echo -e "${GREEN}📖 Ver DEPLOY.md para instrucciones detalladas${NC}"