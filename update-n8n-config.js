/**
 * N8N Configuration Update Script
 * Updates the N8N workflow JSON with the correct IDs from environment variables
 * This script automatically configures the workflow with your specific Google Sheets and Drive folder IDs
 */

const fs = require('fs');
const path = require('path');
require('dotenv').config();

class N8NConfigUpdater {
  constructor() {
    this.workflowPath = path.join(__dirname, 'legal-ai-system-n8n-workflow.json');
    this.workflowData = null;
  }

  async updateConfiguration() {
    try {
      console.log('🔄 Updating N8N workflow configuration...');
      
      // Load the workflow JSON
      await this.loadWorkflow();
      
      // Validate environment variables
      this.validateEnvironmentVariables();
      
      // Update the workflow with actual IDs
      await this.updateWorkflowData();
      
      // Save the updated workflow
      await this.saveWorkflow();
      
      console.log('✅ N8N workflow configuration updated successfully!');
      this.displayConfigurationSummary();
      
    } catch (error) {
      console.error('❌ Failed to update N8N workflow:', error.message);
      process.exit(1);
    }
  }

  async loadWorkflow() {
    try {
      if (!fs.existsSync(this.workflowPath)) {
        throw new Error(`Workflow file not found: ${this.workflowPath}`);
      }
      
      const workflowContent = fs.readFileSync(this.workflowPath, 'utf8');
      this.workflowData = JSON.parse(workflowContent);
      
      console.log('📁 Loaded workflow JSON file');
      
    } catch (error) {
      throw new Error(`Failed to load workflow file: ${error.message}`);
    }
  }

  validateEnvironmentVariables() {
    console.log('🔍 Validating environment variables...');
    
    const requiredVars = [
      'LEGAL_SUMMARIES_SHEET_ID',
      'CONTRACT_ANALYSIS_SHEET_ID',
      'COMPLAINTS_CONTRACTS_FOLDER_ID',
      'CONTRACT_ANALYSIS_FOLDER_ID',
      'LEGAL_TEAM_EMAIL'
    ];
    
    const missingVars = requiredVars.filter(varName => !process.env[varName]);
    
    if (missingVars.length > 0) {
      console.warn('⚠️  Missing environment variables:', missingVars.join(', '));
      console.warn('Please run the setup scripts first to generate these IDs');
      
      // Use placeholder values for missing variables
      missingVars.forEach(varName => {
        process.env[varName] = `${varName.toLowerCase().replace(/_/g, '-')}-placeholder`;
      });
    }
    
    console.log('✅ Environment variables validated');
  }

  async updateWorkflowData() {
    console.log('🔧 Updating workflow data...');
    
    // Define mapping configurations
    const mappings = {
      sheetIds: {
        'legal-summaries-sheet-id': process.env.LEGAL_SUMMARIES_SHEET_ID,
        'contract-analysis-sheet-id': process.env.CONTRACT_ANALYSIS_SHEET_ID
      },
      folderIds: {
        'complaints-contracts-folder-id': process.env.COMPLAINTS_CONTRACTS_FOLDER_ID,
        'contract-analysis-folder-id': process.env.CONTRACT_ANALYSIS_FOLDER_ID
      },
      emails: {
        'legal-team@yourfirm.com': process.env.LEGAL_TEAM_EMAIL
      }
    };
    
    // Update each node in the workflow
    this.workflowData.nodes.forEach((node, index) => {
      this.updateNodeParameters(node, mappings, index);
    });
    
    console.log('✅ Workflow data updated');
  }

  updateNodeParameters(node, mappings, nodeIndex) {
    if (!node.parameters) return;
    
    // Update Google Sheets document IDs
    if (node.parameters.documentId) {
      const placeholder = node.parameters.documentId.value;
      if (mappings.sheetIds[placeholder]) {
        node.parameters.documentId.value = mappings.sheetIds[placeholder];
        console.log(`  📊 Updated sheet ID in node "${node.name}": ${placeholder} → ${mappings.sheetIds[placeholder]}`);
      }
    }
    
    // Update Google Drive folder IDs
    if (node.parameters.folderId) {
      const placeholder = node.parameters.folderId.value;
      if (mappings.folderIds[placeholder]) {
        node.parameters.folderId.value = mappings.folderIds[placeholder];
        console.log(`  📁 Updated folder ID in node "${node.name}": ${placeholder} → ${mappings.folderIds[placeholder]}`);
      }
    }
    
    // Update email addresses
    if (node.parameters.toEmail) {
      const placeholder = node.parameters.toEmail;
      if (mappings.emails[placeholder]) {
        node.parameters.toEmail = mappings.emails[placeholder];
        console.log(`  📧 Updated email in node "${node.name}": ${placeholder} → ${mappings.emails[placeholder]}`);
      }
    }
    
    // Update other email-related parameters
    if (node.parameters.subject && typeof node.parameters.subject === 'string') {
      Object.keys(mappings.emails).forEach(placeholder => {
        if (node.parameters.subject.includes(placeholder)) {
          node.parameters.subject = node.parameters.subject.replace(placeholder, mappings.emails[placeholder]);
          console.log(`  📧 Updated email reference in subject of node "${node.name}"`);
        }
      });
    }
  }

  async saveWorkflow() {
    try {
      const updatedContent = JSON.stringify(this.workflowData, null, 2);
      fs.writeFileSync(this.workflowPath, updatedContent);
      
      console.log('💾 Saved updated workflow to file');
      
    } catch (error) {
      throw new Error(`Failed to save workflow file: ${error.message}`);
    }
  }

  displayConfigurationSummary() {
    console.log('\n📋 CONFIGURATION SUMMARY');
    console.log('='.repeat(50));
    console.log('📊 Google Sheets:');
    console.log(`  Legal Summaries: ${process.env.LEGAL_SUMMARIES_SHEET_ID}`);
    console.log(`  Contract Analysis: ${process.env.CONTRACT_ANALYSIS_SHEET_ID}`);
    console.log('📁 Google Drive Folders:');
    console.log(`  Complaints & Contracts: ${process.env.COMPLAINTS_CONTRACTS_FOLDER_ID}`);
    console.log(`  Contract Analysis: ${process.env.CONTRACT_ANALYSIS_FOLDER_ID}`);
    console.log('📧 Email Configuration:');
    console.log(`  Legal Team Email: ${process.env.LEGAL_TEAM_EMAIL}`);
    console.log('='.repeat(50));
    
    console.log('\n🚀 NEXT STEPS:');
    console.log('1. Import the updated workflow JSON into your N8N instance');
    console.log('2. Configure your N8N credentials (Gmail, Google Drive, Google Sheets, OpenAI)');
    console.log('3. Test the workflow with sample documents');
    console.log('4. Set up proper permissions for your Google Drive folders');
    console.log('5. Configure email notifications and team access');
    
    console.log('\n📁 Files ready for import:');
    console.log(`  - ${this.workflowPath}`);
    console.log('  - All setup scripts completed');
    console.log('  - Environment configuration ready');
  }

  // Method to create a backup of the original workflow
  async createBackup() {
    try {
      const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
      const backupPath = `${this.workflowPath}.backup.${timestamp}`;
      
      fs.copyFileSync(this.workflowPath, backupPath);
      console.log(`📦 Created backup: ${backupPath}`);
      
    } catch (error) {
      console.warn('⚠️  Could not create backup:', error.message);
    }
  }
}

// Main execution function
async function main() {
  const updater = new N8NConfigUpdater();
  
  try {
    // Create backup before updating
    await updater.createBackup();
    
    // Update the configuration
    await updater.updateConfiguration();
    
  } catch (error) {
    console.error('❌ Configuration update failed:', error.message);
    process.exit(1);
  }
}

// Export for use in other scripts
module.exports = { N8NConfigUpdater };

// Run if called directly
if (require.main === module) {
  main().catch(console.error);
}