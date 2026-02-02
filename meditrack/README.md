# meditrack

Core Concept

A medicine reminder + inventory + expense tracker
So user knows:
⏰ When to take medicine
💊 How much medicine is left
💰 How much money is being spent
📜 History of medicine price & usage



# MediTrack – Smart Health Reminder App

MediTrack is a smart health reminder application that helps users manage their medicines efficiently by combining **medicine reminders**, **stock tracking**, and **expense management** in one place.

---

## 🧠 Core Concept

MediTrack is designed to solve three major problems faced by medicine users:

1. Forgetting to take medicines on time  
2. Losing track of remaining medicine stock  
3. Not knowing how much money is being spent on medicines  

The app ensures users:
- Never miss a dose
- Always know how much medicine is left
- Can track medicine expenses and price history over time

---

## 🚀 Key Features

### 1. Medicine Reminder
- Add medicine name and type (Tablet, Syrup, Capsule, Injection)
- Set dosage per intake
- Flexible reminder schedules:
  - Once a day
  - Twice a day
  - Custom times
- Start and end date support
- Push notifications with sound & vibration
- Mark medicine as **Taken** or **Missed**

---

### 2. Medicine Stock Management
- Add total available medicine quantity
- Auto-reduce stock when medicine is marked as taken
- Low stock alert notifications
- Shows remaining days based on usage
- Prevents sudden medicine shortages

---

### 3. Expense Tracking 💰
- Add price details whenever medicine is purchased
- Store quantity purchased and total price
- Auto-calculate:
  - Price per unit
  - Monthly medicine expense
  - Total expense per medicine

---

### 4. Price History & Analytics
- Track medicine price changes over time
- View historical purchase data:
  - Purchase date
  - Quantity
  - Price paid
- Identify price increase or decrease trends

---

### 5. History & Logs
- Medicine intake history (Taken / Missed)
- Expense history with date-wise records
- Helps users analyze adherence and spending habits

---

### 6. Dashboard
- Today’s medicine schedule
- Next upcoming reminder
- Low stock warnings
- Monthly medicine expense summary

---

## 🔁 App Flow

### 1. Onboarding
- Simple introduction screens
- Permission requests for notifications

---

### 2. Home / Dashboard
- Displays today’s medicines
- Shows next reminder time
- Alerts for low medicine stock
- Monthly expense overview

---

### 3. Add Medicine Flow
1. Enter medicine details
2. Set dosage and frequency
3. Choose reminder times
4. Add total available stock
5. (Optional) Add purchase price

---

### 4. Reminder Action
- Notification triggers at scheduled time
- User actions:
  - Mark as **Taken** → stock reduces
  - Mark as **Missed** → logged only

---

### 5. Stock & Expense Update
- When stock is low → alert user
- When new medicine is purchased:
  - Add quantity
  - Add price
  - Save to price history

---

### 6. History & Reports
- View medicine intake history
- View expense and price history
- Filter by date or medicine

---

## 🧩 Optional Future Enhancements

- Family profiles (parents / kids)
- Doctor & prescription tracking
- Cloud backup & sync
- Export reports (PDF / Excel)
- AI insights (missed dose trends, cost prediction)

---

## 🛠 Tech Stack (Suggested)
- Flutter (Android, iOS)
- Local Database: Drift / Isar
- Notifications: flutter_local_notifications
- Charts: Syncfusion / Charts Flutter
- Clean Architecture for scalability

---

## 🎯 Goal
To create a reliable, easy-to-use, and intelligent medicine management app that improves health habits and financial awareness.

---

**MediTrack – Never Miss a Dose. Never Run Out.**
