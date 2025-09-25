#!/bin/bash

# =============================================================================
# Script de Instalación - Agente Legal IA Argentina (Mendoza)
# =============================================================================

set -e

echo "🏛️  Instalando Agente Legal IA - Argentina (Mendoza)"
echo "=================================================="

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar dependencias
check_dependencies() {
    print_status "Verificando dependencias..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker no está instalado. Por favor instala Docker primero."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose no está instalado. Por favor instala Docker Compose primero."
        exit 1
    fi
    
    if ! command -v curl &> /dev/null; then
        print_error "curl no está instalado. Por favor instala curl primero."
        exit 1
    fi
    
    print_success "Todas las dependencias están instaladas"
}

# Configurar variables de entorno
setup_environment() {
    print_status "Configurando variables de entorno..."
    
    # Crear archivo .env si no existe
    if [ ! -f .env ]; then
        cat > .env << EOF
# Base de datos PostgreSQL
PG_HOST=postgres
PG_DB=legal
PG_USER=legal_user
PG_PASS=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)

# Qdrant
QDRANT_URL=http://qdrant:6333

# Redis
REDIS_HOST=redis

# OpenAI API (CONFIGURAR MANUALMENTE)
OPENAI_API_KEY=sk-xxx
EMBEDDINGS_MODEL=text-embedding-3-large
LLM_MODEL=gpt-4o

# EvolutionAPI (WhatsApp)
EVOLUTION_BASE_URL=http://evolutionapi:8080
EVOLUTION_INSTANCE=legal-agent
EVOLUTION_API_KEY=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)

# Webhook público (CONFIGURAR MANUALMENTE)
BASE_URL=https://agentlaw.midominio.com

# Token de setup
SETUP_TOKEN=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
EOF
        print_success "Archivo .env creado con credenciales aleatorias"
    else
        print_warning "Archivo .env ya existe, no se sobrescribirá"
    fi
    
    print_warning "IMPORTANTE: Configura manualmente OPENAI_API_KEY y BASE_URL en el archivo .env"
}

# Iniciar servicios
start_services() {
    print_status "Iniciando servicios..."
    
    # Cargar variables de entorno
    if [ -f .env ]; then
        export $(cat .env | grep -v '^#' | xargs)
    fi
    
    # Actualizar docker-compose.yml con las variables
    envsubst < docker-compose.yml > docker-compose.override.yml
    
    # Iniciar servicios
    docker-compose up -d
    
    print_success "Servicios iniciados"
}

# Esperar a que los servicios estén listos
wait_for_services() {
    print_status "Esperando a que los servicios estén listos..."
    
    # Esperar PostgreSQL
    print_status "Esperando PostgreSQL..."
    until docker exec legal-postgres pg_isready -U legal_user -d legal; do
        sleep 2
    done
    print_success "PostgreSQL está listo"
    
    # Esperar Redis
    print_status "Esperando Redis..."
    until docker exec legal-redis redis-cli ping | grep PONG; do
        sleep 2
    done
    print_success "Redis está listo"
    
    # Esperar Qdrant
    print_status "Esperando Qdrant..."
    until curl -s http://localhost:6333/health | grep -q "ok"; do
        sleep 2
    done
    print_success "Qdrant está listo"
    
    # Esperar n8n
    print_status "Esperando n8n..."
    until curl -s http://localhost:5678/healthz | grep -q "ok"; do
        sleep 5
    done
    print_success "n8n está listo"
}

# Configurar sistema
setup_system() {
    print_status "Configurando sistema..."
    
    # Cargar variables de entorno
    if [ -f .env ]; then
        export $(cat .env | grep -v '^#' | xargs)
    fi
    
    BASE_URL=${BASE_URL:-"http://localhost:5678"}
    
    print_status "Configurando base de datos..."
    curl -X POST "${BASE_URL}/webhook/setup/db" \
        -H "Authorization: Bearer ${SETUP_TOKEN}" \
        -H "Content-Type: application/json" \
        --max-time 60
    
    print_status "Insertando plantillas legales..."
    curl -X POST "${BASE_URL}/webhook/setup/seed" \
        -H "Authorization: Bearer ${SETUP_TOKEN}" \
        -H "Content-Type: application/json" \
        --max-time 60
    
    print_status "Configurando Qdrant..."
    curl -X POST "${BASE_URL}/webhook/setup/qdrant" \
        -H "Authorization: Bearer ${SETUP_TOKEN}" \
        -H "Content-Type: application/json" \
        --max-time 60
    
    print_success "Sistema configurado correctamente"
}

# Mostrar información de acceso
show_access_info() {
    print_success "¡Instalación completada!"
    echo ""
    echo "🔗 Accesos del sistema:"
    echo "  - n8n UI: http://localhost:5678"
    echo "  - PostgreSQL: localhost:5432"
    echo "  - Qdrant: http://localhost:6333"
    echo "  - Redis: localhost:6379"
    echo "  - EvolutionAPI: http://localhost:8080"
    echo ""
    echo "📋 Credenciales por defecto:"
    echo "  - n8n Usuario: admin"
    echo "  - n8n Contraseña: admin123"
    echo ""
    echo "🔧 Próximos pasos:"
    echo "  1. Configura OPENAI_API_KEY en el archivo .env"
    echo "  2. Configura BASE_URL en el archivo .env"
    echo "  3. Importa los workflows desde la carpeta n8n/"
    echo "  4. Configura las credenciales en n8n"
    echo ""
    echo "📚 Documentación completa en README.md"
}

# Función principal
main() {
    check_dependencies
    setup_environment
    start_services
    wait_for_services
    setup_system
    show_access_info
}

# Ejecutar script
main "$@"