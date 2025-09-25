# Legal AI System - Deployment Guide

This guide provides step-by-step instructions for deploying the Legal AI System in your N8N environment.

## 🎯 Pre-Deployment Checklist

### Required Accounts & Services
- [ ] Google Cloud Platform account with billing enabled
- [ ] OpenAI API account with GPT-4 access
- [ ] Gmail account for email processing
- [ ] N8N instance (self-hosted or cloud)
- [ ] Domain or server for hosting (if self-hosting N8N)

### Required APIs & Permissions
- [ ] Google Sheets API enabled
- [ ] Google Drive API enabled
- [ ] Gmail API enabled
- [ ] OpenAI API access
- [ ] Service account with appropriate permissions

## 🚀 Step-by-Step Deployment

### Phase 1: Environment Setup

#### 1.1 Download and Extract Files
```bash
# Create project directory
mkdir legal-ai-system
cd legal-ai-system

# Copy all provided files to this directory
# Files to include:
# - legal-ai-system-n8n-workflow.json
# - setup-google-sheets.js
# - setup-google-drive.js
# - setup-environment.sh
# - update-n8n-config.js
# - test-workflow.js
# - ai-prompts.md
# - package.json
# - .env.example
# - README.md
# - DEPLOYMENT_GUIDE.md
```

#### 1.2 Run Automated Setup
```bash
# Make setup script executable
chmod +x setup-environment.sh

# Run the setup
./setup-environment.sh
```

#### 1.3 Verify Installation
```bash
# Test the installation
npm test
```

### Phase 2: Google Cloud Configuration

#### 2.1 Create Google Cloud Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click "Select a project" > "New Project"
3. Enter project name: "Legal AI System"
4. Click "Create"

#### 2.2 Enable Required APIs
1. Go to "APIs & Services" > "Library"
2. Enable the following APIs:
   - Google Sheets API
   - Google Drive API
   - Gmail API
   - Google+ API (for OAuth)

#### 2.3 Create Service Account
1. Go to "IAM & Admin" > "Service Accounts"
2. Click "Create Service Account"
3. Name: "legal-ai-service-account"
4. Description: "Service account for Legal AI System"
5. Click "Create and Continue"
6. Grant roles:
   - Editor (for Google Drive)
   - Service Account User
7. Click "Done"

#### 2.4 Generate Service Account Key
1. Click on the created service account
2. Go to "Keys" tab
3. Click "Add Key" > "Create New Key"
4. Select "JSON" format
5. Download the key file
6. Save as `service-account-key.json`

#### 2.5 Set up OAuth2 Credentials
1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "OAuth client ID"
3. Application type: "Web application"
4. Name: "Legal AI System OAuth"
5. Authorized redirect URIs:
   - `http://localhost:5678/rest/oauth2-credential/callback`
   - `https://your-n8n-domain.com/rest/oauth2-credential/callback`
6. Click "Create"
7. Download the credentials JSON

### Phase 3: OpenAI Configuration

#### 3.1 Create OpenAI Account
1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Sign up or log in
3. Go to "API Keys"
4. Click "Create new secret key"
5. Name: "Legal AI System"
6. Copy the API key

#### 3.2 Add Credits
1. Go to "Billing" in OpenAI dashboard
2. Add payment method
3. Add initial credits ($20-50 recommended for testing)

### Phase 4: Environment Configuration

#### 4.1 Configure Environment Variables
```bash
# Copy the example environment file
cp .env.example .env

# Edit the .env file with your actual values
nano .env
```

#### 4.2 Update .env File
```bash
# Google Service Account (from downloaded JSON key)
GOOGLE_PROJECT_ID=your-actual-project-id
GOOGLE_PRIVATE_KEY_ID=your-actual-private-key-id
GOOGLE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYOUR_ACTUAL_PRIVATE_KEY\n-----END PRIVATE KEY-----\n"
GOOGLE_CLIENT_EMAIL=your-service-account@your-project.iam.gserviceaccount.com
GOOGLE_CLIENT_ID=your-actual-client-id

# OpenAI API
OPENAI_API_KEY=your-actual-openai-api-key

# Gmail OAuth2 (from OAuth2 credentials JSON)
GMAIL_USER_EMAIL=your-email@gmail.com
GMAIL_CLIENT_ID=your-actual-oauth-client-id
GMAIL_CLIENT_SECRET=your-actual-oauth-client-secret
GMAIL_REFRESH_TOKEN=your-actual-refresh-token

# Legal Team
LEGAL_TEAM_EMAIL=legal-team@yourfirm.com
```

### Phase 5: Google Services Setup

#### 5.1 Set up Google Sheets
```bash
# Run the Google Sheets setup script
npm run setup-sheets
```

#### 5.2 Set up Google Drive Folders
```bash
# Run the Google Drive setup script
npm run setup-drive
```

#### 5.3 Update N8N Configuration
```bash
# Update the workflow with your actual IDs
node update-n8n-config.js
```

### Phase 6: N8N Deployment

#### 6.1 Install N8N (if self-hosting)
```bash
# Install N8N globally
npm install n8n -g

# Start N8N
n8n start
```

#### 6.2 Access N8N Interface
1. Open browser to `http://localhost:5678`
2. Complete the initial setup wizard
3. Create your admin account

#### 6.3 Configure Credentials in N8N

##### Gmail OAuth2 Credential
1. Go to "Credentials" in N8N
2. Click "Add Credential"
3. Select "Gmail OAuth2 API"
4. Fill in:
   - Client ID: From your OAuth2 credentials
   - Client Secret: From your OAuth2 credentials
5. Click "Connect my account"
6. Complete OAuth flow

##### Google Drive OAuth2 Credential
1. Create new credential
2. Select "Google Drive OAuth2 API"
3. Use same OAuth2 client ID and secret
4. Complete OAuth flow

##### Google Sheets OAuth2 Credential
1. Create new credential
2. Select "Google Sheets OAuth2 API"
3. Use same OAuth2 client ID and secret
4. Complete OAuth flow

##### OpenAI API Credential
1. Create new credential
2. Select "OpenAI API"
3. Enter your OpenAI API key

#### 6.4 Import Workflow
1. Go to "Workflows" in N8N
2. Click "Import from File"
3. Select `legal-ai-system-n8n-workflow.json`
4. Click "Import"

#### 6.5 Configure Workflow Nodes
1. Open the imported workflow
2. Update any remaining placeholder values
3. Test each node individually

### Phase 7: Testing & Validation

#### 7.1 Test Document Processing
1. Send a test email with a PDF attachment to your configured Gmail
2. Check if the workflow triggers
3. Verify document is saved to Google Drive
4. Check if summary is created in Google Sheets
5. Verify email notification is sent

#### 7.2 Test Contract Analysis
1. Upload a contract to the designated Google Drive folder
2. Check if the workflow triggers
3. Verify analysis is generated
4. Check if results are saved to Google Sheets
5. Verify email notification is sent

#### 7.3 Test AI Agent
1. Open the chat interface in N8N
2. Ask test questions:
   - "What deadlines are due soon?"
   - "Show me contract summaries"
   - "Draft a memo for case XYZ"

#### 7.4 Performance Testing
```bash
# Run comprehensive tests
npm test

# Test individual components
node test-workflow.js
```

### Phase 8: Production Deployment

#### 8.1 Security Hardening
1. Use environment-specific credentials
2. Enable HTTPS for N8N
3. Set up proper firewall rules
4. Configure SSL certificates

#### 8.2 Monitoring Setup
1. Set up logging for all workflows
2. Configure alerting for failures
3. Monitor API usage and costs
4. Set up backup procedures

#### 8.3 Team Access Configuration
1. Set up team member access to N8N
2. Configure appropriate permissions
3. Train team on system usage
4. Document procedures and workflows

## 🔧 Troubleshooting

### Common Deployment Issues

#### Google API Errors
**Problem**: "API not enabled" or "Quota exceeded"
**Solution**:
- Verify all required APIs are enabled
- Check quota limits in Google Cloud Console
- Monitor API usage

#### Authentication Failures
**Problem**: "Invalid credentials" or "Access denied"
**Solution**:
- Verify service account key is correct
- Check OAuth2 configuration
- Ensure proper scopes are set

#### N8N Import Issues
**Problem**: "Invalid workflow" or "Node not found"
**Solution**:
- Verify N8N version compatibility
- Check node types are supported
- Validate JSON syntax

### Performance Issues

#### Slow Processing
**Problem**: Workflows taking too long
**Solution**:
- Check API rate limits
- Optimize prompts for efficiency
- Consider using faster AI models

#### High Costs
**Problem**: Unexpected API charges
**Solution**:
- Monitor OpenAI usage
- Use cost-effective models
- Implement usage limits

## 📊 Monitoring & Maintenance

### Regular Maintenance Tasks
1. **Weekly**: Check API usage and costs
2. **Monthly**: Review and update AI prompts
3. **Quarterly**: Update dependencies and security patches
4. **Annually**: Review and optimize system performance

### Monitoring Checklist
- [ ] API usage within limits
- [ ] Workflow execution success rates
- [ ] System performance metrics
- [ ] Security logs and alerts
- [ ] Backup verification

## 🚀 Go-Live Checklist

### Pre-Launch
- [ ] All tests passing
- [ ] Credentials configured correctly
- [ ] Team trained on system usage
- [ ] Documentation complete
- [ ] Backup procedures in place

### Launch Day
- [ ] Monitor system performance
- [ ] Verify all workflows functioning
- [ ] Check email notifications working
- [ ] Test AI agent responses
- [ ] Monitor API usage

### Post-Launch
- [ ] Gather user feedback
- [ ] Monitor system performance
- [ ] Address any issues promptly
- [ ] Plan future enhancements

## 📞 Support

### Getting Help
1. Check this deployment guide
2. Review the main README.md
3. Test individual components
4. Check N8N and Google Cloud documentation

### Emergency Procedures
1. **System Down**: Check N8N service status
2. **API Errors**: Verify credentials and quotas
3. **Data Issues**: Check Google Sheets permissions
4. **Performance Issues**: Monitor API usage

---

**Congratulations!** Your Legal AI System is now deployed and ready to automate your legal workflows.