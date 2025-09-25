## AI Accounting (n8n + Postgres) — Guía de instalación en Dokploy

### Requisitos
- Dokploy con servicios: `n8n-with-postgres`, `postgres`, `redis`, `chatwoot`, `evolutionapi`, `qdrant` (opcional), `stripe` (externo)
- DNS/HTTPS para n8n (ej: https://n8n.tu-dominio.com)
- Credenciales: OpenAI, SMTP, Stripe, Chatwoot, EvolutionAPI

### 1) Cargar el esquema en Postgres
1. Accede al contenedor o servicio `postgres` de Dokploy
2. Ejecuta el SQL:
   - Archivo: `sql/schema.sql`
   - Asegura extensión `pgcrypto` (el script ya intenta crearla)

### 2) Configurar credenciales en n8n
En n8n → Credentials:
- Postgres: host `postgres`, puerto 5432, base/usuario/clave según Dokploy
- OpenAI: API Key
- SMTP: servidor y remitente
- Stripe API: Secret y Webhook Secret (para firmar, opcional si validas en proxy)
- Chatwoot: usa credencial HTTP (token) o credencial dedicada si disponible
- EvolutionAPI: base URL, instance key y token (si usarás WhatsApp)

### 3) Importar los workflows
Importa estos 5 archivos desde `workflows/`:
- `AP_ingest_from_email.json`
- `AP_overdue_alerts.json`
- `AR_stripe_new_and_update.json`
- `AR_overdue_alerts.json`
- `Main_agent_chatwoot.json`

Edita placeholders: `TU_EMAIL`, `TU_PASSWORD`, credenciales y dominios.

### 4) Endpoints externos
- Stripe Webhook: `https://TU_N8N_DOMAIN/webhook/stripe-ar`
- Chatwoot Webhook: `https://TU_N8N_DOMAIN/webhook/chatwoot-agent`

Configura en Stripe los eventos: `invoice.created`, `invoice.updated`, `invoice.payment_succeeded`, `invoice.payment_failed`.

### 5) Templates (escritos repetitivos)
Inserta filas en `finance.templates` (campos `slug`, `title`, `body` con {{mustache}}). Ya hay 2 ejemplos. Puedes agregar más con SQL o desde n8n (nodo Postgres).

### 6) Activación
Activa workflows en este orden:
1. `AR_stripe_new_and_update`
2. `AR_overdue_alerts`
3. `AP_ingest_from_email`
4. `AP_overdue_alerts`
5. `Main_agent_chatwoot`

### 7) Opcional: WhatsApp (EvolutionAPI)
Duplica paso de envío de email en `AP_overdue_alerts` y `AR_overdue_alerts` con un nodo HTTP POST a EvolutionAPI:
- URL: `{{EVO_BASE_URL}}/message/text`
- Body JSON: `{ "instance_key": "{{INSTANCE_KEY}}", "to": "+54911...", "message": "texto" }`

### 8) Pruebas rápidas
- Envía un email con PDF “invoice” al buzón configurado → verifica inserción en `finance.ap_expenses`
- Crea/actualiza una invoice en Stripe → verifica `finance.ar_invoices`
- En Chatwoot envía: "listar AP vencidas" o "marcar pagada raw_id=XXXX"

### 9) Seguridad y notas
- Restringe IPs al webhook de Stripe o valida firma
- Mueve adjuntos grandes a S3/MinIO y guarda URL (adaptar query)
- Ajusta horarios de cron a tu zona

