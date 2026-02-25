# 🦖 Raptor JobSearcher (JobHud)

<div align="center">

![Project Status](https://img.shields.io/badge/status-active-success.svg)
![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat&logo=Flutter&logoColor=white)
![NodeJS](https://img.shields.io/badge/node.js-6DA55F?style=flat&logo=node.js&logoColor=white)
![Express.js](https://img.shields.io/badge/express.js-%23404d59.svg?style=flat&logo=express&logoColor=%2361DAFB)
![MySQL](https://img.shields.io/badge/mysql-%2300f.svg?style=flat&logo=mysql&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

**A Smart Career Guidance & Job Recommendation Platform**

*Empowering job seekers with AI-driven insights, personalized recommendations, and comprehensive career tools*

[Features](#-features) • [Tech Stack](#-tech-stack) • [Quick Start](#-quick-start) • [Contributing](#-contributing)

</div>

---

## � Table of Contents

- [About The Project](#-about-the-project)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Quick Start](#-quick-start)
- [Project Structure](#-project-structure)
- [Configuration](#-configuration)
- [Testing](#-testing)
- [Deployment](#-deployment)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [API Documentation](#-api-documentation)
- [Roadmap](#-roadmap)
- [License](#-license)
- [Author](#-author)
- [Acknowledgments](#-acknowledgments)
- [Support](#-support)

---

## �📖 About The Project

**JobHud** (Raptor JobSearcher) is a comprehensive full-stack career enhancement platform designed to revolutionize the job search experience. Built with Flutter for a seamless cross-platform mobile experience and powered by a robust Node.js backend, JobHud provides users with intelligent job matching, cultural fit analysis, daily career tips, and interview preparation tools.

### 🎯 Why JobHud?

- **🎯 Smart Job Matching**: AI-powered job recommendations based on your profile and preferences
- **🧠 Culture Fit Analysis**: Discover companies that align with your values and work style
- **📚 Daily Career Tips**: Stay ahead with curated career advice and industry insights
- **💼 Comprehensive Tracking**: Save and manage your job applications in one place
- **📈 Skill Development**: Access interview prep resources and tech trends
- **🌐 Cross-Platform**: Works seamlessly on Android, iOS, and Web

---

## ✨ Features

<table>
  <tr>
    <td width="50%">
      
### 🔐 **User Authentication**
- Secure JWT-based authentication
- User registration and login
- Profile management
- Password encryption

### 🎯 **Job Discovery**
- Browse curated job listings
- Advanced filtering options
- Detailed job descriptions
- Company information

    </td>
    <td width="50%">

### 💾 **Saved Jobs**
- Bookmark interesting positions
- Track application status
- Organize your pipeline
- Quick access dashboard

### 🧪 **Culture Quiz**
- Personality assessment
- Company culture matching
- Work environment preferences
- Team fit analysis

    </td>
  </tr>
  <tr>
    <td width="50%">

### 💡 **Daily Tips**
- Career development advice
- Industry insights
- Interview preparation
- Skill enhancement tips

    </td>
    <td width="50%">

### 📊 **Tech Trends**
- Latest industry news
- Technology updates
- Market insights
- Skill demand analysis

    </td>
  </tr>
</table>

---

## 🛠️ Tech Stack

### Frontend
- **Flutter 3.x** - Cross-platform mobile framework
- **Dart** - Programming language
- **Provider** - State management
- **HTTP** - REST API integration
- **Material Design** - UI/UX components

### Backend
- **Node.js** - Runtime environment
- **Express.js** - Web application framework
- **MySQL** - Relational database
- **JWT** - Authentication
- **bcrypt** - Password hashing
- **dotenv** - Environment configuration

---

## 🚀 Quick Start

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.0 or higher) - [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Node.js** (16.x or higher) - [Install Node.js](https://nodejs.org/)
- **MySQL** (8.0 or higher) - [Install MySQL](https://dev.mysql.com/downloads/)
- **Git** - [Install Git](https://git-scm.com/downloads)
- A code editor (VS Code, Android Studio, or IntelliJ IDEA)

### 📥 Installation

#### 1️⃣ Clone the Repository

```bash
git clone https://github.com/your-username/your-repo.git
cd your-repo
```

#### 2️⃣ Backend Setup

```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Create environment file
cp .env.example .env

# Configure your .env file with these variables:
# DB_HOST=localhost
# DB_USER=root
# DB_PASSWORD=yourpassword
# DB_NAME=jobhud
# JWT_SECRET=your_super_secret_jwt_key
# PORT=5000

# Create MySQL database
mysql -u root -p
CREATE DATABASE jobhud;
USE jobhud;
SOURCE schema.sql;  # If you have a schema file
EXIT;

# Start the server
npm start
```

The backend server should now be running on `http://localhost:5000`

#### 3️⃣ Frontend Setup

```bash
# Navigate to frontend directory (from project root)
cd jobhud

# Install Flutter dependencies
flutter pub get

# Update API endpoint in lib/services/api_service.dart
# For Android Emulator:
# final String baseUrl = "http://10.0.2.2:5000";
# For iOS Simulator:
# final String baseUrl = "http://localhost:5000";
# For Web:
# final String baseUrl = "http://localhost:5000";

# Run the app
flutter run

# Or run on specific platform:
flutter run -d chrome        # For web
flutter run -d android       # For Android
flutter run -d ios           # For iOS
```

---

## 📁 Project Structure

### Backend Architecture

```
backend/
├── middleware/              # Custom middleware (auth, validation, etc.)
│   └── authMiddleware.js
├── routes/                  # API route definitions
│   ├── auth.js             # Authentication routes
│   ├── jobs.js             # Job-related routes
│   ├── profile.js          # User profile routes
│   └── tips.js             # Daily tips routes
├── services/               # Business logic layer
│   ├── authService.js      # Authentication service
│   ├── jobService.js       # Job service
│   └── userService.js      # User service
├── models/                 # Database models
│   ├── User.js
│   ├── Job.js
│   └── SavedJob.js
├── config/                 # Configuration files
│   └── database.js         # Database configuration
├── utils/                  # Utility functions
│   └── validators.js
├── .env                    # Environment variables
├── .gitignore
├── server.js               # Main application entry point
└── package.json            # Dependencies
```

### Frontend Architecture

```
jobhud/
├── lib/
│   ├── main.dart           # App entry point
│   ├── models/             # Data models
│   │   ├── user.dart
│   │   ├── job.dart
│   │   └── tip.dart
│   ├── providers/          # State management
│   │   ├── auth_provider.dart
│   │   ├── job_provider.dart
│   │   └── theme_provider.dart
│   ├── screens/            # UI screens
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── dashboard/
│   │   │   ├── home_screen.dart
│   │   │   ├── jobs_screen.dart
│   │   │   └── saved_jobs_screen.dart
│   │   └── profile/
│   │       └── profile_screen.dart
│   ├── services/           # API services
│   │   ├── api_service.dart
│   │   └── auth_service.dart
│   ├── widgets/            # Reusable components
│   │   ├── job_card.dart
│   │   └── custom_button.dart
│   └── utils/              # Utilities
│       ├── constants.dart
│       └── theme.dart
├── android/                # Android platform files
├── ios/                    # iOS platform files
├── web/                    # Web platform files
├── assets/                 # Images, fonts, etc.
├── test/                   # Unit tests
├── pubspec.yaml            # Flutter dependencies
└── README.md
```

---

## 🔧 Configuration

### Database Schema

Create these tables in your MySQL database:

```sql
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE jobs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    company VARCHAR(255) NOT NULL,
    location VARCHAR(255),
    description TEXT,
    requirements TEXT,
    salary_range VARCHAR(100),
    job_type ENUM('Full-time', 'Part-time', 'Contract', 'Internship'),
    posted_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE saved_jobs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    job_id INT NOT NULL,
    saved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
    UNIQUE KEY unique_save (user_id, job_id)
);

CREATE TABLE daily_tips (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    category VARCHAR(100),
    published_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Environment Variables

Create a `.env` file in the backend directory:

```env
# Database Configuration
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=jobhud
DB_PORT=3306

# Server Configuration
PORT=5000
NODE_ENV=development

# JWT Configuration
JWT_SECRET=your_super_secret_jwt_key_change_this_in_production
JWT_EXPIRE=7d

# API Configuration
API_VERSION=v1
```

---

## 🧪 Testing

### Backend Tests

```bash
cd backend
npm test
```

### Frontend Tests

```bash
cd jobhud
flutter test
```

### API Testing with cURL

```bash
# Get daily tips
curl http://localhost:5000/api/tips/daily

# User login
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123"}'

# Get jobs (with auth token)
curl http://localhost:5000/api/jobs \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## 🚀 Deployment

### Backend Deployment

1. **Prepare for Production**:
   - Set `NODE_ENV=production` in your environment variables
   - Ensure all dependencies are installed: `npm install --production`
   - Run database migrations if any

2. **Deploy Options**:
   - **Heroku**: Push to Heroku git, set environment variables
   - **Vercel**: Use Vercel CLI or connect GitHub repo
   - **AWS/DigitalOcean**: Use PM2 or Docker for containerization

3. **Example with Heroku**:
   ```bash
   heroku create your-app-name
   heroku config:set JWT_SECRET=your_secret_key
   heroku config:set DB_HOST=your_db_host
   git push heroku main
   ```

### Frontend Deployment

1. **Build the App**:
   ```bash
   flutter build apk          # For Android
   flutter build ios          # For iOS
   flutter build web          # For Web
   ```

2. **Deploy**:
   - **Android**: Upload APK to Google Play Store
   - **iOS**: Upload to App Store Connect
   - **Web**: Host on Firebase, Netlify, or Vercel

---

## 🔧 Troubleshooting

### Common Issues

- **Backend Connection Issues**: Ensure the backend server is running and the API endpoint in `api_service.dart` is correct.
- **Database Errors**: Check MySQL connection settings in `.env`.
- **Flutter Build Errors**: Run `flutter clean` and `flutter pub get`.
- **Authentication Problems**: Verify JWT secret and token expiration.

### Getting Help

- Check the [Issues](https://github.com/your-repo/issues) page on GitHub
- Join our community discussions

---

We love contributions! Here's how you can help make JobHud better:

### Contributing Guidelines

1. **Fork the Repository**
   ```bash
   # Click the "Fork" button on GitHub
   ```

2. **Clone Your Fork**
   ```bash
   git clone https://github.com/YOUR-USERNAME/Raptor-JobSearcher.git
   cd Raptor-JobSearcher
   ```

3. **Create a Feature Branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```

4. **Make Your Changes**
   - Write clean, readable code
   - Follow existing code style
   - Add comments where necessary
   - Update documentation if needed

5. **Test Your Changes**
   ```bash
   # Backend
   cd backend && npm test
   
   # Frontend
   cd jobhud && flutter test
   ```

6. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "Add: amazing new feature"
   ```

   **Commit Message Convention:**
   - `Add:` for new features
   - `Fix:` for bug fixes
   - `Update:` for updates to existing features
   - `Refactor:` for code refactoring
   - `Docs:` for documentation changes

7. **Push to Your Fork**
   ```bash
   git push origin feature/amazing-feature
   ```

8. **Open a Pull Request**
   - Go to the original repository
   - Click "New Pull Request"
   - Select your feature branch
   - Describe your changes in detail

### 🐛 Bug Reports

Found a bug? Please open an issue with:
- Clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Screenshots (if applicable)
- Your environment (OS, Flutter version, Node version)

### 💡 Feature Requests

Have an idea? We'd love to hear it! Open an issue with:
- Clear description of the feature
- Use cases and benefits
- Any implementation ideas

---

## 📝 API Documentation

### Authentication Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/auth/register` | Register new user | No |
| POST | `/api/auth/login` | Login user | No |
| GET | `/api/auth/profile` | Get user profile | Yes |
| PUT | `/api/auth/profile` | Update profile | Yes |

### Job Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/jobs` | Get all jobs | No |
| GET | `/api/jobs/:id` | Get job by ID | No |
| GET | `/api/jobs/saved` | Get saved jobs | Yes |
| POST | `/api/jobs/save/:id` | Save a job | Yes |
| DELETE | `/api/jobs/unsave/:id` | Remove saved job | Yes |

### Tips Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/tips/daily` | Get daily tip | No |
| GET | `/api/tips` | Get all tips | No |

---

## 🗺️ Roadmap

- [x] User authentication system
- [x] Job browsing and search
- [x] Save jobs functionality
- [x] Daily tips feature
- [x] Profile management
- [ ] Advanced job filtering
- [ ] AI-powered job recommendations
- [ ] Resume builder
- [ ] Application tracking system
- [ ] Company reviews
- [ ] Salary insights
- [ ] Video interview preparation
- [ ] Networking features
- [ ] Mobile notifications
- [ ] Dark mode support

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Lokesh**

- GitHub: [@lokesh](https://github.com/lokesh)
- LinkedIn: [Your LinkedIn Profile](#)
- Email: [your.email@example.com](#)

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Express.js community for the robust backend framework
- All contributors who help improve this project
- Open source community for inspiration and resources

---

## 📞 Support

Need help? Here's how to get support:

- 📧 **Email**: Open an issue on GitHub
- 💬 **Discussions**: Use GitHub Discussions for questions
- 🐛 **Bug Reports**: Open an issue with the bug template
- 💡 **Feature Requests**: Open an issue with the feature template

---

## ⭐ Show Your Support

If you find this project helpful, please consider:

- Giving it a ⭐️ on GitHub
- Sharing it with others
- Contributing to the codebase
- Reporting bugs or suggesting features

---

<div align="center">

**Made with ❤️ by Lokesh**

*Happy Job Hunting! 🎯*

</div>
