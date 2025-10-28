CREATE SCHEMA IF NOT EXISTS finance;

-- Extensions (enable UUID generation if available)
DO $$ BEGIN
  PERFORM 1 FROM pg_extension WHERE extname = 'pgcrypto';
  IF NOT FOUND THEN
    CREATE EXTENSION pgcrypto;
  END IF;
EXCEPTION WHEN insufficient_privilege THEN
  RAISE NOTICE 'Extension pgcrypto not created due to insufficient privileges. Ensure gen_random_uuid() exists or switch to uuid-ossp.';
END $$;

CREATE TABLE IF NOT EXISTS finance.ap_expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  raw_id TEXT UNIQUE NOT NULL,
  posted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  vendor TEXT NOT NULL,
  amount NUMERIC(18,2) NOT NULL,
  due_date DATE,
  category TEXT,
  description TEXT,
  paid BOOLEAN NOT NULL DEFAULT false,
  source_email TEXT,
  attachment_filename TEXT,
  attachment_mime TEXT,
  attachment_base64 TEXT
);

CREATE INDEX IF NOT EXISTS ap_expenses_due_idx ON finance.ap_expenses (due_date, paid);

CREATE TABLE IF NOT EXISTS finance.ar_invoices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id TEXT UNIQUE NOT NULL,
  issued_at TIMESTAMPTZ NOT NULL,
  customer TEXT NOT NULL,
  amount_remaining NUMERIC(18,2) NOT NULL,
  due_date DATE,
  customer_email TEXT,
  stripe_status TEXT,
  last_update TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ar_invoices_due_idx ON finance.ar_invoices (due_date, amount_remaining);

CREATE TABLE IF NOT EXISTS finance.templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  channel TEXT NOT NULL DEFAULT 'email',
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO finance.templates (slug, title, body, channel, description) VALUES
('ap_overdue_notice_internal', 'Pago vencido: {{vendor}}',
'<p>Recordatorio: la factura {{raw_id}} de {{vendor}} ({{amount}}) venció el {{due_date}}.</p><p>Descripción: {{description}}</p>',
'email', 'Aviso interno al equipo finanzas')
ON CONFLICT (slug) DO NOTHING;

INSERT INTO finance.templates (slug, title, body, channel, description) VALUES
('ar_overdue_customer', 'Recordatorio de pago — Factura {{invoice_id}}',
'Estimado/a {{customer}}, detectamos un saldo pendiente de {{amount_remaining}} vencido el {{due_date}}. Por favor, regularice a la brevedad.',
'email', 'Recordatorio de cobro al cliente')
ON CONFLICT (slug) DO NOTHING;

