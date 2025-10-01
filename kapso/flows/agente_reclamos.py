"""
Agente Especialista en Reclamos - Kapso Flow
Maneja la captura estructurada de datos para reclamos
"""

from kapso.builder.nodes import (
    Flow,
    AgentNode,
    FlowAgentWebhook,
    SendTextNode,
    add_edge
)

def create_agente_reclamos():
    """
    Crea el flujo especializado para manejo de reclamos
    """
    
    # Crear el flujo de reclamos
    flow = Flow(
        name="agente_reclamos",
        description="Especialista en captura y procesamiento de reclamos"
    )
    
    # Agente especialista en reclamos
    reclamos_specialist = AgentNode(
        name="reclamos_specialist",
        model="claude-sonnet-4-20250514",
        system_prompt="""Eres un especialista en atención al cliente para reclamos. Tu objetivo es capturar TODA la información necesaria para procesar el reclamo de manera eficiente.

INFORMACIÓN OBLIGATORIA A CAPTURAR:
1. **Nombre completo** del cliente
2. **Email** de contacto  
3. **Producto** específico (nombre, modelo, código si lo tiene)
4. **Motivo** del reclamo (defecto, mal funcionamiento, etc.)
5. **Descripción detallada** del problema

INSTRUCCIONES:
- Sé empático y profesional en todo momento
- Haz preguntas específicas para obtener información completa
- NO proceses el reclamo hasta tener TODOS los datos obligatorios
- Confirma cada dato importante con el cliente
- Si falta información, pregunta de manera amigable

EJEMPLO DE INTERACCIÓN:
Cliente: "Mi producto llegó roto"
Tú: "Lamento mucho escuchar eso. Para ayudarte de la mejor manera, necesito algunos datos:

¿Podrías proporcionarme tu nombre completo?"

Una vez que tengas TODA la información obligatoria, confirma los datos y procede a guardar el reclamo.

FORMATO DE CONFIRMACIÓN:
"Perfecto, he registrado tu reclamo con los siguientes datos:
- Nombre: [nombre]
- Email: [email] 
- Producto: [producto]
- Motivo: [motivo]
- Descripción: [descripción]

¿Es correcta toda esta información? Si confirmas, procederé a crear tu ticket de reclamo."

IMPORTANTE: Solo cuando el cliente confirme, envía los datos para procesamiento.""",
        max_iterations=10,
        description="Agente que captura información completa de reclamos"
    )
    
    # Webhook para enviar datos a n8n
    save_reclamo = FlowAgentWebhook(
        name="save_reclamo",
        # URL del webhook de n8n - CRÍTICO para la integración
        webhook_url="https://your-n8n-instance.com/webhook/reclamos-processor",
        method="POST",
        headers={
            "Content-Type": "application/json",
            "Authorization": "Bearer {{env.N8N_WEBHOOK_TOKEN}}"  # Token opcional para seguridad
        },
        payload_template={
            "timestamp": "{{current_timestamp}}",
            "source": "kapso_whatsapp",
            "reclamo_data": {
                "nombre": "{{agent_data.nombre}}",
                "email": "{{agent_data.email}}",
                "producto": "{{agent_data.producto}}",
                "motivo": "{{agent_data.motivo}}",
                "descripcion": "{{agent_data.descripcion}}",
                "conversation_id": "{{conversation.id}}",
                "user_phone": "{{user.phone}}"
            }
        },
        description="Envía datos del reclamo a n8n para procesamiento"
    )
    
    # Confirmación exitosa con ID del ticket
    confirmacion_exitosa = SendTextNode(
        name="confirmacion_exitosa",
        text="""✅ **¡Reclamo registrado exitosamente!**

Tu ticket de reclamo ha sido creado con el ID: **{{agent_response.reclamo_id}}**

📧 **Próximos pasos:**
• Recibirás un email de confirmación en los próximos minutos
• Nuestro equipo revisará tu caso en un plazo máximo de 24 horas
• Te contactaremos para informarte sobre la resolución

📞 **¿Necesitas ayuda adicional?**
Puedes contactarnos mencionando tu ticket ID: {{agent_response.reclamo_id}}

¡Gracias por contactarnos y disculpa las molestias ocasionadas!""",
        description="Confirma el registro exitoso del reclamo"
    )
    
    # Agregar nodos al flujo
    flow.add_node(reclamos_specialist)
    flow.add_node(save_reclamo)
    flow.add_node(confirmacion_exitosa)
    
    # Definir conexiones
    add_edge(flow, reclamos_specialist, save_reclamo)
    add_edge(flow, save_reclamo, confirmacion_exitosa)
    
    return flow

def create_agente_devoluciones():
    """
    Crea el flujo para manejo de devoluciones
    """
    
    flow = Flow(
        name="agente_devoluciones", 
        description="Especialista en devoluciones y reembolsos"
    )
    
    devoluciones_specialist = AgentNode(
        name="devoluciones_specialist",
        model="claude-sonnet-4-20250514",
        system_prompt="""Eres un especialista en devoluciones y reembolsos. Tu objetivo es ayudar al cliente con su solicitud de devolución.

INFORMACIÓN A CAPTURAR:
1. **Nombre completo**
2. **Email** 
3. **Número de orden** o comprobante
4. **Producto** a devolver
5. **Motivo** de la devolución
6. **Estado** del producto (nuevo, usado, defectuoso)

POLÍTICA DE DEVOLUCIONES:
- 30 días desde la compra
- Producto en condiciones originales
- Comprobante de compra requerido

Sé amable y explica claramente el proceso de devolución."""
    )
    
    save_devolucion = FlowAgentWebhook(
        name="save_devolucion",
        webhook_url="https://your-n8n-instance.com/webhook/devoluciones-processor",
        method="POST",
        payload_template={
            "tipo": "devolucion",
            "data": "{{agent_data}}"
        }
    )
    
    confirmacion_devolucion = SendTextNode(
        name="confirmacion_devolucion",
        text="✅ Solicitud de devolución registrada. ID: {{agent_response.devolucion_id}}"
    )
    
    flow.add_node(devoluciones_specialist)
    flow.add_node(save_devolucion)
    flow.add_node(confirmacion_devolucion)
    
    add_edge(flow, devoluciones_specialist, save_devolucion)
    add_edge(flow, save_devolucion, confirmacion_devolucion)
    
    return flow

def create_agente_consultas():
    """
    Crea el flujo para consultas generales
    """
    
    flow = Flow(
        name="agente_consultas",
        description="Especialista en consultas generales"
    )
    
    consultas_specialist = AgentNode(
        name="consultas_specialist", 
        model="claude-3-5-sonnet-20241022",
        system_prompt="""Eres un asistente de soporte general. Ayuda con consultas sobre productos, servicios y información general.

CAPACIDADES:
- Información de productos
- Guías de uso básicas  
- Horarios y contactos
- Políticas de la empresa

Si la consulta requiere soporte técnico avanzado, deriva al cliente al equipo especializado."""
    )
    
    respuesta_consulta = SendTextNode(
        name="respuesta_consulta",
        text="{{agent_response.respuesta}}\n\n¿Hay algo más en lo que pueda ayudarte?"
    )
    
    flow.add_node(consultas_specialist)
    flow.add_node(respuesta_consulta)
    
    add_edge(flow, consultas_specialist, respuesta_consulta)
    
    return flow

if __name__ == "__main__":
    # Crear todos los flujos especializados
    reclamos_flow = create_agente_reclamos()
    devoluciones_flow = create_agente_devoluciones()
    consultas_flow = create_agente_consultas()
    
    print("✅ Flujos de agentes especializados creados:")
    print(f"- Reclamos: {len(reclamos_flow.nodes)} nodos")
    print(f"- Devoluciones: {len(devoluciones_flow.nodes)} nodos") 
    print(f"- Consultas: {len(consultas_flow.nodes)} nodos")