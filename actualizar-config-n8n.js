/**
 * Script de Actualización de Configuración N8N
 * Actualiza el workflow JSON de N8N con los IDs correctos de las variables de entorno
 * Este script configura automáticamente el workflow con tus IDs específicos de Google Sheets y carpetas de Drive
 */

const fs = require('fs');
const path = require('path');
require('dotenv').config();

class ActualizadorConfigN8N {
  constructor() {
    this.rutaWorkflow = path.join(__dirname, 'sistema-ia-legal-n8n-workflow.json');
    this.datosWorkflow = null;
  }

  async actualizarConfiguracion() {
    try {
      console.log('🔄 Actualizando configuración del workflow N8N...');
      
      // Cargar el workflow JSON
      await this.cargarWorkflow();
      
      // Validar variables de entorno
      this.validarVariablesEntorno();
      
      // Actualizar el workflow con IDs reales
      await this.actualizarDatosWorkflow();
      
      // Guardar el workflow actualizado
      await this.guardarWorkflow();
      
      console.log('✅ Configuración del workflow N8N actualizada exitosamente!');
      this.mostrarResumenConfiguracion();
      
    } catch (error) {
      console.error('❌ Falló la actualización del workflow N8N:', error.message);
      process.exit(1);
    }
  }

  async cargarWorkflow() {
    try {
      if (!fs.existsSync(this.rutaWorkflow)) {
        throw new Error(`Archivo de workflow no encontrado: ${this.rutaWorkflow}`);
      }
      
      const contenidoWorkflow = fs.readFileSync(this.rutaWorkflow, 'utf8');
      this.datosWorkflow = JSON.parse(contenidoWorkflow);
      
      console.log('📁 Archivo JSON del workflow cargado');
      
    } catch (error) {
      throw new Error(`Falló la carga del archivo de workflow: ${error.message}`);
    }
  }

  validarVariablesEntorno() {
    console.log('🔍 Validando variables de entorno...');
    
    const variablesRequeridas = [
      'HOJA_RESUMENES_LEGALES_ID',
      'HOJA_ANALISIS_CONTRATOS_ID',
      'CARPETA_DEMANDAS_CONTRATOS_ID',
      'CARPETA_ANALISIS_CONTRATOS_ID',
      'EQUIPO_LEGAL_EMAIL'
    ];
    
    const variablesFaltantes = variablesRequeridas.filter(nombreVar => !process.env[nombreVar]);
    
    if (variablesFaltantes.length > 0) {
      console.warn('⚠️  Variables de entorno faltantes:', variablesFaltantes.join(', '));
      console.warn('Por favor ejecuta los scripts de configuración primero para generar estos IDs');
      
      // Usar valores de marcador para variables faltantes
      variablesFaltantes.forEach(nombreVar => {
        process.env[nombreVar] = `${nombreVar.toLowerCase().replace(/_/g, '-')}-marcador`;
      });
    }
    
    console.log('✅ Variables de entorno validadas');
  }

  async actualizarDatosWorkflow() {
    console.log('🔧 Actualizando datos del workflow...');
    
    // Definir configuraciones de mapeo
    const mapeos = {
      idsHojas: {
        'hoja-resumenes-legales-id': process.env.HOJA_RESUMENES_LEGALES_ID,
        'hoja-analisis-contratos-id': process.env.HOJA_ANALISIS_CONTRATOS_ID
      },
      idsCarpetas: {
        'carpeta-demandas-contratos-id': process.env.CARPETA_DEMANDAS_CONTRATOS_ID,
        'carpeta-analisis-contratos-id': process.env.CARPETA_ANALISIS_CONTRATOS_ID
      },
      emails: {
        'equipo-legal@tuempresa.com': process.env.EQUIPO_LEGAL_EMAIL
      }
    };
    
    // Actualizar cada nodo en el workflow
    this.datosWorkflow.nodes.forEach((nodo, indice) => {
      this.actualizarParametrosNodo(nodo, mapeos, indice);
    });
    
    console.log('✅ Datos del workflow actualizados');
  }

  actualizarParametrosNodo(nodo, mapeos, indiceNodo) {
    if (!nodo.parameters) return;
    
    // Actualizar IDs de documentos de Google Sheets
    if (nodo.parameters.documentId) {
      const marcador = nodo.parameters.documentId.value;
      if (mapeos.idsHojas[marcador]) {
        nodo.parameters.documentId.value = mapeos.idsHojas[marcador];
        console.log(`  📊 Actualizado ID de hoja en nodo "${nodo.name}": ${marcador} → ${mapeos.idsHojas[marcador]}`);
      }
    }
    
    // Actualizar IDs de carpetas de Google Drive
    if (nodo.parameters.folderId) {
      const marcador = nodo.parameters.folderId.value;
      if (mapeos.idsCarpetas[marcador]) {
        nodo.parameters.folderId.value = mapeos.idsCarpetas[marcador];
        console.log(`  📁 Actualizado ID de carpeta en nodo "${nodo.name}": ${marcador} → ${mapeos.idsCarpetas[marcador]}`);
      }
    }
    
    // Actualizar direcciones de email
    if (nodo.parameters.toEmail) {
      const marcador = nodo.parameters.toEmail;
      if (mapeos.emails[marcador]) {
        nodo.parameters.toEmail = mapeos.emails[marcador];
        console.log(`  📧 Actualizado email en nodo "${nodo.name}": ${marcador} → ${mapeos.emails[marcador]}`);
      }
    }
    
    // Actualizar otros parámetros relacionados con email
    if (nodo.parameters.subject && typeof nodo.parameters.subject === 'string') {
      Object.keys(mapeos.emails).forEach(marcador => {
        if (nodo.parameters.subject.includes(marcador)) {
          nodo.parameters.subject = nodo.parameters.subject.replace(marcador, mapeos.emails[marcador]);
          console.log(`  📧 Actualizada referencia de email en asunto del nodo "${nodo.name}"`);
        }
      });
    }
  }

  async guardarWorkflow() {
    try {
      const contenidoActualizado = JSON.stringify(this.datosWorkflow, null, 2);
      fs.writeFileSync(this.rutaWorkflow, contenidoActualizado);
      
      console.log('💾 Workflow actualizado guardado en archivo');
      
    } catch (error) {
      throw new Error(`Falló el guardado del archivo de workflow: ${error.message}`);
    }
  }

  mostrarResumenConfiguracion() {
    console.log('\n📋 RESUMEN DE CONFIGURACIÓN');
    console.log('='.repeat(50));
    console.log('📊 Google Sheets:');
    console.log(`  Resúmenes Legales: ${process.env.HOJA_RESUMENES_LEGALES_ID}`);
    console.log(`  Análisis de Contratos: ${process.env.HOJA_ANALISIS_CONTRATOS_ID}`);
    console.log('📁 Carpetas de Google Drive:');
    console.log(`  Demandas y Contratos: ${process.env.CARPETA_DEMANDAS_CONTRATOS_ID}`);
    console.log(`  Análisis de Contratos: ${process.env.CARPETA_ANALISIS_CONTRATOS_ID}`);
    console.log('📧 Configuración de Email:');
    console.log(`  Email del Equipo Legal: ${process.env.EQUIPO_LEGAL_EMAIL}`);
    console.log('='.repeat(50));
    
    console.log('\n🚀 PRÓXIMOS PASOS:');
    console.log('1. Importa el workflow JSON actualizado en tu instancia de N8N');
    console.log('2. Configura tus credenciales de N8N (Gmail, Google Drive, Google Sheets, OpenAI)');
    console.log('3. Prueba el workflow con documentos de muestra');
    console.log('4. Configura permisos apropiados para tus carpetas de Google Drive');
    console.log('5. Configura notificaciones de email y acceso del equipo');
    
    console.log('\n📁 Archivos listos para importar:');
    console.log(`  - ${this.rutaWorkflow}`);
    console.log('  - Todos los scripts de configuración completados');
    console.log('  - Configuración de entorno lista');
  }

  // Método para crear una copia de seguridad del workflow original
  async crearRespaldo() {
    try {
      const marcaTiempo = new Date().toISOString().replace(/[:.]/g, '-');
      const rutaRespaldo = `${this.rutaWorkflow}.respaldo.${marcaTiempo}`;
      
      fs.copyFileSync(this.rutaWorkflow, rutaRespaldo);
      console.log(`📦 Respaldo creado: ${rutaRespaldo}`);
      
    } catch (error) {
      console.warn('⚠️  No se pudo crear respaldo:', error.message);
    }
  }
}

// Función principal de ejecución
async function main() {
  const actualizador = new ActualizadorConfigN8N();
  
  try {
    // Crear respaldo antes de actualizar
    await actualizador.crearRespaldo();
    
    // Actualizar la configuración
    await actualizador.actualizarConfiguracion();
    
  } catch (error) {
    console.error('❌ Falló la actualización de configuración:', error.message);
    process.exit(1);
  }
}

// Exportar para uso en otros scripts
module.exports = { ActualizadorConfigN8N };

// Ejecutar si se llama directamente
if (require.main === module) {
  main().catch(console.error);
}