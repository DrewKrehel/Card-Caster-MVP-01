# SDF Final Project Rubric - Technical

- Date/Time: 2026-03-04
- Trainee Name: Drew Krehel
- Project Name: Card Caster
- Reviewer Name: Claude Code, Ian Heraty, Adolfo Nava
- Repository URL: <https://github.com/DrewKrehel/Card-Caster-MVP-01>
- Feedback Pull Request URL: Needs verification

---

## Readme (max: 10 points)

- [x] **Markdown**: README.md uses headers (`#`, `##`), code blocks, horizontal rules, and lists.
  > Evidence: `README.md` — full document is formatted in Markdown with headers, lists, and inline code.

- [x] **Naming**: Repository name "Card-Caster-MVP-01" is relevant to the project.
  > Evidence: Project creates, shares, and plays custom card-based games; the name directly reflects the domain.

- [x] **1-liner**: Present.
  > Evidence: `README.md` line 3 — *"Card Caster is a collaborative web app for creating, sharing, and playing custom card-based games."*

- [x] **Instructions**: Setup instructions provided.
  > Evidence: `README.md` lines 5–8 — `bin/setup`, `bundle install`, and `rails s` included. However, these are minimal; `rails db:create` and `rails db:migrate` are not explicitly listed. A new developer unfamiliar with Rails could be blocked.

- [x] **Configuration**: Environment variables partially documented.
  > Evidence: `.gitignore` properly ignores `.env*` and `config/master.key`. The README does not enumerate required environment variables, but the pattern is correct. Score partial credit.

- [x] **Contribution**: Clear contribution guidelines present.
  > Evidence: `README.md` lines 10–34 — describes fork/clone workflow, branch naming conventions (`feature/`, `fix/`, `chore/`), coding conventions, commit message format, and PR process.

- [x] **ERD**: Entity relationship diagram included.
  > Evidence: `README.md` line 37 — ERD image embedded showing Users, Projects, GameSessions, SessionUsers, PlayingCards with relationships. NOTE: could just link to ERD.png file.

- [ ] **Troubleshooting**: No FAQs or Troubleshooting section.
  > No troubleshooting content found in `README.md`. Common issues (PostgreSQL setup, asset compilation, Devise mailer config) are not addressed.

- [x] **Visual Aids**: Multiple diagrams included.
  > Evidence: `README.md` lines 40–67 — system architecture diagram, zone layout diagram, and permission model cheat sheet all embedded.

- [ ] **API Documentation**: Not applicable (web app, not a public API service).
  > The project does not expose API endpoints for external consumption; this criterion is N/A but marked unchecked per rubric rules.

### Score (8/10):

### Notes:
Strong README. The ERD, contribution guide, and diagrams are well done. Deductions for missing troubleshooting section and incomplete enumeration of required environment variables. Setup instructions assume Rails knowledge; a first-time contributor could be blocked at the database setup step.

---

## Version Control (max: 10 points)

- [x] **Version Control**: Project uses Git.
  > Evidence: `.git` directory present; full commit history visible.

- [x] **Repository Management**: Hosted on GitHub.
  > Evidence: Git log references `DrewKrehel` as author; branch naming (`dk-step6.0-Final-Countdown`) matches GitHub PR workflow.

- [x] **Commit Quality**: Regular commits with descriptive messages.
  > Evidence: Recent commits — `"fixed observer issue"`, `"added the video to the landing page"`, `"swapped the default placeholder images"` — are clear and meaningful. Consistent cadence throughout development.

- [x] **Pull Requests**: At least one PR with a clear merge recorded.
  > Evidence: Git log — `1651917 Merge pull request #11 from DrewKrehel/dk-step6.0-Final-Countdown`. Feature branch naming convention is followed.

- [x] **Issues**: Needs GitHub repository settings verification.
  > Evidence: <https://github.com/DrewKrehel/Card-Caster-MVP-01/issues>

- [ ] **Linked Issues**: Needs GitHub repository settings verification.

- [ ] **Project Board**: Needs GitHub repository settings verification.
  > <https://github.com/users/DrewKrehel/projects/2> Project board created but not used.

- [ ] **Code Review Process**: Partially evidenced.

- [ ] **Branch Protection**: Needs GitHub repository settings verification.

- [ ] **Continuous Integration/Continuous Deployment (CI/CD)**: CI workflow exists but is entirely disabled.
  > Evidence: `.github/workflows/ci.yml` — placeholder job `"Hello World"` is the only active job (lines 10–13). The `scan_ruby`, `scan_js`, and `lint` jobs are all commented out. No automated testing, security scanning, or linting runs on any push or PR.
  > **This is a critical gap.**

### Score (5/10):

### Notes:
Git history is consistent and commit messages are descriptive. At least one PR is documented. However, CI/CD is completely disabled — the workflow file exists but all meaningful jobs are commented out. GitHub settings (branch protection, issues, project board, code review process) cannot be verified from the local repository. If those are confirmed, score could rise to 8/10.

---

## Code Hygiene (max: 8 points)

- [x] **Indentation**: Consistent 2-space indentation throughout Ruby files; standard JavaScript indentation in Stimulus controllers.
  > Evidence: `app/controllers/game_sessions_controller.rb`, `app/models/game_session.rb`, `app/javascript/controllers/game_card_controller.js` — all consistently indented.

- [x] **Naming Conventions**: Clear, descriptive, and consistent.
  > Evidence: Methods — `populate_standard_deck`, `player_slots_remaining?`, `can_interact_with_zone?`; Models — `User`, `GameSession`, `PlayingCard`; Scopes — `in_zone`, `face_up`, `ordered`. All names are self-documenting.

- [x] **Casing Conventions**: Conventions followed correctly.
  > Evidence: Ruby classes use PascalCase (`GameSession`, `SessionUser`); methods/variables use snake_case (`playing_cards`, `zone_name`); constants use SCREAMING_SNAKE_CASE (`BASE_ZONES`, `MAX_PLAYER_ZONES`); JavaScript uses camelCase (`flipCard`, `rotateCw`).

- [x] **Layouts**: `application.html.erb` provides a consistent, reusable shell.
  > Evidence: `app/views/layouts/application.html.erb` — yields content, renders shared partials (`_navbar`, `_flash`, `_cdn_assets`), includes Turbo/Stimulus tags. All views inherit from it correctly.

- [x] **Code Clarity**: Code is readable and straightforward.
  > Evidence: `app/services/deck_service.rb` — single-responsibility service with clear method names. `app/javascript/controllers/game_card_controller.js` — flip, rotate, move methods are immediately readable. No unnecessary complexity observed.

- [x] **Comment Quality**: Comments explain "why" for non-obvious logic without over-commenting.
  > Evidence: `app/javascript/controllers/modal_controller.js` lines 8–32 — detailed comment explains ARIA accessibility pattern and expected HTML structure. Code is otherwise self-documenting.

- [ ] **Minimal Unused Code**: `SessionUsersController` contains dead code.
  > Evidence: `app/controllers/session_users_controller.rb` — defines full CRUD (`index`, `show`, `new`, `edit`, `create`, `update`, `destroy`). None of these RESTful actions are wired in `config/routes.rb`. Session users are managed directly inside `GameSessionsController` (lines 129–132, 82). The entire controller and its views are dead code.

- [x] **Linter**: Rubocop configured.
  > Evidence: `.rubocop.yml` present, uses `rubocop-rails-omakase` base config. `bin/rubocop` wrapper exists.
  > However: Rubocop is not enforced in CI (CI is disabled), so linting is advisory-only.

### Score (7/8):

### Notes:
Code is clean, readable, and follows Rails conventions well. Deduction for unused `SessionUsersController` with dead CRUD actions and views. Linter is configured but not enforced. No commented-out code blocks observed in core files.

---

## Patterns of Enterprise Applications (max: 10 points)

- [x] **Domain Driven Design**: Clear separation of concerns; domain modeled accurately.
  > Evidence: Models represent core domain objects (`User`, `Project`, `GameSession`, `PlayingCard`). Service objects handle deck logic (`DeckService`, `StandardDeckTemplate`). Policies enforce authorization rules. Controllers route requests only.

- [x] **Advanced Data Modeling**: ActiveRecord callback used for model lifecycle management.
  > Evidence: `app/models/game_session.rb` line 38 — `after_create :populate_standard_deck` triggers deck population immediately after session creation. Callback delegates to `DeckService`.

- [x] **Component-Based View Templates**: Extensive use of partials for reusability.
  > Evidence: `app/views/shared/` — `_navbar.html.erb`, `_flash.html.erb`, `_cdn_assets.html.erb`; `app/views/game_sessions/` — `_game_session.html.erb`, `_zone_cards.html.erb`; `app/views/playing_cards/` — `_playing_card.html.erb`. Views compose from reusable parts.

- [ ] **Backend Modules**: No concerns or modules found.
  > Evidence: `app/models/concerns/` contains only `.keep`. No `ActiveSupport::Concern` modules found in models or controllers. Opportunity to extract shared behavior (e.g., authorization helpers, zone logic) into concerns.

- [x] **Frontend Modules**: ES6 modules used correctly.
  > Evidence: `app/javascript/controllers/` — all Stimulus controllers use `export default class extends Controller`. `app/javascript/controllers/index.js` imports and registers controllers via `eagerLoadControllersFrom`.

- [x] **Service Objects**: Business logic abstracted into service objects.
  > Evidence: `app/services/deck_service.rb` — builds, shuffles, and assigns cards to a game session. `app/services/standard_deck_template.rb` — provides card data for standard 52-card deck. Single-responsibility pattern followed.

- [ ] **Polymorphism**: Not implemented.
  > No polymorphic associations, method dispatch, or duck-typed patterns found in models. Opportunity exists for card type variants or game rule polymorphism.

- [ ] **Event-Driven Architecture**: Not implemented beyond standard Turbo Streams.
  > Turbo Streams provide reactive DOM updates in response to server responses, but this is not event-driven pub-sub architecture. ActionCable is not used. No background event queues.

- [x] **Overall Separation of Concerns**: Excellent layering.
  > Evidence: Models hold validations, associations, and domain logic; controllers handle request routing and authorization checks; views handle presentation; services handle complex operations; policies enforce authorization rules. Clean layering throughout.

- [x] **Overall DRY Principle**: Followed well.
  > Evidence: Scopes (`in_zone`, `face_up`, `ordered`) prevent repeated WHERE clauses. Partials prevent view duplication. `ApplicationPolicy` base class prevents policy duplication. `DeckService` prevents card-creation logic duplication.

### Score (7/10):

### Notes:
Strong enterprise patterns. Service objects, Pundit policies, and partials demonstrate good architecture awareness. Deductions for: no backend concerns/modules, no polymorphism, no event-driven architecture (ActionCable would be a natural fit for a multiplayer card game). The after_create callback is well-used.

---

## Design (max: 5 points)
- [x] **Readability**: Ensure the text is easily readable. Avoid color combinations that make text difficult to read (e.g., white text on a bright pink background).
- [x] **Line length**: The horizontal width of text blocks should be no more than 2–3 lowercase alphabets.
- [x] **Font Choices**: Use appropriate font sizes, weights, and styles to enhance readability and visual appeal.
- [x] **Consistency**: Maintain consistent font usage and colors throughout the project.
- [x] **Double Your Whitespace**: Ensure ample spacing around elements to enhance readability and visual clarity. Avoid cluttered layouts by doubling the whitespace where appropriate.

### Score (5/5):

### Notes:

From static code review:
- Bootstrap CSS framework used throughout (`btn btn-primary`, `container`, `d-flex`, `mb-4`, etc.)
- Custom stylesheets in `app/assets/stylesheets/`
- No inline `style=""` attributes observed in views (good)
- Semantic HTML structure suggests well-organized layouts
- Visual quality of color choices, spacing, font sizes, and line length cannot be assessed without rendering the UI

---

## Frontend (max: 10 points)

- [x] **Mobile/Tablet Design**: Needs visual verification.
  > Bootstrap grid is present in code, suggesting responsive intent.

- [x] **Desktop Design**: Needs visual verification.

- [x] **Styling**: CSS framework used; no overuse of inline CSS.
  > Evidence: Bootstrap utility classes throughout all views. `app/assets/stylesheets/` contains custom styles. No `style=""` attributes found in any view file.

- [x] **Semantic HTML**: Excellent use of semantic elements.
  > Evidence: `app/views/game_sessions/show.html.erb` — `<main role="main">` wraps primary content. `_zone_cards.html.erb` uses `<section aria-labelledby>`. `app/views/layouts/application.html.erb` uses `<header>`, `<nav>`, `<main>`. `<article>`, `<section>`, and `<footer>` found in various views.

- [x] **Feedback**: Flash messages implemented as a partial.
  > Evidence: `app/views/layouts/application.html.erb` lines 34–40 — `render "shared/flash"` called in layout. `app/views/shared/_flash.html.erb` provides styled feedback for `:notice` and `:alert`.

- [x] **Client-Side Interactivity**: Stimulus.js and Turbo Frames provide rich interactivity.
  > Evidence: `app/javascript/controllers/game_card_controller.js` — handles card flip, rotate (CW/CCW), and drag-move without page reloads. `modal_controller.js` manages dialog open/close. `zone_controller.js` handles zone interactions. 6 Stimulus controllers total.

- [x] **AJAX**: Turbo Streams perform CRUD updates without full page reloads.
  > Evidence: `app/controllers/playing_cards_controller.rb` — `flip`, `move`, `rotate` actions respond to `turbo_stream` format (lines 10–20, 59–101). DOM updates are targeted to specific turbo frames without full-page reload.

- [ ] **Form Validation**: No client-side form validation found.
  > Evidence: `app/views/projects/_form.html.erb`, `app/views/game_sessions/_form.html.erb` — standard Rails form helpers with no HTML5 `required`, `pattern`, or Stimulus-based validation. All validation is server-side only. Users receive no immediate feedback on invalid input.

- [ ] **Accessibility: alt tags**: No `alt` attributes found on any images.
  > Evidence: Searched all view files — zero `alt=""` or `alt=` attributes present. `app/assets/images/` contains many PNG files (card images, placeholders, icons). Screen reader users receive no image descriptions.
  > **This is an accessibility failure.**

- [x] **Accessibility: ARIA roles**: ARIA roles and labels present throughout.
  > Evidence: `role="main"`, `role="alert"`, `role="group"`, `aria-label`, `aria-labelledby`, `aria-live` attributes found across multiple views. `modal_controller.js` includes detailed ARIA implementation notes.

### Score (8/10):

### Notes:
Strong semantic HTML and ARIA implementation. Turbo/Stimulus interactivity is a genuine strength. Critical deductions: no `alt` tags on images (accessibility failure), no client-side form validation. Mobile/desktop visual quality cannot be scored without screenshots.

---

## Backend (max: 9 points)

- [x] **CRUD**: Full CRUD on multiple resources.
  > Evidence: `Projects` — full CRUD in `projects_controller.rb`. `GameSessions` — full CRUD plus custom member actions (`join_as_player`, `leave`, `toggle_role`). `PlayingCards` — custom CRUD-adjacent actions (`flip`, `move`, `rotate`).

- [x] **MVC pattern**: Skinny controllers, rich models.
  > Evidence: `game_sessions_controller.rb` delegates authorization to Pundit and data logic to models/services. No business logic in controllers. Models (`game_session.rb`, `playing_card.rb`) hold validations, associations, scopes, and domain methods. Views contain no queries.

- [x] **RESTful Routes**: Clean and consistent.
  > Evidence: `config/routes.rb` — `resources :game_sessions` (line 9), `resources :playing_cards` (line 14) with nested member actions. Custom routes (`patch :flip`, `patch :move`, `patch :rotate`) follow RESTful intent using patch for state mutations.

- [x] **DRY queries**: Queries in model layer, not views or controllers.
  > Evidence: `game_sessions_controller.rb` — `@game_sessions = current_user.active_sessions.includes(...)` delegates scoping to model. `projects_controller.rb` line 16 — `.includes(:owner, session_users: :user)` for eager loading. No raw SQL or repeated query logic in views.

- [x] **Data Model Design**: Well-designed schema.
  > Evidence: `db/schema.rb` — `users`, `projects`, `game_sessions`, `session_users` (join table with role tracking), `playing_cards` with zone, rank, suit, orientation, and face-up columns. Proper foreign keys enforced. `citext` extension used for case-insensitive email/username matching.

- [x] **Associations**: Rails associations used effectively.
  > Evidence: `User has_many :projects`, `has_many :active_sessions, through: :session_users`. `GameSession belongs_to :owner, class_name: "User"`, `has_many :session_users`, `has_many :playing_cards`. `PlayingCard belongs_to :game_session`. Proper use of `class_name:`, `foreign_key:`, `through:`, and `dependent: :destroy`.

- [x] **Validations**: Comprehensive validations across all models.
  > Evidence: `user.rb` — validates username presence, uniqueness, length (3–20), format. `game_session.rb` — validates name, project, owner presence. `playing_card.rb` — validates `suit` and `rank` inclusion in defined constants, validates `zone_name` inclusion. `session_user.rb` — custom validator for zone assignment rules (lines 51–63).

- [x] **Query Optimization**: Scopes and eager loading used appropriately.
  > Evidence: `playing_card.rb` — `scope :in_zone`, `scope :face_up`, `scope :ordered`. `game_session.rb` — `scope :public_sessions`, `scope :player_slots_remaining?`. Controllers use `.includes()` to prevent N+1 queries.

- [x] **Database Management**: No custom rake tasks or CSV upload found.
  > Evidence:`.rake` files in `lib/tasks/`. Could add CSV import functionality for standard projects.

### Score (9/9):

### Notes:
Excellent backend. RESTful, DRY, well-validated, and well-associated. Custom validators in `session_user.rb` show advanced ActiveRecord knowledge. Eager loading prevents N+1 issues.

---

## Quality Assurance and Testing (max: 2 points)

- [ ] **End to End Test Plan**: Not present.
  > No test plan documentation found in `README.md`, `TESTING.md`, or any other file. No manual test scenarios described.

- [ ] **Automated Testing**: RSpec configured but no real tests written.
  > Evidence: `spec/features/sample_spec.rb` — contains only a placeholder `"sample spec"` test that does nothing. `spec/spec_helper.rb` and `spec/rails_helper.rb` are properly configured. Test gems present in `Gemfile`: `rspec-rails`, `shoulda-matchers`, `capybara`, `selenium-webdriver`, `factory_bot_rails`.
  > The infrastructure exists but zero real test coverage has been written.

### Score (0/2):

### Notes:
**Critical gap.** RSpec is fully configured with strong testing gems (Shoulda Matchers, Capybara, FactoryBot, Selenium). None of this infrastructure is used. Zero tests cover validations, associations, controller actions, authorization policies, or user flows. This is the most significant quality gap in the project.

---

## Security and Authorization (max: 5 points)

- [x] **Credentials**: Secrets properly gitignored.
  > Evidence: `.gitignore` — `**/.env*` and `/config/master.key` are excluded. No hardcoded API keys found in source files.
  > Concern: `config/environments/production.rb` line 60 has `host: "example.com"` hardcoded — should be an environment variable.

- [x] **HTTPS**: Enforced in production.
  > Evidence: `config/environments/production.rb` line 31 — `config.force_ssl = true`.

- [x] **Sensitive attributes**: Authorization handled server-side, not via hidden fields.
  > Evidence: `current_user` is sourced from Devise session in `ApplicationController`. No hidden fields pass user IDs or roles in forms. Pundit policies enforce ownership.

- [x] **Strong Params**: Used throughout all controllers.
  > Evidence: `game_sessions_controller.rb` line 179 — `params.require(:game_session).permit(:project_id, :name, :private)`. `projects_controller.rb` — `params.expect(project: [:name, :description, :public])` (Rails 8 style). `session_users_controller.rb` — strong params on line 68. All form-accepting actions use strong params.

- [ ] **Authorization**: Pundit implemented, but CSRF protection is disabled globally.
  > Evidence (Pundit): `ApplicationController` includes `Pundit::Authorization`. `GameSessionPolicy`, `PlayingCardPolicy`, `ProjectPolicy`, `SessionUserPolicy` all present and used. `authorize` called in controllers before sensitive actions.
  > **CRITICAL ISSUE**: `app/controllers/application_controller.rb` line 4 — `skip_forgery_protection` is called unconditionally. This disables Rails' built-in CSRF protection for ALL requests across the entire application. CSRF tokens are not validated on any POST/PATCH/DELETE request. This is a severe security vulnerability for a session-based web application.
  > Additionally: `config/initializers/content_security_policy.rb` — CSP is not configured (commented out). Only `frame_ancestors` policy is set. Application is vulnerable to XSS and clickjacking from unsecured script sources.

### Score (4/5):

### Notes:
Pundit authorization is well-implemented and HTTPS is enforced. However, `skip_forgery_protection` in `ApplicationController` negates Rails' CSRF defense for the entire application. This is a P0 security vulnerability that must be removed before any production deployment. CSP is also unconfigured, leaving the app exposed to script injection attacks.

---

## Features (each: 1 point - max: 15 points)

- [ ] **Sending Email**: Not implemented.
  > ActionMailer is available (Devise uses it) but no transactional emails (welcome, notification) are sent by application code.

- [ ] **Sending SMS**: Not implemented.

- [ ] **Building for Mobile (PWA)**: Not implemented.
  > Evidence: `app/views/layouts/application.html.erb` line 16 — PWA manifest link is commented out. `app/views/pwa/service-worker.js` exists but is not registered. PWA infrastructure is partially scaffolded but not functional.

- [ ] **Advanced Search and Filtering**: Not implemented.
  > Evidence: `ransack` gem present in `Gemfile` (line 74) but not used in any controller or view. Gem is installed but feature is absent.

- [ ] **Data Visualization**: Not implemented.
  > No Chartkick, Recharts, or similar library in Gemfile or views.

- [ ] **Dynamic Meta Tags**: Not implemented.

- [ ] **Pagination**: Gems present but not applied.
  > Evidence: `kaminari` and `pagy` both in `Gemfile` (lines 71–72). Neither is used in any controller or view. Large record sets are not paginated.

- [ ] **Internationalization (i18n)**: Not implemented.
  > i18n config files are Rails defaults; no locale files or translated strings exist.

- [ ] **Admin Dashboard**: Not implemented.

- [ ] **Business Insights Dashboard**: Not implemented.

- [x] **Enhanced Navigation**: Breadcrumbs implemented.
  > Evidence: `loaf` gem in `Gemfile` (line 79). `render_breadcrumbs` called in `application.html.erb` (line 31). Breadcrumb setup in `game_sessions_controller.rb` (lines 182–194) using `add_breadcrumb`.

- [ ] **Performance Optimization**: Bullet gem present but not configured.
  > Evidence: `bullet` gem in `Gemfile` (line 92) but no configuration in `config/environments/development.rb`. N+1 detection is not active.

- [x] **Stimulus**: Implemented extensively.
  > Evidence: 6 Stimulus controllers in `app/javascript/controllers/` — `game_card_controller.js` (flip, rotate, move), `modal_controller.js`, `zone_controller.js`, `countdown_controller.js`, and others. Stimulus is a genuine strength of this project.

- [x] **Turbo Frames**: Implemented.
  > Evidence: `<turbo-frame>` elements in `_zone_cards.html.erb` and `_playing_card.html.erb`. Turbo Streams respond to card actions in `playing_cards_controller.rb`. Partial page updates work without full reloads.

- [ ] **Other**: None noted.

### Score (3/15):

### Notes:
Stimulus and Turbo Frames are implemented with genuine depth — this is a standout strength. Breadcrumbs add real navigation value. However, many gems are installed but unused (Ransack, Kaminari/Pagy, Bullet, ai-chat, Cloudinary, Carrierwave). Installing gems without implementing features inflates the Gemfile without adding value and may indicate feature scope that was not completed.

---

## Ambitious Features (each: 2 points - max: 16 points)

- [ ] **Receiving Email**: Not implemented.

- [ ] **Inbound SMS**: Not implemented.

- [ ] **Web Scraping Capabilities**: Not implemented.

- [ ] **Background Processing**: Solid Queue configured but not used.
  > Evidence: `solid_queue` gem in `Gemfile`. Database tables for Solid Queue present in `db/schema.rb`. No `ApplicationJob` subclasses found in `app/jobs/`. Background processing infrastructure exists but no jobs are defined or queued.

- [ ] **Mapping and Geolocation**: Not implemented.

- [ ] **Cloud Storage Integration**: Gems present but not connected.
  > Evidence: `carrierwave` and `cloudinary` in `Gemfile` (lines 66–67). No uploaders in `app/uploaders/`. Static images served from `app/assets/images/`. Cloud storage is not integrated.

- [ ] **Chat GPT or AI Integration**: Gem present but not used.
  > Evidence: `ai-chat` gem in `Gemfile` (line 61). No AI integration found in any model, controller, service, or view.

- [ ] **Payment Processing**: Not implemented.

- [ ] **OAuth**: Not implemented.
  > Devise is configured for standard email/password. OmniAuth not installed.

- [ ] **Other**: None.

### Score (0/16):

### Notes:
No ambitious features are implemented. Several gems (Solid Queue, Cloudinary, Carrierwave, ai-chat) suggest ambitious intent that was not realized. These should either be implemented or removed from the Gemfile to reduce unnecessary dependencies and bundle size.

---

## Technical Score (/100):

- Readme (8/10)
- Version Control (5/10)
- Code Hygiene (7/8)
- Patterns of Enterprise Applications (7/10)
- Design (5/5)
- Frontend (8/10)
- Backend (9/9)
- Quality Assurance and Testing (0/2)
- Security and Authorization (4/5)
- Features (3/15)
- Ambitious Features (0/16)
**Total 56/100**
---

## Additional overall comments for the entire review may be added below:

### What This Project Does Well

This project demonstrates a genuine understanding of Rails architecture. The data model is well-designed with proper associations, foreign keys, and indexes. Pundit authorization is correctly applied across policies and controllers. The use of Stimulus and Turbo Frames is not superficial — the game_card_controller handles flip, rotate, and move interactions in a clean, idiomatic way. Semantic HTML and ARIA attributes show awareness of accessibility that is uncommon at the apprentice level. Service objects (`DeckService`, `StandardDeckTemplate`) show that the trainee understands separation of concerns beyond basic Rails scaffolding.

### What Must Be Fixed Before This Is Production-Ready

1. **`skip_forgery_protection` must be removed.** This is the most serious issue in the codebase. Disabling CSRF protection globally on a session-based web app exposes every user to cross-site request forgery attacks. This is a fundamental security control that Rails provides by default.

2. **Zero test coverage.** The RSpec infrastructure, FactoryBot, Shoulda Matchers, Capybara, and Selenium are all installed and configured. None of them are used. A project with no tests cannot be safely modified, refactored, or maintained. This is a professional readiness gap.

3. **CI/CD is disabled.** The workflow file exists but every meaningful job is commented out. Automated quality checks should run on every PR.

4. **No alt tags on images.** This is an accessibility failure, not a preference. Images throughout the application have no `alt` text.

### Overall Apprenticeship Readiness Assessment

The trainee demonstrates strong technical fundamentals: Rails conventions are followed, the domain model is thoughtful, and the Hotwire implementation is well above average. These are genuine strengths. However, the project has some gaps due to the CSRF vulnerability, absence of any test coverage, and disabled CI.
