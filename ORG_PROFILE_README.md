# 🐾 PetSewa India — Official GitHub Organization

<div align="center">

![PetSewa Banner](https://img.shields.io/badge/PetSewa-Enterprise%20Pet%20Care-4CAF50?style=for-the-badge&logo=shield&logoColor=white)
![Build Status](https://img.shields.io/badge/Build-Passing-brightgreen?style=for-the-badge)
![Security Status](https://img.shields.io/badge/Security-0%20Vulnerabilities-success?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Flutter%20%7C%20NestJS-blue?style=for-the-badge)

**Transforming Pet Healthcare, Adoption, and Community Services across India.**

[Official Website](https://petsewa.in) • [Documentation](https://github.com/PetSewa-India/petsewa_app) • [Security Policy](https://github.com/PetSewa-India/petsewa_app/blob/main/SECURITY.md)

---

</div>

## 🌟 About PetSewa India

**PetSewa** is an all-in-one digital ecosystem designed to connect pet parents, veterinary doctors, rescue centers, foster caretakers, and animal welfare organizations across India.

---

## 🏗️ Core Technology Ecosystem

```mermaid
graph TD
    classDef client fill:#E0F2FE,stroke:#0284C7,stroke-width:2px,color:#0F172A;
    classDef gateway fill:#FEF3C7,stroke:#D97706,stroke-width:2px,color:#0F172A;
    classDef backend fill:#DCFCE7,stroke:#16A34A,stroke-width:2px,color:#0F172A;
    classDef storage fill:#F3E8FF,stroke:#9333EA,stroke-width:2px,color:#0F172A;

    subgraph Tier1 ["📱 Client Layer"]
        C1["PetSewa Flutter Mobile App (iOS / Android / Web)"]:::client
    end

    subgraph Tier2 ["🚪 API Gateway Layer"]
        G1["JWT Auth Guard & Global Validation Pipe"]:::gateway
    end

    subgraph Tier3 ["⚙️ Backend Engine"]
        B1["NestJS Core API & TypeORM Engine"]:::backend
    end

    subgraph Tier4 ["💾 Data & Cloud Services"]
        D1[("PostgreSQL Database & Supabase Storage")]:::storage
    end

    C1 -->|REST API / HTTPS| G1
    G1 -->|Validated Requests| B1
    B1 -->|TypeORM Queries| D1
```

---

## 📦 Key Repositories

| Repository | Purpose | Tech Stack |
| :--- | :--- | :--- |
| [**`petsewa_app`**](https://github.com/PetSewa-India/petsewa_app) | Unified Monorepo for Backend API Engine & Cross-Platform Mobile Application | NestJS 11, TypeScript, Flutter, Supabase |

---

## 👑 Governance & Core Leadership

| Handle | Role | Team |
| :--- | :--- | :--- |
| **`@Hammaduddin561`** | Repository Admin & Lead | `Petsewa Core` |
| **`@pathakaanya12`** | Core Architect & Reviewer | `Petsewa Core` |
| **`@YantrikMinds`** | Core Admin & Operations | `Petsewa Core` |
| **`@petsewa`** | Organization Admin | `Petsewa Core` |

---

## 🔒 Security & Standards

* **0-Vulnerability Stack**: Strictly audited on modern dependencies.
* **Strict Code Reviews**: All pull requests require review and sign-off by **`Petsewa Core`**.
* **Proprietary Software**: Copyright © 2026 **PetSewa-India**. All rights reserved.

<div align="center">
  <sub>Built with ❤️ by the PetSewa India Engineering Team</sub>
</div>
