# 🐾 PetSewa — NestJS Core Backend Engine

Core API backend for the **PetSewa Ecosystem Platform**. Built using NestJS, TypeORM, PostgreSQL, and TypeScript.

---

## 📐 Architecture & Modules

The backend follows a modular domain-driven structure:

- **`auth/`**: JWT Auth, Refresh Tokens, Session Management & RBAC
- **`ngo/`** ✅ *(Fully Implemented)*: NGO Registrations, Admin Approvals, Pet Listings, Adoption Request Lifecycle, Donation Campaigns
- **`bookings/`**: Multi-service Booking Engine (Vets, Grooming, Training, Hostels, Walkers)
- **`ecommerce/`**: Products, Marketplace, Orders, Cart & Inventory
- **`emergency/`**: Emergency SOS Requests, Realtime Vet Dispatching
- **`adoption/`**: General Adoption & Rescue Management
- **`lostfound/`**: Lost & Found Pet Mapping & Reporting
- **`rewards/`**: Pet Points, Gamification & Level Progression
- **`social/`**: Reels, Community Feed, Posts & Comments
- **`vendors/`**: Provider Portals, Service Listings, Payouts & Commission Engine

---

## 🔌 NGO Platform REST Endpoints Reference (`/ngo/*`)

### Auth & Registration
- `POST /ngo/register` — Submit NGO registration (`status: pending`)
- `POST /ngo/login` — NGO login authentication

### Admin Moderation
- `GET /ngo/admin/pending` — Fetch all pending NGO registrations
- `PATCH /ngo/:id/approve` — Approve NGO registration
- `PATCH /ngo/:id/reject` — Reject NGO registration with optional reason

### Profile & Browse
- `GET /ngo/all` — List all approved NGOs
- `GET /ngo/:id` — Get NGO details by ID
- `PATCH /ngo/:id/profile` — Update NGO profile info

### Pet Management
- `POST /ngo/:id/pets` — Add pet for adoption
- `GET /ngo/:id/pets` — List pets for a specific NGO
- `GET /ngo/pets/all` — List all available pets across all NGOs
- `DELETE /ngo/pets/:petId` — Remove pet listing

### Adoption Lifecycle
- `POST /ngo/adoption-request` — User submits adoption request
- `GET /ngo/:id/requests` — NGO views incoming adoption requests
- `GET /ngo/user-requests/:userId` — User views their submitted requests
- `PATCH /ngo/requests/:id/accept` — NGO accepts request
- `PATCH /ngo/requests/:id/reject` — NGO rejects request
- `PATCH /ngo/requests/:id/meet` — NGO schedules meet & greet
- `PATCH /ngo/requests/:id/adopted` — NGO marks pet as adopted

### Campaigns & Donations
- `POST /ngo/campaigns` — Create donation campaign
- `GET /ngo/campaigns/active` — List active campaigns
- `PATCH /ngo/campaigns/:id/donate` — Process donation to campaign

---

## ⚡ Quick Start

```bash
# 1. Install dependencies
npm install

# 2. Setup environment variables
cp .env.example .env

# 3. Run in development mode (Auto-synchronizes DB entities)
npm run start:dev

# 4. Build for production
npm run build
npm run start:prod
```
