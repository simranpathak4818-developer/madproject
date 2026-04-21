# Academic Resource Sharing and Communication System

A Flutter + Firebase Android application for managing academic resources, materials, and communication between faculty and students.

## Features

✅ **User Authentication**
- Role-based login (Faculty/Student)
- Email-based authentication
- User profile management

✅ **Material Management**
- Faculty can upload study materials (PDF, PPT, DOC, etc.)
- Materials are visible only to correct branch → semester → section
- Students can view and download materials
- Download count tracking

✅ **1-on-1 Messaging**
- Private chat between students and faculty
- Real-time message updates
- Message timestamps

✅ **Group Study/Collaborative Learning**
- Students can create study groups
- Group messaging for doubt solving
- Member management

✅ **PDF Viewer**
- In-app PDF viewing
- Page navigation
- Zoom support

## Project Structure

```
lib/
├── main.dart
├── firebase_options.dart
├── models/
│   ├── user_model.dart
│   ├── material_model.dart
│   ├── message_model.dart
│   └── group_chat_model.dart
├── providers/
│   └── auth_provider.dart
├── services/
│   ├── firestore_service.dart
│   └── storage_service.dart
├── screens/
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── upload_material_screen.dart
│   ├── view_materials_screen.dart
│   ├── pdf_viewer_screen.dart
│   ├── my_materials_screen.dart
│   ├── messaging_screen.dart
│   └── group_chat_screen.dart
└── constants/
    └── constants.dart
```

## Setup Instructions

### 1. Prerequisites
- Flutter SDK (>=3.0.0)
- Android SDK
- Firebase project
- Git

### 2. Create Flutter Project

```bash
flutter create academicapp
cd academicapp
```

### 3. Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create new project: "academicapp"
3. Add Android app
4. Package name: `com.example.academicapp`
5. Download `google-services.json`
6. Place in `android/app/`

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Run the App

```bash
flutter run
```

## Firebase Security Rules

### Firestore

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    match /materials/{materialId} {
      allow read: if true;
      allow create, update, delete: if request.auth.uid != null;
    }
    
    match /chats/{chatId}/messages/{messageId} {
      allow read, write: if request.auth.uid != null;
    }
    
    match /groupChats/{groupId}/messages/{messageId} {
      allow read, write: if request.auth.uid != null;
    }
  }
}
```

### Storage

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /materials/{userId}/{fileName} {
      allow read: if true;
      allow write: if request.auth.uid == userId;
    }
  }
}
```

## Features Usage

### Faculty Features
- Upload materials
- Manage materials
- Chat with students
- View group discussions

### Student Features
- View materials
- Download files
- View PDFs in-app
- Chat with faculty
- Create study groups
- Collaborative learning

## Dependencies

- firebase_core
- firebase_auth
- cloud_firestore
- firebase_storage
- provider
- file_picker
- pdfx
- intl
- uuid
- cached_network_image
- url_launcher
- google_fonts

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License

## Support

For issues and questions, please create an issue on GitHub.

---

**Made with ❤️ for Academic Excellence**