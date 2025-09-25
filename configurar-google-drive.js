/**
 * Script de Configuración de Google Drive para Sistema de IA Legal
 * Este script crea las carpetas necesarias de Google Drive para el sistema de IA legal
 * Ejecuta este script para configurar la estructura de carpetas de Google Drive
 */

const { GoogleDrive } = require('googleapis');
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

class ConfiguracionGoogleDrive {
  constructor() {
    this.drive = null;
    this.carpetas = {};
  }

  async inicializar() {
    try {
      console.log('🚀 Inicializando Configuración de Google Drive...');
      
      // Configurar API de Google Drive
      await this.configurarAPI();
      
      // Crear carpetas
      await this.crearCarpetaDemandasYContratos();
      await this.crearCarpetaAnalisisContratos();
      
      console.log('✅ Configuración de Google Drive completada exitosamente!');
      console.log('\n📋 Próximos Pasos:');
      console.log('1. Copia los IDs de carpetas de la salida anterior');
      console.log('2. Actualiza el workflow JSON de N8N con estos IDs de carpetas');
      console.log('3. Configura permisos apropiados para tus carpetas');
      console.log('4. Prueba el acceso a las carpetas desde N8N');
      
    } catch (error) {
      console.error('❌ La configuración falló:', error.message);
      throw error;
    }
  }

  async configurarAPI() {
    try {
      console.log('🔧 Configurando API de Google Drive...');
      
      const autenticacionCuentaServicio = new JWT({
        email: config.credencialesCuentaServicio.client_email,
        key: config.credencialesCuentaServicio.private_key,
        scopes: [
          'https://www.googleapis.com/auth/drive',
          'https://www.googleapis.com/auth/drive.file',
        ],
      });

      const drive = GoogleDrive({
        version: 'v3',
        auth: autenticacionCuentaServicio,
      });

      this.drive = drive;
      console.log('✅ API de Google Drive inicializada');

    } catch (error) {
      console.error('❌ Falló la configuración de la API de Google Drive:', error.message);
      throw error;
    }
  }

  async crearCarpetaDemandasYContratos() {
    try {
      console.log('\n📁 Creando carpeta de Demandas y Contratos...');
      
      const metadatosCarpeta = {
        name: 'Sistema IA Legal - Demandas y Contratos',
        mimeType: 'application/vnd.google-apps.folder',
        description: 'Almacenamiento automatizado para documentos legales recibidos por email',
        parents: ['root'] // Colocar en directorio raíz
      };

      const carpeta = await this.drive.files.create({
        resource: metadatosCarpeta,
        fields: 'id,name,webViewLink'
      });

      this.carpetas.demandasYContratos = {
        id: carpeta.data.id,
        name: carpeta.data.name,
        url: carpeta.data.webViewLink
      };

      console.log(`✅ Carpeta de Demandas y Contratos creada!`);
      console.log(`📁 ID de la Carpeta: ${carpeta.data.id}`);
      console.log(`🔗 URL: ${carpeta.data.webViewLink}`);

      // Crear subcarpetas para mejor organización
      await this.crearSubcarpeta(carpeta.data.id, 'Documentos Recibidos', 'Documentos recibidos por automatización de email');
      await this.crearSubcarpeta(carpeta.data.id, 'Documentos Procesados', 'Documentos que han sido analizados y procesados');

      return carpeta.data.id;

    } catch (error) {
      console.error('❌ Falló la creación de la carpeta de Demandas y Contratos:', error.message);
      throw error;
    }
  }

  async crearCarpetaAnalisisContratos() {
    try {
      console.log('\n📋 Creando carpeta de Análisis de Contratos...');
      
      const metadatosCarpeta = {
        name: 'Sistema IA Legal - Análisis de Contratos',
        mimeType: 'application/vnd.google-apps.folder',
        description: 'Carpeta para contratos a ser analizados por el sistema de IA',
        parents: ['root'] // Colocar en directorio raíz
      };

      const carpeta = await this.drive.files.create({
        resource: metadatosCarpeta,
        fields: 'id,name,webViewLink'
      });

      this.carpetas.analisisContratos = {
        id: carpeta.data.id,
        name: carpeta.data.name,
        url: carpeta.data.webViewLink
      };

      console.log(`✅ Carpeta de Análisis de Contratos creada!`);
      console.log(`📁 ID de la Carpeta: ${carpeta.data.id}`);
      console.log(`🔗 URL: ${carpeta.data.webViewLink}`);

      // Crear subcarpetas para mejor organización
      await this.crearSubcarpeta(carpeta.data.id, 'Pendientes de Análisis', 'Contratos esperando análisis de IA');
      await this.crearSubcarpeta(carpeta.data.id, 'Análisis Completados', 'Contratos que han sido analizados');
      await this.crearSubcarpeta(carpeta.data.id, 'Contratos de Alto Riesgo', 'Contratos marcados como alto riesgo');

      return carpeta.data.id;

    } catch (error) {
      console.error('❌ Falló la creación de la carpeta de Análisis de Contratos:', error.message);
      throw error;
    }
  }

  async crearSubcarpeta(idPadre, nombreCarpeta, descripcion) {
    try {
      const metadatosCarpeta = {
        name: nombreCarpeta,
        mimeType: 'application/vnd.google-apps.folder',
        description: descripcion,
        parents: [idPadre]
      };

      const carpeta = await this.drive.files.create({
        resource: metadatosCarpeta,
        fields: 'id,name'
      });

      console.log(`  📂 Subcarpeta creada: ${nombreCarpeta} (ID: ${carpeta.data.id})`);
      return carpeta.data.id;

    } catch (error) {
      console.error(`❌ Falló la creación de la subcarpeta ${nombreCarpeta}:`, error.message);
      throw error;
    }
  }

  async establecerPermisosCarpeta(idCarpeta, direccionEmail, rol = 'writer') {
    try {
      const permiso = {
        type: 'user',
        role: rol,
        emailAddress: direccionEmail
      };

      await this.drive.permissions.create({
        fileId: idCarpeta,
        resource: permiso
      });

      console.log(`✅ Establecidos permisos ${rol} para ${direccionEmail} en la carpeta ${idCarpeta}`);

    } catch (error) {
      console.error(`❌ Falló el establecimiento de permisos:`, error.message);
      throw error;
    }
  }

  obtenerIdsCarpetas() {
    return {
      demandasYContratos: this.carpetas.demandasYContratos?.id,
      analisisContratos: this.carpetas.analisisContratos?.id
    };
  }

  async crearArchivosEjemplo() {
    try {
      console.log('\n📄 Creando archivos de ejemplo para pruebas...');
      
      // Crear un contrato de ejemplo en la carpeta de análisis de contratos
      const contenidoContratoEjemplo = `
CONTRATO DE SERVICIOS

Este Contrato de Servicios ("Contrato") es celebrado entre Servicios Legales Alpha ("Proveedor") y Corporación Beta ("Cliente") el ${new Date().toISOString().split('T')[0]}.

1. CLÁUSULA DE TERMINACIÓN
Cualquiera de las partes puede terminar este contrato con 30 días de aviso por escrito.

2. CLÁUSULA DE INDEMNIZACIÓN  
El Cliente se compromete a indemnizar al Proveedor contra todas las reclamaciones derivadas del uso de servicios por parte del Cliente.

3. CLÁUSULA DE CONFIDENCIALIDAD
Ambas partes se comprometen a mantener confidencial toda la información compartida.

4. FUERZA MAYOR
Ninguna de las partes será responsable por retrasos debido a circunstancias fuera de su control.

5. LEY APLICABLE
Este contrato se regirá por las leyes de México.

6. LIMITACIÓN DE RESPONSABILIDAD
La responsabilidad del Proveedor no excederá las tarifas totales pagadas bajo este contrato.
      `;

      const metadatosArchivo = {
        name: 'Contrato de Servicios de Ejemplo.pdf',
        parents: [this.carpetas.analisisContratos.id]
      };

      const media = {
        mimeType: 'application/pdf',
        body: contenidoContratoEjemplo
      };

      const archivo = await this.drive.files.create({
        resource: metadatosArchivo,
        media: media,
        fields: 'id,name,webViewLink'
      });

      console.log(`✅ Contrato de ejemplo creado: ${archivo.data.name}`);
      console.log(`📄 ID del Archivo: ${archivo.data.id}`);
      console.log(`🔗 URL: ${archivo.data.webViewLink}`);

    } catch (error) {
      console.error('❌ Falló la creación de archivos de ejemplo:', error.message);
      throw error;
    }
  }
}

// Ejecutar la configuración
async function main() {
  const configuracion = new ConfiguracionGoogleDrive();
  await configuracion.inicializar();
  
  // Crear archivos de ejemplo para pruebas
  await configuracion.crearArchivosEjemplo();
  
  const idsCarpetas = configuracion.obtenerIdsCarpetas();
  
  console.log('\n📝 VALORES DE CONFIGURACIÓN PARA WORKFLOW N8N:');
  console.log('='.repeat(50));
  console.log(`carpeta-demandas-contratos-id: ${idsCarpetas.demandasYContratos}`);
  console.log(`carpeta-analisis-contratos-id: ${idsCarpetas.analisisContratos}`);
  console.log('='.repeat(50));
  
  console.log('\n🔐 CONFIGURACIÓN DE PERMISOS:');
  console.log('Asegúrate de establecer permisos apropiados para tus carpetas:');
  console.log('1. Agregar tu cuenta principal de Google como colaborador');
  console.log('2. Establecer permisos a "Editor" o "Visualizador" según sea necesario');
  console.log('3. Asegurar que la cuenta de servicio tenga acceso a estas carpetas');
}

// Exportar para uso en otros scripts
module.exports = { ConfiguracionGoogleDrive };

// Ejecutar si se llama directamente
if (require.main === module) {
  main().catch(console.error);
}