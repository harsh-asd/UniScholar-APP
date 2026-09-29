## Live Demo
Scan the QR code below or visit [https://uni-scholar-app.vercel.app/](https://uni-scholar-app.vercel.app/) to access the live Web App and download the Android APK.

![UniScholar QR Code](uni_scholar_qr.png)

# ðŸŽ“ MoTA Unified Scholarship App (UniScholar)

> **Solving Problem Statements 238 & 26239 (Ministry of Tribal Affairs)**
> A unified, AI-enabled, mobile-first ecosystem for Scheduled Tribe (ST) students to seamlessly apply for, track, and manage all 5 MoTA scholarship schemes.

![MoTA App Banner](https://via.placeholder.com/1200x400.png?text=UniScholar+-+Ministry+of+Tribal+Affairs)

## ðŸŒŸ The Problem
Currently, MoTA administers 5 disconnected scholarship schemes (Pre-Matric, Post-Matric, Top Class, NFST, NOS) across multiple portals (NSP, SFMP). Students struggle with repetitive data entry, lack of transparency, and disjointed DBT tracking. 

## ðŸ’¡ Our Solution
We built a decoupled microservices architecture featuring a Flutter Mobile App for students and a Web Portal for Nodal Officers. 

### Key Features
* ðŸ” **NSP OTR Architecture:** One-Time Registration using mock Aadhaar/Face-Auth flow. Students register once; the profile serves as a single source of truth.
* ðŸ“‚ **DigiLocker Document Wallet:** Automated API fetching of Income, Caste, and Academic certificates. Zero manual uploads required.
* ðŸ¤– **JAGO Chatbot Integration:** A context-aware conversational AI that reads the student's OTR ID and answers dynamically (e.g., *"Where is my money?"*).
* ðŸš« **Smart Deduplication Engine:** Background middleware preventing a student from availing dual-benefits in the same academic year.
* ðŸ›ï¸ **L1/L2 Admin Dashboard:** A responsive web interface for Institute and District nodal officers to approve applications and verify DigiLocker documents in one click.

## ðŸ› ï¸ Tech Stack
* **Frontend:** Flutter (Mobile App), Flutter Web (Admin Portal)
* **Backend:** Node.js, Express.js
* **Database:** PostgreSQL (Prisma ORM)
* **AI/Integrations:** NLP Intent Matching (JAGO), mock DigiLocker OAuth, PFMS/DBT tracking.

## ðŸš€ How to Run the End-to-End Demo

**1. Clone and Setup**
```bash
git clone https://github.com/harsh-asd/UniScholar-APP.git
cd UniScholar-APP
```

**2. Start Backend & Seed Database**
```bash
cd backend
npm install
npm run dev
node prisma/seed.js # Seeds the DB with OTR profiles, L1/L2 Admins, and active applications
```

**3. Run the Mobile App (Student View)**
```bash
cd frontend
flutter pub get
flutter run
```

**4. Run the Admin Portal (Officer View)**
```bash
cd frontend
flutter run -d chrome # Opens the Admin Dashboard in a web browser
```


