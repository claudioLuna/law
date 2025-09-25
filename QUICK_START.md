# Legal AI System - Quick Start Guide

Get your Legal AI System up and running in 30 minutes with this quick start guide.

## ⚡ 5-Minute Setup

### 1. Prerequisites Check
- [ ] Google Cloud account
- [ ] OpenAI API key
- [ ] Gmail account
- [ ] N8N instance

### 2. Run Automated Setup
```bash
# Make executable and run
chmod +x setup-environment.sh
./setup-environment.sh

# Configure your credentials
cp .env.example .env
# Edit .env with your actual values

# Set up Google services
npm run setup-all

# Update N8N configuration
node update-n8n-config.js
```

### 3. Import to N8N
1. Copy `legal-ai-system-n8n-workflow.json` content
2. Import into N8N
3. Configure credentials
4. Test workflows

## 🎯 Essential Configuration

### Google Cloud (5 minutes)
1. Create project in [Google Cloud Console](https://console.cloud.google.com/)
2. Enable APIs: Sheets, Drive, Gmail
3. Create service account → Download JSON key
4. Create OAuth2 credentials

### OpenAI (2 minutes)
1. Get API key from [OpenAI Platform](https://platform.openai.com/)
2. Add credits to account
3. Update `.env` file

### Gmail OAuth2 (5 minutes)
1. Use Google Cloud OAuth2 credentials
2. Generate refresh token
3. Update `.env` file

## 🧪 Quick Test

### Test Document Processing
```bash
# Send email with PDF attachment to your Gmail
# Check Google Drive for saved document
# Verify summary in Google Sheets
# Confirm email notification sent
```

### Test Contract Analysis
```bash
# Upload contract to Google Drive folder
# Check analysis in Google Sheets
# Verify email report sent
```

### Test AI Agent
```bash
# Ask in N8N chat: "What deadlines are due soon?"
# Verify response with document data
```

## 🔧 Common Issues & Solutions

### "Authentication failed"
- Check Google service account JSON key
- Verify APIs are enabled
- Ensure OAuth2 tokens are valid

### "Permission denied"
- Check Google Drive folder permissions
- Verify service account access
- Confirm Google Sheets sharing

### "Invalid workflow"
- Update N8N to latest version
- Check JSON syntax
- Verify node types supported

## 📞 Need Help?

1. **Quick Issues**: Check this guide
2. **Setup Problems**: See `README.md`
3. **Full Deployment**: See `DEPLOYMENT_GUIDE.md`
4. **Technical Details**: See `ai-prompts.md`

## 🚀 You're Ready!

Your Legal AI System is now processing documents, analyzing contracts, and providing AI-powered legal assistance!

**Next Steps:**
- Train your team on the system
- Set up monitoring and alerts
- Customize prompts for your practice area
- Scale up for production use