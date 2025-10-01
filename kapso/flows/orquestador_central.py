"""
Orquestador Central - Kapso Flow
Sistema de soporte WhatsApp que clasifica y dirige conversaciones
"""

from kapso.builder.nodes import (
    Flow, 
    StartNode, 
    SendTextNode, 
    WaitNode, 
    DecideNode,
    add_edge
)

def create_orquestador_central():
    """
    Crea el flujo principal que maneja la conversación inicial y clasificación
    """
    
    # Crear el flujo principal
    flow = Flow(
        name="orquestador_central",
        description="Orquestador principal para soporte WhatsApp"
    )
    
    # Nodo de inicio
    start_orquestador = StartNode(
        name="start_orquestador",
        description="Punto de entrada del sistema"
    )
    
    # Saludo inicial
    saludo_inicial = SendTextNode(
        name="saludo_inicial",
        text="""¡Hola! 👋 Bienvenido al soporte de nuestra empresa.

Estoy aquí para ayudarte con:
• 📋 Reclamos y quejas
• 🔄 Devoluciones de productos  
• ❓ Consultas generales

Por favor, describe brevemente tu solicitud y te dirigiré con el especialista adecuado."""
    )
    
    # Esperar respuesta del usuario
    wait_solicitud = WaitNode(
        name="wait_solicitud",
        description="Espera la descripción inicial del usuario"
    )
    
    # Nodo de clasificación usando Claude Sonnet
    clasificar_tipo_caso = DecideNode(
        name="clasificar_tipo_caso",
        model="claude-3-5-sonnet-20241022",
        system_prompt="""Eres un clasificador experto de casos de soporte al cliente.

Analiza el mensaje del usuario y clasifica en una de estas categorías:

1. **reclamo**: Quejas, problemas con productos/servicios, insatisfacción, errores, fallos
2. **devolucion**: Solicitudes de devolución, reembolsos, cambios de producto
3. **consulta**: Preguntas generales, información sobre productos, dudas, soporte técnico básico

IMPORTANTE: 
- Responde SOLO con una palabra: "reclamo", "devolucion" o "consulta"
- No agregues explicaciones adicionales
- Si no estás seguro, clasifica como "consulta"

Ejemplos:
- "El producto llegó defectuoso" → reclamo
- "Quiero devolver mi compra" → devolucion  
- "¿Cómo funciona este producto?" → consulta""",
        conditions={
            "reclamo": "reclamo",
            "devolucion": "devolucion", 
            "consulta": "consulta"
        }
    )
    
    # Agregar nodos al flujo
    flow.add_node(start_orquestador)
    flow.add_node(saludo_inicial)
    flow.add_node(wait_solicitud)
    flow.add_node(clasificar_tipo_caso)
    
    # Definir conexiones
    add_edge(flow, start_orquestador, saludo_inicial)
    add_edge(flow, saludo_inicial, wait_solicitud)
    add_edge(flow, wait_solicitud, clasificar_tipo_caso)
    
    return flow

if __name__ == "__main__":
    # Crear y registrar el flujo
    orquestador_flow = create_orquestador_central()
    print("✅ Flujo Orquestador Central creado exitosamente")
    print(f"Nodos: {len(orquestador_flow.nodes)}")
    print(f"Conexiones: {len(orquestador_flow.edges)}")