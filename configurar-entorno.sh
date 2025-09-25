#!/bin/bash

# Sistema de IA Legal - Script de Configuración del Entorno
# Este script configura el entorno completo para el Sistema de IA Legal

set -e

echo "🚀 Configurando entorno del Sistema de IA Legal..."

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

# Verificar si Node.js está instalado
verificar_nodejs() {
    imprimir_estado "Verificando instalación de Node.js..."
    if command -v node &> /dev/null; then
        VERSION_NODE=$(node --version)
        imprimir_exito "Node.js está instalado: $VERSION_NODE"
    else
        imprimir_error "Node.js no está instalado. Por favor instala Node.js primero."
        exit 1
    fi
}

# Verificar si npm está instalado
verificar_npm() {
    imprimir_estado "Verificando instalación de npm..."
    if command -v npm &> /dev/null; then
        VERSION_NPM=$(npm --version)
        imprimir_exito "npm está instalado: $VERSION_NPM"
    else
        imprimir_error "npm no está instalado. Por favor instala npm primero."
        exit 1
    fi
}

# Instalar dependencias de Node.js
instalar_dependencias() {
    imprimir_estado "Instalando dependencias de Node.js..."
    
    # Crear package.json si no existe
    if [ ! -f "package.json" ]; then
        cat > package.json << EOF
{
  "name": "sistema-ia-legal",
  "version": "1.0.0",
  "description": "Sistema de IA Legal para automatización de workflows N8N",
  "main": "index.js",
  "scripts": {
    "configurar-hojas": "node configurar-google-sheets.js",
    "configurar-drive": "node configurar-google-drive.js",
    "configurar-todo": "npm run configurar-hojas && npm run configurar-drive",
    "probar": "node probar-workflow.js",
    "actualizar-config": "node actualizar-config-n8n.js"
  },
  "dependencies": {
    "google-spreadsheet": "^4.1.2",
    "googleapis": "^128.0.0",
    "google-auth-library": "^9.0.0",
    "dotenv": "^16.3.1"
  },
  "devDependencies": {
    "nodemon": "^3.0.2"
  },
  "keywords": ["legal", "ia", "automatización", "n8n", "google-sheets", "google-drive"],
  "author": "Sistema de IA Legal",
  "license": "MIT"
}
EOF
        imprimir_exito "package.json creado"
    fi
    
    npm install
    imprimir_exito "Dependencias instaladas exitosamente"
}

# Crear archivo de configuración de entorno
crear_archivo_env() {
    imprimir_estado "Creando archivo de configuración de entorno..."
    
    cat > .env.ejemplo << EOF
# Configuración del Sistema de IA Legal
# Copia este archivo a .env y completa con tus valores reales

# Credenciales de Cuenta de Servicio de Google
GOOGLE_PROJECT_ID=tu-id-del-proyecto
GOOGLE_PRIVATE_KEY_ID=tu-id-de-clave-privada
GOOGLE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nTU_CLAVE_PRIVADA\n-----END PRIVATE KEY-----\n"
GOOGLE_CLIENT_EMAIL=tu-cuenta-de-servicio@tu-proyecto.iam.gserviceaccount.com
GOOGLE_CLIENT_ID=tu-id-de-cliente

# Configuración de OpenAI
OPENAI_API_KEY=tu-clave-api-openai

# Configuración de Gmail
GMAIL_USER_EMAIL=tu-email@gmail.com
GMAIL_CLIENT_ID=tu-id-cliente-gmail
GMAIL_CLIENT_SECRET=tu-secreto-cliente-gmail
GMAIL_REFRESH_TOKEN=tu-token-actualizacion-gmail

# Configuración del Equipo Legal
EQUIPO_LEGAL_EMAIL=equipo-legal@tuempresa.com

# IDs de Google Sheets (se generarán con los scripts de configuración)
HOJA_RESUMENES_LEGALES_ID=
HOJA_ANALISIS_CONTRATOS_ID=

# IDs de Carpetas de Google Drive (se generarán con los scripts de configuración)
CARPETA_DEMANDAS_CONTRATOS_ID=
CARPETA_ANALISIS_CONTRATOS_ID=

# Configuración de N8N
N8N_HOST=http://localhost:5678
N8N_API_KEY=tu-clave-api-n8n

# Opcional: Configuraciones personalizadas
# Configuración de procesamiento de documentos
PROCESAMIENTO_DOCUMENTOS_HABILITADO=true
ANALISIS_CONTRATOS_HABILITADO=true
NOTIFICACIONES_EMAIL_HABILITADO=true

# Configuración del Modelo de IA
MODELO_IA=gpt-4o-mini
TEMPERATURA_IA=0.3
MAX_TOKENS_IA=2000

# Configuración de Email
PREFIJO_ASUNTO_EMAIL="[IA Legal]"
FORMATO_HTML_EMAIL=true

# Configuración de Google Drive
PERMISOS_CARPETA_DRIVE=writer
COMPARTIR_CON_DOMINIO=false

# Registro y Monitoreo
NIVEL_LOG=info
MODO_DEBUG_HABILITADO=false
EOF

    if [ ! -f ".env" ]; then
        cp .env.ejemplo .env
        imprimir_exito "Archivo .env creado desde plantilla"
        imprimir_advertencia "Por favor edita el archivo .env con tus valores de configuración reales"
    else
        imprimir_advertencia "El archivo .env ya existe, omitiendo creación"
    fi
}

# Crear script de actualización de configuración N8N
crear_script_config_n8n() {
    imprimir_estado "Creando script de actualización de configuración N8N..."
    
    cat > actualizar-config-n8n.js << 'EOF'
/**
 * Script de Actualización de Configuración N8N
 * Actualiza el workflow JSON de N8N con los IDs correctos de las variables de entorno
 */

const fs = require('fs');
const path = require('path');
require('dotenv').config();

function actualizarWorkflowN8N() {
    try {
        console.log('🔄 Actualizando configuración del workflow N8N...');
        
        // Leer el archivo JSON del workflow
        const rutaWorkflow = path.join(__dirname, 'sistema-ia-legal-n8n-workflow.json');
        const datosWorkflow = JSON.parse(fs.readFileSync(rutaWorkflow, 'utf8'));
        
        // Actualizar IDs de hojas
        const mapeosIdsHojas = {
            'hoja-resumenes-legales-id': process.env.HOJA_RESUMENES_LEGALES_ID,
            'hoja-analisis-contratos-id': process.env.HOJA_ANALISIS_CONTRATOS_ID
        };
        
        // Actualizar IDs de carpetas
        const mapeosIdsCarpetas = {
            'carpeta-demandas-contratos-id': process.env.CARPETA_DEMANDAS_CONTRATOS_ID,
            'carpeta-analisis-contratos-id': process.env.CARPETA_ANALISIS_CONTRATOS_ID
        };
        
        // Actualizar direcciones de email
        const mapeosEmails = {
            'equipo-legal@tuempresa.com': process.env.EQUIPO_LEGAL_EMAIL
        };
        
        // Función para actualizar parámetros de nodos recursivamente
        function actualizarParametrosNodo(nodo) {
            if (nodo.parameters) {
                // Actualizar IDs de hojas
                Object.keys(mapeosIdsHojas).forEach(marcador => {
                    if (nodo.parameters.documentId && nodo.parameters.documentId.value === marcador) {
                        nodo.parameters.documentId.value = mapeosIdsHojas[marcador];
                        console.log(`✅ Actualizado ${marcador} a ${mapeosIdsHojas[marcador]}`);
                    }
                });
                
                // Actualizar IDs de carpetas
                Object.keys(mapeosIdsCarpetas).forEach(marcador => {
                    if (nodo.parameters.folderId && nodo.parameters.folderId.value === marcador) {
                        nodo.parameters.folderId.value = mapeosIdsCarpetas[marcador];
                        console.log(`✅ Actualizado ${marcador} a ${mapeosIdsCarpetas[marcador]}`);
                    }
                });
                
                // Actualizar direcciones de email
                Object.keys(mapeosEmails).forEach(marcador => {
                    if (nodo.parameters.toEmail === marcador) {
                        nodo.parameters.toEmail = mapeosEmails[marcador];
                        console.log(`✅ Actualizado email a ${mapeosEmails[marcador]}`);
                    }
                });
            }
        }
        
        // Actualizar todos los nodos
        datosWorkflow.nodes.forEach(actualizarParametrosNodo);
        
        // Escribir el workflow actualizado de vuelta al archivo
        fs.writeFileSync(rutaWorkflow, JSON.stringify(datosWorkflow, null, 2));
        
        console.log('✅ Configuración del workflow N8N actualizada exitosamente!');
        console.log('📁 Archivo actualizado: sistema-ia-legal-n8n-workflow.json');
        
    } catch (error) {
        console.error('❌ Falló la actualización del workflow N8N:', error.message);
        process.exit(1);
    }
}

// Ejecutar la actualización
actualizarWorkflowN8N();
EOF

    imprimir_exito "Script de actualización de configuración N8N creado"
}

# Crear script de prueba
crear_script_prueba() {
    imprimir_estado "Creando script de prueba..."
    
    cat > probar-workflow.js << 'EOF'
/**
 * Script de Prueba para Sistema de IA Legal
 * Prueba la funcionalidad básica de la configuración
 */

const { ConfiguracionSistemaIA } = require('./configurar-google-sheets');
const { ConfiguracionGoogleDrive } = require('./configurar-google-drive');

async function probarConfiguracion() {
    try {
        console.log('🧪 Probando Configuración del Sistema de IA Legal...');
        
        // Probar configuración de Google Sheets
        console.log('\n📊 Probando configuración de Google Sheets...');
        const configuracionHojas = new ConfiguracionSistemaIA();
        // Nota: Esto crearía hojas reales, así que solo probamos la carga de la clase
        console.log('✅ Clase de configuración de Google Sheets cargada exitosamente');
        
        // Probar configuración de Google Drive
        console.log('\n📁 Probando configuración de Google Drive...');
        const configuracionDrive = new ConfiguracionGoogleDrive();
        console.log('✅ Clase de configuración de Google Drive cargada exitosamente');
        
        // Probar variables de entorno
        console.log('\n🔧 Probando variables de entorno...');
        require('dotenv').config();
        
        const variablesRequeridas = [
            'GOOGLE_PROJECT_ID',
            'GOOGLE_CLIENT_EMAIL',
            'OPENAI_API_KEY',
            'EQUIPO_LEGAL_EMAIL'
        ];
        
        let variablesFaltantes = [];
        variablesRequeridas.forEach(nombreVar => {
            if (!process.env[nombreVar]) {
                variablesFaltantes.push(nombreVar);
            }
        });
        
        if (variablesFaltantes.length > 0) {
            console.log('⚠️  Variables de entorno faltantes:', variablesFaltantes.join(', '));
            console.log('Por favor actualiza tu archivo .env con los valores faltantes');
        } else {
            console.log('✅ Todas las variables de entorno requeridas están configuradas');
        }
        
        console.log('\n🎉 Prueba completada exitosamente!');
        console.log('\n📋 Próximos pasos:');
        console.log('1. Actualiza tu archivo .env con valores reales');
        console.log('2. Ejecuta: npm run configurar-todo');
        console.log('3. Ejecuta: node actualizar-config-n8n.js');
        console.log('4. Importa el workflow en N8N');
        
    } catch (error) {
        console.error('❌ La prueba falló:', error.message);
        process.exit(1);
    }
}

probarConfiguracion();
EOF

    imprimir_exito "Script de prueba creado"
}

# Crear archivo README
crear_readme() {
    imprimir_estado "Creando documentación README..."
    
    cat > README.md << 'EOF'
# Sistema de IA Legal para N8N

Un sistema de automatización legal completo que replica exactamente el video que compartiste. Procesa documentos legales, analiza contratos y proporciona un asistente de IA para bufetes de abogados.

## 🎯 Características

### Flujos de Trabajo Principales
- **📧 Flujo de Resumen de Documentos**: Procesa automáticamente documentos legales entrantes vía Gmail
- **📋 Flujo de Análisis de Contratos**: Analiza contratos subidos a Google Drive  
- **🤖 Asistente de IA Principal**: Hub central que puede acceder a toda la información y redactar memorandos legales
- **📊 Integración con Google Sheets**: Almacena todos los datos procesados en hojas de cálculo organizadas
- **📨 Automatización de Email**: Envía resúmenes y memorandos a equipos legales

### Capacidades de IA
- **Análisis de Documentos**: Extrae problemas clave, fechas límite y resúmenes de documentos legales
- **Revisión de Contratos**: Identifica cláusulas críticas y evaluaciones de riesgo
- **Generación de Memorandos Legales**: Crea memorandos internos comprensivos con análisis legal
- **Seguimiento de Fechas Límite**: Monitorea y alerta sobre fechas límite legales próximas
- **Procesamiento de Consultas**: Consultas en lenguaje natural sobre casos, contratos y asuntos legales

## 🏗️ Arquitectura del Sistema

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Gmail Trigger │    │  Google Drive    │    │   Chat Trigger  │
│  (Documentos)    │    │   Trigger        │    │  (Agente Principal)│
│                 │    │  (Contratos)     │    │                 │
└─────────┬───────┘    └─────────┬────────┘    └─────────┬───────┘
          │                      │                       │
          ▼                      ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│ Análisis de     │    │ Análisis de      │    │ Asistente de IA │
│ Documentos      │    │ Contratos        │    │ Principal       │
│                 │    │                  │    │ (Abogado)       │
└─────────┬───────┘    └─────────┬────────┘    └─────────┬───────┘
          │                      │                       │
          ▼                      ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│ Google Sheets   │    │ Google Sheets    │    │ Gmail Sender    │
│ (Resúmenes)     │    │ (Contratos)      │    │ (Memorandos)    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 📋 Prerrequisitos

### Software Requerido
- **Node.js** (v16 o superior)
- **npm** (v8 o superior)
- **N8N** (instancia auto-hospedada o en la nube)

### Cuentas y APIs Requeridas
- **Google Cloud Platform** con facturación habilitada
- **Clave API OpenAI** con acceso GPT-4
- **Cuenta Gmail** para procesamiento de emails
- **Google Drive** para almacenamiento de documentos
- **Google Sheets** para gestión de datos

### Permisos Requeridos
- Acceso a API de Google Sheets
- Acceso a API de Google Drive
- Acceso a API de Gmail
- Acceso a API de OpenAI

## 🚀 Instalación

### 1. Configuración Rápida (Recomendada)

```bash
# Descarga o clona todos los archivos a tu directorio de proyecto
# Hacer ejecutable el script de configuración
chmod +x configurar-entorno.sh

# Ejecutar la configuración automatizada
./configurar-entorno.sh
```

### 2. Configuración Manual

```bash
# Instalar dependencias
npm install

# Copiar plantilla de entorno
cp .env.ejemplo .env

# Editar .env con tus valores de configuración reales
# (Ver sección de Configuración abajo)

# Configurar Google Sheets
npm run configurar-hojas

# Configurar carpetas de Google Drive
npm run configurar-drive

# Actualizar configuración del workflow N8N
node actualizar-config-n8n.js

# Probar la configuración
npm run probar
```

## ⚙️ Configuración

### 1. Configuración de Google Cloud

#### Crear un Proyecto de Google Cloud
1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Crea un nuevo proyecto o selecciona uno existente
3. Habilita la facturación para el proyecto

#### Habilitar APIs Requeridas
```bash
# Habilitar estas APIs en Google Cloud Console:
- Google Sheets API
- Google Drive API  
- Gmail API
```

#### Crear Cuenta de Servicio
1. Ve a IAM & Admin > Cuentas de Servicio
2. Crea una nueva cuenta de servicio
3. Descarga el archivo JSON de clave
4. Actualiza el archivo `.env` con las credenciales

### 2. Configuración de OpenAI

1. Ve a [OpenAI Platform](https://platform.openai.com/)
2. Crea una clave API
3. Agrega créditos a tu cuenta
4. Actualiza el archivo `.env` con la clave API

### 3. Configuración de Gmail

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Crea credenciales OAuth2 para Gmail
3. Configura URIs de redirección autorizados
4. Genera token de actualización
5. Actualiza el archivo `.env` con credenciales OAuth2

### 4. Variables de Entorno

Edita tu archivo `.env` con los siguientes valores:

```bash
# Cuenta de Servicio de Google (del archivo JSON de clave)
GOOGLE_PROJECT_ID=tu-id-del-proyecto
GOOGLE_PRIVATE_KEY_ID=tu-id-de-clave-privada
GOOGLE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nTU_CLAVE_PRIVADA\n-----END PRIVATE KEY-----\n"
GOOGLE_CLIENT_EMAIL=tu-cuenta-de-servicio@tu-proyecto.iam.gserviceaccount.com
GOOGLE_CLIENT_ID=tu-id-de-cliente

# API OpenAI
OPENAI_API_KEY=tu-clave-api-openai

# Gmail OAuth2
GMAIL_USER_EMAIL=tu-email@gmail.com
GMAIL_CLIENT_ID=tu-id-cliente-gmail
GMAIL_CLIENT_SECRET=tu-secreto-cliente-gmail
GMAIL_REFRESH_TOKEN=tu-token-actualizacion-gmail

# Equipo Legal
EQUIPO_LEGAL_EMAIL=equipo-legal@tuempresa.com
```

## 📁 Estructura de Archivos

```
sistema-ia-legal/
├── sistema-ia-legal-n8n-workflow.json    # Workflow principal de N8N
├── configurar-google-sheets.js           # Script de configuración de Google Sheets
├── configurar-google-drive.js            # Script de configuración de Google Drive
├── configurar-entorno.sh                 # Script de configuración del entorno
├── actualizar-config-n8n.js              # Actualizador de configuración N8N
├── probar-workflow.js                    # Script de prueba
├── prompts-ia.md                         # Documentación de prompts de IA
├── package.json                          # Dependencias de Node.js
├── .env.ejemplo                          # Plantilla de configuración
├── .env                                  # Tu configuración (crear este)
└── README.md                            # Este archivo
```

## 🎮 Uso

### Flujo de Procesamiento de Documentos

1. **Envía documentos legales** a tu cuenta Gmail configurada
2. **El sistema automáticamente**:
   - Descarga y guarda documentos en Google Drive
   - Extrae texto usando IA
   - Analiza contenido para problemas clave y fechas límite
   - Guarda resúmenes estructurados en Google Sheets
   - Envía notificaciones por email a tu equipo legal

### Flujo de Análisis de Contratos

1. **Sube contratos** a la carpeta designada de Google Drive
2. **El sistema automáticamente**:
   - Descarga y analiza contratos
   - Identifica cláusulas clave (terminación, indemnización, etc.)
   - Evalúa niveles de riesgo (Bajo, Medio, Alto)
   - Guarda análisis detallado en Google Sheets
   - Envía reportes comprensivos por email

### Asistente de IA Legal

Usa la interfaz de chat en N8N para hacer preguntas como:

```
"¿Qué fechas límite vencen pronto?"
"¿Cuáles son los problemas clave en el caso Empresa A vs Empresa B?"
"Redacta un memorando interno para la revisión del contrato"
"¿Qué cláusulas de indemnización existen en nuestros contratos?"
"Muéstrame todos los contratos de alto riesgo del mes pasado"
"¿Cuál es el estado de las demandas pendientes?"
```

### Ejemplos de Interacciones

#### Consultas de Documentos
```
Usuario: "¿Qué fechas límite vencen pronto?"
IA: "Hay una fecha límite próxima el 29 de junio para el caso Empresa A versus Empresa B sobre incumplimiento de contrato. Los problemas clave incluyen incumplimiento y falla en curar defectos."

Usuario: "¿Cuáles son los problemas clave en la demanda Empresa A vs Empresa B?"
IA: "Los problemas clave son: 1) Incumplimiento de contrato, 2) Incumplimiento de términos, 3) Falla en curar defectos, 4) Disputa sobre depósito, 5) Jurisdicción y sede. ¿Te gustaría un memorando detallado sobre estos problemas?"
```

#### Consultas de Contratos
```
Usuario: "¿Hay cláusulas de indemnización en nuestros contratos recientes?"
IA: "El Contrato de Servicios entre Servicios Legales Alpha y Corporación Beta contiene una cláusula de indemnización. Está ubicada en la Sección 4.2 y se evalúa como Riesgo Medio. La cláusula establece: 'El Cliente se compromete a indemnizar al Proveedor contra todas las reclamaciones derivadas del uso de servicios por parte del Cliente.'"

Usuario: "Muéstrame todos los contratos de alto riesgo"
IA: "Encontré 2 contratos de alto riesgo: 1) Contrato de Servicios de Tecnología con TechCorp (cláusula de indemnización), 2) Contrato de Consultoría con StartupXYZ (cláusula de limitación de responsabilidad)."
```

#### Generación de Memorandos
```
Usuario: "Por favor redacta un memorando interno para la demanda Empresa A versus Empresa B"
IA: [Genera memorando comprensivo con Declaración de Hechos, Problemas Presentados, Análisis Legal y Recomendaciones]
```

## 🔧 Configuración de N8N

### 1. Importar Workflow

1. Abre tu instancia de N8N
2. Ve a Workflows > Importar desde Archivo
3. Selecciona `sistema-ia-legal-n8n-workflow.json`
4. El workflow será importado con todos los nodos configurados

### 2. Configurar Credenciales

Configura las siguientes credenciales en N8N:

#### Gmail OAuth2
- **Client ID**: Tu Client ID de Gmail OAuth2
- **Client Secret**: Tu Client Secret de Gmail OAuth2
- **Scope**: `https://www.googleapis.com/auth/gmail.readonly https://www.googleapis.com/auth/gmail.send`

#### Google Drive OAuth2
- **Client ID**: Tu Client ID de Google OAuth2  
- **Client Secret**: Tu Client Secret de Google OAuth2
- **Scope**: `https://www.googleapis.com/auth/drive`

#### Google Sheets OAuth2
- **Client ID**: Tu Client ID de Google OAuth2
- **Client Secret**: Tu Client Secret de Google OAuth2  
- **Scope**: `https://www.googleapis.com/auth/spreadsheets`

#### OpenAI API
- **API Key**: Tu clave API de OpenAI
- **Organization ID**: (Opcional) Tu ID de organización de OpenAI

### 3. Probar Workflows

1. **Probar Procesamiento de Documentos**:
   - Envía un email de prueba con un archivo PDF adjunto
   - Verifica si el workflow se activa y procesa el documento

2. **Probar Análisis de Contratos**:
   - Sube un contrato a la carpeta designada de Google Drive
   - Verifica que se genere el análisis y se guarde

3. **Probar Agente de IA**:
   - Usa la interfaz de chat para hacer preguntas
   - Verifica que las respuestas sean precisas y útiles

## 📊 Estructura de Google Sheets

### Hoja de Resúmenes de Documentos Legales
| Columna | Descripción |
|---------|-------------|
| Fecha | Fecha en que se recibió el documento |
| Asunto | Línea de asunto del email |
| Problema 1-5 | Problemas legales clave identificados |
| Fecha Límite | Fecha límite calculada basada en jurisdicción |
| Resumen Completo | Resumen completo generado por IA |

### Hoja de Análisis de Contratos
| Columna | Descripción |
|---------|-------------|
| Contrato | Nombre/identificador del contrato |
| Análisis | Análisis completo de IA con desglose de cláusulas |

## 📁 Estructura de Google Drive

```
Sistema IA Legal - Demandas y Contratos/
├── Documentos Recibidos/          # Documentos recibidos por email
└── Documentos Procesados/         # Documentos que han sido analizados

Sistema IA Legal - Análisis de Contratos/
├── Pendientes de Análisis/       # Contratos esperando análisis de IA
├── Análisis Completados/         # Contratos que han sido analizados
└── Contratos de Alto Riesgo/     # Contratos marcados como alto riesgo
```

## 🛠️ Solución de Problemas

### Problemas Comunes

#### Errores de Autenticación
**Problema**: "Autenticación fallida" o "Credenciales inválidas"
**Solución**: 
- Verifica tus credenciales de cuenta de servicio de Google en `.env`
- Verifica que las APIs estén habilitadas en Google Cloud Console
- Asegúrate de que los tokens OAuth2 sean válidos y no hayan expirado

#### Problemas de Acceso a Hojas/Carpetas
**Problema**: "Permiso denegado" o "Archivo no encontrado"
**Solución**:
- Verifica que los IDs de carpetas en el workflow sean correctos
- Verifica permisos de compartir en carpetas de Google Drive
- Asegúrate de que la cuenta de servicio tenga acceso a todos los recursos requeridos

#### Problemas de Importación de N8N
**Problema**: "Workflow inválido" o "Nodo no encontrado"
**Solución**:
- Verifica que el workflow JSON sea JSON válido
- Verifica que todos los tipos de nodos sean compatibles con tu versión de N8N
- Actualiza N8N a la última versión

#### Errores del Modelo de IA
**Problema**: "Error de API OpenAI" o "Modelo inválido"
**Solución**:
- Verifica que tu clave API de OpenAI sea correcta
- Verifica que tengas créditos suficientes
- Asegúrate de que el nombre del modelo sea correcto (gpt-4o-mini)

### Modo de Depuración

Habilita el modo de depuración estableciendo en tu `.env`:
```bash
MODO_DEBUG_HABILITADO=true
NIVEL_LOG=debug
```

### Prueba de Componentes Individuales

```bash
# Probar configuración del entorno
npm run probar

# Probar configuración de Google Sheets
npm run configurar-hojas

# Probar configuración de Google Drive  
npm run configurar-drive

# Probar actualización de configuración
node actualizar-config-n8n.js
```

## 🔒 Consideraciones de Seguridad

### Privacidad de Datos
- Todos los datos se procesan a través de tus propias cuentas de Google y OpenAI
- No se almacenan datos en servidores externos
- Los documentos se almacenan en tu propio Google Drive

### Control de Acceso
- Usa cuentas de servicio con permisos mínimos requeridos
- Rota regularmente las claves API y credenciales
- Monitorea el uso de APIs y costos

### Cumplimiento
- Asegúrate del cumplimiento con las leyes de protección de datos de tu jurisdicción
- Considera requisitos de confidencialidad del cliente
- Implementa políticas de retención de datos apropiadas

## 📈 Optimización de Rendimiento

### Gestión de Costos
- Monitorea el uso y costos de la API de OpenAI
- Usa GPT-4o-mini para la mayoría de tareas (rentable)
- Implementa limitación de velocidad si es necesario

### Consejos de Eficiencia
- Procesa documentos en lotes durante horas de menor actividad
- Usa el modelo de IA apropiado para la complejidad de la tarea
- Optimiza prompts para mejor precisión y eficiencia

## 🤝 Soporte y Contribuciones

### Obtener Ayuda
1. Revisa este README para problemas comunes
2. Revisa la documentación de N8N
3. Verifica tu configuración de Google Cloud
4. Prueba componentes individuales usando el script de prueba

### Contribuir
¡Las contribuciones son bienvenidas! Áreas para mejora:
- Tipos adicionales de documentos legales
- Prompts de IA más sofisticados
- Integración con otro software legal
- Optimizaciones de rendimiento

### Licencia
Licencia MIT - Siéntete libre de modificar y usar para tu práctica legal.

## 📚 Recursos Adicionales

- [Documentación de N8N](https://docs.n8n.io/)
- [Documentación de APIs de Google Cloud](https://cloud.google.com/docs)
- [Documentación de API de OpenAI](https://platform.openai.com/docs)
- [Documentación de API de Google Sheets](https://developers.google.com/sheets/api)
- [Documentación de API de Google Drive](https://developers.google.com/drive/api)

---

**Nota**: Este sistema está diseñado para asistir a profesionales legales pero no debe reemplazar el juicio legal profesional. Siempre revisa el contenido generado por IA antes de usarlo en procedimientos legales.
EOF

    imprimir_exito "Documentación README creada"
}

# Función principal de configuración
main() {
    imprimir_estado "Iniciando configuración del entorno del Sistema de IA Legal..."
    
    verificar_nodejs
    verificar_npm
    instalar_dependencias
    crear_archivo_env
    crear_script_config_n8n
    crear_script_prueba
    crear_readme
    
    imprimir_exito "Configuración del entorno completada exitosamente!"
    imprimir_advertencia "Próximos pasos:"
    echo "1. Edita el archivo .env con tus valores de configuración reales"
    echo "2. Ejecuta: npm run configurar-todo"
    echo "3. Ejecuta: node actualizar-config-n8n.js"
    echo "4. Importa el workflow en N8N"
    echo ""
    imprimir_estado "Para instrucciones detalladas, consulta README.md"
}

# Ejecutar la configuración
main "$@"