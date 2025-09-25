/**
 * Test Script for Legal AI System
 * Comprehensive testing of all components and configurations
 */

const { LegalAISetup } = require('./setup-google-sheets');
const { GoogleDriveSetup } = require('./setup-google-drive');
const { N8NConfigUpdater } = require('./update-n8n-config');
const fs = require('fs');
const path = require('path');

class LegalAITester {
  constructor() {
    this.testResults = {
      environment: false,
      dependencies: false,
      configuration: false,
      workflow: false,
      googleServices: false
    };
  }

  async runAllTests() {
    console.log('🧪 Starting Comprehensive Legal AI System Tests...\n');
    
    try {
      await this.testEnvironmentSetup();
      await this.testDependencies();
      await this.testConfiguration();
      await this.testWorkflowFile();
      await this.testGoogleServicesSetup();
      
      this.displayTestResults();
      
    } catch (error) {
      console.error('❌ Test suite failed:', error.message);
      process.exit(1);
    }
  }

  async testEnvironmentSetup() {
    console.log('🔧 Testing Environment Setup...');
    
    try {
      // Check if .env file exists
      const envPath = path.join(__dirname, '.env');
      if (!fs.existsSync(envPath)) {
        console.warn('  ⚠️  .env file not found. Please copy .env.example to .env and configure it.');
        return;
      }
      
      // Load environment variables
      require('dotenv').config();
      
      // Test Node.js version
      const nodeVersion = process.version;
      const majorVersion = parseInt(nodeVersion.slice(1).split('.')[0]);
      
      if (majorVersion >= 16) {
        console.log(`  ✅ Node.js version: ${nodeVersion} (compatible)`);
      } else {
        console.warn(`  ⚠️  Node.js version: ${nodeVersion} (requires v16 or higher)`);
        return;
      }
      
      // Test required environment variables
      const requiredVars = [
        'GOOGLE_PROJECT_ID',
        'GOOGLE_CLIENT_EMAIL',
        'OPENAI_API_KEY',
        'LEGAL_TEAM_EMAIL'
      ];
      
      const missingVars = requiredVars.filter(varName => !process.env[varName]);
      
      if (missingVars.length === 0) {
        console.log('  ✅ All required environment variables are set');
        this.testResults.environment = true;
      } else {
        console.warn(`  ⚠️  Missing environment variables: ${missingVars.join(', ')}`);
      }
      
    } catch (error) {
      console.error('  ❌ Environment setup test failed:', error.message);
    }
  }

  async testDependencies() {
    console.log('\n📦 Testing Dependencies...');
    
    try {
      const packageJsonPath = path.join(__dirname, 'package.json');
      
      if (!fs.existsSync(packageJsonPath)) {
        console.error('  ❌ package.json not found');
        return;
      }
      
      const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
      const requiredDeps = [
        'google-spreadsheet',
        'googleapis',
        'google-auth-library',
        'dotenv'
      ];
      
      const missingDeps = requiredDeps.filter(dep => !packageJson.dependencies[dep]);
      
      if (missingDeps.length === 0) {
        console.log('  ✅ All required dependencies are defined in package.json');
        
        // Test if node_modules exists
        const nodeModulesPath = path.join(__dirname, 'node_modules');
        if (fs.existsSync(nodeModulesPath)) {
          console.log('  ✅ Dependencies are installed');
          this.testResults.dependencies = true;
        } else {
          console.warn('  ⚠️  Dependencies not installed. Run: npm install');
        }
      } else {
        console.error(`  ❌ Missing dependencies: ${missingDeps.join(', ')}`);
      }
      
    } catch (error) {
      console.error('  ❌ Dependencies test failed:', error.message);
    }
  }

  async testConfiguration() {
    console.log('\n⚙️  Testing Configuration Files...');
    
    try {
      const configFiles = [
        'setup-google-sheets.js',
        'setup-google-drive.js',
        'update-n8n-config.js',
        '.env.example'
      ];
      
      const missingFiles = configFiles.filter(file => !fs.existsSync(path.join(__dirname, file)));
      
      if (missingFiles.length === 0) {
        console.log('  ✅ All configuration files are present');
        this.testResults.configuration = true;
      } else {
        console.error(`  ❌ Missing configuration files: ${missingFiles.join(', ')}`);
      }
      
      // Test script permissions
      const setupScriptPath = path.join(__dirname, 'setup-environment.sh');
      if (fs.existsSync(setupScriptPath)) {
        const stats = fs.statSync(setupScriptPath);
        if (stats.mode & parseInt('111', 8)) {
          console.log('  ✅ Setup script has execute permissions');
        } else {
          console.warn('  ⚠️  Setup script needs execute permissions. Run: chmod +x setup-environment.sh');
        }
      }
      
    } catch (error) {
      console.error('  ❌ Configuration test failed:', error.message);
    }
  }

  async testWorkflowFile() {
    console.log('\n🔄 Testing N8N Workflow File...');
    
    try {
      const workflowPath = path.join(__dirname, 'legal-ai-system-n8n-workflow.json');
      
      if (!fs.existsSync(workflowPath)) {
        console.error('  ❌ Workflow JSON file not found');
        return;
      }
      
      const workflowContent = fs.readFileSync(workflowPath, 'utf8');
      const workflow = JSON.parse(workflowContent);
      
      // Test workflow structure
      const requiredProperties = ['name', 'nodes', 'connections'];
      const missingProperties = requiredProperties.filter(prop => !workflow[prop]);
      
      if (missingProperties.length === 0) {
        console.log('  ✅ Workflow JSON structure is valid');
        
        // Test node count
        const nodeCount = workflow.nodes.length;
        console.log(`  ✅ Workflow contains ${nodeCount} nodes`);
        
        // Test for required node types
        const nodeTypes = workflow.nodes.map(node => node.type);
        const requiredNodeTypes = [
          'n8n-nodes-base.gmailTrigger',
          'n8n-nodes-base.googleDrive',
          'n8n-nodes-base.googleSheets',
          '@n8n/n8n-nodes-langchain.openAi'
        ];
        
        const missingNodeTypes = requiredNodeTypes.filter(type => !nodeTypes.includes(type));
        
        if (missingNodeTypes.length === 0) {
          console.log('  ✅ All required node types are present');
          this.testResults.workflow = true;
        } else {
          console.warn(`  ⚠️  Missing node types: ${missingNodeTypes.join(', ')}`);
        }
        
      } else {
        console.error(`  ❌ Workflow JSON missing properties: ${missingProperties.join(', ')}`);
      }
      
    } catch (error) {
      console.error('  ❌ Workflow file test failed:', error.message);
    }
  }

  async testGoogleServicesSetup() {
    console.log('\n🔗 Testing Google Services Setup Classes...');
    
    try {
      // Test Google Sheets setup class
      console.log('  📊 Testing Google Sheets setup class...');
      const sheetsSetup = new LegalAISetup();
      console.log('    ✅ LegalAISetup class loaded successfully');
      
      // Test Google Drive setup class
      console.log('  📁 Testing Google Drive setup class...');
      const driveSetup = new GoogleDriveSetup();
      console.log('    ✅ GoogleDriveSetup class loaded successfully');
      
      // Test N8N config updater class
      console.log('  🔧 Testing N8N config updater class...');
      const configUpdater = new N8NConfigUpdater();
      console.log('    ✅ N8NConfigUpdater class loaded successfully');
      
      this.testResults.googleServices = true;
      
    } catch (error) {
      console.error('  ❌ Google services setup test failed:', error.message);
    }
  }

  displayTestResults() {
    console.log('\n📊 TEST RESULTS SUMMARY');
    console.log('='.repeat(50));
    
    const tests = [
      { name: 'Environment Setup', result: this.testResults.environment },
      { name: 'Dependencies', result: this.testResults.dependencies },
      { name: 'Configuration Files', result: this.testResults.configuration },
      { name: 'N8N Workflow', result: this.testResults.workflow },
      { name: 'Google Services Setup', result: this.testResults.googleServices }
    ];
    
    tests.forEach(test => {
      const status = test.result ? '✅ PASS' : '❌ FAIL';
      console.log(`${status} ${test.name}`);
    });
    
    const passedTests = Object.values(this.testResults).filter(result => result).length;
    const totalTests = Object.keys(this.testResults).length;
    
    console.log('='.repeat(50));
    console.log(`📈 Overall Score: ${passedTests}/${totalTests} tests passed`);
    
    if (passedTests === totalTests) {
      console.log('\n🎉 All tests passed! Your Legal AI System is ready for deployment.');
      this.displayNextSteps();
    } else {
      console.log('\n⚠️  Some tests failed. Please address the issues above before proceeding.');
      this.displayTroubleshootingTips();
    }
  }

  displayNextSteps() {
    console.log('\n🚀 NEXT STEPS FOR DEPLOYMENT:');
    console.log('1. Configure your .env file with actual credentials');
    console.log('2. Run: npm run setup-all');
    console.log('3. Run: node update-n8n-config.js');
    console.log('4. Import the workflow JSON into your N8N instance');
    console.log('5. Set up N8N credentials (Gmail, Google Drive, Google Sheets, OpenAI)');
    console.log('6. Test with sample documents');
    console.log('7. Configure team access and permissions');
  }

  displayTroubleshootingTips() {
    console.log('\n🔧 TROUBLESHOOTING TIPS:');
    console.log('• Missing environment variables: Copy .env.example to .env and configure');
    console.log('• Missing dependencies: Run npm install');
    console.log('• Permission issues: Run chmod +x setup-environment.sh');
    console.log('• Google API issues: Check your service account credentials');
    console.log('• N8N workflow issues: Verify the JSON file is valid');
    console.log('\n📚 For detailed setup instructions, see README.md');
  }
}

// Main execution function
async function main() {
  const tester = new LegalAITester();
  await tester.runAllTests();
}

// Export for use in other scripts
module.exports = { LegalAITester };

// Run if called directly
if (require.main === module) {
  main().catch(console.error);
}