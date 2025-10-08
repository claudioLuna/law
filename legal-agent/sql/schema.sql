-- =============================================================================
-- SCHEMA LEGAL AGENT - ARGENTINA (MENDOZA)
-- Sistema de gestión legal con RAG y redacción automatizada
-- =============================================================================

-- Extensión para UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================================================
-- TABLA: CASOS LEGALES
-- =============================================================================
CREATE TABLE cases (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('pending', 'in_process', 'completed')) DEFAULT 'pending',
    priority TEXT NOT NULL CHECK (priority IN ('low', 'medium', 'high')) DEFAULT 'medium',
    due_at TIMESTAMPTZ,
    client_name TEXT,
    jurisdiction TEXT NOT NULL DEFAULT 'Mendoza',
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para cases
CREATE INDEX idx_cases_status ON cases(status);
CREATE INDEX idx_cases_priority ON cases(priority);
CREATE INDEX idx_cases_due_at ON cases(due_at);
CREATE INDEX idx_cases_jurisdiction ON cases(jurisdiction);
CREATE INDEX idx_cases_client_name ON cases(client_name);

-- =============================================================================
-- TABLA: DOCUMENTOS
-- =============================================================================
CREATE TABLE documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    case_id UUID REFERENCES cases(id) ON DELETE CASCADE,
    filename TEXT NOT NULL,
    mime TEXT NOT NULL,
    storage_url TEXT,
    pages INTEGER DEFAULT 0,
    hash_sha256 TEXT UNIQUE,
    source TEXT NOT NULL DEFAULT 'upload',
    ingested_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para documents
CREATE INDEX idx_documents_case_id ON documents(case_id);
CREATE INDEX idx_documents_hash ON documents(hash_sha256);
CREATE INDEX idx_documents_source ON documents(source);
CREATE INDEX idx_documents_ingested_at ON documents(ingested_at);

-- =============================================================================
-- TABLA: CHUNKS DE DOCUMENTOS
-- =============================================================================
CREATE TABLE doc_chunks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    doc_id UUID NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
    chunk_index INTEGER NOT NULL,
    text TEXT NOT NULL,
    tokens INTEGER NOT NULL,
    qdrant_point_id TEXT UNIQUE,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para doc_chunks
CREATE INDEX idx_doc_chunks_doc_id ON doc_chunks(doc_id);
CREATE INDEX idx_doc_chunks_chunk_index ON doc_chunks(chunk_index);
CREATE INDEX idx_doc_chunks_qdrant_id ON doc_chunks(qdrant_point_id);
CREATE INDEX idx_doc_chunks_metadata ON doc_chunks USING GIN(metadata);

-- =============================================================================
-- TABLA: PLANTILLAS DE DOCUMENTOS
-- =============================================================================
CREATE TABLE templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type TEXT NOT NULL,
    jurisdiction TEXT NOT NULL DEFAULT 'Mendoza',
    version INTEGER NOT NULL DEFAULT 1,
    prompt_vars JSONB DEFAULT '{}',
    body_md TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para templates
CREATE INDEX idx_templates_type ON templates(type);
CREATE INDEX idx_templates_jurisdiction ON templates(jurisdiction);
CREATE INDEX idx_templates_type_jurisdiction ON templates(type, jurisdiction);
CREATE UNIQUE INDEX idx_templates_unique ON templates(type, jurisdiction, version);

-- =============================================================================
-- TABLA: CONSULTAS RAG
-- =============================================================================
CREATE TABLE rag_queries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    case_id UUID REFERENCES cases(id) ON DELETE SET NULL,
    question TEXT NOT NULL,
    llm_model TEXT NOT NULL,
    k INTEGER NOT NULL DEFAULT 8,
    rerank BOOLEAN DEFAULT FALSE,
    latency_ms INTEGER,
    answer_md TEXT,
    citations JSONB DEFAULT '[]',
    cost_usd NUMERIC(10,4) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para rag_queries
CREATE INDEX idx_rag_queries_case_id ON rag_queries(case_id);
CREATE INDEX idx_rag_queries_created_at ON rag_queries(created_at);
CREATE INDEX idx_rag_queries_llm_model ON rag_queries(llm_model);

-- =============================================================================
-- TABLA: EMAILS
-- =============================================================================
CREATE TABLE emails (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    message_id TEXT UNIQUE NOT NULL,
    from_addr TEXT NOT NULL,
    subject TEXT,
    received_at TIMESTAMPTZ DEFAULT NOW(),
    case_id UUID REFERENCES cases(id) ON DELETE SET NULL,
    klass TEXT,
    summary_md TEXT,
    attachments JSONB DEFAULT '[]'
);

-- Índices para emails
CREATE INDEX idx_emails_case_id ON emails(case_id);
CREATE INDEX idx_emails_from_addr ON emails(from_addr);
CREATE INDEX idx_emails_received_at ON emails(received_at);
CREATE INDEX idx_emails_message_id ON emails(message_id);

-- =============================================================================
-- TABLA: TAREAS
-- =============================================================================
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    case_id UUID REFERENCES cases(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    kind TEXT NOT NULL DEFAULT 'general',
    due_at TIMESTAMPTZ,
    assignee TEXT,
    status TEXT NOT NULL CHECK (status IN ('open', 'done')) DEFAULT 'open',
    origin TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para tasks
CREATE INDEX idx_tasks_case_id ON tasks(case_id);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_kind ON tasks(kind);
CREATE INDEX idx_tasks_due_at ON tasks(due_at);
CREATE INDEX idx_tasks_assignee ON tasks(assignee);

-- =============================================================================
-- TABLA: MENSAJES WHATSAPP
-- =============================================================================
CREATE TABLE whatsapp_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    case_id UUID REFERENCES cases(id) ON DELETE SET NULL,
    to_number TEXT NOT NULL,
    direction TEXT NOT NULL CHECK (direction IN ('inbound', 'outbound')),
    body TEXT,
    media_url TEXT,
    status TEXT DEFAULT 'sent',
    provider_message_id TEXT,
    delivered_at TIMESTAMPTZ
);

-- Índices para whatsapp_messages
CREATE INDEX idx_whatsapp_case_id ON whatsapp_messages(case_id);
CREATE INDEX idx_whatsapp_to_number ON whatsapp_messages(to_number);
CREATE INDEX idx_whatsapp_direction ON whatsapp_messages(direction);
CREATE INDEX idx_whatsapp_status ON whatsapp_messages(status);
CREATE INDEX idx_whatsapp_delivered_at ON whatsapp_messages(delivered_at);

-- =============================================================================
-- TABLA: AUDITORÍA
-- =============================================================================
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor TEXT,
    action TEXT NOT NULL,
    entity TEXT NOT NULL,
    entity_id UUID,
    diff JSONB DEFAULT '{}',
    ip TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para audit_logs
CREATE INDEX idx_audit_actor ON audit_logs(actor);
CREATE INDEX idx_audit_action ON audit_logs(action);
CREATE INDEX idx_audit_entity ON audit_logs(entity);
CREATE INDEX idx_audit_entity_id ON audit_logs(entity_id);
CREATE INDEX idx_audit_created_at ON audit_logs(created_at);

-- =============================================================================
-- VISTA: VENCIMIENTOS DE CASOS
-- =============================================================================
CREATE OR REPLACE VIEW vw_case_deadlines AS
SELECT 
    c.id as case_id,
    c.code,
    c.title,
    c.client_name,
    c.jurisdiction,
    c.due_at,
    c.priority,
    c.status,
    CASE 
        WHEN c.due_at < NOW() THEN 'overdue'
        WHEN c.due_at < NOW() + INTERVAL '7 days' THEN 'urgent'
        WHEN c.due_at < NOW() + INTERVAL '30 days' THEN 'upcoming'
        ELSE 'future'
    END as deadline_status,
    EXTRACT(DAYS FROM (c.due_at - NOW())) as days_until_due
FROM cases c
WHERE c.status IN ('pending', 'in_process')
    AND c.due_at IS NOT NULL
ORDER BY c.due_at ASC;

-- =============================================================================
-- TRIGGERS PARA UPDATED_AT
-- =============================================================================

-- Función para actualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para updated_at
CREATE TRIGGER update_cases_updated_at 
    BEFORE UPDATE ON cases 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tasks_updated_at 
    BEFORE UPDATE ON tasks 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================================================
-- FUNCIONES AUXILIARES
-- =============================================================================

-- Función para generar código único de caso
CREATE OR REPLACE FUNCTION generate_case_code(jurisdiction TEXT DEFAULT 'MEN')
RETURNS TEXT AS $$
DECLARE
    year_part TEXT;
    sequence_part TEXT;
    new_code TEXT;
BEGIN
    year_part := TO_CHAR(NOW(), 'YYYY');
    
    SELECT COALESCE(MAX(
        CAST(SUBSTRING(code FROM '[0-9]+$') AS INTEGER)
    ), 0) + 1
    INTO sequence_part
    FROM cases 
    WHERE code LIKE jurisdiction || '-' || year_part || '-%';
    
    new_code := jurisdiction || '-' || year_part || '-' || LPAD(sequence_part::TEXT, 4, '0');
    
    RETURN new_code;
END;
$$ LANGUAGE plpgsql;

-- Función para limpiar texto para embeddings
CREATE OR REPLACE FUNCTION clean_text_for_embedding(input_text TEXT)
RETURNS TEXT AS $$
BEGIN
    RETURN REGEXP_REPLACE(
        REGEXP_REPLACE(
            REGEXP_REPLACE(
                UPPER(TRIM(input_text)),
                '[^\w\s]', ' ', 'g'
            ),
            '\s+', ' ', 'g'
        ),
        '^\s+|\s+$', '', 'g'
    );
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- COMENTARIOS Y DOCUMENTACIÓN
-- =============================================================================

COMMENT ON TABLE cases IS 'Casos legales del sistema';
COMMENT ON TABLE documents IS 'Documentos asociados a casos';
COMMENT ON TABLE doc_chunks IS 'Fragmentos de documentos para RAG';
COMMENT ON TABLE templates IS 'Plantillas para redacción de documentos';
COMMENT ON TABLE rag_queries IS 'Historial de consultas RAG';
COMMENT ON TABLE emails IS 'Emails asociados a casos';
COMMENT ON TABLE tasks IS 'Tareas y recordatorios';
COMMENT ON TABLE whatsapp_messages IS 'Mensajes de WhatsApp';
COMMENT ON TABLE audit_logs IS 'Log de auditoría del sistema';

COMMENT ON VIEW vw_case_deadlines IS 'Vista de vencimientos ordenados por prioridad';