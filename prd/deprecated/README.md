# MekarPad Product Requirements Documentation

This folder contains the Product Requirements Documents (PRDs) and milestone planning for the **MekarPad** platform.

## Overview

MekarPad is an author platform and ecosystem that enables authors to write, publish, and monetize serialized stories. The platform combines features from platforms like Wattpad with distribution capabilities similar to Draft2Digital, creating a comprehensive solution for independent authors.

## Documentation Structure

### Milestone Planning

**[MekarPad Milestone.md](./MekarPad%20Milestone.md)**

Contains the complete 7-milestone roadmap for the MekarPad platform:

1. **Milestone 1: Core Author Platform MVP** - Core writing and publishing features (Wattpad-like)
2. **Milestone 2: Personal Author Pages & Subdomains** - Author branding and vanity URLs
3. **Milestone 3: Reader Engagement & Monetization Readiness** - Chapter locks, newsletters, comments
4. **Milestone 4: Marketplace (MekarBooks Integration)** - Book marketplace and storefront
5. **Milestone 5: Monetization Infrastructure** - Token system and author revenue
6. **Milestone 6: External Distribution & Publishing** - Distribution to Amazon KDP, Google Books, etc.
7. **Milestone 7: Advanced Customization & Add-ons** - Custom domains and premium features

### Detailed PRDs

**[PRD MekarPad [1/7] Core Author Platform.md](./PRD%20MekarPad%20%5B1_7%5D%20Core%20Author%20Platform.md)**

Detailed requirements for Milestone 1 (MVP), including:

- **Core Features**: Magic link authentication, author dashboard, book creation, chapter editor, reader view, discover page
- **Technical Stack**: Ruby on Rails, Hotwire, PostgreSQL, TailwindCSS
- **User Stories organized in 5 Epics**:
  - Epic 1: Authentication & User Roles
  - Epic 2: Authoring (Dashboard & Book Creation)
  - Epic 3: Writing (Chapter Editor)
  - Epic 4: Public Reading & Discovery
  - Epic 5: Non-Functional & Foundation
- **Success Metrics**: Author activation, reader engagement, publishing time, reliability

## Current Status

**Active Branch**: `claude/check-folder-prd-011CV3he71XhRBQkXNPLkLyt`

The platform is currently in **Milestone 1** development phase, focusing on building the Core Author Platform MVP.

### Recent Progress

- Epic 2 (Authoring - Dashboard & Book Creation) has been completed with comprehensive test coverage and UX improvements

## Key Features by Milestone

| Milestone | Key Deliverables | Status |
|-----------|-----------------|--------|
| M1 - Core Platform | User auth, dashboard, book/chapter CRUD, reading experience | 🟡 In Progress |
| M2 - Author Pages | Profile pages, subdomains, custom branding | ⚪ Planned |
| M3 - Reader Engagement | Chapter locks, newsletters, comments, follows | ⚪ Planned |
| M4 - Marketplace | Book listings, storefront, search & filters | ⚪ Planned |
| M5 - Monetization | Token system, payments, revenue dashboard | ⚪ Planned |
| M6 - Distribution | EPUB/PDF export, external platform distribution | ⚪ Planned |
| M7 - Customization | Custom domains, page builder, premium themes | ⚪ Planned |

## Technical Architecture

**Backend**: Ruby on Rails
**Frontend**: Hotwire (Turbo + Stimulus)
**Database**: PostgreSQL
**Authentication**: Magic Link (passwordless)
**Storage**: Cloudinary / ActiveStorage
**Styling**: TailwindCSS
**Deployment**: Fly.io / Render

## Success Metrics (M1)

- **Author Activation**: ≥30% of new users create at least one book
- **Reader Engagement**: ≥50% of sessions exceed 3 minutes of reading
- **Publishing Time**: First-time authors can publish within 10 minutes
- **Reliability**: 99% uptime

## External PRD References

Additional PRDs are maintained in Google Docs:

- [M1 - Core Author Platform](https://docs.google.com/document/d/1Fl-IVtXwC6hpnszSTb-sVpbr1k7c8llcXdi9HE78P6s/edit?usp=sharing)
- [M3 - Reader Engagement](https://docs.google.com/document/d/1ztYpC4N0yuVsVgixelWsjTNf1VZA1kl_kTGkl_ak_Gw/edit?usp=sharing)
- [M4 - Marketplace Integration](https://docs.google.com/document/d/1Td8xJNsdYLqmzqxPJC5SujOa9Xhn42LdftwKMztzYmo/edit?usp=drive_link)
- [M6 - External Distribution](https://docs.google.com/document/d/1eEQPabxbome2O5fSwabA4q5SyyMNOPvDrD8lLNGHwWc/edit?usp=sharing)
- [M7 - Advanced Customization](https://docs.google.com/document/d/1Tl654BaGggNyHg59X_L1Cx8uSUEYUc9eSziFfSPaOHw/edit?usp=sharing)

## Contributing

When adding new PRDs or updating milestones:

1. Follow the naming convention: `PRD MekarPad [X/7] Feature Name.md`
2. Update this README with new document references
3. Ensure alignment with the overall milestone plan
4. Include user stories, technical requirements, and success metrics
