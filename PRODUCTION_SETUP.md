# KwizKid Production Setup Guide

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Web Admin     │───▶│   Backend API   │───▶│   iOS App        │
│   (Content CMS) │    │   (Node.js)     │    │   (Consumer)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │   Cloud DB      │
                       │   (Firebase)    │
                       └─────────────────┘
```

## 🚀 Deployment Steps

### 1. Backend API Setup

#### Prerequisites
- Node.js 18+
- Firebase project
- OpenAI API key

#### Setup
```bash
cd backend
npm install
cp env.example .env
# Edit .env with your configuration
npm start
```

#### Environment Variables
```env
# Firebase Configuration
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY_ID=your-private-key-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project-id.iam.gserviceaccount.com

# OpenAI Configuration
OPENAI_API_KEY=sk-your-openai-api-key

# Server Configuration
PORT=3000
NODE_ENV=production
CORS_ORIGIN=https://your-admin-domain.com
```

### 2. Firebase Setup

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create new project: "KwizKid"
3. Enable Firestore Database
4. Generate service account key
5. Download JSON credentials

#### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Questions collection - read for authenticated users
    match /questions/{document} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        request.auth.token.role == 'admin';
    }
    
    // Categories collection - read for all
    match /categories/{document} {
      allow read: if true;
      allow write: if request.auth != null && 
        request.auth.token.role == 'admin';
    }
  }
}
```

### 3. Web Admin Setup

#### Deploy to Static Hosting
```bash
# Option 1: Netlify
cd web-admin
# Upload files to Netlify

# Option 2: Vercel
cd web-admin
vercel --prod

# Option 3: GitHub Pages
# Push to GitHub and enable Pages
```

#### Update API Endpoint
Edit `web-admin/app.js`:
```javascript
this.apiBase = 'https://your-api-domain.com/api';
```

### 4. iOS App Configuration

#### Remove Admin Tools
The iOS app should NOT include admin functionality in production.

#### Update API Configuration
Edit `CloudQuestionService.swift`:
```swift
private let baseURL = "https://your-api-domain.com/api"
```

#### Environment Variables
Add to `Info.plist`:
```xml
<key>API_BASE_URL</key>
<string>https://your-api-domain.com/api</string>
<key>ENVIRONMENT</key>
<string>production</string>
```

## 🔒 Security Considerations

### 1. API Security
- ✅ Rate limiting implemented
- ✅ CORS configured
- ✅ Helmet security headers
- ✅ Input validation with Joi
- ✅ Firebase authentication

### 2. Content Safety
- ✅ AI content filtering
- ✅ Age-appropriate language adjustment
- ✅ Duplicate detection
- ✅ Review workflow

### 3. Data Protection
- ✅ No sensitive data in iOS app
- ✅ API keys on server only
- ✅ User data encrypted in transit
- ✅ GDPR compliant data handling

## 📊 Monitoring & Analytics

### 1. Backend Monitoring
```bash
# Add monitoring
npm install @sentry/node
npm install express-status-monitor
```

### 2. Firebase Analytics
- User engagement tracking
- Question performance metrics
- Error reporting

### 3. Content Analytics
- Question usage statistics
- Performance by category/difficulty
- User progress tracking

## 🚀 Production Deployment

### 1. Backend Deployment (Heroku)
```bash
# Install Heroku CLI
heroku create kwizkid-api
heroku config:set NODE_ENV=production
heroku config:set OPENAI_API_KEY=your-key
# ... set all environment variables
git push heroku main
```

### 2. Backend Deployment (AWS)
```bash
# Using AWS Elastic Beanstalk
eb init
eb create production
eb deploy
```

### 3. Database Setup
```bash
# Initialize Firestore collections
node scripts/init-database.js
```

### 4. Content Population
```bash
# Generate initial content
node scripts/generate-initial-content.js
```

## 📱 iOS App Store Preparation

### 1. Remove Development Code
- Remove admin tools from production build
- Remove debug logging
- Remove test data

### 2. App Store Assets
- App icons (all sizes)
- Screenshots for all device sizes
- App description and keywords
- Privacy policy

### 3. Testing
- Test on multiple devices
- Test offline functionality
- Test content loading
- Test user flows

## 🔄 Content Management Workflow

### 1. Content Creation
1. Admin logs into web interface
2. Selects category, difficulty, age range
3. Generates questions using AI
4. Reviews and approves content
5. Content goes live immediately

### 2. Content Updates
1. Monitor question performance
2. Update underperforming questions
3. Add new categories as needed
4. Seasonal content updates

### 3. Quality Assurance
1. Automated content filtering
2. Manual review process
3. User feedback integration
4. Regular content audits

## 📈 Scaling Considerations

### 1. Database Scaling
- Firestore auto-scales
- Consider sharding for very high volume
- Implement caching layer

### 2. API Scaling
- Load balancing
- CDN for static assets
- Database connection pooling

### 3. Content Scaling
- Batch question generation
- Content versioning
- A/B testing for questions

## 🛠️ Maintenance

### 1. Regular Tasks
- Monitor API performance
- Update content regularly
- Review user feedback
- Security updates

### 2. Backup Strategy
- Automated Firestore backups
- Code repository backups
- Configuration backups

### 3. Monitoring
- Uptime monitoring
- Error tracking
- Performance metrics
- User analytics

## 📞 Support

### 1. User Support
- In-app help system
- FAQ section
- Contact form

### 2. Technical Support
- Error reporting
- Performance monitoring
- Content management

### 3. Content Support
- Question review process
- Content updates
- Category management

---

## 🎯 Next Steps

1. **Set up Firebase project**
2. **Deploy backend API**
3. **Deploy web admin interface**
4. **Update iOS app configuration**
5. **Test end-to-end functionality**
6. **Submit to App Store**

This production setup provides a scalable, secure, and maintainable architecture for KwizKid that can grow with your user base while maintaining high content quality and user experience.


