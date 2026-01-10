# 🎓 Certificate Generator Plan

## Objective
Implement a system to generate certificates for event attendees.
**Primary Method:** Automatic generation using a template (PDF) and overlaying text.
**Fallback Method:** Hosting pre-generated certificates on Google Drive/Storage.

## 🛠️ Technology Stack
- **Backend:** Next.js API Routes (Node.js) or Supabase Edge Functions.
- **Library:** `pdf-lib` (Node.js) to modify existing PDFs. It is lightweight and powerful for form filling/text overlay.
- **Frontend:** Flutter App (Download button) & Web Dashboard (Template upload).

## 1. Data Model
Need a new table in Supabase to store event certificate configurations.

`event_certificates` Table:
- `event_id` (UUID, FK to events)
- `template_url` (Text, URL to the base PDF/Image in Supabase Storage)
- `config` (JSONB) - Stores coordinates and style for text fields:
  ```json
  {
    "name": { "x": 300, "y": 400, "fontSize": 24, "fontColor": "#000000", "align": "center" },
    "date": { "x": 300, "y": 500, "fontSize": 14, "fontColor": "#333333" },
    "event_name": { ... }
  }
  ```

## 2. Workflow (Method 1: Auto-Generation)

### A. Admin Setup (Web Dashboard)
1.  **Upload Template**: Admin uploads a blank certificate PDF (or high-res PNG) for an event.
2.  **Configure Layout**: (Ideally) A visual tool or simple form to input X/Y coordinates for Name, Date, etc. or just hardcoded defaults for MVP.
3.  **Save**: Template URL and Config saved to database.

### B. User Action (Mobile App)
1.  User goes to "My Tickets" or Event Detail (after event ends).
2.  Clicks "Download Certificate".
3.  App requests `/api/generate-certificate?eventId=xyz&userId=abc`.

### C. Backend Generation (API)
1.  **Validation**: Check if user attended the event.
2.  **Fetch Template**: Download the PDF template from Storage.
3.  **Processing**:
    - Load PDF using `pdf-lib`.
    - Embed standard font (Helvetica) or custom font if provided.
    - Draw user's Name, Event Name, and Date at the configured coordinates.
4.  **Response**: Stream the generated PDF bytes back to the App as `application/pdf`.

### D. App Handling
1.  App receives PDF bytes.
2.  Saves to local storage (Downloads folder).
3.  Opens it using a PDF viewer or shares it.

## 3. Fallback (Method 2: Google Drive Links)
If dynamic generation is too complex or fails:
1.  Add a column `certificate_link` to the `registrations` table.
2.  Admin manually generates certificates in bulk using tools like Autocrat (Google Sheets).
3.  Admin uploads a CSV mapping `user_id` -> `drive_link`.
4.  App simply opens the `certificate_link`.

## 4. Implementation Steps

### Phase 1: Backend API
- [ ] Create `POST /api/cert/generate`.
- [ ] Install `pdf-lib`.
- [ ] Implement PDF modification logic.

### Phase 2: Database
- [ ] Create `event_certificates` table.
- [ ] Create Storage Bucket `certificates`.

### Phase 3: Mobile App
- [ ] Add "Download Certificate" button in `WalletScreen` (visible only if `status == 'attended'`).
- [ ] Implement file download and open logic (`path_provider`, `open_file` packages).

## Example Code (Next.js API)
```javascript
import { PDFDocument, rgb } from 'pdf-lib';

export async function POST(req) {
  // 1. Load Template
  const templateBytes = await fetch(templateUrl).then(res => res.arrayBuffer());
  const pdfDoc = await PDFDocument.load(templateBytes);
  
  // 2. Modify
  const page = pdfDoc.getPages()[0];
  page.drawText('Adithya k', {
    x: 300,
    y: 400,
    size: 24,
    color: rgb(0, 0, 0),
  });

  // 3. Save
  const pdfBytes = await pdfDoc.save();
  return new Response(pdfBytes, { 
    headers: { 'Content-Type': 'application/pdf' } 
  });
}
```
