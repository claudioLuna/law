# Sistema de Soporte WhatsApp - Kapso + n8n

## Descripción
Sistema completo de soporte al cliente vía WhatsApp que utiliza:
- **Kapso**: Orquestador de conversación y agente de captura de datos
- **n8n**: Motor de procesamiento de negocio para tickets y notificaciones
- **Supabase**: Base de datos PostgreSQL
- **OpenAI**: Modelos de IA para clasificación y agentes especializados

## Arquitectura
```
WhatsApp → Kapso (Orquestador) → n8n (Webhook) → Supabase/Jira/Slack
```

## Estructura del Proyecto
```
├── kapso/
│   ├── flows/
│   │   ├── orquestador_central.py
│   │   └── agente_reclamos.py
│   ├── requirements.txt
│   └── Dockerfile
├── n8n/
│   ├── workflows/
│   │   └── reclamos-processor.json
│   └── docker-compose.yml
├── supabase/
│   ├── migrations/
│   │   └── 001_initial_schema.sql
│   └── seed.sql
├── docker-compose.yml
└── dokploy.config.yml
```

## Despliegue en Dokploy
1. Configurar variables de entorno
2. Ejecutar `docker-compose up -d`
3. Importar workflow de n8n
4. Configurar webhooks de Kapso

## Variables de Entorno Requeridas
- `OPENAI_API_KEY`
- `SUPABASE_URL`
- `SUPABASE_KEY`
- `N8N_WEBHOOK_URL`
- `SLACK_WEBHOOK_URL`
- `JIRA_API_TOKEN`