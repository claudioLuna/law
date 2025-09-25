# Sistema de IA Legal - Guía de Despliegue

Esta guía proporciona instrucciones paso a paso para desplegar el Sistema de IA Legal en tu entorno N8N.

## 🎯 Lista de Verificación Pre-Despliegue

### Cuentas y Servicios Requeridos
- [ ] Cuenta de Google Cloud Platform con facturación habilitada
- [ ] Cuenta OpenAI con acceso GPT-4
- [ ] Cuenta Gmail para procesamiento de emails
- [ ] Instancia N8N (auto-hospedada o en la nube)
- [ ] Dominio o servidor para hosting (si auto-hospedeas N8N)

### APIs y Permisos Requeridos
- [ ] API de Google Sheets habilitada
- [ ] API de Google Drive habilitada
- [ ] API de Gmail habilitada
- [ ] Acceso a API de OpenAI
- [ ] Cuenta de servicio con permisos apropiados

## 🚀 Despliegue Paso a Paso

### Fase 1: Configuración del Entorno

#### 1.1 Descargar y Extraer Archivos
```bash
# Crear directorio del proyecto
mkdir sistema-ia-legal
cd sistema-ia-legal

# Copiar todos los archivos proporcionados a este directorio
# Archivos a incluir:
# - sistema-ia-legal-n8n-workflow.json
# - configurar-google-sheets.js
# - configurar-google-drive.js
# - configurar-entorno.sh
# - actualizar-config-n8n.js
# - probar-workflow.js
# - prompts-ia.md
# - package.json
# - .env.ejemplo
# - README.md
# - GUIA_DESPLIEGUE.md
```

#### 1.2 Ejecutar Configuración Automatizada
```bash
# Hacer ejecutable el script de configuración
chmod +x configurar-entorno.sh

# Ejecutar la configuración
./configurar-entorno.sh
```

#### 1.3 Verificar Instalación
```bash
# Probar la instalación
npm run probar
```

### Fase 2: Configuración de Google Cloud

#### 2.1 Crear Proyecto de Google Cloud
1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Haz clic en "Seleccionar un proyecto" > "Nuevo Proyecto"
3. Ingresa nombre del proyecto: "Sistema de IA Legal"
4. Haz clic en "Crear"

#### 2.2 Habilitar APIs Requeridas
1. Ve a "APIs y Servicios" > "Biblioteca"
2. Habilita las siguientes APIs:
   - Google Sheets API
   - Google Drive API
   - Gmail API
   - Google+ API (para OAuth)

#### 2.3 Crear Cuenta de Servicio
1. Ve a "IAM y Administración" > "Cuentas de Servicio"
2. Haz clic en "Crear Cuenta de Servicio"
3. Nombre: "cuenta-servicio-ia-legal"
4. Descripción: "Cuenta de servicio para Sistema de IA Legal"
5. Haz clic en "Crear y Continuar"
6. Concede roles:
   - Editor (para Google Drive)
   - Usuario de Cuenta de Servicio
7. Haz clic en "Listo"

#### 2.4 Generar Clave de Cuenta de Servicio
1. Haz clic en la cuenta de servicio creada
2. Ve a la pestaña "Claves"
3. Haz clic en "Agregar Clave" > "Crear Nueva Clave"
4. Selecciona formato "JSON"
5. Descarga el archivo de clave
6. Guarda como `clave-cuenta-servicio.json`

#### 2.5 Configurar Credenciales OAuth2
1. Ve a "APIs y Servicios" > "Credenciales"
2. Haz clic en "Crear Credenciales" > "ID de cliente OAuth"
3. Tipo de aplicación: "Aplicación web"
4. Nombre: "Sistema de IA Legal OAuth"
5. URIs de redirección autorizados:
   - `http://localhost:5678/rest/oauth2-credential/callback`
   - `https://tu-dominio-n8n.com/rest/oauth2-credential/callback`
6. Haz clic en "Crear"
7. Descarga las credenciales JSON

### Fase 3: Configuración de OpenAI

#### 3.1 Crear Cuenta OpenAI
1. Ve a [OpenAI Platform](https://platform.openai.com/)
2. Regístrate o inicia sesión
3. Ve a "API Keys"
4. Haz clic en "Crear nueva clave secreta"
5. Nombre: "Sistema de IA Legal"
6. Copia la clave API

#### 3.2 Agregar Créditos
1. Ve a "Facturación" en el panel de OpenAI
2. Agrega método de pago
3. Agrega créditos iniciales ($20-50 recomendado para pruebas)

### Fase 4: Configuración del Entorno

#### 4.1 Configurar Variables de Entorno
```bash
# Copiar la plantilla de archivo de entorno
cp .env.ejemplo .env

# Editar el archivo .env con tus valores reales
nano .env
```

#### 4.2 Actualizar Archivo .env
```bash
# Cuenta de Servicio de Google (del archivo JSON de clave descargado)
GOOGLE_PROJECT_ID=tu-id-real-del-proyecto
GOOGLE_PRIVATE_KEY_ID=tu-id-real-de-clave-privada
GOOGLE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nTU_CLAVE_PRIVADA_REAL\n-----END PRIVATE KEY-----\n"
GOOGLE_CLIENT_EMAIL=tu-cuenta-de-servicio@tu-proyecto.iam.gserviceaccount.com
GOOGLE_CLIENT_ID=tu-id-real-de-cliente

# API OpenAI
OPENAI_API_KEY=tu-clave-api-openai-real

# Gmail OAuth2 (del archivo JSON de credenciales OAuth2)
GMAIL_USER_EMAIL=tu-email@gmail.com
GMAIL_CLIENT_ID=tu-id-real-cliente-oauth
GMAIL_CLIENT_SECRET=tu-secreto-real-cliente-oauth
GMAIL_REFRESH_TOKEN=tu-token-real-actualizacion

# Equipo Legal
EQUIPO_LEGAL_EMAIL=equipo-legal@tuempresa.com
```

### Fase 5: Configuración de Servicios de Google

#### 5.1 Configurar Google Sheets
```bash
# Ejecutar script de configuración de Google Sheets
npm run configurar-hojas
```

#### 5.2 Configurar Carpetas de Google Drive
```bash
# Ejecutar script de configuración de Google Drive
npm run configurar-drive
```

#### 5.3 Actualizar Configuración N8N
```bash
# Actualizar workflow con tus IDs reales
node actualizar-config-n8n.js
```

### Fase 6: Despliegue de N8N

#### 6.1 Instalar N8N (si auto-hospedado)
```bash
# Instalar N8N globalmente
npm install n8n -g

# Iniciar N8N
n8n start
```

#### 6.2 Acceder a Interfaz N8N
1. Abre navegador a `http://localhost:5678`
2. Completa el asistente de configuración inicial
3. Crea tu cuenta de administrador

#### 6.3 Configurar Credenciales en N8N

##### Credencial OAuth2 de Gmail
1. Ve a "Credenciales" en N8N
2. Haz clic en "Agregar Credencial"
3. Selecciona "Gmail OAuth2 API"
4. Completa:
   - Client ID: De tus credenciales OAuth2
   - Client Secret: De tus credenciales OAuth2
5. Haz clic en "Conectar mi cuenta"
6. Completa flujo OAuth

##### Credencial OAuth2 de Google Drive
1. Crea nueva credencial
2. Selecciona "Google Drive OAuth2 API"
3. Usa mismo Client ID y Client Secret OAuth2
4. Completa flujo OAuth

##### Credencial OAuth2 de Google Sheets
1. Crea nueva credencial
2. Selecciona "Google Sheets OAuth2 API"
3. Usa mismo Client ID y Client Secret OAuth2
4. Completa flujo OAuth

##### Credencial API de OpenAI
1. Crea nueva credencial
2. Selecciona "OpenAI API"
3. Ingresa tu clave API de OpenAI

#### 6.4 Importar Workflow
1. Ve a "Workflows" en N8N
2. Haz clic en "Importar desde Archivo"
3. Selecciona `sistema-ia-legal-n8n-workflow.json`
4. Haz clic en "Importar"

#### 6.5 Configurar Nodos del Workflow
1. Abre el workflow importado
2. Actualiza cualquier valor de marcador restante
3. Prueba cada nodo individualmente

### Fase 7: Pruebas y Validación

#### 7.1 Probar Procesamiento de Documentos
1. Envía email de prueba con archivo PDF adjunto a tu Gmail configurado
2. Verifica si el workflow se activa
3. Verifica que el documento se guarde en Google Drive
4. Verifica que se cree resumen en Google Sheets
5. Verifica que se envíe notificación por email

#### 7.2 Probar Análisis de Contratos
1. Sube un contrato a la carpeta designada de Google Drive
2. Verifica si el workflow se activa
3. Verifica que se genere análisis
4. Verifica que los resultados se guarden en Google Sheets
5. Verifica que se envíe reporte por email

#### 7.3 Probar Agente de IA
1. Abre interfaz de chat en N8N
2. Haz preguntas de prueba:
   - "¿Qué fechas límite vencen pronto?"
   - "Muéstrame resúmenes de contratos"
   - "Redacta un memo para caso XYZ"

#### 7.4 Pruebas de Rendimiento
```bash
# Ejecutar pruebas comprensivas
npm run probar

# Probar componentes individuales
node probar-workflow.js
```

### Fase 8: Despliegue de Producción

#### 8.1 Endurecimiento de Seguridad
1. Usa credenciales específicas del entorno
2. Habilita HTTPS para N8N
3. Configura reglas de firewall apropiadas
4. Configura certificados SSL

#### 8.2 Configuración de Monitoreo
1. Configura registro para todos los workflows
2. Configura alertas para fallos
3. Monitorea uso de APIs y costos
4. Configura procedimientos de respaldo

#### 8.3 Configuración de Acceso del Equipo
1. Configura acceso de miembros del equipo a N8N
2. Configura permisos apropiados
3. Entrena al equipo en uso del sistema
4. Documenta procedimientos y workflows

## 🔧 Solución de Problemas

### Problemas Comunes de Despliegue

#### Errores de API de Google
**Problema**: "API no habilitada" o "Cuota excedida"
**Solución**:
- Verifica que todas las APIs requeridas estén habilitadas
- Verifica límites de cuota en Google Cloud Console
- Monitorea uso de APIs

#### Fallos de Autenticación
**Problema**: "Credenciales inválidas" o "Acceso denegado"
**Solución**:
- Verifica que la clave de cuenta de servicio sea correcta
- Verifica configuración OAuth2
- Asegúrate de que los scopes apropiados estén configurados

#### Problemas de Importación de N8N
**Problema**: "Workflow inválido" o "Nodo no encontrado"
**Solución**:
- Verifica compatibilidad de versión de N8N
- Verifica que los tipos de nodos sean compatibles
- Valida sintaxis JSON

### Problemas de Rendimiento

#### Procesamiento Lento
**Problema**: Workflows tardando mucho
**Solución**:
- Verifica límites de velocidad de APIs
- Optimiza prompts para eficiencia
- Considera usar modelos de IA más rápidos

#### Costos Altos
**Problema**: Cargos inesperados de API
**Solución**:
- Monitorea uso de OpenAI
- Usa modelos rentables
- Implementa límites de uso

## 📊 Monitoreo y Mantenimiento

### Tareas de Mantenimiento Regular
1. **Semanalmente**: Verificar uso de APIs y costos
2. **Mensualmente**: Revisar y actualizar prompts de IA
3. **Trimestralmente**: Actualizar dependencias y parches de seguridad
4. **Anualmente**: Revisar y optimizar rendimiento del sistema

### Lista de Verificación de Monitoreo
- [ ] Uso de APIs dentro de límites
- [ ] Tasas de éxito de ejecución de workflows
- [ ] Métricas de rendimiento del sistema
- [ ] Registros de seguridad y alertas
- [ ] Verificación de respaldos

## 🚀 Lista de Verificación de Go-Live

### Pre-Lanzamiento
- [ ] Todas las pruebas pasando
- [ ] Credenciales configuradas correctamente
- [ ] Equipo entrenado en uso del sistema
- [ ] Documentación completa
- [ ] Procedimientos de respaldo en su lugar

### Día de Lanzamiento
- [ ] Monitorear rendimiento del sistema
- [ ] Verificar que todos los workflows funcionen
- [ ] Verificar que las notificaciones por email funcionen
- [ ] Probar respuestas del agente de IA
- [ ] Monitorear uso de APIs

### Post-Lanzamiento
- [ ] Recopilar retroalimentación de usuarios
- [ ] Monitorear rendimiento del sistema
- [ ] Abordar cualquier problema rápidamente
- [ ] Planificar mejoras futuras

## 📞 Soporte

### Obtener Ayuda
1. Revisa esta guía de despliegue
2. Consulta la documentación principal README.md
3. Prueba componentes individuales
4. Consulta documentación de N8N y Google Cloud

### Procedimientos de Emergencia
1. **Sistema Caído**: Verificar estado del servicio N8N
2. **Errores de API**: Verificar credenciales y cuotas
3. **Problemas de Datos**: Verificar permisos de Google Sheets
4. **Problemas de Rendimiento**: Monitorear uso de APIs

---

**¡Felicidades!** Tu Sistema de IA Legal está ahora desplegado y listo para automatizar tus workflows legales.