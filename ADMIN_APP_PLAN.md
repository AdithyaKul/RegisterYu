# 📱 Admin Scanner App Plan

## Overview
A lightweight mobile app dedicated to event organizers/volunteers for verifying tickets.
It connects to the same Supabase backend as the main app/dashboard.

## 🎯 Core Features

### 1. Authentication
- Login with Admin/Organizer credentials (email/password).
- Only users with `role: 'organizer'` or `role: 'admin'` can log in.

### 2. Event Selection
- Dashboard showing "Active Events" for today/upcoming.
- Select an event to start scanning.

### 3. Scanner Mode
- **Camera View**: Continuously scan QR codes.
- **Validation Logic**:
  - Parse QR payload (Ticket ID).
  - Check against `registrations` table in Supabase.
  - Verify `event_id` matches selected event.
  - Check `status`:
    - If `active` -> **Success** (Green screen, haptic success). Update status to `checked_in`.
    - If `checked_in` -> **Warning** (Yellow screen, "Already Scanned").
    - If `invalid` -> **Error** (Red screen, "Invalid Ticket").
- **Offline Mode (Optional/Advanced)**: Cache ticket list locally for low-latency scanning.

### 4. Manual Entry
- Input field to type Ticket ID/Phone Number if QR is unreadable.

### 5. Stats Overlay
- Real-time counter: "Scanned: 15 / 200".

## 🛠️ Technical Stack
- **Framework**: Flutter (shared codebase structure with main app potentially, or separate repo).
- **Package**: `mobile_scanner` or `qr_code_scanner`.
- **State Management**: Provider/Riverpod.
- **Backend**: Supabase.

## 📱 UI/UX
- **Theme**: Dark mode, High contrast (Green/Red) for instant feedback.
- **Haptics**: Heavy vibration on error, light click on success.
- **Sound**: Optional beep on scan.

## 🚀 Implementation Steps

1.  **Project Setup**: New Flutter project `sambhram_admin`.
2.  **Auth Integration**: Copy Auth logic from main app.
3.  **Scanner Screen**: Implement camera view.
4.  **Logic**: Wire up Supabase `update` query.
5.  **Feedback**: Add animations/sounds.

## Example Database Query
```sql
-- Check-in function (Postgres RPC)
create or replace function check_in_ticket(ticket_uuid uuid, current_event_id uuid)
returns json
language plpgsql
as $$
declare
  reg_record record;
begin
  select * into reg_record from registrations where id = ticket_uuid;
  
  if not found then
    return '{"status": "error", "message": "Ticket not found"}';
  end if;

  if reg_record.event_id != current_event_id then
     return '{"status": "error", "message": "Wrong Event"}';
  end if;

  if reg_record.status = 'checked_in' then
     return '{"status": "warning", "message": "Already Checked In", "user": "' || reg_record.user_id || '"}';
  end if;

  update registrations set status = 'checked_in', check_in_time = now() where id = ticket_uuid;
  return '{"status": "success", "message": "Welcome!", "user": "' || reg_record.user_id || '"}';
end;
$$;
```
