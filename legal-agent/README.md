# Agente Legal IA - Argentina (Mendoza)

Sistema completo de gestión legal con IA, RAG y redacción automatizada de documentos para Argentina, con foco en Mendoza.

## 🏗️ Arquitectura

- **n8n**: Orquestación de workflows
- **PostgreSQL**: Base de datos principal
- **Qdrant**: Base de datos vectorial para RAG
- **Redis**: Cache y rate limiting
- **OpenAI API**: LLM y embeddings
- **EvolutionAPI**: Integración con WhatsApp

## 📁 Estructura del Proyecto

```
legal-agent/
├── n8n/                          # Workflows de n8n
│   ├── wf_setup_db.json          # Configuración de base de datos
│   ├── wf_setup_seed.json        # Plantillas legales iniciales
│   ├── wf_setup_qdrant.json      # Configuración de Qdrant
│   ├── wf_ingest_index.json      # Indexación de documentos
│   ├── wf_rag_query.json         # Consultas RAG
│   └── wf_drafting.json          # Redacción de documentos
├── sql/
│   ├── schema.sql                # DDL completo de la base de datos
│   └── seed_templates.sql        # Plantillas legales de Mendoza
├── qdrant/
│   └── schema.json               # Configuración de colección Qdrant
└── README.md                     # Este archivo
```

## 🚀 Instalación y Configuración

### 1. Variables de Entorno

Configura estas variables en tu servicio n8n:

```bash
# Base de datos PostgreSQL
PG_HOST=postgres
PG_DB=legal
PG_USER=legal_user
PG_PASS=CAMBIAR

# Qdrant
QDRANT_URL=http://qdrant:6333

# Redis
REDIS_HOST=redis

# OpenAI API
OPENAI_API_KEY=sk-xxx
EMBEDDINGS_MODEL=text-embedding-3-large
LLM_MODEL=gpt-4o

# EvolutionAPI (WhatsApp)
EVOLUTION_BASE_URL=http://evolutionapi:PORT
EVOLUTION_INSTANCE=instancia123
EVOLUTION_API_KEY=token123

# Webhook público
BASE_URL=https://agentlaw.midominio.com

# Token de setup
SETUP_TOKEN=legal-agent-2024
```

### 2. Configuración de Credenciales en n8n

#### PostgreSQL
- **ID**: `postgres-legal-agent`
- **Host**: `{{PG_HOST}}`
- **Database**: `{{PG_DB}}`
- **User**: `{{PG_USER}}`
- **Password**: `{{PG_PASS}}`

#### OpenAI API
- **ID**: `openai-api-legal`
- **API Key**: `{{OPENAI_API_KEY}}`

#### Redis
- **ID**: `redis-legal-agent`
- **Host**: `{{REDIS_HOST}}`
- **Port**: `6379`

### 3. Importación de Workflows

1. Importa los 6 workflows JSON en tu instancia de n8n
2. Activa todos los workflows
3. Configura las credenciales según los IDs especificados

### 4. Configuración Inicial

Ejecuta estos endpoints en orden para configurar el sistema:

#### 4.1 Configurar Base de Datos
```bash
curl -X POST https://agentlaw.midominio.com/webhook/setup/db \
  -H "Authorization: Bearer legal-agent-2024" \
  -H "Content-Type: application/json"
```

#### 4.2 Insertar Plantillas Legales
```bash
curl -X POST https://agentlaw.midominio.com/webhook/setup/seed \
  -H "Authorization: Bearer legal-agent-2024" \
  -H "Content-Type: application/json"
```

#### 4.3 Configurar Qdrant
```bash
curl -X POST https://agentlaw.midominio.com/webhook/setup/qdrant \
  -H "Authorization: Bearer legal-agent-2024" \
  -H "Content-Type: application/json"
```

## 📋 Endpoints Disponibles

### `/ingest` - Indexación de Documentos

**Método**: POST  
**Content-Type**: `multipart/form-data` o `application/json`

#### Ejemplo con archivo:
```bash
curl -X POST https://agentlaw.midominio.com/webhook/ingest \
  -F "file=@documento.pdf" \
  -F "case_id=uuid-del-caso" \
  -F "fuente=jurisprudencia" \
  -F "documento=fallo-csjn" \
  -F "jurisdiction=Mendoza" \
  -F "date=2024-01-15" \
  -F "tags=laboral,despido"
```

#### Ejemplo con URL:
```bash
curl -X POST https://agentlaw.midominio.com/webhook/ingest \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com/documento.pdf",
    "filename": "documento.pdf",
    "mime": "application/pdf",
    "case_id": "uuid-del-caso",
    "fuente": "normativa",
    "documento": "LCT",
    "jurisdiction": "Nacional",
    "date": "2024-01-15",
    "tags": "trabajo,contrato"
  }'
```

### `/ask` - Consultas RAG

**Método**: POST  
**Content-Type**: `application/json`

```bash
curl -X POST https://agentlaw.midominio.com/webhook/ask \
  -H "Content-Type: application/json" \
  -d '{
    "question": "¿Cuáles son los requisitos para una demanda laboral por despido?",
    "case_id": "uuid-del-caso",
    "filters": {
      "jurisdiction": "Mendoza",
      "fuente": "jurisprudencia",
      "date_from": "2020-01-01"
    },
    "k": 8,
    "rerank": false
  }'
```

### `/draft` - Redacción de Documentos

**Método**: POST  
**Content-Type**: `application/json`

```bash
curl -X POST https://agentlaw.midominio.com/webhook/draft \
  -H "Content-Type: application/json" \
  -d '{
    "type": "demanda_laboral",
    "case_id": "uuid-del-caso",
    "variables": {
      "actor_nombre": "Juan Pérez",
      "actor_dni": "12345678",
      "demandado_nombre": "Empresa XYZ S.A.",
      "demandado_cuit": "20-12345678-9",
      "materia": "Despido sin causa",
      "juzgado": "1",
      "monto_estimado": "500000",
      "hechos_detallados": "El actor fue despedido sin causa el 15/01/2024...",
      "prueba_documental": "Recibo de sueldo, telegrama de despido",
      "testigos": "María González, Pedro López",
      "oficios": "Ministerio de Trabajo",
      "autorizados": "Abogado Dr. García"
    }
  }'
```

## 📊 Tipos de Documentos Soportados

### 1. Demanda Laboral
- **Variables**: actor_nombre, actor_dni, demandado_nombre, demandado_cuit, materia, juzgado, monto_estimado, hechos_detallados, prueba_documental, testigos, oficios, autorizados

### 2. Carta Documento
- **Variables**: remitente_nombre, remitente_dni, destinatario_nombre, destinatario_dni, motivo, plazo_dias, consecuencias

### 3. Contrato de Servicios
- **Variables**: cliente_nombre, cliente_dni, proveedor_nombre, proveedor_cuit, servicio_descripcion, monto_total, plazo_ejecucion, forma_pago

### 4. Escrito de Presentación
- **Variables**: actor_nombre, actor_dni, demandado_nombre, demandado_cuit, tipo_proceso, juzgado, materia, petitorio

## 🗄️ Esquema de Base de Datos

### Tablas Principales

- **cases**: Casos legales
- **documents**: Documentos asociados
- **doc_chunks**: Fragmentos para RAG
- **templates**: Plantillas de documentos
- **rag_queries**: Historial de consultas
- **emails**: Emails asociados
- **tasks**: Tareas y recordatorios
- **whatsapp_messages**: Mensajes WhatsApp
- **audit_logs**: Log de auditoría

### Vista Especial

- **vw_case_deadlines**: Vencimientos ordenados por prioridad

## 🔧 Funcionalidades del Sistema

### RAG (Retrieval Augmented Generation)
- Búsqueda semántica en documentos legales
- Cache inteligente con Redis
- Filtros por jurisdicción, fuente, fecha
- Citas automáticas con formato legal

### Redacción Automatizada
- Plantillas específicas para Mendoza
- Integración con contexto RAG
- Generación en Markdown
- Tareas de revisión automáticas

### Gestión de Casos
- Seguimiento de vencimientos
- Asociación de documentos
- Historial de consultas
- Auditoría completa

## 🚨 Sistema de Prompts

### Prompt RAG
```
Eres un asistente legal en Argentina, con foco en Mendoza. 
Responde EXCLUSIVAMENTE con los fragmentos del contexto. 
Cita SIEMPRE con el formato {fuente}:{documento}:{pagina} (score={score}).
Si no hay evidencia suficiente, responde: "No se encontró evidencia suficiente en las fuentes aportadas".
Prioriza normativa/jurisprudencia mendocina; complementa con normativa nacional si está en contexto.
Prohibido inventar artículos, fallos o números de expediente.
```

### Prompt Redactor
```
Eres abogado redactor en Mendoza. Redacta escritos con formato procesal argentino.
Estructura: Personería y Competencia; Hechos; Derecho (citas del contexto); Petitorio; Prueba; Reserva de Caso Federal (si aplica).
Cita {fuente}:{documento}:{pagina} sólo si está en el contexto.
No inventes datos; deja TODO: ... donde falte completar.
Devuelve en Markdown bien formateado.
```

## 📈 Monitoreo y Logs

- **audit_logs**: Registro de todas las acciones
- **rag_queries**: Métricas de consultas (latencia, costo)
- **tasks**: Seguimiento de tareas pendientes
- **vw_case_deadlines**: Dashboard de vencimientos

## 🔒 Seguridad

- Autenticación por token en endpoints de setup
- Validación de tipos de documento
- Sanitización de inputs
- Logs de auditoría completos

## 🆘 Solución de Problemas

### Error: "Plantilla no encontrada"
- Verificar que se ejecutó `/setup/seed`
- Comprobar que el tipo de documento es válido

### Error: "No se encontró evidencia suficiente"
- Verificar que se indexaron documentos con `/ingest`
- Comprobar filtros de búsqueda
- Revisar configuración de Qdrant

### Error: "Token de autorización inválido"
- Verificar variable `SETUP_TOKEN`
- Comprobar header `Authorization: Bearer`

## 📞 Soporte

Para soporte técnico o consultas sobre el sistema, contacta al equipo de desarrollo.

---

**Desarrollado para el sistema legal argentino con foco en Mendoza** 🇦🇷