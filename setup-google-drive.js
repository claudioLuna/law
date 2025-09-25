/**
 * Google Drive Setup Script for Legal AI System
 * This script creates the necessary Google Drive folders for the legal AI system
 * Run this script to set up your Google Drive folder structure
 */

const { GoogleDrive } = require('googleapis');
const { JWT } = require('google-auth-library');

// Configuration - Replace with your actual values
const config = {
  // Google Service Account credentials (JSON format)
  serviceAccountCredentials: {
    "type": "service_account",
    "project_id": "your-project-id",
    "private_key_id": "your-private-key-id",
    "private_key": "-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY\n-----END PRIVATE KEY-----\n",
    "client_email": "your-service-account@your-project.iam.gserviceaccount.com",
    "client_id": "your-client-id",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/your-service-account%40your-project.iam.gserviceaccount.com"
  }
};

class GoogleDriveSetup {
  constructor() {
    this.drive = null;
    this.folders = {};
  }

  async initialize() {
    try {
      console.log('🚀 Initializing Google Drive Setup...');
      
      // Set up Google Drive API
      await this.setupDriveAPI();
      
      // Create folders
      await this.createComplaintsAndContractsFolder();
      await this.createContractAnalysisFolder();
      
      console.log('✅ Google Drive setup completed successfully!');
      console.log('\n📋 Next Steps:');
      console.log('1. Copy the folder IDs from the output above');
      console.log('2. Update the N8N workflow JSON with these folder IDs');
      console.log('3. Set up proper permissions for your folders');
      console.log('4. Test the folder access from N8N');
      
    } catch (error) {
      console.error('❌ Setup failed:', error.message);
      throw error;
    }
  }

  async setupDriveAPI() {
    try {
      console.log('🔧 Setting up Google Drive API...');
      
      const serviceAccountAuth = new JWT({
        email: config.serviceAccountCredentials.client_email,
        key: config.serviceAccountCredentials.private_key,
        scopes: [
          'https://www.googleapis.com/auth/drive',
          'https://www.googleapis.com/auth/drive.file',
        ],
      });

      const drive = GoogleDrive({
        version: 'v3',
        auth: serviceAccountAuth,
      });

      this.drive = drive;
      console.log('✅ Google Drive API initialized');

    } catch (error) {
      console.error('❌ Failed to setup Google Drive API:', error.message);
      throw error;
    }
  }

  async createComplaintsAndContractsFolder() {
    try {
      console.log('\n📁 Creating Complaints and Contracts folder...');
      
      const folderMetadata = {
        name: 'Legal AI - Complaints and Contracts',
        mimeType: 'application/vnd.google-apps.folder',
        description: 'Automated storage for legal documents received via email',
        parents: ['root'] // Place in root directory
      };

      const folder = await this.drive.files.create({
        resource: folderMetadata,
        fields: 'id,name,webViewLink'
      });

      this.folders.complaintsAndContracts = {
        id: folder.data.id,
        name: folder.data.name,
        url: folder.data.webViewLink
      };

      console.log(`✅ Complaints and Contracts folder created!`);
      console.log(`📁 Folder ID: ${folder.data.id}`);
      console.log(`🔗 URL: ${folder.data.webViewLink}`);

      // Create subfolder for better organization
      await this.createSubfolder(folder.data.id, 'Incoming Documents', 'Documents received via email automation');
      await this.createSubfolder(folder.data.id, 'Processed Documents', 'Documents that have been analyzed and processed');

      return folder.data.id;

    } catch (error) {
      console.error('❌ Failed to create Complaints and Contracts folder:', error.message);
      throw error;
    }
  }

  async createContractAnalysisFolder() {
    try {
      console.log('\n📋 Creating Contract Analysis folder...');
      
      const folderMetadata = {
        name: 'Legal AI - Contract Analysis',
        mimeType: 'application/vnd.google-apps.folder',
        description: 'Folder for contracts to be analyzed by the AI system',
        parents: ['root'] // Place in root directory
      };

      const folder = await this.drive.files.create({
        resource: folderMetadata,
        fields: 'id,name,webViewLink'
      });

      this.folders.contractAnalysis = {
        id: folder.data.id,
        name: folder.data.name,
        url: folder.data.webViewLink
      };

      console.log(`✅ Contract Analysis folder created!`);
      console.log(`📁 Folder ID: ${folder.data.id}`);
      console.log(`🔗 URL: ${folder.data.webViewLink}`);

      // Create subfolders for better organization
      await this.createSubfolder(folder.data.id, 'Pending Analysis', 'Contracts waiting for AI analysis');
      await this.createSubfolder(folder.data.id, 'Completed Analysis', 'Contracts that have been analyzed');
      await this.createSubfolder(folder.data.id, 'High Risk Contracts', 'Contracts flagged as high risk');

      return folder.data.id;

    } catch (error) {
      console.error('❌ Failed to create Contract Analysis folder:', error.message);
      throw error;
    }
  }

  async createSubfolder(parentId, folderName, description) {
    try {
      const folderMetadata = {
        name: folderName,
        mimeType: 'application/vnd.google-apps.folder',
        description: description,
        parents: [parentId]
      };

      const folder = await this.drive.files.create({
        resource: folderMetadata,
        fields: 'id,name'
      });

      console.log(`  📂 Created subfolder: ${folderName} (ID: ${folder.data.id})`);
      return folder.data.id;

    } catch (error) {
      console.error(`❌ Failed to create subfolder ${folderName}:`, error.message);
      throw error;
    }
  }

  async setFolderPermissions(folderId, emailAddress, role = 'writer') {
    try {
      const permission = {
        type: 'user',
        role: role,
        emailAddress: emailAddress
      };

      await this.drive.permissions.create({
        fileId: folderId,
        resource: permission
      });

      console.log(`✅ Set ${role} permissions for ${emailAddress} on folder ${folderId}`);

    } catch (error) {
      console.error(`❌ Failed to set permissions:`, error.message);
      throw error;
    }
  }

  getFolderIds() {
    return {
      complaintsAndContracts: this.folders.complaintsAndContracts?.id,
      contractAnalysis: this.folders.contractAnalysis?.id
    };
  }

  async createSampleFiles() {
    try {
      console.log('\n📄 Creating sample files for testing...');
      
      // Create a sample contract in the contract analysis folder
      const sampleContractContent = `
SERVICE AGREEMENT

This Service Agreement ("Agreement") is entered into between Alpha Legal Services ("Provider") and Beta Corp ("Client") on ${new Date().toISOString().split('T')[0]}.

1. TERMINATION CLAUSE
Either party may terminate this agreement with 30 days written notice.

2. INDEMNITY CLAUSE  
Client agrees to indemnify Provider against all claims arising from Client's use of services.

3. CONFIDENTIALITY CLAUSE
Both parties agree to maintain confidentiality of all shared information.

4. FORCE MAJEURE
Neither party shall be liable for delays due to circumstances beyond their control.

5. GOVERNING LAW
This agreement shall be governed by the laws of California.

6. LIMITATION OF LIABILITY
Provider's liability shall not exceed the total fees paid under this agreement.
      `;

      const fileMetadata = {
        name: 'Sample Service Agreement.pdf',
        parents: [this.folders.contractAnalysis.id]
      };

      const media = {
        mimeType: 'application/pdf',
        body: sampleContractContent
      };

      const file = await this.drive.files.create({
        resource: fileMetadata,
        media: media,
        fields: 'id,name,webViewLink'
      });

      console.log(`✅ Created sample contract: ${file.data.name}`);
      console.log(`📄 File ID: ${file.data.id}`);
      console.log(`🔗 URL: ${file.data.webViewLink}`);

    } catch (error) {
      console.error('❌ Failed to create sample files:', error.message);
      throw error;
    }
  }
}

// Run the setup
async function main() {
  const setup = new GoogleDriveSetup();
  await setup.initialize();
  
  // Create sample files for testing
  await setup.createSampleFiles();
  
  const folderIds = setup.getFolderIds();
  
  console.log('\n📝 CONFIGURATION VALUES FOR N8N WORKFLOW:');
  console.log('='.repeat(50));
  console.log(`complaints-contracts-folder-id: ${folderIds.complaintsAndContracts}`);
  console.log(`contract-analysis-folder-id: ${folderIds.contractAnalysis}`);
  console.log('='.repeat(50));
  
  console.log('\n🔐 PERMISSION SETUP:');
  console.log('Make sure to set appropriate permissions for your folders:');
  console.log('1. Add your main Google account as a collaborator');
  console.log('2. Set permissions to "Editor" or "Viewer" as needed');
  console.log('3. Ensure N8N service account has access to these folders');
}

// Export for use in other scripts
module.exports = { GoogleDriveSetup };

// Run if called directly
if (require.main === module) {
  main().catch(console.error);
}