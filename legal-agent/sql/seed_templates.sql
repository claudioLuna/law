-- =============================================================================
-- SEED TEMPLATES - PLANTILLAS LEGALES PARA MENDOZA, ARGENTINA
-- Sistema de redacción automatizada de documentos legales
-- =============================================================================

-- =============================================================================
-- PLANTILLA: DEMANDA LABORAL
-- =============================================================================
INSERT INTO templates (id, type, jurisdiction, version, prompt_vars, body_md) VALUES (
    uuid_generate_v4(),
    'demanda_laboral',
    'Mendoza',
    1,
    '{
        "actor_nombre": "string",
        "actor_dni": "string", 
        "demandado_nombre": "string",
        "demandado_cuit": "string",
        "materia": "string",
        "juzgado": "string",
        "monto_estimado": "string",
        "hechos_detallados": "string",
        "prueba_documental": "string",
        "testigos": "string",
        "oficios": "string",
        "autorizados": "string"
    }',
    '# DEMANDA LABORAL

**{{actor_nombre}}**  
DNI: {{actor_dni}}  
Domicilio: TODO: COMPLETAR  
Teléfono: TODO: COMPLETAR  
Email: TODO: COMPLETAR  

**EN CONTRA DE:**

**{{demandado_nombre}}**  
CUIT: {{demandado_cuit}}  
Domicilio: TODO: COMPLETAR  

**ANTE SU SEÑORÍA JUEZ DE PRIMERA INSTANCIA EN LO LABORAL N° {{juzgado}}**

## PERSONERÍA Y COMPETENCIA

El actor, {{actor_nombre}}, DNI {{actor_dni}}, comparece por derecho propio y en carácter de parte interesada, a los efectos de formular la presente demanda laboral contra {{demandado_nombre}}, CUIT {{demandado_cuit}}, por las causales que se exponen en el cuerpo de la presente.

Vengo a peticionar ante V.S. en los términos del art. 1° de la Ley N° 26.522, en razón de encontrarse radicado el domicilio del demandado en esta ciudad de Mendoza, lo que determina la competencia territorial de este Juzgado.

## HECHOS

{{hechos_detallados}}

### RELACIÓN LABORAL

1. El actor prestó servicios para el demandado desde TODO: FECHA INICIO hasta TODO: FECHA FIN, en calidad de TODO: CATEGORÍA/ESPECIALIDAD.

2. Durante toda la relación laboral, el actor cumplió con sus obligaciones en forma diligente y responsable, siendo reconocido su buen desempeño.

3. Las tareas desarrolladas consistían en: TODO: DESCRIPCIÓN DETALLADA DE TAREAS.

4. La jornada laboral era de TODO: HORAS DIARIAS, de TODO: HORARIO INICIO a TODO: HORARIO FIN.

5. El salario percibido era de $TODO: MONTO MENSUAL, abonándose TODO: FRECUENCIA DE PAGO.

### VULNERACIONES DETECTADAS

1. **Salarios no registrados**: Durante TODO: PERÍODO, el demandado abonó al actor montos inferiores a los establecidos en el Convenio Colectivo aplicable.

2. **Horas extras no abonadas**: El actor trabajó horas extras que no fueron compensadas conforme a la legislación vigente.

3. **Vacaciones no gozadas**: El actor no pudo gozar de las vacaciones correspondientes durante TODO: PERÍODO.

4. **Aguinaldo proporcional**: Al momento de la extinción del vínculo, el demandado no abonó el aguinaldo proporcional correspondiente.

5. **Indemnización por despido**: El actor fue despedido sin causa justificada, correspondiendo las indemnizaciones del art. 232 y 233 de la L.C.T.

## DERECHO

### FUNDAMENTOS LEGALES

1. **Constitución Nacional**: Art. 14 bis - Derecho al trabajo y condiciones dignas de labor.

2. **Ley de Contrato de Trabajo (L.C.T.)**:
   - Art. 80: Definición de relación laboral
   - Art. 232: Indemnización por despido sin causa
   - Art. 233: Indemnización sustitutiva de preaviso
   - Art. 245: Indemnización por falta de preaviso
   - Art. 155: Vacaciones anuales

3. **Convenio Colectivo**: TODO: ESPECIFICAR CONVENIO APLICABLE

4. **Jurisprudencia**: 
   - Corte Suprema: "Vizzoti, Carlos Alberto c/ AMSA S.A. s/ despido" (2004)
   - CSJN: "Aquino, Isacio c/ Cargo Servicios Industriales S.A." (2004)

### CÁLCULO DE PRETENSIONES

**Salarios no registrados**: ${{monto_estimado}}  
**Horas extras**: TODO: CÁLCULO  
**Vacaciones no gozadas**: TODO: CÁLCULO  
**Aguinaldo proporcional**: TODO: CÁLCULO  
**Indemnización art. 232 L.C.T.**: TODO: CÁLCULO  
**Indemnización art. 233 L.C.T.**: TODO: CÁLCULO  
**Indemnización art. 245 L.C.T.**: TODO: CÁLCULO  

**TOTAL ESTIMADO**: ${{monto_estimado}}

## PETITORIO

Por lo expuesto, vengo a solicitar a V.S. tenga a bien:

1. **HACER LUGAR** a la presente demanda laboral formulada contra {{demandado_nombre}}.

2. **CONDENAR** al demandado al pago de las sumas adeudadas por salarios no registrados, horas extras, vacaciones no gozadas, aguinaldo proporcional e indemnizaciones por despido.

3. **CONDENAR** al demandado al pago de los intereses y actualizaciones correspondientes desde la fecha de la extinción del vínculo.

4. **CONDENAR** al demandado al pago de las costas del proceso.

5. **DESIGNAR** perito contador para la liquidación de las sumas adeudadas, de no arribarse a acuerdo entre las partes.

## PRUEBA

Para mejor proveer, ofrezco la siguiente prueba:

### DOCUMENTAL
{{prueba_documental}}

### TESTIMONIAL  
{{testigos}}

### INFORMATIVA
{{oficios}}

## AUTORIZADOS
{{autorizados}}

## RESERVA DE CASO FEDERAL

En caso de que la sentencia que se dicte en autos fuera adversa a los intereses del actor, se reserva el derecho de plantear las cuestiones de constitucionalidad que correspondan ante la Corte Suprema de Justicia de la Nación.

Por lo expuesto, pido a V.S. tenga a bien hacer lugar a la presente demanda y condenar al demandado en los términos solicitados.

Mendoza, TODO: FECHA.

{{actor_nombre}}  
DNI: {{actor_dni}}  
Firma: _________________'
);

-- =============================================================================
-- PLANTILLA: CARTA DOCUMENTO
-- =============================================================================
INSERT INTO templates (id, type, jurisdiction, version, prompt_vars, body_md) VALUES (
    uuid_generate_v4(),
    'carta_documento',
    'Mendoza',
    1,
    '{
        "remitente_nombre": "string",
        "remitente_dni": "string",
        "destinatario_nombre": "string", 
        "destinatario_dni": "string",
        "motivo": "string",
        "plazo_dias": "string",
        "consecuencias": "string"
    }',
    '# CARTA DOCUMENTO

**{{remitente_nombre}}**  
DNI: {{remitente_dni}}  
Domicilio: TODO: COMPLETAR  
Teléfono: TODO: COMPLETAR  
Email: TODO: COMPLETAR  

**A:**

**{{destinatario_nombre}}**  
DNI: {{destinatario_dni}}  
Domicilio: TODO: COMPLETAR  

**ASUNTO**: {{motivo}}

---

**{{destinatario_nombre}}:**

Por la presente, le comunico que:

TODO: DESARROLLAR EL CONTENIDO ESPECÍFICO DE LA CARTA DOCUMENTO

### RECLAMO FORMAL

Le reclamo formalmente:

1. TODO: ESPECIFICAR QUÉ SE RECLAMA
2. TODO: FUNDAMENTAR EL RECLAMO
3. TODO: MENCIONAR NORMAS APLICABLES

### PLAZO Y CONSECUENCIAS

Le otorgo un plazo de **{{plazo_dias}} días** a contar desde la recepción de la presente para que proceda a TODO: ESPECIFICAR ACCIÓN REQUERIDA.

Vencido dicho plazo sin que hubiere cumplido con lo requerido, {{consecuencias}}.

### RESERVA DE DERECHOS

Me reservo el derecho de ejercer todas las acciones legales que me correspondan, tanto en sede administrativa como judicial, incluyendo pero no limitándose a:

- Acción de daños y perjuicios
- Medidas cautelares
- Acciones específicas previstas en la legislación vigente
- Reclamo por los gastos y costas que se generen

### NOTIFICACIÓN

La presente carta documento tiene carácter de notificación fehaciente y surte todos los efectos legales previstos en el Código Civil y Comercial de la Nación.

Mendoza, TODO: FECHA.

{{remitente_nombre}}  
DNI: {{remitente_dni}}  
Firma: _________________'
);

-- =============================================================================
-- PLANTILLA: CONTRATO DE SERVICIOS
-- =============================================================================
INSERT INTO templates (id, type, jurisdiction, version, prompt_vars, body_md) VALUES (
    uuid_generate_v4(),
    'contrato_servicios',
    'Mendoza',
    1,
    '{
        "cliente_nombre": "string",
        "cliente_dni": "string",
        "proveedor_nombre": "string",
        "proveedor_cuit": "string",
        "servicio_descripcion": "string",
        "monto_total": "string",
        "plazo_ejecucion": "string",
        "forma_pago": "string"
    }',
    '# CONTRATO DE PRESTACIÓN DE SERVICIOS

## PARTES

**PRIMERA PARTE - CONTRATANTE:**
{{cliente_nombre}}  
DNI: {{cliente_dni}}  
Domicilio: TODO: COMPLETAR  
Teléfono: TODO: COMPLETAR  
Email: TODO: COMPLETAR  

**SEGUNDA PARTE - CONTRATISTA:**
{{proveedor_nombre}}  
CUIT: {{proveedor_cuit}}  
Domicilio: TODO: COMPLETAR  
Teléfono: TODO: COMPLETAR  
Email: TODO: COMPLETAR  

## OBJETO DEL CONTRATO

Las partes convienen en celebrar el presente contrato de prestación de servicios profesionales, mediante el cual la SEGUNDA PARTE se compromete a prestar a la PRIMERA PARTE los siguientes servicios:

{{servicio_descripcion}}

### ESPECIFICACIONES TÉCNICAS

TODO: DETALLAR ESPECIFICACIONES TÉCNICAS DEL SERVICIO

## OBLIGACIONES DEL CONTRATISTA

La SEGUNDA PARTE se compromete a:

1. Ejecutar los servicios objeto del presente contrato con la mayor diligencia y profesionalismo.

2. Cumplir con los plazos establecidos en el presente acuerdo.

3. Entregar toda la documentación técnica y administrativa que resulte necesaria.

4. Mantener la confidencialidad sobre toda la información que tome conocimiento en el marco de la prestación del servicio.

5. Cumplir con todas las normativas vigentes aplicables a la actividad.

6. Responder por los daños que pueda ocasionar por su culpa o negligencia en la ejecución del servicio.

## OBLIGACIONES DEL CONTRATANTE

La PRIMERA PARTE se compromete a:

1. Proporcionar toda la información necesaria para la correcta ejecución del servicio.

2. Facilitar el acceso a las instalaciones, equipos y personal que resulte necesario.

3. Realizar los pagos en los términos y condiciones establecidos en el presente contrato.

4. Colaborar activamente para el cumplimiento de los objetivos del servicio.

## PRECIO Y FORMA DE PAGO

### MONTO TOTAL
El precio total del servicio es de **${{monto_total}}** (TODO: ESPECIFICAR MONEDA).

### FORMA DE PAGO
{{forma_pago}}

TODO: DETALLAR CRONOGRAMA DE PAGOS SI CORRESPONDE

## PLAZO DE EJECUCIÓN

El servicio deberá ser ejecutado en un plazo de **{{plazo_ejecucion}}** a contar desde la firma del presente contrato.

TODO: ESPECIFICAR FECHAS LÍMITE PARCIALES SI CORRESPONDE

## MODALIDAD DE TRABAJO

TODO: ESPECIFICAR SI ES PRESENCIAL, REMOTO O MIXTO

## CONFIDENCIALIDAD

Las partes se comprometen a mantener la más estricta confidencialidad sobre toda la información que tomen conocimiento en el marco del presente contrato, no pudiendo divulgarla a terceros sin autorización expresa y por escrito.

## PROPIEDAD INTELECTUAL

TODO: ESPECIFICAR QUÉ PASA CON LOS DERECHOS DE PROPIEDAD INTELECTUAL DE LOS TRABAJOS REALIZADOS

## RESCISIÓN

El presente contrato podrá ser rescindido:

1. Por mutuo acuerdo entre las partes.
2. Por incumplimiento de cualquiera de las obligaciones aquí establecidas, previo requerimiento de cumplimiento con un plazo de TODO: ESPECIFICAR días.
3. Por imposibilidad sobreviniente de cumplimiento.

## RESOLUCIÓN DE CONTROVERSIAS

Las controversias que pudieran suscitarse serán resueltas en primera instancia por mediación, y en caso de no arribarse a acuerdo, por los Tribunales Ordinarios de la Ciudad de Mendoza.

## JURISDICCIÓN

Las partes se someten a la jurisdicción de los Tribunales Ordinarios de la Ciudad de Mendoza, renunciando a cualquier otro fuero que pudiera corresponderles.

## APROBACIÓN

El presente contrato se aprueba en TODO: CANTIDAD de ejemplares de un mismo tenor y a un solo efecto, firmando las partes al pie de cada una de ellas.

Mendoza, TODO: FECHA.

**CONTRATANTE**  
{{cliente_nombre}}  
DNI: {{cliente_dni}}  
Firma: _________________

**CONTRATISTA**  
{{proveedor_nombre}}  
CUIT: {{proveedor_cuit}}  
Firma: _________________

**TESTIGOS**  
TODO: COMPLETAR SI ES NECESARIO

**TESTIGO 1:** _________________ DNI: ___________  
**TESTIGO 2:** _________________ DNI: ___________'
);

-- =============================================================================
-- PLANTILLA: ESCRITO DE PRESENTACIÓN
-- =============================================================================
INSERT INTO templates (id, type, jurisdiction, version, prompt_vars, body_md) VALUES (
    uuid_generate_v4(),
    'escrito_presentacion',
    'Mendoza',
    1,
    '{
        "actor_nombre": "string",
        "actor_dni": "string",
        "demandado_nombre": "string",
        "demandado_cuit": "string",
        "tipo_proceso": "string",
        "juzgado": "string",
        "materia": "string",
        "petitorio": "string"
    }',
    '# ESCRITO DE PRESENTACIÓN

**{{actor_nombre}}**  
DNI: {{actor_dni}}  
Domicilio: TODO: COMPLETAR  
Teléfono: TODO: COMPLETAR  
Email: TODO: COMPLETAR  

**EN CONTRA DE:**

**{{demandado_nombre}}**  
{{demandado_cuit}}  
Domicilio: TODO: COMPLETAR  

**ANTE SU SEÑORÍA JUEZ DE {{juzgado}}**

## PERSONERÍA Y COMPETENCIA

El actor, {{actor_nombre}}, DNI {{actor_dni}}, comparece por derecho propio y en carácter de parte interesada, a los efectos de formular la presente {{tipo_proceso}} contra {{demandado_nombre}}, {{demandado_cuit}}, por las causales que se exponen en el cuerpo de la presente.

Vengo a peticionar ante V.S. en los términos del art. TODO: ESPECIFICAR NORMATIVA APLICABLE, en razón de encontrarse radicado el domicilio del demandado en esta ciudad de Mendoza, lo que determina la competencia territorial de este Juzgado.

## HECHOS

### ANTECEDENTES

TODO: DESARROLLAR LOS ANTECEDENTES DEL CASO

### HECHOS CONSTITUTIVOS

1. TODO: DESCRIBIR HECHO 1

2. TODO: DESCRIBIR HECHO 2

3. TODO: DESCRIBIR HECHO 3

### VULNERACIONES

TODO: DETALLAR QUÉ DERECHOS HAN SIDO VULNERADOS Y CÓMO

## DERECHO

### FUNDAMENTOS LEGALES

1. **Constitución Nacional**: TODO: ARTÍCULOS APLICABLES

2. **Código Civil y Comercial de la Nación**:
   - Art. TODO: ARTÍCULOS APLICABLES
   - Art. TODO: ARTÍCULOS APLICABLES

3. **Legislación Específica**: TODO: NORMAS ESPECÍFICAS APLICABLES

4. **Jurisprudencia**:
   - TODO: FALLOS APLICABLES
   - TODO: PRECEDENTES RELEVANTES

### ANÁLISIS DE LA CUESTIÓN

TODO: REALIZAR ANÁLISIS JURÍDICO DEL CASO

## PETITORIO

Por lo expuesto, vengo a solicitar a V.S. tenga a bien:

{{petitorio}}

## PRUEBA

Para mejor proveer, ofrezco la siguiente prueba:

### DOCUMENTAL

1. TODO: ESPECIFICAR DOCUMENTOS A OFRECER

2. TODO: ESPECIFICAR DOCUMENTOS A OFRECER

3. TODO: ESPECIFICAR DOCUMENTOS A OFRECER

### TESTIMONIAL

TODO: ESPECIFICAR TESTIGOS SI LOS HAY

### INFORMATIVA

TODO: ESPECIFICAR OFICIOS SI LOS HAY

### PERICIAL

TODO: ESPECIFICAR PERICIAS SI SON NECESARIAS

## AUTORIZADOS

TODO: COMPLETAR SI CORRESPONDE

## RESERVA DE CASO FEDERAL

En caso de que la sentencia que se dicte en autos fuera adversa a los intereses del actor, se reserva el derecho de plantear las cuestiones de constitucionalidad que correspondan ante la Corte Suprema de Justicia de la Nación.

## COSTAS

Solicito que se condenen en costas a la parte vencida.

Por lo expuesto, pido a V.S. tenga a bien hacer lugar a la presente {{tipo_proceso}} y condenar al demandado en los términos solicitados.

Mendoza, TODO: FECHA.

{{actor_nombre}}  
DNI: {{actor_dni}}  
Firma: _________________'
);

-- =============================================================================
-- COMENTARIOS FINALES
-- =============================================================================

-- Verificar que las plantillas se insertaron correctamente
SELECT 
    type,
    jurisdiction,
    version,
    jsonb_object_keys(prompt_vars) as variables_disponibles
FROM templates 
WHERE jurisdiction = 'Mendoza'
ORDER BY type, version;

COMMENT ON TABLE templates IS 'Plantillas de documentos legales para redacción automatizada';