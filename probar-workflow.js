/**
 * Script de Prueba para Sistema de IA Legal
 * Prueba comprensiva de todos los componentes y configuraciones
 */

const { ConfiguracionSistemaIA } = require('./configurar-google-sheets');
const { ConfiguracionGoogleDrive } = require('./configurar-google-drive');
const { ActualizadorConfigN8N } = require('./actualizar-config-n8n');
const fs = require('fs');
const path = require('path');

class ProbadorSistemaIA {
  constructor() {
    this.resultadosPruebas = {
      entorno: false,
      dependencias: false,
      configuracion: false,
      workflow: false,
      serviciosGoogle: false
    };
  }

  async ejecutarTodasLasPruebas() {
    console.log('🧪 Iniciando Pruebas Comprensivas del Sistema de IA Legal...\n');
    
    try {
      await this.probarConfiguracionEntorno();
      await this.probarDependencias();
      await this.probarConfiguracion();
      await this.probarArchivoWorkflow();
      await this.probarConfiguracionServiciosGoogle();
      
      this.mostrarResultadosPruebas();
      
    } catch (error) {
      console.error('❌ La suite de pruebas falló:', error.message);
      process.exit(1);
    }
  }

  async probarConfiguracionEntorno() {
    console.log('🔧 Probando Configuración del Entorno...');
    
    try {
      // Verificar si el archivo .env existe
      const rutaEnv = path.join(__dirname, '.env');
      if (!fs.existsSync(rutaEnv)) {
        console.warn('  ⚠️  Archivo .env no encontrado. Por favor copia .env.ejemplo a .env y configúralo.');
        return;
      }
      
      // Cargar variables de entorno
      require('dotenv').config();
      
      // Probar versión de Node.js
      const versionNode = process.version;
      const versionMayor = parseInt(versionNode.slice(1).split('.')[0]);
      
      if (versionMayor >= 16) {
        console.log(`  ✅ Versión de Node.js: ${versionNode} (compatible)`);
      } else {
        console.warn(`  ⚠️  Versión de Node.js: ${versionNode} (requiere v16 o superior)`);
        return;
      }
      
      // Probar variables de entorno requeridas
      const variablesRequeridas = [
        'GOOGLE_PROJECT_ID',
        'GOOGLE_CLIENT_EMAIL',
        'OPENAI_API_KEY',
        'EQUIPO_LEGAL_EMAIL'
      ];
      
      const variablesFaltantes = variablesRequeridas.filter(nombreVar => !process.env[nombreVar]);
      
      if (variablesFaltantes.length === 0) {
        console.log('  ✅ Todas las variables de entorno requeridas están configuradas');
        this.resultadosPruebas.entorno = true;
      } else {
        console.warn(`  ⚠️  Variables de entorno faltantes: ${variablesFaltantes.join(', ')}`);
      }
      
    } catch (error) {
      console.error('  ❌ Falló la prueba de configuración del entorno:', error.message);
    }
  }

  async probarDependencias() {
    console.log('\n📦 Probando Dependencias...');
    
    try {
      const rutaPackageJson = path.join(__dirname, 'package.json');
      
      if (!fs.existsSync(rutaPackageJson)) {
        console.error('  ❌ package.json no encontrado');
        return;
      }
      
      const packageJson = JSON.parse(fs.readFileSync(rutaPackageJson, 'utf8'));
      const dependenciasRequeridas = [
        'google-spreadsheet',
        'googleapis',
        'google-auth-library',
        'dotenv'
      ];
      
      const dependenciasFaltantes = dependenciasRequeridas.filter(dep => !packageJson.dependencies[dep]);
      
      if (dependenciasFaltantes.length === 0) {
        console.log('  ✅ Todas las dependencias requeridas están definidas en package.json');
        
        // Probar si node_modules existe
        const rutaNodeModules = path.join(__dirname, 'node_modules');
        if (fs.existsSync(rutaNodeModules)) {
          console.log('  ✅ Las dependencias están instaladas');
          this.resultadosPruebas.dependencias = true;
        } else {
          console.warn('  ⚠️  Las dependencias no están instaladas. Ejecuta: npm install');
        }
      } else {
        console.error(`  ❌ Dependencias faltantes: ${dependenciasFaltantes.join(', ')}`);
      }
      
    } catch (error) {
      console.error('  ❌ Falló la prueba de dependencias:', error.message);
    }
  }

  async probarConfiguracion() {
    console.log('\n⚙️  Probando Archivos de Configuración...');
    
    try {
      const archivosConfiguracion = [
        'configurar-google-sheets.js',
        'configurar-google-drive.js',
        'actualizar-config-n8n.js',
        '.env.ejemplo'
      ];
      
      const archivosFaltantes = archivosConfiguracion.filter(archivo => !fs.existsSync(path.join(__dirname, archivo)));
      
      if (archivosFaltantes.length === 0) {
        console.log('  ✅ Todos los archivos de configuración están presentes');
        this.resultadosPruebas.configuracion = true;
      } else {
        console.error(`  ❌ Archivos de configuración faltantes: ${archivosFaltantes.join(', ')}`);
      }
      
      // Probar permisos de scripts
      const rutaScriptConfiguracion = path.join(__dirname, 'configurar-entorno.sh');
      if (fs.existsSync(rutaScriptConfiguracion)) {
        const stats = fs.statSync(rutaScriptConfiguracion);
        if (stats.mode & parseInt('111', 8)) {
          console.log('  ✅ El script de configuración tiene permisos de ejecución');
        } else {
          console.warn('  ⚠️  El script de configuración necesita permisos de ejecución. Ejecuta: chmod +x configurar-entorno.sh');
        }
      }
      
    } catch (error) {
      console.error('  ❌ Falló la prueba de configuración:', error.message);
    }
  }

  async probarArchivoWorkflow() {
    console.log('\n🔄 Probando Archivo de Workflow N8N...');
    
    try {
      const rutaWorkflow = path.join(__dirname, 'sistema-ia-legal-n8n-workflow.json');
      
      if (!fs.existsSync(rutaWorkflow)) {
        console.error('  ❌ Archivo JSON del workflow no encontrado');
        return;
      }
      
      const contenidoWorkflow = fs.readFileSync(rutaWorkflow, 'utf8');
      const workflow = JSON.parse(contenidoWorkflow);
      
      // Probar estructura del workflow
      const propiedadesRequeridas = ['name', 'nodes', 'connections'];
      const propiedadesFaltantes = propiedadesRequeridas.filter(prop => !workflow[prop]);
      
      if (propiedadesFaltantes.length === 0) {
        console.log('  ✅ La estructura del JSON del workflow es válida');
        
        // Probar conteo de nodos
        const conteoNodos = workflow.nodes.length;
        console.log(`  ✅ El workflow contiene ${conteoNodos} nodos`);
        
        // Probar tipos de nodos requeridos
        const tiposNodos = workflow.nodes.map(nodo => nodo.type);
        const tiposNodosRequeridos = [
          'n8n-nodes-base.gmailTrigger',
          'n8n-nodes-base.googleDrive',
          'n8n-nodes-base.googleSheets',
          '@n8n/n8n-nodes-langchain.openAi'
        ];
        
        const tiposNodosFaltantes = tiposNodosRequeridos.filter(tipo => !tiposNodos.includes(tipo));
        
        if (tiposNodosFaltantes.length === 0) {
          console.log('  ✅ Todos los tipos de nodos requeridos están presentes');
          this.resultadosPruebas.workflow = true;
        } else {
          console.warn(`  ⚠️  Tipos de nodos faltantes: ${tiposNodosFaltantes.join(', ')}`);
        }
        
      } else {
        console.error(`  ❌ El JSON del workflow falta propiedades: ${propiedadesFaltantes.join(', ')}`);
      }
      
    } catch (error) {
      console.error('  ❌ Falló la prueba del archivo de workflow:', error.message);
    }
  }

  async probarConfiguracionServiciosGoogle() {
    console.log('\n🔗 Probando Configuración de Servicios de Google...');
    
    try {
      // Probar clase de configuración de Google Sheets
      console.log('  📊 Probando clase de configuración de Google Sheets...');
      const configuracionHojas = new ConfiguracionSistemaIA();
      console.log('    ✅ Clase ConfiguracionSistemaIA cargada exitosamente');
      
      // Probar clase de configuración de Google Drive
      console.log('  📁 Probando clase de configuración de Google Drive...');
      const configuracionDrive = new ConfiguracionGoogleDrive();
      console.log('    ✅ Clase ConfiguracionGoogleDrive cargada exitosamente');
      
      // Probar clase de actualizador de configuración N8N
      console.log('  🔧 Probando clase de actualizador de configuración N8N...');
      const actualizadorConfig = new ActualizadorConfigN8N();
      console.log('    ✅ Clase ActualizadorConfigN8N cargada exitosamente');
      
      this.resultadosPruebas.serviciosGoogle = true;
      
    } catch (error) {
      console.error('  ❌ Falló la prueba de configuración de servicios de Google:', error.message);
    }
  }

  mostrarResultadosPruebas() {
    console.log('\n📊 RESUMEN DE RESULTADOS DE PRUEBAS');
    console.log('='.repeat(50));
    
    const pruebas = [
      { nombre: 'Configuración del Entorno', resultado: this.resultadosPruebas.entorno },
      { nombre: 'Dependencias', resultado: this.resultadosPruebas.dependencias },
      { nombre: 'Archivos de Configuración', resultado: this.resultadosPruebas.configuracion },
      { nombre: 'Workflow N8N', resultado: this.resultadosPruebas.workflow },
      { nombre: 'Configuración de Servicios de Google', resultado: this.resultadosPruebas.serviciosGoogle }
    ];
    
    pruebas.forEach(prueba => {
      const estado = prueba.resultado ? '✅ APROBADO' : '❌ FALLADO';
      console.log(`${estado} ${prueba.nombre}`);
    });
    
    const pruebasAprobadas = Object.values(this.resultadosPruebas).filter(resultado => resultado).length;
    const totalPruebas = Object.keys(this.resultadosPruebas).length;
    
    console.log('='.repeat(50));
    console.log(`📈 Puntuación General: ${pruebasAprobadas}/${totalPruebas} pruebas aprobadas`);
    
    if (pruebasAprobadas === totalPruebas) {
      console.log('\n🎉 ¡Todas las pruebas aprobadas! Tu Sistema de IA Legal está listo para el despliegue.');
      this.mostrarProximosPasos();
    } else {
      console.log('\n⚠️  Algunas pruebas fallaron. Por favor aborda los problemas arriba antes de proceder.');
      this.mostrarConsejosSolucion();
    }
  }

  mostrarProximosPasos() {
    console.log('\n🚀 PRÓXIMOS PASOS PARA EL DESPLIEGUE:');
    console.log('1. Configura tu archivo .env con valores reales');
    console.log('2. Ejecuta: npm run configurar-todo');
    console.log('3. Ejecuta: node actualizar-config-n8n.js');
    console.log('4. Importa el workflow JSON en tu instancia de N8N');
    console.log('5. Configura credenciales de N8N (Gmail, Google Drive, Google Sheets, OpenAI)');
    console.log('6. Prueba con documentos de muestra');
    console.log('7. Configura acceso del equipo y permisos');
  }

  mostrarConsejosSolucion() {
    console.log('\n🔧 CONSEJOS DE SOLUCIÓN:');
    console.log('• Variables de entorno faltantes: Copia .env.ejemplo a .env y configura');
    console.log('• Dependencias faltantes: Ejecuta npm install');
    console.log('• Problemas de permisos: Ejecuta chmod +x configurar-entorno.sh');
    console.log('• Problemas de API de Google: Verifica las credenciales de tu cuenta de servicio');
    console.log('• Problemas de workflow N8N: Verifica que el archivo JSON sea válido');
    console.log('\n📚 Para instrucciones detalladas de configuración, consulta README.md');
  }
}

// Función principal de ejecución
async function main() {
  const probador = new ProbadorSistemaIA();
  await probador.ejecutarTodasLasPruebas();
}

// Exportar para uso en otros scripts
module.exports = { ProbadorSistemaIA };

// Ejecutar si se llama directamente
if (require.main === module) {
  main().catch(console.error);
}