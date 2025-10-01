"""
Flujo Principal - Integración completa del sistema
Conecta el orquestador con los agentes especializados
"""

from kapso.builder.nodes import Flow, add_edge
from orquestador_central import create_orquestador_central
from agente_reclamos import (
    create_agente_reclamos,
    create_agente_devoluciones, 
    create_agente_consultas
)

def create_main_sistema_soporte():
    """
    Crea el sistema completo integrando todos los flujos
    """
    
    # Crear flujo principal
    main_flow = Flow(
        name="sistema_soporte_whatsapp",
        description="Sistema completo de soporte WhatsApp con Kapso y n8n"
    )
    
    # Obtener flujos individuales
    orquestador = create_orquestador_central()
    agente_reclamos = create_agente_reclamos()
    agente_devoluciones = create_agente_devoluciones()
    agente_consultas = create_agente_consultas()
    
    # Integrar todos los nodos en el flujo principal
    for flow in [orquestador, agente_reclamos, agente_devoluciones, agente_consultas]:
        for node in flow.nodes:
            main_flow.add_node(node)
        for edge in flow.edges:
            main_flow.add_edge(edge)
    
    # Conectar el clasificador con los agentes especializados
    clasificador = orquestador.get_node("clasificar_tipo_caso")
    
    # Conexiones basadas en clasificación
    add_edge(
        main_flow,
        clasificador,
        agente_reclamos.get_node("reclamos_specialist"),
        condition="reclamo"
    )
    
    add_edge(
        main_flow,
        clasificador,
        agente_devoluciones.get_node("devoluciones_specialist"), 
        condition="devolucion"
    )
    
    add_edge(
        main_flow,
        clasificador,
        agente_consultas.get_node("consultas_specialist"),
        condition="consulta"
    )
    
    return main_flow

def deploy_sistema():
    """
    Despliega el sistema completo en Kapso
    """
    
    sistema = create_main_sistema_soporte()
    
    # Configuración de despliegue
    deployment_config = {
        "name": "soporte-whatsapp-mvp",
        "version": "1.0.0",
        "environment": "production",
        "webhook_base_url": "https://your-n8n-instance.com/webhook/",
        "models": {
            "clasificador": "claude-3-5-sonnet-20241022",
            "especialistas": "claude-sonnet-4-20250514"
        },
        "integrations": {
            "n8n": {
                "base_url": "https://your-n8n-instance.com",
                "endpoints": {
                    "reclamos": "/webhook/reclamos-processor",
                    "devoluciones": "/webhook/devoluciones-processor"
                }
            },
            "whatsapp": {
                "provider": "twilio",  # o el proveedor que uses
                "webhook_url": "/whatsapp/incoming"
            }
        }
    }
    
    print("🚀 Desplegando sistema de soporte WhatsApp...")
    print(f"Flujo principal: {sistema.name}")
    print(f"Total de nodos: {len(sistema.nodes)}")
    print(f"Total de conexiones: {len(sistema.edges)}")
    print("\n📋 Configuración:")
    for key, value in deployment_config.items():
        print(f"  {key}: {value}")
    
    return sistema, deployment_config

if __name__ == "__main__":
    sistema, config = deploy_sistema()
    print("\n✅ Sistema listo para despliegue en Dokploy")