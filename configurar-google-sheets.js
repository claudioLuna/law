/**
 * Script de Configuración de Google Sheets para Sistema de IA Legal
 * Este script crea las hojas de Google Sheets necesarias con encabezados de columnas apropiados
 * Ejecuta este script para configurar tus Google Sheets antes de importar el workflow N8N
 */

const { GoogleSpreadsheet } = require('google-spreadsheet');
const { JWT } = require('google-auth-library');

// Configuración - Reemplaza con tus valores reales
const config = {
  // Credenciales de Cuenta de Servicio de Google (formato JSON)
  credencialesCuentaServicio: {
    "type": "service_account",
    "project_id": "tu-id-del-proyecto",
    "private_key_id": "tu-id-de-clave-privada",
    "private_key": "-----BEGIN PRIVATE KEY-----\nTU_CLAVE_PRIVADA\n-----END PRIVATE KEY-----\n",
    "client_email": "tu-cuenta-de-servicio@tu-proyecto.iam.gserviceaccount.com",
    "client_id": "tu-id-de-cliente",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/tu-cuenta-de-servicio%40tu-proyecto.iam.gserviceaccount.com"
  }
};

class ConfiguracionSistemaIA {
  constructor() {
    this.doc = null;
    this.hojas = {};
  }

  async inicializar() {
    try {
      console.log('🚀 Inicializando Configuración del Sistema de IA Legal...');
      
      // Crear Hojas de Google Sheets
      await this.crearHojaResumenesLegales();
      await this.crearHojaAnalisisContratos();
      
      console.log('✅ Configuración completada exitosamente!');
      console.log('\n📋 Próximos Pasos:');
      console.log('1. Copia los IDs de Google Sheets de la salida anterior');
      console.log('2. Actualiza el workflow JSON de N8N con estos IDs');
      console.log('3. Configura las carpetas de Google Drive como se especifica en configurar-google-drive.js');
      console.log('4. Configura tus credenciales de N8N');
      console.log('5. Importa el workflow en N8N');
      
    } catch (error) {
      console.error('❌ La configuración falló:', error.message);
      throw error;
    }
  }

  async crearHojaResumenesLegales() {
    try {
      console.log('\n📊 Creando Hoja de Google Sheets de Resúmenes Legales...');
      
      // Crear una nueva hoja de cálculo
      const doc = new GoogleSpreadsheet();
      
      // Configurar autenticación
      const autenticacionCuentaServicio = new JWT({
        email: config.credencialesCuentaServicio.client_email,
        key: config.credencialesCuentaServicio.private_key,
        scopes: [
          'https://www.googleapis.com/auth/spreadsheets',
          'https://www.googleapis.com/auth/drive.file',
        ],
      });

      await doc.useServiceAccountAuth(autenticacionCuentaServicio);
      await doc.createNewSpreadsheetDocument({
        title: 'Resúmenes de Documentos Legales',
        locale: 'es_ES',
      });

      // Configurar la hoja principal con encabezados
      const sheet = doc.sheetsByIndex[0];
      await sheet.updateProperties({
        title: 'Resúmenes Legales',
      });

      // Agregar encabezados
      await sheet.setHeaderRow([
        'Fecha',
        'Asunto', 
        'Problema 1',
        'Problema 2',
        'Problema 3',
        'Problema 4',
        'Problema 5',
        'Fecha Límite',
        'Resumen Completo'
      ]);

      // Formatear encabezados
      await sheet.loadCells('A1:I1');
      const celdasEncabezado = sheet.getCellRange(0, 0, 0, 8);
      celdasEncabezado.forEach(cell => {
        cell.backgroundColor = { red: 0.2, green: 0.4, blue: 0.8 };
        cell.textFormat = { bold: true, foregroundColor: { red: 1, green: 1, blue: 1 } };
      });
      await sheet.saveUpdatedCells();

      // Establecer anchos de columna
      await sheet.updateDimensionProperties('COLUMNS', 0, 8, {
        pixelSize: 150
      });

      this.hojas.resumenesLegales = {
        id: doc.spreadsheetId,
        url: `https://docs.google.com/spreadsheets/d/${doc.spreadsheetId}/edit`
      };

      console.log(`✅ Hoja de Resúmenes Legales creada!`);
      console.log(`📋 ID de la Hoja: ${doc.spreadsheetId}`);
      console.log(`🔗 URL: https://docs.google.com/spreadsheets/d/${doc.spreadsheetId}/edit`);

      return doc.spreadsheetId;

    } catch (error) {
      console.error('❌ Falló la creación de la hoja de Resúmenes Legales:', error.message);
      throw error;
    }
  }

  async crearHojaAnalisisContratos() {
    try {
      console.log('\n📋 Creando Hoja de Google Sheets de Análisis de Contratos...');
      
      // Crear una nueva hoja de cálculo
      const doc = new GoogleSpreadsheet();
      
      // Configurar autenticación
      const autenticacionCuentaServicio = new JWT({
        email: config.credencialesCuentaServicio.client_email,
        key: config.credencialesCuentaServicio.private_key,
        scopes: [
          'https://www.googleapis.com/auth/spreadsheets',
          'https://www.googleapis.com/auth/drive.file',
        ],
      });

      await doc.useServiceAccountAuth(autenticacionCuentaServicio);
      await doc.createNewSpreadsheetDocument({
        title: 'Base de Datos de Análisis de Contratos',
        locale: 'es_ES',
      });

      // Configurar la hoja principal con encabezados
      const sheet = doc.sheetsByIndex[0];
      await sheet.updateProperties({
        title: 'Análisis de Contratos',
      });

      // Agregar encabezados
      await sheet.setHeaderRow([
        'Contrato',
        'Análisis'
      ]);

      // Formatear encabezados
      await sheet.loadCells('A1:B1');
      const celdasEncabezado = sheet.getCellRange(0, 0, 0, 1);
      celdasEncabezado.forEach(cell => {
        cell.backgroundColor = { red: 0.2, green: 0.6, blue: 0.4 };
        cell.textFormat = { bold: true, foregroundColor: { red: 1, green: 1, blue: 1 } };
      });
      await sheet.saveUpdatedCells();

      // Establecer anchos de columna
      await sheet.updateDimensionProperties('COLUMNS', 0, 1, {
        pixelSize: 300
      });

      this.hojas.analisisContratos = {
        id: doc.spreadsheetId,
        url: `https://docs.google.com/spreadsheets/d/${doc.spreadsheetId}/edit`
      };

      console.log(`✅ Hoja de Análisis de Contratos creada!`);
      console.log(`📋 ID de la Hoja: ${doc.spreadsheetId}`);
      console.log(`🔗 URL: https://docs.google.com/spreadsheets/d/${doc.spreadsheetId}/edit`);

      return doc.spreadsheetId;

    } catch (error) {
      console.error('❌ Falló la creación de la hoja de Análisis de Contratos:', error.message);
      throw error;
    }
  }

  obtenerIdsHojas() {
    return {
      resumenesLegales: this.hojas.resumenesLegales?.id,
      analisisContratos: this.hojas.analisisContratos?.id
    };
  }
}

// Ejecutar la configuración
async function main() {
  const configuracion = new ConfiguracionSistemaIA();
  await configuracion.inicializar();
  
  const idsHojas = configuracion.obtenerIdsHojas();
  
  console.log('\n📝 VALORES DE CONFIGURACIÓN PARA WORKFLOW N8N:');
  console.log('='.repeat(50));
  console.log(`hoja-resumenes-legales-id: ${idsHojas.resumenesLegales}`);
  console.log(`hoja-analisis-contratos-id: ${idsHojas.analisisContratos}`);
  console.log('='.repeat(50));
}

// Exportar para uso en otros scripts
module.exports = { ConfiguracionSistemaIA };

// Ejecutar si se llama directamente
if (require.main === module) {
  main().catch(console.error);
}