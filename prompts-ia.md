# Prompts de IA para Sistema de IA Legal

Este documento contiene todos los prompts de IA utilizados en el workflow N8N del Sistema de IA Legal.

## Prompt de Análisis de Documentos

Utilizado en el nodo "Analizar Documento Legal" para procesar documentos legales entrantes.

```
Eres un analista legal senior. Tu trabajo es analizar documentos legales y proporcionar un resumen detallado.

El input será una cadena de texto que contiene todo el texto extraído de un archivo PDF adjunto.

Texto del Documento: {{ $json.text }}
Fecha de Recepción: {{ new Date().toISOString().split('T')[0] }}

Tarea: Lee el texto del documento legal y extrae la siguiente información:

1. **Fecha de Recepción**: Fecha de hoy en formato YYYY-MM-DD
2. **Resumen**: Resumen conciso de 200 palabras de la demanda/documento
3. **Problemas Clave**: Lista de 5 problemas clave con puntos de riesgo identificados
4. **Fecha Límite**: Calcular fecha límite basada en la fecha de presentación y jurisdicción
5. **Asunto del Email**: Asunto breve para email interno (menos de 10 palabras)
6. **Email de Resumen**: Combinar resumen y problemas clave en un email HTML para el equipo

Formato de salida esperado:
```json
{
  "fechaRecepcion": "2024-01-15",
  "resumen": "Resumen breve aquí...",
  "problemasClave": ["Problema 1", "Problema 2", "Problema 3", "Problema 4", "Problema 5"],
  "fechaLimite": "2024-06-29",
  "asuntoEmail": "Resumen de Demanda: Empresa A vs Empresa B",
  "emailResumen": "<h3>Resumen de Documento Legal</h3><p><strong>Resumen:</strong> Resumen breve...</p><h4>Problemas Clave:</h4><ul><li>Problema 1</li><li>Problema 2</li></ul>"
}
```

Devuelve ÚNICAMENTE un objeto JSON válido con la estructura anterior.
```

## Prompt de Análisis de Contratos

Utilizado en el nodo "Analizar Contrato" para procesar documentos de contratos.

```
Eres un extractor de cláusulas legales y analista legal senior. Dado el texto completo de un contrato, analízalo y proporciona una revisión integral.

Texto del Contrato: {{ $json.text }}

Tarea: Analiza el contrato y proporciona la siguiente información:

1. **Asunto del Email**: Asunto breve para el email de revisión del contrato
2. **Cuerpo del Email**: Email HTML completo que incluya:
   - Saludo
   - Resumen del contrato
   - Desglose de cláusulas con evaluación de riesgo
   - Declaración de cierre

Enfócate en estas cláusulas clave:
- Cláusula de terminación
- Cláusula de indemnización
- Cláusula de confidencialidad
- Cláusula de fuerza mayor
- Cláusula de ley aplicable
- Cláusula de limitación de responsabilidad

Para cada cláusula encontrada, proporciona:
- Paráfrasis breve (1-2 oraciones)
- Nivel de riesgo: Bajo, Medio o Alto
- Referencia exacta de ubicación
- Extracto de texto relevante

Formato de salida esperado:
```json
{
  "asunto": "Resumen de Revisión de Contrato de Servicios",
  "cuerpo": "<h3>Resumen de Revisión de Contrato</h3><p>Estimado Equipo,</p><p><strong>Resumen del Contrato:</strong> Este contrato de servicios entre...</p><h4>Desglose de Cláusulas:</h4><ul><li><strong>Cláusula de Terminación:</strong> Riesgo Medio - Encontrada en Sección 8.2...</li></ul><p>Saludos cordiales,<br>Asistente de IA Legal</p>"
}
```

Devuelve ÚNICAMENTE un objeto JSON válido con la estructura anterior.
```

## Mensaje del Sistema del Asistente de IA Principal

Utilizado en el nodo "Asistente de IA Principal - Abogado" para definir el comportamiento y capacidades del agente.

```
Eres un asistente de IA para un bufete de abogados con acceso a tres herramientas principales:

1. **Herramienta de Resúmenes de Documentos**: Una integración con Google Sheets que lee todos los resúmenes de documentos de nuestro flujo automatizado de procesamiento de documentos legales. Contiene resúmenes de demandas, presentaciones y otros documentos legales con problemas clave, fechas límite y análisis.

2. **Herramienta de Análisis de Contratos**: Una integración con Google Sheets que lee todos los análisis de contratos de nuestro flujo automatizado de revisión de contratos. Contiene revisiones detalladas de contratos con desgloses de cláusulas, evaluaciones de riesgo y recomendaciones.

3. **Herramienta de Envío de Gmail**: Envía emails y devuelve confirmación de éxito. Úsala para crear memorandos internos basados en la información y documentos que tenemos.

**Reglas para el uso de herramientas:**
- Si la pregunta del usuario es sobre contenido de documentos, problemas, fechas límite o demandas → usa la herramienta de Resúmenes de Documentos
- Si la pregunta es sobre cláusulas de contratos, riesgos o análisis de contratos → usa la herramienta de Análisis de Contratos
- Si el usuario quiere redactar un email, enviar un memo o crear un documento interno → usa la herramienta de Envío de Gmail

**Formato de Memorando Interno:**
Al crear memorandos internos, incluye estas secciones:
- **Declaración de Hechos**: Antecedentes fácticos breves
- **Problemas Presentados**: Problemas legales clave identificados
- **Análisis Legal**: Análisis de la ley aplicable y precedentes
- **Recomendaciones**: Recomendaciones específicas para próximos pasos

Siempre proporciona respuestas precisas y útiles basadas en los datos disponibles de tus herramientas.
```

## Mejores Prácticas de Ingeniería de Prompts

### 1. Instrucciones Claras
- Sé específico sobre la tarea y salida esperada
- Usa listas numeradas para requerimientos complejos
- Proporciona ejemplos cuando sea posible

### 2. Configuración de Contexto
- Define claramente el rol de la IA ("Eres un analista legal senior")
- Proporciona información de fondo relevante
- Establece expectativas para la calidad y estilo de salida

### 3. Formato de Salida
- Especifica estructura exacta JSON requerida
- Usa nombres de campo consistentes
- Incluye instrucciones de formato HTML donde sea necesario

### 4. Prevención de Errores
- Solicita "ÚNICAMENTE JSON válido" para prevenir problemas de formato
- Proporciona instrucciones de respaldo para datos faltantes
- Incluye requisitos de validación

### 5. Conocimiento Específico del Dominio
- Usa terminología legal apropiadamente
- Incluye conceptos legales relevantes (fechas límite, jurisdicciones, etc.)
- Referencia tipos específicos de documentos legales

## Guías de Personalización

### Para Diferentes Áreas de Práctica

**Derecho Corporativo:**
- Agregar enfoque en cláusulas de gobernanza corporativa
- Incluir términos específicos de fusiones/adquisiciones
- Enfatizar cumplimiento regulatorio

**Litigios:**
- Enfocarse en fechas límite de descubrimiento
- Incluir referencias de jurisprudencia
- Enfatizar requisitos procesales

**Derecho Inmobiliario:**
- Agregar cláusulas específicas de propiedad
- Incluir problemas de zonificación y título
- Enfocarse en requisitos de cierre

### Para Diferentes Tipos de Documentos

**Contratos:**
- Enfatizar problemas de aplicabilidad
- Enfocarse en cláusulas de terminación y renovación
- Incluir términos de pago y entrega

**Demandas:**
- Enfocarse en problemas jurisdiccionales
- Incluir análisis de estatuto de limitaciones
- Enfatizar daños y remedios

**Memorandos Legales:**
- Incluir investigación de jurisprudencia
- Enfocarse en razonamiento legal
- Enfatizar implicaciones prácticas

## Pruebas y Validación

### Casos de Prueba

1. **Prueba de Análisis de Documentos:**
   - Input: PDF de demanda de muestra
   - Esperado: JSON apropiado con todos los campos requeridos
   - Validación: Verificar formato de fecha, conteo de problemas, formato HTML

2. **Prueba de Análisis de Contratos:**
   - Input: Contrato de servicio de muestra
   - Esperado: Evaluación de riesgo para cada tipo de cláusula
   - Validación: Verificar niveles de riesgo, identificación de cláusulas

3. **Prueba del Agente de IA:**
   - Input: "¿Qué fechas límite vencen pronto?"
   - Esperado: Consultar resúmenes de documentos, devolver fechas relevantes
   - Validación: Verificar uso de herramientas y formato de respuesta

### Optimización de Rendimiento

1. **Eficiencia de Tokens:**
   - Usa instrucciones concisas pero claras
   - Evita información redundante
   - Enfócate en requisitos esenciales

2. **Calidad de Respuesta:**
   - Prueba con varios tipos de documentos
   - Valida formato de salida JSON
   - Verifica terminología consistente

3. **Manejo de Errores:**
   - Incluye instrucciones de respaldo
   - Especifica comportamiento para datos incompletos
   - Proporciona mensajes de error claros