# Legal AI System for N8N

A comprehensive legal AI system that automates document processing, contract analysis, and legal memo generation using N8N workflows. This system replicates the functionality shown in the referenced video, providing a complete legal automation solution for law firms.

## 🎯 Features

### Core Workflows
- **📧 Document Summary Workflow**: Automatically processes incoming legal documents via Gmail
- **📋 Contract Analysis Workflow**: Analyzes contracts uploaded to Google Drive  
- **🤖 Main AI Agent**: Central hub that can access all information and draft legal memos
- **📊 Google Sheets Integration**: Stores all processed data in organized spreadsheets
- **📨 Email Automation**: Sends summaries and memos to legal teams

### AI Capabilities
- **Document Analysis**: Extracts key issues, deadlines, and summaries from legal documents
- **Contract Review**: Identifies critical clauses and risk assessments
- **Legal Memo Generation**: Creates comprehensive internal memos with legal analysis
- **Deadline Tracking**: Monitors and alerts on upcoming legal deadlines
- **Query Processing**: Natural language queries about cases, contracts, and legal matters

## 🏗️ System Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Gmail Trigger │    │  Google Drive    │    │   Chat Trigger  │
│  (Documents)    │    │   Trigger        │    │  (Main Agent)   │
│                 │    │  (Contracts)     │    │                 │
└─────────┬───────┘    └─────────┬────────┘    └─────────┬───────┘
          │                      │                       │
          ▼                      ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│ Document        │    │ Contract         │    │ Main AI Agent   │
│ Analysis        │    │ Analysis         │    │ (Legal Assistant)│
│ Workflow        │    │ Workflow         │    │                 │
└─────────┬───────┘    └─────────┬────────┘    └─────────┬───────┘
          │                      │                       │
          ▼                      ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│ Google Sheets   │    │ Google Sheets    │    │ Gmail Sender    │
│ (Summaries)     │    │ (Contracts)      │    │ (Memos)         │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 📋 Prerequisites

### Required Software
- **Node.js** (v16 or higher)
- **npm** (v8 or higher)
- **N8N** instance (self-hosted or cloud)

### Required Accounts & APIs
- **Google Cloud Platform** account with billing enabled
- **OpenAI API** key with GPT-4 access
- **Gmail** account for email processing
- **Google Drive** for document storage
- **Google Sheets** for data management

### Required Permissions
- Google Sheets API access
- Google Drive API access
- Gmail API access
- OpenAI API access

## 🚀 Installation

### 1. Quick Setup (Recommended)

```bash
# Clone or download all files to your project directory
# Make the setup script executable
chmod +x setup-environment.sh

# Run the automated setup
./setup-environment.sh
```

### 2. Manual Setup

```bash
# Install dependencies
npm install

# Copy environment template
cp .env.example .env

# Edit .env with your actual configuration values
# (See Configuration section below)

# Set up Google Sheets
npm run setup-sheets

# Set up Google Drive folders
npm run setup-drive

# Update N8N workflow configuration
node update-n8n-config.js

# Test the setup
npm test
```

## ⚙️ Configuration

### 1. Google Cloud Setup

#### Create a Google Cloud Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable billing for the project

#### Enable Required APIs
```bash
# Enable these APIs in Google Cloud Console:
- Google Sheets API
- Google Drive API  
- Gmail API
```

#### Create Service Account
1. Go to IAM & Admin > Service Accounts
2. Create a new service account
3. Download the JSON key file
4. Update `.env` file with the credentials

### 2. OpenAI Setup

1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Create an API key
3. Add credits to your account
4. Update `.env` file with the API key

### 3. Gmail Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create OAuth2 credentials for Gmail
3. Configure authorized redirect URIs
4. Generate refresh token
5. Update `.env` file with OAuth2 credentials

### 4. Environment Variables

Edit your `.env` file with the following values:

```bash
# Google Service Account (from JSON key file)
GOOGLE_PROJECT_ID=your-project-id
GOOGLE_PRIVATE_KEY_ID=your-private-key-id
GOOGLE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY\n-----END PRIVATE KEY-----\n"
GOOGLE_CLIENT_EMAIL=your-service-account@your-project.iam.gserviceaccount.com
GOOGLE_CLIENT_ID=your-client-id

# OpenAI API
OPENAI_API_KEY=your-openai-api-key

# Gmail OAuth2
GMAIL_USER_EMAIL=your-email@gmail.com
GMAIL_CLIENT_ID=your-gmail-client-id
GMAIL_CLIENT_SECRET=your-gmail-client-secret
GMAIL_REFRESH_TOKEN=your-gmail-refresh-token

# Legal Team
LEGAL_TEAM_EMAIL=legal-team@yourfirm.com
```

## 📁 File Structure

```
legal-ai-system/
├── legal-ai-system-n8n-workflow.json    # Main N8N workflow
├── setup-google-sheets.js               # Google Sheets setup script
├── setup-google-drive.js                # Google Drive setup script
├── setup-environment.sh                 # Environment setup script
├── update-n8n-config.js                 # N8N configuration updater
├── test-workflow.js                     # Test script
├── ai-prompts.md                        # AI prompts documentation
├── package.json                         # Node.js dependencies
├── .env.example                         # Environment template
├── .env                                 # Your configuration (create this)
└── README.md                           # This file
```

## 🎮 Usage

### Document Processing Workflow

1. **Send legal documents** to your configured Gmail account
2. **System automatically**:
   - Downloads and saves documents to Google Drive
   - Extracts text using AI
   - Analyzes content for key issues and deadlines
   - Saves structured summaries to Google Sheets
   - Sends email notifications to your legal team

### Contract Analysis Workflow

1. **Upload contracts** to the designated Google Drive folder
2. **System automatically**:
   - Downloads and analyzes contracts
   - Identifies key clauses (termination, indemnity, etc.)
   - Assesses risk levels (Low, Medium, High)
   - Saves detailed analysis to Google Sheets
   - Sends comprehensive reports via email

### AI Legal Assistant

Use the chat interface in N8N to ask questions like:

```
"What deadlines are due soon?"
"What are the key issues in the Acme vs Zephyr case?"
"Draft an internal memo for the contract review"
"What indemnity clauses exist in our contracts?"
"Show me all high-risk contracts from last month"
"What's the status of pending complaints?"
```

### Example Interactions

#### Document Queries
```
User: "What deadlines are due soon?"
AI: "There's an upcoming deadline on June 29th for the case Acme versus Zephyr regarding breach of contract. The key issues include non-compliance and failure to cure defects."

User: "What are the key issues in the Acme vs Zephyr complaint?"
AI: "The key issues are: 1) Breach of contract, 2) Non-compliance with terms, 3) Failure to cure defects, 4) Dispute over deposit, 5) Jurisdiction and venue. Would you like a detailed memo on these issues?"
```

#### Contract Queries
```
User: "Are there any indemnity clauses in our recent contracts?"
AI: "The Services Agreement between Alpha Legal Services and Beta Corp contains an indemnity clause. It's located in Section 4.2 and is assessed as Medium Risk. The clause states: 'Client agrees to indemnify Provider against all claims arising from Client's use of services.'"

User: "Show me all high-risk contracts"
AI: "I found 2 high-risk contracts: 1) Technology Services Agreement with TechCorp (indemnity clause), 2) Consulting Agreement with StartupXYZ (limitation of liability clause)."
```

#### Memo Generation
```
User: "Please draft an internal memo for the Acme versus Zephyr complaint"
AI: [Generates comprehensive memo with Statement of Facts, Issues Presented, Legal Analysis, and Recommendations]
```

## 🔧 N8N Configuration

### 1. Import Workflow

1. Open your N8N instance
2. Go to Workflows > Import from File
3. Select `legal-ai-system-n8n-workflow.json`
4. The workflow will be imported with all nodes configured

### 2. Configure Credentials

Set up the following credentials in N8N:

#### Gmail OAuth2
- **Client ID**: Your Gmail OAuth2 client ID
- **Client Secret**: Your Gmail OAuth2 client secret
- **Scope**: `https://www.googleapis.com/auth/gmail.readonly https://www.googleapis.com/auth/gmail.send`

#### Google Drive OAuth2
- **Client ID**: Your Google OAuth2 client ID  
- **Client Secret**: Your Google OAuth2 client secret
- **Scope**: `https://www.googleapis.com/auth/drive`

#### Google Sheets OAuth2
- **Client ID**: Your Google OAuth2 client ID
- **Client Secret**: Your Google OAuth2 client secret  
- **Scope**: `https://www.googleapis.com/auth/spreadsheets`

#### OpenAI API
- **API Key**: Your OpenAI API key
- **Organization ID**: (Optional) Your OpenAI organization ID

### 3. Test Workflows

1. **Test Document Processing**:
   - Send a test email with a PDF attachment
   - Check if the workflow triggers and processes the document

2. **Test Contract Analysis**:
   - Upload a contract to the designated Google Drive folder
   - Verify the analysis is generated and saved

3. **Test AI Agent**:
   - Use the chat interface to ask questions
   - Verify responses are accurate and helpful

## 📊 Google Sheets Structure

### Legal Document Summaries Sheet
| Column | Description |
|--------|-------------|
| Date | Date document was received |
| Subject | Email subject line |
| Issue 1-5 | Key legal issues identified |
| Deadline | Calculated deadline based on jurisdiction |
| Full Summary | Complete AI-generated summary |

### Contract Analysis Sheet
| Column | Description |
|--------|-------------|
| Contract | Contract name/identifier |
| Analysis | Complete AI analysis with clause breakdown |

## 📁 Google Drive Structure

```
Legal AI - Complaints and Contracts/
├── Incoming Documents/          # Documents received via email
└── Processed Documents/         # Documents that have been analyzed

Legal AI - Contract Analysis/
├── Pending Analysis/           # Contracts waiting for AI analysis
├── Completed Analysis/         # Contracts that have been analyzed
└── High Risk Contracts/        # Contracts flagged as high risk
```

## 🛠️ Troubleshooting

### Common Issues

#### Authentication Errors
**Problem**: "Authentication failed" or "Invalid credentials"
**Solution**: 
- Verify your Google service account credentials in `.env`
- Check that APIs are enabled in Google Cloud Console
- Ensure OAuth2 tokens are valid and not expired

#### Sheet/Folder Access Issues
**Problem**: "Permission denied" or "File not found"
**Solution**:
- Verify folder IDs in the workflow are correct
- Check sharing permissions on Google Drive folders
- Ensure service account has access to all required resources

#### N8N Import Issues
**Problem**: "Invalid workflow" or "Node not found"
**Solution**:
- Verify the workflow JSON is valid JSON
- Check that all node types are supported in your N8N version
- Update N8N to the latest version

#### AI Model Errors
**Problem**: "OpenAI API error" or "Invalid model"
**Solution**:
- Verify your OpenAI API key is correct
- Check that you have sufficient credits
- Ensure the model name is correct (gpt-4o-mini)

### Debug Mode

Enable debug mode by setting in your `.env`:
```bash
ENABLE_DEBUG_MODE=true
LOG_LEVEL=debug
```

### Testing Individual Components

```bash
# Test environment setup
npm test

# Test Google Sheets setup
npm run setup-sheets

# Test Google Drive setup  
npm run setup-drive

# Test configuration update
node update-n8n-config.js
```

## 🔒 Security Considerations

### Data Privacy
- All data is processed through your own Google and OpenAI accounts
- No data is stored on external servers
- Documents are stored in your own Google Drive

### Access Control
- Use service accounts with minimal required permissions
- Regularly rotate API keys and credentials
- Monitor API usage and costs

### Compliance
- Ensure compliance with your jurisdiction's data protection laws
- Consider client confidentiality requirements
- Implement appropriate data retention policies

## 📈 Performance Optimization

### Cost Management
- Monitor OpenAI API usage and costs
- Use GPT-4o-mini for most tasks (cost-effective)
- Implement rate limiting if needed

### Efficiency Tips
- Process documents in batches during off-peak hours
- Use appropriate AI model for task complexity
- Optimize prompts for better accuracy and efficiency

## 🤝 Support & Contributing

### Getting Help
1. Check this README for common issues
2. Review the N8N documentation
3. Verify your Google Cloud setup
4. Test individual components using the test script

### Contributing
Contributions are welcome! Areas for improvement:
- Additional legal document types
- More sophisticated AI prompts
- Integration with other legal software
- Performance optimizations

### License
MIT License - Feel free to modify and use for your legal practice.

## 📚 Additional Resources

- [N8N Documentation](https://docs.n8n.io/)
- [Google Cloud APIs Documentation](https://cloud.google.com/docs)
- [OpenAI API Documentation](https://platform.openai.com/docs)
- [Google Sheets API Documentation](https://developers.google.com/sheets/api)
- [Google Drive API Documentation](https://developers.google.com/drive/api)

---

**Note**: This system is designed to assist legal professionals but should not replace professional legal judgment. Always review AI-generated content before using it in legal proceedings.