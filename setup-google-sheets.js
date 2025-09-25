/**
 * Google Sheets Setup Script for Legal AI System
 * This script creates the necessary Google Sheets with proper column headers
 * Run this script to set up your Google Sheets before importing the N8N workflow
 */

const { GoogleSpreadsheet } = require('google-spreadsheet');
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

class LegalAISetup {
  constructor() {
    this.doc = null;
    this.sheets = {};
  }

  async initialize() {
    try {
      console.log('🚀 Initializing Legal AI System Setup...');
      
      // Create Google Sheets
      await this.createLegalSummariesSheet();
      await this.createContractAnalysisSheet();
      
      console.log('✅ Setup completed successfully!');
      console.log('\n📋 Next Steps:');
      console.log('1. Copy the Google Sheets IDs from the output above');
      console.log('2. Update the N8N workflow JSON with these IDs');
      console.log('3. Set up Google Drive folders as specified in setup-google-drive.js');
      console.log('4. Configure your N8N credentials');
      console.log('5. Import the workflow into N8N');
      
    } catch (error) {
      console.error('❌ Setup failed:', error.message);
      throw error;
    }
  }

  async createLegalSummariesSheet() {
    try {
      console.log('\n📊 Creating Legal Summaries Google Sheet...');
      
      // Create a new spreadsheet
      const doc = new GoogleSpreadsheet();
      
      // Set up authentication
      const serviceAccountAuth = new JWT({
        email: config.serviceAccountCredentials.client_email,
        key: config.serviceAccountCredentials.private_key,
        scopes: [
          'https://www.googleapis.com/auth/spreadsheets',
          'https://www.googleapis.com/auth/drive.file',
        ],
      });

      await doc.useServiceAccountAuth(serviceAccountAuth);
      await doc.createNewSpreadsheetDocument({
        title: 'Legal Document Summaries',
        locale: 'en_US',
      });

      // Set up the main sheet with headers
      const sheet = doc.sheetsByIndex[0];
      await sheet.updateProperties({
        title: 'Legal Summaries',
      });

      // Add headers
      await sheet.setHeaderRow([
        'Date',
        'Subject', 
        'Issue 1',
        'Issue 2',
        'Issue 3',
        'Issue 4',
        'Issue 5',
        'Deadline',
        'Full Summary'
      ]);

      // Format headers
      await sheet.loadCells('A1:I1');
      const headerCells = sheet.getCellRange(0, 0, 0, 8);
      headerCells.forEach(cell => {
        cell.backgroundColor = { red: 0.2, green: 0.4, blue: 0.8 };
        cell.textFormat = { bold: true, foregroundColor: { red: 1, green: 1, blue: 1 } };
      });
      await sheet.saveUpdatedCells();

      // Set column widths
      await sheet.updateDimensionProperties('COLUMNS', 0, 8, {
        pixelSize: 150
      });

      this.sheets.legalSummaries = {
        id: doc.spreadsheetId,
        url: `https://docs.google.com/spreadsheets/d/${doc.spreadsheetId}/edit`
      };

      console.log(`✅ Legal Summaries Sheet created!`);
      console.log(`📋 Sheet ID: ${doc.spreadsheetId}`);
      console.log(`🔗 URL: https://docs.google.com/spreadsheets/d/${doc.spreadsheetId}/edit`);

      return doc.spreadsheetId;

    } catch (error) {
      console.error('❌ Failed to create Legal Summaries sheet:', error.message);
      throw error;
    }
  }

  async createContractAnalysisSheet() {
    try {
      console.log('\n📋 Creating Contract Analysis Google Sheet...');
      
      // Create a new spreadsheet
      const doc = new GoogleSpreadsheet();
      
      // Set up authentication
      const serviceAccountAuth = new JWT({
        email: config.serviceAccountCredentials.client_email,
        key: config.serviceAccountCredentials.private_key,
        scopes: [
          'https://www.googleapis.com/auth/spreadsheets',
          'https://www.googleapis.com/auth/drive.file',
        ],
      });

      await doc.useServiceAccountAuth(serviceAccountAuth);
      await doc.createNewSpreadsheetDocument({
        title: 'Contract Analysis Database',
        locale: 'en_US',
      });

      // Set up the main sheet with headers
      const sheet = doc.sheetsByIndex[0];
      await sheet.updateProperties({
        title: 'Contract Analysis',
      });

      // Add headers
      await sheet.setHeaderRow([
        'Contract',
        'Analysis'
      ]);

      // Format headers
      await sheet.loadCells('A1:B1');
      const headerCells = sheet.getCellRange(0, 0, 0, 1);
      headerCells.forEach(cell => {
        cell.backgroundColor = { red: 0.2, green: 0.6, blue: 0.4 };
        cell.textFormat = { bold: true, foregroundColor: { red: 1, green: 1, blue: 1 } };
      });
      await sheet.saveUpdatedCells();

      // Set column widths
      await sheet.updateDimensionProperties('COLUMNS', 0, 1, {
        pixelSize: 300
      });

      this.sheets.contractAnalysis = {
        id: doc.spreadsheetId,
        url: `https://docs.google.com/spreadsheets/d/${doc.spreadsheetId}/edit`
      };

      console.log(`✅ Contract Analysis Sheet created!`);
      console.log(`📋 Sheet ID: ${doc.spreadsheetId}`);
      console.log(`🔗 URL: https://docs.google.com/spreadsheets/d/${doc.spreadsheetId}/edit`);

      return doc.spreadsheetId;

    } catch (error) {
      console.error('❌ Failed to create Contract Analysis sheet:', error.message);
      throw error;
    }
  }

  getSheetIds() {
    return {
      legalSummaries: this.sheets.legalSummaries?.id,
      contractAnalysis: this.sheets.contractAnalysis?.id
    };
  }
}

// Run the setup
async function main() {
  const setup = new LegalAISetup();
  await setup.initialize();
  
  const sheetIds = setup.getSheetIds();
  
  console.log('\n📝 CONFIGURATION VALUES FOR N8N WORKFLOW:');
  console.log('='.repeat(50));
  console.log(`legal-summaries-sheet-id: ${sheetIds.legalSummaries}`);
  console.log(`contract-analysis-sheet-id: ${sheetIds.contractAnalysis}`);
  console.log('='.repeat(50));
}

// Export for use in other scripts
module.exports = { LegalAISetup };

// Run if called directly
if (require.main === module) {
  main().catch(console.error);
}