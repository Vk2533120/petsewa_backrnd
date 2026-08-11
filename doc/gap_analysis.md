# PetSewa Ecosystem Platform — Gap Analysis and Engineering Status

Reference Document: `doc/Pet Care Ecosystem Platform (3).pdf`

- **Target Delivery Deadline**: Monday, August 17, 2026 (EOD)

This document outlines the current engineering status versus the full technical scope defined in the PetSewa platform architecture proposal. It explicitly documents all existing implementations in the codebase and specifies the advanced extensions required for production deployment across active GitHub tracking tasks.

---

## 1. Platform Implementation Overview

| Component | Architecture Stack | Current Status | Master Issue |
|---|---|---|---|
| **Backend & Core API Engine** | NestJS 11, PostgreSQL, TypeORM, Redis, Socket.io, Cloudflare R2 | Modernized to NestJS 11 (0 vulnerabilities, clean build). Core module services for Rewards, Referrals, and NGO are implemented; advancing with complete TypeORM relational migrations, automated 80G tax receipt PDF engine, multi-tier leaderboards, real-time gateway, and payment/commission infrastructure. | [Issue #38](https://github.com/PetSewa-India/petsewa_app/issues/38) |
| **Cross-Platform Mobile App** | Flutter 3.x, Dart, Supabase | 37+ production screens implemented (Auth, Pet Profiles, Bookings, Shop, NGO Hub, Adoption Workflow, Referral, Wallet, Provider baseline). Advancing with specialized provider operational tools, social feed, reels, recurring NGO pledges, gamification celebration animations, and real-time Socket.io chat/SOS. | [Issue #39](https://github.com/PetSewa-India/petsewa_app/issues/39) |
| **Web Ecosystem & Admin CMS** | Next.js, React, Tailwind, Laravel Admin | Architectural specifications finalized for public marketing, web store, adoption/lost-and-found portals, NGO transparency showcases, and operational admin CMS. | [Issue #40](https://github.com/PetSewa-India/petsewa_app/issues/40) |

---

## 2. Exhaustive Audit: What is Already Done in Codebase

### A. NestJS Backend Engine (`petsewa-backend`)
- [x] **Framework Modernization**: Upgraded to NestJS 11 with 0 security vulnerabilities (`npm run build` passing).
- [x] **NGO Module (`src/modules/ngo`)**:
  - `Campaign` entity with TypeORM (`id`, `title`, `ngoName`, `description`, `targetAmount`, `raisedAmount`, `isActive`).
  - `NgoService` with `createCampaign()`, `getActiveCampaigns()`, and `processDonation()`.
  - `NgoController` exposing `POST /ngo/campaigns`, `GET /ngo/campaigns`, and `PATCH /ngo/campaigns/:id/donate`.
- [x] **Rewards & Gamification Module (`src/modules/rewards`)**:
  - `Reward`, `RewardTransaction`, `Coupon` TypeORM entities.
  - `RewardsService` with 4-tier level thresholds (*Bronze < 200, Silver >= 200, Gold >= 500, Platinum >= 1000*).
  - 7-day daily check-in streak calculation with escalating bonus rewards.
  - Referral code generator (`PET-<userId>-<random>`) awarding +100 points to referrer and +50 points to referee.
  - Points ledger transaction logging and discount coupon redemption (`PET-VO-...`).
- [x] **Modular Structure**: Base module directories and DTO validation pipes for `auth`, `vendors`, `bookings`, `ecommerce`, `emergency`, `lostfound`, `adoption`, `ngo`, `rewards`, `social`, `notifications`.

### B. Flutter Mobile App (`petsewa_app`)
- [x] **NGO Hub & Adoption Suite (6 Dedicated Screens + Service)**:
  - `ngo_hub_screen.dart`: Tabbed interface to browse approved NGOs and adoptable rescued pets.
  - `ngo_detail_screen.dart`: NGO public profile, registration info, mission, and listed pets.
  - `ngo_dashboard_screen.dart`: NGO shelter management portal with incoming adoption requests.
  - `ngo_registration_screen.dart`: Multi-field NGO onboarding form.
  - `ngo_pending_screen.dart`: Verification pending status screen.
  - `ngo_add_pet_screen.dart`: Form for NGOs to list new rescue animals.
  - `ngo_service.dart`: Client API service for NGO registration, login, pet management, adoption requests (`sendAdoptionRequest`, `acceptRequest`, `rejectRequest`, `scheduleMeet`, `markAdopted`), and campaigns.
  - `adoption_screen.dart`, `adoption_request_screen.dart`, and `my_adoption_requests_screen.dart`.
- [x] **Rewards, Referrals & Wallet Suite**:
  - `referral_screen.dart`: Native referral code share sheet, invite metrics, and rewards dashboard.
  - `wallet_screen.dart`: Pet Points balance, transaction history, and coupon vouchers.
- [x] **Core Customer & Booking Screens**:
  - Authentication: `login_screen.dart`, `register_screen.dart`, `otp_screen.dart`, `onboarding_screen.dart`, `splash_screen.dart`.
  - Profile & Pets: `customer_home.dart`, `profile_screen.dart`, `create_pet_profile_screen.dart`, `edit_pet_profile_screen.dart`.
  - Services & Bookings: `service_discovery_screen.dart`, `service_details_screen.dart`, `booking_flow_screen.dart`, `booking_success_screen.dart`, `my_bookings_screen.dart`.
  - Shop & Cart: `shop_screen.dart`, `product_details_screen.dart`, `cart_screen.dart`.
  - Portals: `lost_found_screen.dart`, `emergency_screen.dart`.
- [x] **Provider Baseline Screens**:
  - `provider_home_screen.dart`, `provider_register_screen.dart`, `provider_service_select_screen.dart`, `provider_verification_screen.dart`, `provider_pending_screen.dart`.
- [x] **Repository Governance & CI**: Automated CI build pipeline, CODEOWNERS, and Feature/Architecture Proposal workflow active.

---

## 3. Active Work Streams & Group Breakdown

### Group 1: Backend and Infrastructure Engineering
**Tracking Issue**: [GitHub Issue #38](https://github.com/PetSewa-India/petsewa_app/issues/38)  
**Primary Reference**: `doc/Pet Care Ecosystem Platform (3).pdf`

#### Completed Foundation (In Codebase)
- Base entity files created for `User`, `Campaign`, `Reward`, `RewardTransaction`, `Coupon`.
- Active `RewardsService` with 4-tier level progression, daily streak calculations, referral code generator (`PET-<id>-<random>`), point awards, and coupon redemption.
- Active `NgoService` with campaign creation, active campaign queries, and donation accumulation logic.
- NestJS 11 framework upgrade completed with 0 dependencies audit vulnerabilities.

#### Required Advanced Implementation (To be Built)
- [ ] **Advanced Database & TypeORM Schema Layer**:
  - `User`, `Vendor`, `UserAddress`, `RefreshToken`, `Role` (RBAC)
  - `Pet`, `MedicalRecord`, `VaccinationRecord`
  - `Service`, `Booking`, `BookingTracking`
  - `Product`, `Order`, `OrderItem`, `InventoryLog`, `Wishlist`, `RefundRequest`
  - `Post`, `Reel`, `Comment`, `Like`, `Share`, `Save`, `Community`, `Discussion`, `Poll`, `Event`
  - **NGO Entities**: `NGO`, `NGOCampaign`, `NGODonation`, `FundUtilizationReport`, `NGOVerificationDocument`
  - **Gamification Entities**: `UserRewards`, `PetPointsLedger`, `Badge`, `UserBadge`, `TierLevel`, `ReferralCode`, `ReferralLog`, `Leaderboard`
  - Spatial GIST and composite B-Tree indexing with TypeORM migrations.
- [ ] **Advanced NGO & Fundraising Engine (`/api/v1/ngo`)**:
  - Automated 80G Tax Exemption Certificate PDF Generator (with donor PAN, unique certificate number, and verification QR code).
  - Fund utilization transparency ledger (uploading veterinary medical bills, medicine invoices, and recovery photo evidence).
  - Recurring monthly micro-donation subscription engine (₹99/mo, ₹299/mo shelter food support).
- [ ] **Advanced Rewards, Referral & Gamification System (`/api/v1/rewards`)**:
  - Multi-tier gamification leaderboards (Global, City-level, and Breed Community leaderboards with weekly reward resets).
  - Milestone achievement badges engine with unlock triggers (e.g. *Rescue Champion, Frequent Parent, Top Reviewer*).
  - Fraud-resistant referral tracking (device fingerprinting and IP validation).
  - Point redemption marketplace API (converting Pet Points into service discounts, grooming vouchers, or donation sponsorships).
- [ ] **Core Domain REST APIs**:
  - Authentication (JWT, Redis OTP, `@Roles()` guard)
  - User and vendor profile management, KYC document review
  - Pet medical history, clinical notes, and digital prescriptions
  - Service catalog, appointment booking state machine, and status transitions
  - E-Commerce product catalog, cart, checkout, order tracking, and returns
- [ ] **Social Media, Reels & Community APIs**:
  - Posts publishing, nested comments, likes, shares, saves, and hashtag discovery
  - Velocity-based trending feed algorithm, geolocation-nearby feed, and species-recommended feed
  - Short-video Reels infinite-scroll stream API and deduplicated view counter
  - Community groups, discussion threads, multi-option polls, and pet meetup events
- [ ] **Real-time WebSockets (Socket.io)**:
  - Authenticated WebSocket gateway with Redis cluster adapter
  - Customer ↔ Vendor and Customer ↔ Doctor direct messaging with read receipts
  - Emergency Vet SOS 10 km radius geospatial broadcast and priority room lock
  - Live GPS walker tracking coordinates stream (3–5s intervals)
- [ ] **Cloud Infrastructure & Storage**:
  - Redis caching (OTP TTL, session tokens, feed cache, `GEOSEARCH` proximity queries)
  - BullMQ background queues (FCM push notifications, SMS/Email, video thumbnail generation, ledger reconciliation)
  - Cloudflare R2 / AWS S3 media pipeline (WebP image compression, chunked video uploads, signed temporary URLs for medical PDFs)
- [ ] **Payments, Dynamic Commissions & Vendor Wallet**:
  - Payment gateway webhooks (UPI, Razorpay / Stripe, Cards) with cryptographic signature validation
  - Category-based dynamic platform fee engine (Vets, Grooming, Training, Hostels, Walkers, Shop)
  - Vendor wallet ledger with 24–48 hour escrow hold period and payout approval workflow

---

### Group 2: Flutter Mobile App Development
**Tracking Issue**: [GitHub Issue #39](https://github.com/PetSewa-India/petsewa_app/issues/39)  
**Primary Reference**: `doc/Pet Care Ecosystem Platform (3).pdf`

#### Completed Foundation (In Codebase)
- Base UI screens created: `ngo_hub_screen.dart`, `ngo_detail_screen.dart`, `ngo_dashboard_screen.dart`, `ngo_registration_screen.dart`, `ngo_pending_screen.dart`, `ngo_add_pet_screen.dart`, `adoption_screen.dart`, `adoption_request_screen.dart`, `my_adoption_requests_screen.dart`, `referral_screen.dart`, and `wallet_screen.dart`.
- Active `NgoService` in Flutter supporting registration, login, pet management, adoption workflow state management, and campaigns.

#### Required Advanced Implementation (To be Built)
- [ ] **Advanced NGO & Fundraising Hub**:
  - Interactive campaign progress bars with real-time donor feed.
  - One-tap donation checkout supporting UPI, Cards, and Net Banking.
  - Transparent fund utilization gallery (before/after rescue photos and medical invoices).
  - 80G tax receipt instant PDF download UI.
  - Recurring monthly shelter support pledge manager.
- [ ] **Advanced Gamification & Referral Hub**:
  - Interactive Pet Points dashboard with animated progress bar to next Tier (*Bronze, Silver, Gold, Platinum*).
  - Achievement badge unlock screen with celebration animations.
  - Daily check-in streak calendar with bonus multipliers.
  - Referral Center: Native share sheet, live invite status tracker, and points claim button.
  - City-wide and community leaderboards with top-pet avatars.
- [ ] **Specialized Vendor Tools**:
  - Veterinarian: Medical records UI, vaccination schedules, digital prescriptions, treatment notes, PDF uploader
  - Groomer: Before/After comparison gallery, grooming package configurator, dynamic pricing tiers
  - Trainer: Session scheduler, curriculum plans, progress reports, behavior tracking logs
  - Boarding / Hostel: Room management, real-time occupancy grid, check-in/check-out checklist, medication logs
  - Dog Walker: Walk scheduling, acceptance alerts, live GPS route map, post-walk summary report
- [ ] **Social Media Feed**:
  - Feed screen supporting image, video, and text posts
  - Post creation with multi-image picker, filter preview, captions, location, and pet tags
  - Post interactions (like, nested comments, shares, bookmarks, follow/unfollow)
  - Hashtag discovery and tabbed feeds (Following, Trending, Recommended, Nearby)
- [ ] **Reels Short-Video Platform**:
  - Full-screen vertical swipeable video player with auto-play, double-tap like, and comments modal
  - In-app video recording, video trimming tool, thumbnail frame selector, and upload progress bar
  - Creator profiles with video grid and follower metrics
- [ ] **Community Groups**:
  - Category directory (Dog, Cat, Breed-specific, Rescue, Adoption communities)
  - Discussion threads, interactive polls with live percentages, and meetup events with RSVP
- [ ] **Real-time Communication & Emergency SOS**:
  - 1-to-1 live chat screen with read receipts and typing indicators
  - Live GPS service tracking map view
  - Emergency SOS trigger button, symptom selector, nearby vet radar search, and immediate live room
- [ ] **Mobile E-Commerce**:
  - Wishlist screen with move-to-cart action
  - Order details with live status tracking stepper and tabbed order history
  - Return & refund dispute submission flow with photo evidence

---

### Group 3: Web Ecosystem & Admin Panel Development
**Tracking Issue**: [GitHub Issue #40](https://github.com/PetSewa-India/petsewa_app/issues/40)  
**Primary Reference**: `doc/Pet Care Ecosystem Platform (3).pdf`

#### Required Advanced Implementation (To be Built)
- [ ] **Next.js Public Web Platform**:
  - Landing page with dynamic search, metrics counter, and app download CTAs
  - Public NGO donation directory and transparency case showcase
  - Technical SEO setup (SSR/SSG, JSON-LD schema, dynamic Open Graph meta tags, sitemap.xml)
  - E-Commerce web store (Catalog, cart, checkout, payment, order tracking)
  - Lost & Found portal with interactive map marker picker and public listings
  - Adoption portal with pet profiles, digital adoption questionnaire, and application status tracking
  - Vendor & partner onboarding portal with multi-step registration and document upload
- [ ] **Laravel Admin Panel & Operational CMS**:
  - Central dashboard with executive KPIs, revenue analytics, and system health alerts
  - NGO campaign verification, donation tracking, and fund release approvals
  - Gamification & rewards configuration (Points rules, tier thresholds, badge manager)
  - User and vendor management directory with account status controls
  - KYC document verification tool with approve/reject workflows
  - Granular Role-Based Access Control (Super Admin, Operations, Finance, Support, Moderation)
  - CMS management (Promotional banners, hero sliders, featured vendors/products)
  - Commission configuration and vendor payout approval queue
  - Content moderation queues for flagged posts, reels, comments, and user reports

---

## 4. Execution Roadmap

1. **Sprint 1 — Core Data Layer, NGO/Rewards & Real-time Gateway (Group 1)**: Deploy PostgreSQL TypeORM migrations, JWT/RBAC auth, NGO & Gamification APIs, and Socket.io gateway.
2. **Sprint 2 — Mobile Social, Community, NGO Hub & Specialized Tools (Group 2)**: Deliver Flutter social feed, reels, donation hub, rewards center, and provider operational dashboards.
3. **Sprint 3 — Web Portals & Operational Admin CMS (Group 3)**: Launch Next.js public platform and Laravel administration panel.
4. **Sprint 4 — End-to-End Integration & Production Hardening**: Multi-gateway payment testing, live GPS tracking verification, and load testing.
5. **Final Deliverable — Comprehensive Engineering Documentation**: Each group must produce and commit dedicated architecture, API/Screen specifications, setup guides, and test verification reports under `doc/`.
