# 📱 ChatApp

A modern **group chat application** built with **Flutter** and **Firebase**.

## 🚀 Features

### 🔹 Authentication & Security
- Users can **Sign In / Register** using:
  - **Google Sign-In**
  - **Email & Password** (via Firebase Authentication)
- If a user is already signed in, they are redirected to the **chat page**.
- Secure authentication with Firebase.

---

## 🖥️ Screens & Functionality

### 1️⃣ **Login / Sign-Up Page**
- If the user has an account, they are redirected to the **Chat Page**.
- New users can register using **Google Sign-In** or **Email & Password**.
- Secure authentication powered by Firebase.

### 2️⃣ **One-to-One Chat**
- Displays a list of **recent chats** with users.
- Users can **start a new chat** with other users.
- Real-time messaging powered by **Cloud Firestore**.
- **Message Features:**
  - Send & receive messages.
  - **Delete messages** (single/multiple delete).
  - **Edit messages**.
  - **Copy messages** to clipboard.
  - **Reply** to messages.
  - **Star & Pin** messages.
  - **Message Info** (shows if the message was read or not).
  - **Read Receipts:**
    - **Single Tick**: Message sent but not seen.
    - **Blue Double Tick**: Message seen.
  - **Timestamps** for messages sent.
- Clicking on the **user’s name** opens the **Chat Description Page** showing:
  - User’s **name & email**.

---

### 3️⃣ **Group Chat**
- Displays **all groups** the user is a member of.
- **Last message & sender’s name** shown in the group list.
- Users can **search for groups** by name.
- Users can **create new groups**, add members, and modify settings.
- **Group Settings (Admin Controls):**
  - **Control who can send messages**.
  - **Control who can add new members**.
  - **Edit group info** (name, description, image).
  - **Promote/Demote Admins**.
  - **Remove participants**.
- **Inside a Group Chat:**
  - All one-to-one chat features apply.
  - Additional Features:
    - **Poll Creation:** Ask questions & view votes.
    - **Message Search**: Users can search for messages; found chats are highlighted.
- Clicking on the **Group Name** opens the **Group Description Page**, showing:
  - Group **name & description**.
  - List of **members**.
  - Admin **settings & permissions**.
  - **Add & search for new members**.
  - **Exit the group**.
- Admin can restrict **message sending** to **admins only**.

---

### 4️⃣ **Status Feature**
- Users can post **statuses** with:
  - **Different fonts & colors**.
- **Other Users Can:**
  - View the **recently added status**.
  - See the **time** when it was posted.
  - Reply to the status.
  - View statuses in a **"Viewed Status" section**.
- **Status disappears after 24 hours**.
- Users can **delete their own status**.

---

### 5️⃣ **Profile Page**
- Displays **current user details** (First Name, Email).
- Users can **log out** and will be redirected to the **Sign-In / Register Page**.

---

## 🛠️ Tech Stack
- **Flutter** (Dart) - Frontend UI.
- **Firebase** - Backend Services:
  - **Firebase Authentication** (User Login/Signup).
  - **Cloud Firestore** (Real-time Database).

---

## 🔧 Installation
```sh
# Clone the repository
git clone https://github.com/your-repo/chatapp.git

# Navigate to the project folder
cd chatapp

# Install dependencies
flutter pub get

# Run the app
flutter run
```

---

## 📌 Future Enhancements
- Voice & Video Calling.
- Media Sharing (Images, Videos, Documents).
- End-to-End Encryption for Messages.

---



### 🚀 Happy Coding! 🎉

