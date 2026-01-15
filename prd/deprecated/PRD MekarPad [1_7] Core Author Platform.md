# **🧾 Product Requirements Document (PRD)**

### **Project: MekarPad – Core Author Platform (MVP)**

### **Milestone: 1 of 7**

### **Objective:**

Build the foundation of MekarPad as a minimal, functional platform that allows authors to sign up, write serialized stories, and publish them for public reading — similar to Wattpad’s core flow, but lightweight, clean, and privacy-respectful.

---

## **🎯 Goals**

* Allow authors to create and publish their first story within minutes.  
* Provide a pleasant and distraction-free reading experience for readers.  
* Establish a scalable base for future features (author profiles, monetization, marketplace).

---

## **🧱 Core Features**

| Category | Feature | Description | Priority |
| ----- | ----- | ----- | ----- |
| **Authentication** | Magic Link Login | Users register and log in using an email-based magic link (no password). | 🟢 High |
| **Author Dashboard** | My Books, Drafts, Published | Authors can view, create, and manage their books in one dashboard. | 🟢 High |
| **Book Creation** | Create / Edit Book | Simple form for title, description, category, language and optional cover upload. | 🟢 High |
| **Chapter Editor** | Write / Edit Chapters | Minimal text editor to write, save drafts, and publish chapters. | 🟢 High |
| **Reader View** | Public Reading Page | Publicly accessible book pages showing chapter list, next/previous navigation. | 🟢 High |
| **Discover Page** | Feed of Stories | Public page displaying latest or featured published stories. | 🟡 Medium |
| **User Roles** | Author / Reader Roles | Different UI and permissions for authors and readers. | 🟢 High |
| **Responsive UI** | Mobile & Desktop | Clean, minimalist, mobile-first layout for reading and writing. | 🟢 High |

---

## **⚙️ Non-Functional Requirements**

| Category | Details |
| ----- | ----- |
| **Performance** | Reading pages should load in under 2 seconds on average. |
| **Scalability** | Modular architecture ready for future multi-tenant setup. |
| **Security** | Magic link must expire in 15 minutes and be single-use only. |
| **SEO / Indexing** | Published stories must include proper meta title, description, and OG tags. |
| **Accessibility** | High-contrast colors and readable typography (e.g. Inter, Poppins, Open Sans). |

---

## **🧭 User Flow**

1. User visits MekarPad homepage.  
2. Clicks “Login with Email.”  
3. Receives a magic link → clicks → redirected to dashboard.  
4. Creates a new book → enters title, description, and uploads cover.  
5. Adds a first chapter → writes → publishes.  
6. The book becomes publicly available and appears in the “Discover” feed.

---

## **🧩 Technical Stack (Proposed)**

| Layer | Tool / Framework | Notes |
| ----- | ----- | ----- |
| Backend | Ruby on Rails | Core API & server rendering (Hotwire/Turbo). |
| Frontend | Hotwire (Turbo \+ Stimulus) | SPA-like experience without heavy JS frameworks. |
| Authentication | Magic Link (Devise or Sorcery custom) | Passwordless auth. |
| Database | PostgreSQL | Relational storage for users, books, and chapters. |
| Storage | Cloudinary / ActiveStorage | For book cover uploads. |
| Deployment | Fly.io / Render | Lightweight hosting with quick CI/CD setup. |
| Styling | TailwindCSS | Utility-first responsive design. |

---

## **📊 Success Metrics**

| Metric | Target |
| ----- | ----- |
| Author Activation | ≥ 30 % of new users create at least one book. |
| Reader Engagement | ≥ 50 % of sessions exceed 3 minutes of reading. |
| Publishing Time | First-time authors can publish a book within 10 minutes. |
| Reliability | 99 % uptime for MVP release. |

---

## **🪜 Future Hooks (for next milestones)**

* Endpoint for author profile (`/author/:username`)  
* Placeholder for likes, comments, and followers  
* Chapter locking flag for future monetization  
* Base `Book` ↔ `Chapter` schema for scalability

### **Epic 1: Authentication & User Roles**

*(Mencakup fitur: Magic Link Login, User Roles, Basic reader account system, dan Security NFR)*

* **As a prospective Author,** I want to register using only my email, so that I can create an account and start writing as fast as possible, without password friction.  
* **As a prospective Reader,** I want to register using only my email, so that I can create a basic account for future use (like following or bookmarking in M3).  
* **As a registered User (Author or Reader),** I want to log in by clicking a time-sensitive (15-minute) magic link sent to my email, so that I can securely access my account without a password.  
* **(Critical) As a User,** if I click an expired or already-used magic link, I want to be clearly informed that the link is invalid and be given an option to request a new one, so that I am not left confused or locked out.  
* **(Critical) As a User,** if I don't receive the magic link email (e.g., spam folder), I want a clear "Resend link" option on the login page, so I have a way to retry.  
* **(Critical) As a logged-in Author,** I want my dashboard view to be different from a Reader's view, so that I have access to my "My Books" and "Create" tools, which a reader should not see.

  ### **Epic 2: Authoring (Dashboard & Book Creation)**

*(Mencakup fitur: Author Dashboard, Book Creation, dan Success Metrics)*

* **(Critical \- Empty State) As a new Author** visiting my dashboard for the first time, I want to see a clear call-to-action (e.g., "Create Your First Book"), so that I am guided on what to do next to meet the "Author Activation" goal.  
* **As an Author with existing books,** I want my dashboard to show all my books, clearly separated into "Published" and "Draft" lists, so I can quickly find, edit, or manage my work.  
* **As an Author,** I want to create a new book by providing a **title, description, language, category,** and uploading a **cover image**, so that I can establish the main identity of my story **and ensure it is discoverable by the right readers.**
* **As an Author,** I want to be able to edit a book's **title, description, language, category,** or **cover** after it has been created, so I can make corrections or updates.

  ### **Epic 3: Writing (Chapter Editor)**

*(Mencakup fitur: Chapter Editor dan Success Metrics)*

* **As an Author,** I want a minimal, distraction-free text editor with only basic formatting (e.g., bold, italic, lists), so I can focus purely on writing the content.  
* **As an Author,** I want to be able to save my chapter as a "Draft", so I can work on it incrementally and securely without it being public.  
* **(Critical \- Auto-save) As an Author,** I want my draft to auto-save frequently while I'm writing, so that I don't lose my work if my internet connection drops or I accidentally close the tab.  
* **As an Author,** I want to explicitly click a "Publish" button for a chapter, so I have full control over when my content goes live.  
* **As an Author,** I want to be able to edit and re-save a chapter after it has been published, so I can fix typos or make revisions.  
* **(Metric-driven) As a first-time Author,** I want the entire flow from signup to publishing my first chapter to be so simple that I can complete it in under 10 minutes, so that I feel immediately successful.

  ### **Epic 4: Public Reading & Discovery**

*(Mencakup fitur: Reader View, Discover Page, NFRs, dan Success Metrics)*

* **As a Reader,** I want to visit a "Discover" page that shows a feed of the newest published stories, so I can find new content. (Catatan: Ini sekarang dapat didukung oleh Kategori & Bahasa dari Epic 2).  
* **As a Reader,** I want to access a book's public page and see its cover, description, and a list of all its published chapters, so I can decide if I want to read it.  
* **As a Reader,** when reading a chapter, I want clear "Next Chapter" and "Previous Chapter" navigation links, so I can move through the story seamlessly.  
* **(NFR \- Performance) As a Reader,** I want the reading pages to load in under 2 seconds, so I can start reading immediately without frustration.  
* **(Metric-driven) As a Reader,** I want the reading experience to be so clean and engaging that I am encouraged to stay and read for more than 3 minutes.

  ### **Epic 5: Non-Functional & Foundation**

*(Mencakup fitur: Responsive UI dan NFRs)*

* **(NFR \- Responsive) As any User (Author or Reader),** I want the entire platform (dashboard, editor, reading pages) to be fully usable and readable on my mobile phone, so I can read or write on the go.  
* **(NFR \- Accessibility) As a User with visual impairments,** I want the UI to use high-contrast colors and readable typography (like Inter or Poppins), so I can have a comfortable experience.  
* **(NFR \- SEO) As an Author,** I want my published book's page to automatically use my book title and description as the `<title>` and `<meta description>` tags, so that it appears correctly in Google search results and when shared on social media.