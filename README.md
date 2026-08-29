# Smart Hostel Management System with Facial Recognition

A full-stack **hostel management application** that combines a Flutter mobile interface, PHP REST APIs, MySQL database, and a Python-based facial recognition module to automate hostel operations, attendance tracking, and identity verification.

## Overview

The **Smart Hostel Management System** is designed to digitize day-to-day hostel activities through a centralized mobile application.

The system provides modules for **student profile management, leave requests, complaints, announcements, and attendance/check-in tracking**. A dedicated facial recognition module uses computer vision and machine learning to identify registered students and automate check-in records.

The application follows a modular architecture in which the Flutter client communicates with the backend through REST APIs, while the facial recognition module handles AI-based identity verification.

---

## Architecture

```text
                    ┌──────────────────────┐
                    │    Flutter Client    │
                    │   Mobile Application │
                    └──────────┬───────────┘
                               │
                         REST API Calls
                               │
                               ▼
                    ┌──────────────────────┐
                    │     PHP Backend      │
                    │      REST APIs       │
                    └──────────┬───────────┘
                               │
                         Database Queries
                               │
                               ▼
                    ┌──────────────────────┐
                    │    MySQL Database    │
                    └──────────────────────┘


                    Facial Recognition
                           Module
                               │
                               ▼
                    ┌──────────────────────┐
                    │        OpenCV        │
                    │   Image Processing   │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │        MTCNN         │
                    │    Face Detection    │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │   InceptionResnetV1  │
                    │  Feature Extraction  │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │         SVM          │
                    │ Identity Classification│
                    └──────────┬───────────┘
                               │
                               ▼
                    Check-in / Alert Result
```

### Project Structure

```text
hostel-management-app/
│
├── client/              # Flutter mobile application
├── server/              # PHP REST API backend
├── worker/              # Facial recognition / AI module
├── infra/               # Infrastructure configuration
├── docs/                # Project documentation
│
├── docker-compose.yml   # Service configuration
├── Makefile             # Development commands
├── ARCHITECTURE.md      # Detailed architecture documentation
├── SETUP.md             # Setup instructions
├── LICENSE
└── README.md
```

---

## Features

### Student Management
- **Student Profiles** — Manage and access student information.
- **Leave Management** — Submit and manage hostel leave requests.
- **Complaint Management** — Submit and track hostel complaints.
- **Announcements** — Publish and access important hostel announcements.

### Attendance & Security
- **Facial Recognition** — Automatically identify registered students using camera/image input.
- **Automated Check-in** — Generate attendance/check-in records after successful identity verification.
- **Unknown Face Detection** — Identify unrecognized individuals.
- **Security Alerts** — Generate alerts for unauthorized or unrecognized identities.

---

## Facial Recognition Pipeline

The facial recognition system uses a multi-stage computer vision and machine learning pipeline:

```text
Input Image / Camera Frame
          │
          ▼
    Face Detection
        MTCNN
          │
          ▼
 Face Preprocessing
       OpenCV
          │
          ▼
 Feature Extraction
   InceptionResnetV1
          │
          ▼
 Identity Classification
         SVM
          │
          ▼
    Identity Result
       /       \
      /         \
Registered     Unknown
   │              │
   ▼              ▼
Check-in       Security
  Log            Alert
```

### Technologies Used

- **OpenCV** — Image processing and computer vision operations.
- **MTCNN** — Face detection and localization.
- **InceptionResnetV1** — Generation of facial feature embeddings.
- **SVM** — Classification of facial embeddings for identity recognition.

---

## Technology Stack

| Layer | Technology |
|---|---|
| Mobile Application | **Flutter** |
| Backend | **PHP REST API** |
| Database | **MySQL** |
| AI Module | **Python** |
| Computer Vision | **OpenCV** |
| Face Detection | **MTCNN** |
| Face Embeddings | **InceptionResnetV1** |
| Classification | **SVM** |
| Local Development | **XAMPP** |

---

## Application Flow

### Hostel Management Flow

```text
Student
   │
   ▼
Flutter Mobile App
   │
   ▼
PHP REST API
   │
   ▼
MySQL Database
   │
   ▼
Stored / Retrieved Hostel Data
```

### Facial Recognition Flow

```text
Camera / Image
      │
      ▼
Face Detection
      │
      ▼
Feature Extraction
      │
      ▼
Identity Classification
      │
      ├───────────────┐
      ▼               ▼
 Recognized        Unknown
      │               │
      ▼               ▼
Check-in Record    Alert
```

---

## Getting Started

### Prerequisites

Make sure the following tools are installed:

- **Flutter SDK**
- **PHP**
- **MySQL**
- **XAMPP**
- **Python 3.x**
- Required Python dependencies for the facial recognition module

### Clone the Repository

```bash
git clone https://github.com/PrachiPMishra/Smart-Hostel-Management-System-with-Facial-Recognition.git

cd Smart-Hostel-Management-System-with-Facial-Recognition
```

### Backend Setup

1. Start **Apache** and **MySQL** through XAMPP.
2. Configure the PHP backend according to the project configuration.
3. Create/configure the required MySQL database.
4. Update the database connection settings as required.

Refer to [`SETUP.md`](SETUP.md) for detailed project setup instructions.

### Flutter Application

Navigate to the client directory:

```bash
cd client
```

Install Flutter dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

### Facial Recognition Module

Set up the Python environment and install the dependencies required by the facial recognition module.

The AI pipeline uses:

```text
OpenCV
MTCNN
InceptionResnetV1
SVM
```

Refer to the project documentation for module-specific configuration and execution instructions.

---

## API Layer

The Flutter application communicates with the backend through **REST APIs**.

The API layer handles application operations such as:

- Student profile management
- Leave management
- Complaint management
- Announcements
- Attendance/check-in records
- Facial recognition results

This separation allows the mobile client, backend services, database, and AI module to operate as independent components while communicating through defined interfaces.

---

## Security & Privacy

The system involves student information and facial-recognition data. Production deployment should therefore follow appropriate security practices, including:

- Secure authentication and authorization
- HTTPS/TLS for API communication
- Secure database credentials
- Input validation and API-level access control
- Appropriate handling and protection of facial data
- Restricted access to administrative functions

> Security configurations may vary depending on the deployment environment.

---

## Future Enhancements

Potential improvements include:

- Real-time CCTV stream integration
- Improved recognition performance with larger datasets
- Role-based dashboards for administrators and wardens
- Push notifications for hostel alerts
- Advanced attendance analytics
- Automated reporting
- Cloud deployment
- Production-grade authentication and monitoring

---

## Documentation

Additional documentation is available in:

- [`ARCHITECTURE.md`](ARCHITECTURE.md) — System architecture and component design
- [`SETUP.md`](SETUP.md) — Installation and configuration instructions
- [`docs/`](docs/) — Additional project documentation

---

## License

This project is licensed under the **MIT License**. See [`LICENSE`](LICENSE) for details.