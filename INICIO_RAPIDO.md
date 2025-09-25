# Sistema de IA Legal - Inicio Rápido

Pon en marcha tu Sistema de IA Legal en 30 minutos con esta guía de inicio rápido.

## ⚡ Configuración de 5 Minutos

### 1. Verificación de Prerrequisitos
- [ ] Cuenta de Google Cloud
- [ ] Clave API de OpenAI
- [ ] Cuenta Gmail
- [ ] Instancia N8N

### 2. Ejecutar Configuración Automatizada
```bash
# Hacer ejecutable y ejecutar
chmod +x configurar-entorno.sh
./configurar-entorno.sh

# Configurar tus credenciales
cp .env.ejemplo .env
# Edita .env con tus valores reales

# Configurar servicios de Google
npm run configurar-todo

# Actualizar configuración N8N
node actualizar-config-n8n.js
```

### 3. Importar a N8N
1. Copia contenido de `sistema-ia-legal-n8n-workflow.json`
2. Importa en N8N
3. Configura credenciales
4. Prueba workflows

## 🎯 Configuración Esencial

### Google Cloud (5 minutos)
1. Crear proyecto en [Google Cloud Console](https://console.cloud.google.com/)
2. Habilitar APIs: Sheets, Drive, Gmail
3. Crear cuenta de servicio → Descargar JSON
4. Crear credenciales OAuth2

### OpenAI (2 minutos)
1. Obtener clave API de [OpenAI Platform](https://platform.openai.com/)
2. Agregar créditos a cuenta
3. Actualizar archivo `.env`

### Gmail OAuth2 (5 minutos)
1. Usar credenciales OAuth2 de Google Cloud
2. Generar token de actualización
3. Actualizar archivo `.env`

## 🧪 Prueba Rápida

### Probar Procesamiento de Documentos
```bash
# Envía email con PDF adjunto a tu Gmail
# Verifica Google Drive para documento guardado
# Verifica resumen en Google Sheets
# Confirma notificación por email enviada
```

### Probar Análisis de Contratos
```bash
# Sube contrato a carpeta de Google Drive
# Verifica análisis en Google Sheets
# Confirma reporte por email enviado
```

### Probar Agente de IA
```bash
# Pregunta en chat N8N: "¿Qué fechas límite vencen pronto?"
# Verifica respuesta con datos de documentos
```

## 🔧 Problemas Comunes y Soluciones

### "Autenticación fallida"
- Verificar clave JSON de cuenta de servicio de Google
- Verificar APIs habilitadas
- Asegurar tokens OAuth2 válidos

### "Permiso denegado"
- Verificar IDs de carpetas en workflow
- Verificar permisos de compartir de Google Drive
- Confirmar acceso de cuenta de servicio

### "Workflow inválido"
- Actualizar N8N a última versión
- Verificar sintaxis JSON
- Confirmar tipos de nodos compatibles

## 📞 ¿Necesitas Ayuda?

1. **Problemas Rápidos**: Consulta esta guía
2. **Problemas de Configuración**: Ve `README.md`
3. **Despliegue Completo**: Ve `GUIA_DESPLIEGUE.md`
4. **Detalles Técnicos**: Ve `prompts-ia.md`

## 🚀 ¡Estás Listo!

Tu Sistema de IA Legal está procesando documentos, analizando contratos y proporcionando asistencia legal con IA!

**Próximos Pasos:**
- Entrenar a tu equipo en el sistema
- Configurar monitoreo y alertas
- Personalizar prompts para tu área de práctica
- Escalar para uso en producción