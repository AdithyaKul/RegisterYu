# 📜 Certificate Generator Implementation Plan

## 1. Overview
The goal is to automatically generate and distribute participation/merit certificates to students who attended specific events. This is a critical feature for increasing student engagement.

## 2. Workflow
1.  **Event Setup**: Admin uploads a "Certificate Template" (SVG/HTML) for an event.
2.  **Trigger**: Event status is marked as "Completed".
3.  **Generation**: System identifies all students with status `checked_in`.
4.  **Creation**: System overlays Student Name, Event Name, and Date onto the template.
5.  **Delivery**: 
    *   Certificate is stored in Supabase Storage.
    *   Link is linked to the User's Ticket Wallet in the Mobile App.
    *   (Optional) Email notification sent via Resend.

## 3. Technical Architecture

### A. The Template Engine (Edge Function)
We will use a **Supabase Edge Function** (Deno) to handle the heavy lifting.

*   **Libraries**: 
    *   `pdf-lib`: For manipulating PDF templates.
    *   `canvaskit-wasm`: For rendering complex designs if needed.
*   **Process**:
    ```typescript
    // Pseudo-code for Edge Function
    serve(async (req) => {
      const { user_name, event_name, template_url } = await req.json();
      
      // Load Template
      const pdfDoc = await PDFDocument.load(await fetch(template_url).then(res => res.arrayBuffer()));
      const page = pdfDoc.getPages()[0];
      
      // Draw Text
      page.drawText(user_name, { x: 300, y: 400, size: 24 });
      
      // Save
      const pdfBytes = await pdfDoc.save();
      return new Response(pdfBytes, { headers: { 'Content-Type': 'application/pdf' } });
    });
    ```

### B. Database Schema
We need a new table to track issued certificates.

```sql
create table certificates (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references profiles(id) not null,
  event_id uuid references events(id) not null,
  storage_path text not null, -- Path to the generated PDF in Supabase Storage
  issued_at timestamp with time zone default now(),
  unique_hash text unique not null -- For QR code verification
);
```

### C. Mobile App Integration
1.  **Wallet Screen**: Add a new tab `Certificates`.
2.  **UI**: List of cards showing "Event Name" and "Download PDF" button.
3.  **Logic**:
    *   Fetch `certificates` table where `user_id == current_user`.
    *   On tap, download the PDF to common storage (Android/iOS).

## 4. Verification System
To prevent fraud (Photoshop edits):
*   Every certificate gets a unique, tamper-proof **QR Code**.
*   Scanning the QR code redirects to `https://registeryu.com/verify/{unique_hash}`.
*   The verification page shows the *original* valid data (Name, Event) from the database.

## 5. Implementation Steps
- [ ] Create `certificates` table in Supabase.
- [ ] Create `generate-certificate` Edge Function.
- [ ] Add "Upload Template" UI to Web Dashboard (Event Builder).
- [ ] implemented "My Certificates" screen in Flutter App.
