# Known Issues

## Current Limitations (v1.0.5)

### Backend/Database
- **Manual Migration Required**: The `profiles` table migration (`backend/migrations/20260111_add_student_details.sql`) must be run manually in Supabase SQL Editor for profile updates to work
- **AuthManager Cache**: Profile updates don't immediately refresh the cached user name in the header until app restart

### Mobile App
- **Image Loading**: First-time image loads may cause brief stutters (cached afterward)
- **NFC Integration**: NFC-based check-in not yet implemented
- **Offline Mode**: App requires internet connection for all operations

### Admin Dashboard
- **RBAC Configuration**: Role-Based Access Control requires manual setup in Supabase
- **Real-time Updates**: Dashboard doesn't auto-refresh; requires manual page reload
- **Certificate Generation**: Automated certificate generator not yet implemented

### Scanner App
- **In Development**: Admin scanner app for QR ticket verification is work-in-progress
- **Offline Scanning**: Offline mode with sync capability not yet available

## Workarounds

### Profile Update Not Saving
**Issue**: Profile changes don't save  
**Fix**: Run the SQL migration in Supabase:
```sql
-- Execute backend/migrations/20260111_add_student_details.sql in Supabase SQL Editor
```

### Scrolling Performance
**Status**: RESOLVED in v1.0.5
- Removed animated background
- Implemented ClampingScrollPhysics
- Optimized cache settings

### Google Sign-In Issues
**Issue**: SHA-1 fingerprint mismatch  
**Fix**: Follow [GOOGLE_AUTH_SETUP.md](./GOOGLE_AUTH_SETUP.md) to configure correctly

## Planned Fixes

### Short Term (Next Release)
- [ ] Auto-refresh AuthManager profile cache
- [ ] Implement proper loading states for images
- [ ] Add offline indicator

### Medium Term
- [ ] Complete scanner app with offline support
- [ ] Implement push notifications
- [ ] Add certificate generator

### Long Term
- [ ] Full offline mode with sync
- [ ] NFC-based check-in
- [ ] Advanced analytics dashboard

---

**Reporting Issues**: Please create an issue on [GitHub](https://github.com/AdithyaKul/RegisterYu/issues) with:
- App version
- Device/OS info
- Steps to reproduce
- Screenshots if applicable
