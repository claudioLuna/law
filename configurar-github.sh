#!/bin/bash

# Script de Configuración Automática para GitHub
# Este script configura automáticamente el repositorio y sube todo el código a GitHub

set -e

echo "🚀 Configurando repositorio GitHub para Sistema de IA Legal..."

# Colores para salida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sin Color

# Función para imprimir salida coloreada
imprimir_estado() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

imprimir_exito() {
    echo -e "${GREEN}[ÉXITO]${NC} $1"
}

imprimir_advertencia() {
    echo -e "${YELLOW}[ADVERTENCIA]${NC} $1"
}

imprimir_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar si Git está instalado
verificar_git() {
    imprimir_estado "Verificando instalación de Git..."
    if command -v git &> /dev/null; then
        VERSION_GIT=$(git --version)
        imprimir_exito "Git está instalado: $VERSION_GIT"
    else
        imprimir_error "Git no está instalado. Por favor instala Git primero."
        exit 1
    fi
}

# Inicializar repositorio Git
inicializar_git() {
    imprimir_estado "Inicializando repositorio Git..."
    
    if [ ! -d ".git" ]; then
        git init
        imprimir_exito "Repositorio Git inicializado"
    else
        imprimir_advertencia "Repositorio Git ya existe"
    fi
}

# Crear .gitignore
crear_gitignore() {
    imprimir_estado "Creando archivo .gitignore..."
    
    cat > .gitignore << 'EOF'
# Dependencias
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Variables de entorno
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Logs
logs
*.log

# Archivos temporales
.tmp/
.temp/

# Archivos de sistema
.DS_Store
Thumbs.db

# Archivos de IDE
.vscode/
.idea/
*.swp
*.swo

# Archivos de respaldo
*.backup
*.bak

# Archivos de configuración específicos del usuario
config.json
credentials.json

# Archivos de prueba
test-files/
sample-documents/

# Archivos de N8N específicos
n8n-data/
.n8n/
EOF

    imprimir_exito "Archivo .gitignore creado"
}

# Crear README para GitHub
crear_readme_github() {
    imprimir_estado "Creando README para GitHub..."
    
    cat > README-GITHUB.md << 'EOF'
# Sistema de IA Legal para N8N

![Sistema de IA Legal](https://img.shields.io/badge/Legal-AI-blue)
![N8N](https://img.shields.io/badge/N8N-Workflow-green)
![OpenAI](https://img.shields.io/badge/OpenAI-GPT--4-orange)

Un sistema completo de automatización legal que replica exactamente la funcionalidad mostrada en el video de referencia. Procesa documentos legales, analiza contratos y proporciona un asistente de IA para bufetes de abogados.

## 🎯 Características Principales

- **📧 Procesamiento Automático de Documentos**: Detecta y procesa documentos legales vía Gmail
- **📋 Análisis de Contratos**: Analiza contratos subidos a Google Drive con IA
- **🤖 Asistente de IA Legal**: Hub central que accede a toda la información y redacta memorandos
- **📊 Integración Google Sheets**: Almacena todos los datos procesados en hojas organizadas
- **📨 Automatización de Email**: Envía resúmenes y memorandos al equipo legal

## 🚀 Inicio Rápido

### Configuración en 5 Minutos

```bash
# Clonar el repositorio
git clone https://github.com/tu-usuario/sistema-ia-legal.git
cd sistema-ia-legal

# Configuración automatizada
chmod +x configurar-entorno.sh
./configurar-entorno.sh

# Configurar credenciales
cp .env.ejemplo .env
# Edita .env con tus valores reales

# Configurar servicios de Google
npm run configurar-todo

# Actualizar configuración N8N
node actualizar-config-n8n.js

# Importar workflow en N8N
# Copia sistema-ia-legal-n8n-workflow.json a tu N8N
```

### Prerrequisitos

- Node.js (v16+)
- Cuenta Google Cloud Platform
- Clave API OpenAI
- Cuenta Gmail
- Instancia N8N

## 📋 Uso

### Procesamiento de Documentos
1. Envía documentos legales a tu Gmail configurado
2. El sistema automáticamente:
   - Guarda documentos en Google Drive
   - Analiza contenido con IA
   - Extrae problemas clave y fechas límite
   - Guarda resúmenes en Google Sheets
   - Envía notificaciones por email

### Análisis de Contratos
1. Sube contratos a Google Drive
2. El sistema automáticamente:
   - Analiza cláusulas críticas
   - Evalúa niveles de riesgo
   - Genera reportes detallados
   - Guarda análisis en Google Sheets

### Asistente de IA
Usa el chat en N8N para preguntas como:
- "¿Qué fechas límite vencen pronto?"
- "¿Cuáles son los problemas clave en el caso XYZ?"
- "Redacta un memorando para la revisión del contrato"

## 🏗️ Arquitectura

```
Gmail → Google Drive → IA Analysis → Google Sheets → Email Notifications
  ↓
Chat Interface → AI Agent → Document/Contract Queries → Memo Generation
```

## 📁 Estructura del Proyecto

```
sistema-ia-legal/
├── sistema-ia-legal-n8n-workflow.json    # Workflow principal N8N
├── configurar-google-sheets.js           # Configuración Google Sheets
├── configurar-google-drive.js            # Configuración Google Drive
├── configurar-entorno.sh                 # Script de configuración
├── actualizar-config-n8n.js              # Actualizador N8N
├── probar-workflow.js                    # Script de pruebas
├── prompts-ia.md                         # Documentación de prompts
├── README.md                             # Documentación completa
├── GUIA_DESPLIEGUE.md                    # Guía de despliegue
└── INICIO_RAPIDO.md                      # Guía de inicio rápido
```

## ⚙️ Configuración

### Variables de Entorno Requeridas

```bash
# Google Cloud
GOOGLE_PROJECT_ID=tu-proyecto
GOOGLE_CLIENT_EMAIL=cuenta-servicio@proyecto.iam.gserviceaccount.com
GOOGLE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n..."

# OpenAI
OPENAI_API_KEY=tu-clave-openai

# Gmail
GMAIL_USER_EMAIL=tu-email@gmail.com
GMAIL_CLIENT_ID=tu-client-id
GMAIL_CLIENT_SECRET=tu-client-secret

# Equipo Legal
EQUIPO_LEGAL_EMAIL=equipo@tuempresa.com
```

## 🔧 Scripts Disponibles

```bash
npm run configurar-hojas    # Configurar Google Sheets
npm run configurar-drive    # Configurar Google Drive
npm run configurar-todo     # Configurar todo
npm run probar              # Ejecutar pruebas
npm run actualizar-config   # Actualizar configuración N8N
```

## 📚 Documentación

- [README Completo](README.md) - Documentación detallada
- [Guía de Despliegue](GUIA_DESPLIEGUE.md) - Instrucciones paso a paso
- [Inicio Rápido](INICIO_RAPIDO.md) - Configuración en 30 minutos
- [Prompts de IA](prompts-ia.md) - Documentación de prompts

## 🤝 Contribuciones

¡Las contribuciones son bienvenidas! Áreas para mejora:

- Tipos adicionales de documentos legales
- Prompts de IA más sofisticados
- Integración con otro software legal
- Optimizaciones de rendimiento

## 📄 Licencia

MIT License - Libre para usar y modificar para tu práctica legal.

## ⚠️ Disclaimer

Este sistema está diseñado para asistir a profesionales legales pero no debe reemplazar el juicio legal profesional. Siempre revisa el contenido generado por IA antes de usarlo en procedimientos legales.

## 🆘 Soporte

- [Issues](https://github.com/tu-usuario/sistema-ia-legal/issues)
- [Documentación](README.md)
- [Wiki](https://github.com/tu-usuario/sistema-ia-legal/wiki)

---

**⭐ Si te gusta este proyecto, ¡dale una estrella en GitHub!**
EOF

    imprimir_exito "README para GitHub creado"
}

# Agregar archivos al repositorio
agregar_archivos() {
    imprimir_estado "Agregando archivos al repositorio..."
    
    # Agregar todos los archivos relevantes
    git add sistema-ia-legal-n8n-workflow.json
    git add configurar-google-sheets.js
    git add configurar-google-drive.js
    git add configurar-entorno.sh
    git add actualizar-config-n8n.js
    git add probar-workflow.js
    git add prompts-ia.md
    git add package-espanol.json
    git add .env.ejemplo
    git add README.md
    git add GUIA_DESPLIEGUE.md
    git add INICIO_RAPIDO.md
    git add README-GITHUB.md
    git add .gitignore
    
    imprimir_exito "Archivos agregados al repositorio"
}

# Hacer commit inicial
hacer_commit_inicial() {
    imprimir_estado "Haciendo commit inicial..."
    
    git commit -m "🎉 Commit inicial: Sistema de IA Legal completo

✨ Características:
- Workflow N8N completo con 3 componentes principales
- Scripts de configuración automatizada en español
- Prompts de IA optimizados para análisis legal
- Documentación completa en español
- Integración con Google Sheets, Drive y Gmail
- Asistente de IA para bufetes de abogados

🚀 Listo para usar:
1. Ejecutar ./configurar-entorno.sh
2. Configurar variables en .env
3. Ejecutar npm run configurar-todo
4. Importar workflow en N8N

📚 Documentación incluida:
- README completo
- Guía de despliegue paso a paso
- Guía de inicio rápido
- Documentación de prompts de IA

🤖 Sistema completamente funcional que replica el video de referencia"
    
    imprimir_exito "Commit inicial realizado"
}

# Configurar repositorio remoto
configurar_remoto() {
    imprimir_estado "Configurando repositorio remoto..."
    
    echo ""
    imprimir_advertencia "IMPORTANTE: Necesitas crear el repositorio en GitHub primero"
    echo ""
    echo "Pasos para crear repositorio en GitHub:"
    echo "1. Ve a https://github.com/new"
    echo "2. Nombre del repositorio: sistema-ia-legal"
    echo "3. Descripción: Sistema de IA Legal para N8N - Automatización completa de workflows legales"
    echo "4. Marca como público o privado según prefieras"
    echo "5. NO inicialices con README, .gitignore o licencia"
    echo "6. Haz clic en 'Create repository'"
    echo ""
    
    read -p "¿Ya creaste el repositorio en GitHub? (y/n): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Ingresa tu nombre de usuario de GitHub: " usuario_github
        
        # Configurar remoto
        git remote add origin https://github.com/$usuario_github/sistema-ia-legal.git
        
        # Configurar rama principal
        git branch -M main
        
        imprimir_exito "Repositorio remoto configurado"
        
        # Hacer push inicial
        imprimir_estado "Subiendo código a GitHub..."
        git push -u origin main
        
        imprimir_exito "¡Código subido exitosamente a GitHub!"
        
        echo ""
        imprimir_exito "🎉 ¡Tu Sistema de IA Legal está ahora en GitHub!"
        echo ""
        echo "🔗 URL del repositorio: https://github.com/$usuario_github/sistema-ia-legal"
        echo ""
        echo "📋 Próximos pasos:"
        echo "1. Comparte el repositorio con tu equipo"
        echo "2. Configura GitHub Pages si deseas documentación web"
        echo "3. Crea issues para seguimiento de tareas"
        echo "4. Configura GitHub Actions para CI/CD si es necesario"
        
    else
        imprimir_advertencia "Crea el repositorio en GitHub primero y luego ejecuta:"
        echo "git remote add origin https://github.com/TU-USUARIO/sistema-ia-legal.git"
        echo "git branch -M main"
        echo "git push -u origin main"
    fi
}

# Función principal
main() {
    imprimir_estado "Iniciando configuración de GitHub para Sistema de IA Legal..."
    
    verificar_git
    inicializar_git
    crear_gitignore
    crear_readme_github
    agregar_archivos
    hacer_commit_inicial
    configurar_remoto
    
    imprimir_exito "Configuración de GitHub completada!"
}

# Ejecutar configuración
main "$@"