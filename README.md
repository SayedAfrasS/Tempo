# Tempo

> A minimal cloud-synced weekly planner & todo app that helps you plan your week, stay focused, and get things done across all your devices.

---

## 📸 Screenshots

<!-- Add project screenshots or GIF here -->
<!-- Example placeholders (replace with actual paths when available): -->
<!-- ![Week View](./screenshots/week-view.png) -->
<!-- ![Month View](./screenshots/month-view.png) -->
<!-- ![Today View](./screenshots/today-view.png) -->
<!-- ![Login Screen](./screenshots/login.png) -->

---

## ✨ Features

### 🗓️ Planning

- **Weekly Planner** — Visualize your entire week at a glance with a clean 7-day layout.
- **Monthly View** — See tasks across the whole month with category-colored chips and overflow indicators.
- **Today View** — Focus on just today's tasks with a progress bar showing completion percentage.

### ✅ Task Management

- **Categories** — Organize tasks into Personal, Study, Work, Health, or None, each with its own color.
- **Colored Task Boxes** — Categorized tasks display as soft-colored blocks for quick visual scanning.
- **Subtasks** — Break large tasks into smaller steps with expandable checklists.
- **Recurring Tasks** — Set tasks to repeat daily or weekly (e.g., LeetCode streak, PCN class).
- **Per-Date Completion** — Recurring tasks track completion separately for each day.
- **Reminders** — Set a specific time for any task and receive a notification when it's due.

### ☁️ Cloud & Sync

- **Email Authentication** — Secure sign-in powered by Supabase Auth.
- **Cloud Task Sync** — Tasks are stored in the cloud under your account and sync across devices.
- **Offline Support** — Tasks created offline upload automatically when connectivity returns.


### 🎨 Design & UX

- **Themed Palettes** — Multiple carefully crafted themes.
- **Bottom Navigation** — Fast switching between Week, Month, Today, and Settings.
- **Dismissible Tasks** — Swipe to delete, tap to edit.
- **Expandable UI** — Subtasks and filter chips reveal detail on demand without clutter.

### 🔔 Reliability

- **Local Notifications** — Uses `flutter_local_notifications` with `inexactAllowWhileIdle` mode for reliable background delivery.
- **Battery Optimization Handling** — Native Kotlin bridge to help users whitelist the app on aggressive OEM ROMs (Realme, Xiaomi, Samsung, etc.).
- **Android Boot Receivers** — Alarms survive device reboots.

---

## 🛠️ Tech Stack

| Category | Technology |
| --- | --- |
| Framework | Flutter |
| Language | Dart |
| State Management | Provider |
| Backend / Auth | Supabase |
| Local Storage | `shared_preferences` |
| Notifications | `flutter_local_notifications`, `flutter_timezone` |
| Icons | `lucide_icons_flutter` |
| Date Handling | `intl`, `timezone` |
| Secrets Management | `flutter_dotenv` |
| Native Bridge | Kotlin (Android) |

---

## ⚙️ Installation

### 1. Clone the repository

```bash
git clone https://github.com/SayedAfrasS/Tempo.git
cd tempo
```

### 2. Install Flutter dependencies

Make sure you have [Flutter](https://docs.flutter.dev/get-started/install) installed on your machine.

```bash
flutter pub get
```

### 3. Create a Supabase project

1. Go to [Supabase](https://supabase.com/) and create a new project.
2. In the SQL Editor, run the SQL schema required by the project to create the tasks table with Row-Level Security.
3. From **Project Settings → API**, copy your **Project URL** and **anon public key**.

### 4. Configure environment variables

Create a `.env` file in the project root. This file should be listed in `.gitignore` and must not be committed.

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

### 5. Run the app

```bash
flutter run
```

> **Note:** Android notification permissions (`POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, `VIBRATE`) are declared in `android/app/src/main/AndroidManifest.xml`. On first launch, the app will request notification permission from the user.

---

## 🚀 Usage

### 1. Create an account

- Launch the app on your device.
- Tap **"No account? Create one"** and fill in your email, password, full name, date of birth, and occupation.
- Sign in.

### 2. Add a task

- From any view, tap the **"+"** or **"Add Task"** button.
- Enter a title, choose a date, and optionally pick:
  - A category (color-coded box)
  - A reminder time (triggers a notification)
  - A repeat rule (daily / weekly)
- Save. The task syncs to the cloud immediately.

### 3. Complete and manage tasks

- Tap the circle to mark a task complete.
- Swipe a task to delete it.
- Tap a task to edit it.
- Tap the **"Add subtask"** row under any task to break it into steps.

### 4. Filter and navigate

- On the Today screen, use category chips to filter tasks.
- Use the bottom navigation to switch between Week, Month, Today, and Settings.
- In Month view, tap any day to open a detailed sheet of that day's tasks.

### 5. Sync across devices

- Sign in with the same email on another device.
- All your tasks download automatically — your planner travels with you.

---

## 🗺️ Roadmap

### Completed

- Week, Month, and Today views
- Task categories with color-coded boxes
- Subtasks
- Recurring tasks (daily / weekly) with per-date completion
- Local notifications with custom reminder times
- Battery optimization handling for OEM Android devices
- Supabase email authentication
- Cloud task sync
- Editable user profile
- Multiple bird-themed color palettes
- Environment variable management via `.env`

### Planned

- Google Calendar sync (import/export events)
- Smooth task animations
- Splash screen on app launch
- Release APK build
- Automated tests

---

## 🤝 Contributing

Contributions are welcome! To contribute:

1. **Fork** the repository.
2. **Create a feature branch** from `main`:

   ```bash
   git checkout -b feature/your-feature
   ```

3. **Make your changes** and test them on your device.
4. **Commit** with a clear, descriptive message:

   ```bash
   git commit -m "Add your feature"
   ```

5. **Push** to your fork:

   ```bash
   git push origin feature/your-feature
   ```

6. **Open a pull request** against `main` on GitHub and describe what your change does.

### Guidelines

- Follow the existing Dart formatting and project structure.
- Keep environment secrets out of commits — never commit the `.env` file.
- Write clear commit messages in imperative mood with a short summary.
- Keep pull requests focused on a single concern.
- Update documentation when your changes affect how the app is used.

