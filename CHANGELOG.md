# RegisterYu Changelog

## [v1.0.5] - 2026-01-12

### Performance & UX Improvements
- **FIXED**: Infinite scroll/bounce issues on vertical and horizontal scrolling
- **REMOVED**: LiquidBackground animation for better scroll performance
- **ADDED**: ClampingScrollPhysics for native Android scroll behavior
- **OPTIMIZED**: Reduced cache extent from 1000px to 500px for faster rendering
- **IMPROVED**: Event feed scrolling is now buttery smooth

### Features
- Profile save functionality fully working
- Added college_id field for backward compatibility
- Better error handling in profile updates
- Direct navigation to Edit Profile form when incomplete

### Bug Fixes
- Fixed profile update not saving to database
- Fixed infinite scrolling at screen edges
- Fixed laggy scroll performance

## [v1.0.4] - 2026-01-12

### Performance
- Replaced custom FastScrollPhysics with native BouncingScrollPhysics
- Removed RepaintBoundary from event cards for simpler rendering

### Bug Fixes
- Profile completion flow now directly opens edit form
- Fixed navigation back to registration after profile completion

## [v1.0.3] - 2026-01-12

### Features
- Added student detail fields (USN, semester, section, department, phone)
- Profile edit screen with complete form
- Better profile validation

### Improvements
- Improved scroll physics configuration
- Increased cache extent to 3000px

## [v1.0.2] - 2026-01-11

### Features
- Initial release with core functionality
- Event browsing and registration
- Google Sign-In integration
- QR code ticket generation
- Razorpay payment integration

### UI/UX
- Liquid Glass aesthetic design
- Dark theme enforced globally
- Smooth scrolling with custom physics

## [v1.0.1] - Initial Beta

### Core Features
- User authentication
- Event discovery
- Ticket wallet
- Profile management
- Admin dashboard

---

**Note**: This changelog follows [Keep a Changelog](https://keepachangelog.com/) format.
