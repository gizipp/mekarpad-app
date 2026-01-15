# MekarPad

An author platform and ecosystem built with Rails 8.1.1 - **Milestone 1 MVP**

[![Epic 4: Complete](https://img.shields.io/badge/Epic%204-Complete%20(100%25)-brightgreen)](doc/EPIC4_COMPLETION_REPORT.md)
[![Tests](https://img.shields.io/badge/Tests-168%2B-success)]()
[![Performance](https://img.shields.io/badge/Load%20Time-%3C2s-blue)]()

## Overview

MekarPad is a comprehensive platform where writers can create, edit, publish, and monetize serialized stories, and readers can discover and engage with them. The platform combines the core publishing features of platforms like Wattpad with distribution capabilities similar to Draft2Digital, creating a complete solution for independent authors.

**Current Phase**: Milestone 1 MVP - Building the foundational author platform with core writing, publishing, and reading features in a clean, minimal interface.

**Latest Update**: Epic 4 (Public Reading & Discovery) completed with 100% test coverage, performance monitoring, and multi-language support.

## Key Features (Milestone 1 MVP)

### 📚 Story Management
- Create, edit, and publish stories with chapters
- Simple text editor for content
- Cover image uploads via Active Storage
- Categorization by genre
- Draft and published status
- Basic view count tracking

### 🔐 Authentication
- Magic link email authentication (OTP)
- Passwordless authentication with 6-digit codes
- 15-minute code expiration
- No password storage

### 👤 Author Dashboard
- View all your stories (drafts and published)
- Manage chapters
- Track story statistics
- Simple, clean interface

### 📖 Reading Experience (Epic 4 - Complete ✅)
- **Discover Page**: Browse newest published stories with filters
- **Multi-Language Support**: Filter by English, Bahasa Indonesia, Bahasa Melayu
- **Category Filtering**: 7 genres (Romance, Fantasy, Mystery, Thriller, SciFi, Horror, Adventure)
- **Book Public Pages**: Cover, description, and chapter list
- **Seamless Navigation**: Next/previous chapter links at top and bottom
- **Performance Optimized**: All pages load in <2 seconds
- **Mobile-Responsive**: Clean reading experience on all devices

### 🎯 Epic Completion Status

- ✅ **Epic 1**: Authentication & User Roles (Complete)
- ✅ **Epic 2**: Authoring (Dashboard & Book Creation) (Complete)
- ✅ **Epic 3**: Writing (Chapter Editor) (Complete)
- ✅ **Epic 4**: Public Reading & Discovery (Complete - 100%)
- 🔄 **Epic 5**: Non-Functional & Foundation (In Progress)

### ✨ What's NOT in Milestone 1
This is a focused MVP. The following features are planned for future milestones:
- Monetization (coins, payments, earnings)
- Social features (comments, votes, follows, reading lists)
- Author profile pages and custom subdomains
- Marketplace integration
- External distribution (Amazon KDP, Google Books, etc.)
- Advanced customization and premium features

## Success Metrics (Milestone 1)

- **Author Activation**: ≥30% of new users create at least one book
- **Reader Engagement**: ≥50% of sessions exceed 3 minutes of reading
- **Publishing Time**: First-time authors can publish within 10 minutes
- **Reliability**: 99% uptime for MVP release

## Tech Stack

- **Backend:** Ruby on Rails 8.1.1
- **Frontend:** Hotwire (Turbo + Stimulus)
- **Database:** SQLite3 (development) / PostgreSQL (production)
- **Storage:** Active Storage for cover images
- **Styling:** Tailwind CSS
- **Ruby:** 3.3.6

## Quick Start

### 1. Install Dependencies
```bash
bundle install
```

### 2. Setup Database
```bash
bin/rails db:setup
```

This will:
- Create the database
- Run migrations
- Seed initial data (default coin packages, system settings)

### 3. Start the Server
```bash
bin/dev
```

Or for a simple Rails server:
```bash
bin/rails server
```

### 4. Access the Application
Open your browser and navigate to `http://localhost:3000`

### 5. First Time Setup

1. Sign in with your email (OTP code will be in server logs during development)
2. Complete your profile
3. Start creating stories!

## User Guide

### For Readers

**Discovering Stories (No Login Required)**
1. Visit the home page to see newest published stories
2. **Filter by Category**: Romance, Fantasy, Mystery, Thriller, SciFi, Horror, Adventure
3. **Filter by Language**: English, Bahasa Indonesia, Bahasa Melayu
4. Click on any story to view cover, description, and chapter list
5. Browse by combining category and language filters

**Reading Stories**
1. Click on any story to view details
2. Click on a chapter to start reading
3. Use **Next** and **Previous** buttons to navigate seamlessly
4. Navigation available at both top and bottom of page
5. End-of-story message when reaching the last chapter

**Sign In (Optional for Reading)**
1. Enter your email to receive an OTP code
2. Check your email (or server logs in development) for the 6-digit code
3. Verify code to access additional features

### For Authors

**Creating Stories** (Epic 2 Complete ✅)
1. Sign in and go to Dashboard
2. Click "Create New Story" or "New Story"
3. Add title, description, **category**, **language**, and cover image
4. Choose category from 7 genres
5. Select language (English, Bahasa Indonesia, Bahasa Melayu)
6. Save as draft or publish immediately

**Adding Chapters** (Epic 3 Complete ✅)
1. Open your story from the dashboard
2. Click "Add Chapter"
3. Write your chapter title and content
4. Save as draft or publish
5. Chapters are automatically ordered

**Managing Stories**
- Edit story details anytime (including language and category)
- Add, edit, or delete chapters
- Toggle between draft and published status
- View basic statistics (views, chapter count)
- Your stories are discoverable by language and category filters

## Configuration

### Environment Variables (Production)

Create a `.env` file or set environment variables:

```bash
# Email Configuration
SMTP_ADDRESS=smtp.example.com
SMTP_PORT=587
SMTP_DOMAIN=example.com
SMTP_USERNAME=your_username
SMTP_PASSWORD=your_password

# Database
DATABASE_URL=postgresql://user:password@host:port/database

# Rails
RAILS_ENV=production
SECRET_KEY_BASE=your_secret_key
```

## Development

### Email Configuration

In development, emails are logged to console. Check Rails server output for OTP codes.

For production, configure SMTP settings in `config/environments/production.rb` or use environment variables.

### Database Migrations

```bash
# Create a new migration
bin/rails generate migration MigrationName

# Run migrations
bin/rails db:migrate

# Rollback
bin/rails db:rollback

# Reset database
bin/rails db:reset
```

### Seeds

The seed file (`db/seeds.rb`) creates:
- Default coin packages
- System settings with default values
- Optional demo data

Run with:
```bash
bin/rails db:seed
```

### Testing

MekarPad has **168+ comprehensive tests** covering all Epic 4 features:
- **Unit Tests**: 146 tests (controllers + models)
- **Feature Tests**: 30 scenarios (end-to-end user journeys)
- **Performance Tests**: 22 tests (validating <2s load time requirement)

**Run all tests**
```bash
bundle exec rspec
```

**Run specific test suites**
```bash
# Epic 4 feature tests (complete user journeys)
bundle exec rspec spec/features/public_reading_discovery_spec.rb

# Performance tests (NFR validation)
bundle exec rspec spec/performance/reading_pages_spec.rb

# Controller tests
bundle exec rspec spec/controllers/

# Model tests
bundle exec rspec spec/models/
```

**Run with coverage**
```bash
COVERAGE=true bundle exec rspec
```

**Performance Testing**
```bash
# Validate <2s page load requirement
bundle exec rspec spec/performance/reading_pages_spec.rb --format documentation
```

### Code Quality

**RuboCop (Linting)**
```bash
bundle exec rubocop
```

**Brakeman (Security)**
```bash
bundle exec brakeman
```

**Bundler Audit**
```bash
bundle exec bundler-audit check --update
```

## Routes

### Public Routes (No Authentication Required)
- `GET /` - Discover page (browse published stories)
- `GET /stories` - Browse stories with filters
  - `?category=Romance` - Filter by category
  - `?language=en` - Filter by language (en/id/ms)
  - `?category=Romance&language=en` - Combined filters
- `GET /stories/:id` - View story details and chapter list
- `GET /stories/:story_id/chapters/:id` - Read chapter with navigation

### Authentication
- `GET /session/new` - Login page
- `POST /session` - Send OTP code to email
- `GET /session/verify` - OTP verification page
- `POST /session/validate_otp` - Verify OTP code
- `DELETE /session` - Sign out

### User Actions (Authenticated)
- `GET /user/edit` - Edit profile
- `PATCH /user` - Update profile
- `GET /dashboard` - Author dashboard
- `GET /stories/my_stories` - View your stories
- `GET /stories/new` - New story form
- `POST /stories` - Create story
- `GET /stories/:id/edit` - Edit story
- `PATCH /stories/:id` - Update story
- `DELETE /stories/:id` - Delete story
- `GET /stories/:story_id/chapters/new` - New chapter form
- `POST /stories/:story_id/chapters` - Create chapter
- `GET /stories/:story_id/chapters/:id/edit` - Edit chapter
- `PATCH /stories/:story_id/chapters/:id` - Update chapter
- `DELETE /stories/:story_id/chapters/:id` - Delete chapter

## Deployment

### Docker

Build and run with Docker:

```bash
# Build image
docker build -t mekarpad .

# Run container
docker run -p 3000:3000 \
  -e DATABASE_URL=your_database_url \
  -e SECRET_KEY_BASE=your_secret \
  mekarpad
```

### Kamal

Deploy with Kamal (included in Gemfile):

```bash
# Setup
kamal setup

# Deploy
kamal deploy

# Other commands
kamal app logs
kamal app exec 'bin/rails console'
```

### Traditional Deployment

1. Set up PostgreSQL database
2. Configure environment variables
3. Precompile assets: `RAILS_ENV=production bin/rails assets:precompile`
4. Run migrations: `RAILS_ENV=production bin/rails db:migrate`
5. Start server: `RAILS_ENV=production bin/rails server`

## Project Structure

```
app/
├── controllers/      # Request handlers
├── models/          # Data models and business logic
├── views/           # HTML templates (ERB)
├── mailers/         # Email templates and logic
├── jobs/            # Background jobs
└── helpers/         # View helpers

config/
├── locales/         # Translation files (9 languages)
├── routes.rb        # URL routing
└── environments/    # Environment-specific configs

db/
├── migrate/         # Database migrations
└── seeds.rb         # Seed data

spec/
├── controllers/     # Controller unit tests (61 tests)
├── models/          # Model unit tests (85 tests)
├── features/        # End-to-end feature tests (30 scenarios)
└── performance/     # Performance tests (22 tests)

test/                # Minitest tests

doc/
├── EPIC4_COMPLETION_REPORT.md  # Epic 4 implementation details
└── PERFORMANCE.md              # Performance optimization guide
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Standards

- Follow Ruby Style Guide
- Run RuboCop before committing
- Write tests for new features
- Update documentation as needed

## Security

- Report security vulnerabilities to security@mekarpad.com
- Do not commit sensitive data (.env files, credentials)
- Use environment variables for all secrets
- Keep dependencies updated

## Performance

Epic 4 implements **strict performance requirements**:
- ✅ **All pages load in < 2 seconds** (NFR validated with automated tests)
- ✅ Database indexes on all critical queries
- ✅ N+1 query prevention via eager loading
- ✅ Counter caches for efficient counts
- ✅ Pagination limiting (20 stories per page)

### Performance Monitoring

**Automatic Monitoring** (Production):
- Slow queries logged automatically (>100ms)
- Slow page loads logged (>2s - NFR violations)
- See `config/initializers/performance_monitoring.rb`

**Recommended APM Tools**:
- New Relic
- Scout APM
- Skylight
- Datadog

For complete performance guide, see: [`doc/PERFORMANCE.md`](doc/PERFORMANCE.md)

## Documentation

### Epic 4: Public Reading & Discovery
- **Completion Report**: [`doc/EPIC4_COMPLETION_REPORT.md`](doc/EPIC4_COMPLETION_REPORT.md)
  - Full implementation details
  - Test coverage summary
  - Production readiness checklist

- **Performance Guide**: [`doc/PERFORMANCE.md`](doc/PERFORMANCE.md)
  - Optimization strategies
  - Monitoring setup
  - APM recommendations
  - Troubleshooting guide

### PRD Documentation
- See `/prd` folder for all Product Requirements Documents
- [`prd/PRD MekarPad [1_7] Core Author Platform.md`](prd/PRD%20MekarPad%20[1_7]%20Core%20Author%20Platform.md)

## Troubleshooting

### Common Issues

**OTP not received**
- In development: Check Rails server logs for the OTP code
- In production: Verify SMTP settings in environment variables
- Check spam/junk folder
- OTP expires after 15 minutes

**Can't upload cover image**
- Verify Active Storage is configured
- Check file size limits
- Ensure storage directory is writable

**Slow page loads (>2 seconds)**
- Check `log/production.log` for slow query warnings
- Review performance monitoring logs
- See troubleshooting section in [`doc/PERFORMANCE.md`](doc/PERFORMANCE.md)
- Run performance tests: `bundle exec rspec spec/performance/`

**Tests failing**
- Ensure database is set up: `bin/rails db:test:prepare`
- Check for pending migrations: `bin/rails db:migrate`
- Clear test cache: `bin/rails tmp:clear`

## License

This project is available as open source under the terms of the MIT License.

## Roadmap

This is **Milestone 1 of 7** in the MekarPad platform development. Each milestone builds upon the previous to create a comprehensive author ecosystem.

### Milestone 1: Core Author Platform MVP ✅ In Progress
**Goal**: Launch a working MVP where authors can write, edit, and publish serialized stories.

**Deliverables**:
- User registration (Magic link login)
- Author dashboard (My Books, Drafts, Published)
- Book creation (title, cover, description)
- Chapter writing + editor
- Publish/unpublish chapters
- Public book view with reading experience
- Simple feed / discover page
- Basic reader account system
- Mobile-friendly UI

**User Stories organized in 5 Epics**:
- Epic 1: Authentication & User Roles
- Epic 2: Authoring (Dashboard & Book Creation) ✅ Completed
- Epic 3: Writing (Chapter Editor)
- Epic 4: Public Reading & Discovery
- Epic 5: Non-Functional & Foundation

### Milestone 2: Personal Author Pages & Subdomains
**Goal**: Let each author have their own page or subdomain (e.g., `gilang.mekarpad.com`)

**Deliverables**:
- Author profile page with bio, photo, social links
- List of books by the author
- Optional vanity URL or subdomain support
- Custom branding options (basic theming)

### Milestone 3: Reader Engagement & Monetization Readiness
**Goal**: Add features for reader growth and monetization prep

**Deliverables**:
- Chapter locks (for email or future coins)
- Newsletter signup integration (Mailchimp, ConvertKit, etc.)
- Comments or reactions per chapter
- Book likes or bookmarks
- Author follow system

### Milestone 4: Marketplace (MekarBooks Integration)
**Goal**: Connect published books with a marketplace

**Deliverables**:
- Book listing metadata (genre, price, etc.)
- Integration with MekarBooks or dedicated storefront
- Search, filters, category views
- "Add to Cart" or "Read Sample" options
- Free vs paid version control

### Milestone 5: Monetization Infrastructure
**Goal**: Enable authors to earn

**Deliverables**:
- Coin/token purchase system (Midtrans/Xendit or Stripe)
- Unlocking content via tokens
- Author revenue dashboard
- Commission/split settings
- Payment gateway + payout integration

### Milestone 6: External Distribution & Publishing
**Goal**: Enable authors to distribute books to outside platforms (Draft2Digital-style)

**Deliverables**:
- Manuscript export (EPUB/PDF)
- Metadata export tools
- Distribution options: Amazon KDP, Google Books, etc.
- Integration hooks (manual or API-first)
- Simple agreement & approval flow for distribution

### Milestone 7: Advanced Customization & Add-ons
**Goal**: Personal branding, premium author experience

**Deliverables**:
- Custom domain mapping (`authorname.com`)
- Page builder for authors
- Premium author themes
- Author-only analytics
- Collaboration tools (co-authoring)

---

**For detailed product requirements**, see the [`/prd`](./prd) folder which contains:
- [MekarPad Milestone Plan](./prd/MekarPad%20Milestone.md) - Complete 7-milestone roadmap
- [PRD Milestone 1: Core Author Platform](./prd/PRD%20MekarPad%20%5B1_7%5D%20Core%20Author%20Platform.md) - Detailed requirements and user stories
- [PRD README](./prd/README.md) - Documentation overview and external PRD links

## Key Features Summary

### 🎯 Epic 4: Public Reading & Discovery (100% Complete)
- ✅ Discover page with newest stories
- ✅ Category filtering (7 genres)
- ✅ Language filtering (3 languages)
- ✅ Book public pages with all details
- ✅ Seamless chapter navigation
- ✅ Performance optimized (<2s load time)
- ✅ 168+ comprehensive tests
- ✅ Production-ready monitoring

### 📊 Test Coverage
| Type | Count | Status |
|------|-------|--------|
| Unit Tests | 146 | ✅ |
| Feature Tests | 30 scenarios | ✅ |
| Performance Tests | 22 | ✅ |
| **Total** | **168+** | ✅ |

### ⚡ Performance Metrics
| Page | Target | Status |
|------|--------|--------|
| Discover Page | <2s | ✅ Validated |
| Book Page | <2s | ✅ Validated |
| Chapter Page | <2s | ✅ Validated |

## Support

- **Issues**: Open an issue on GitHub
- **Documentation**: Check `doc/` directory
- **PRD**: Check `prd/` directory for product requirements
- **Performance**: See `doc/PERFORMANCE.md`
- **Epic 4 Details**: See `doc/EPIC4_COMPLETION_REPORT.md`
- **Product Requirements**: Check [`prd/`](./prd) directory for detailed PRDs and milestone plans
- **Documentation**: See [`prd/README.md`](./prd/README.md) for complete documentation overview

## Acknowledgments

Built with:
- Ruby on Rails 8.1.1
- Hotwire (Turbo + Stimulus)
- SQLite3 / PostgreSQL
- Active Storage
- Tailwind CSS
- RSpec (Testing framework)
- Capybara (Feature testing)

---

**Last Updated**: 2025-11-12 | **Epic 4 Status**: ✅ Complete (100%)
