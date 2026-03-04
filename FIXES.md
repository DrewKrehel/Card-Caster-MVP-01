# Prioritized Improvement Plan — Card Caster

Generated: 2026-03-04
Reviewer: Claude Code (DPI Tech Apprenticeship)

---

## P0 — Critical (Security / Architecture / Broken Patterns)

These must be resolved before any production deployment or peer review sign-off.

---

### P0-1: Remove `skip_forgery_protection` (SECURITY — CRITICAL)

**File:** `app/controllers/application_controller.rb`, line 4

**Problem:**
`skip_forgery_protection` disables Rails' built-in CSRF protection globally across the entire application. Every state-changing request (POST, PATCH, DELETE) is vulnerable to cross-site request forgery. An attacker on any website can forge requests on behalf of authenticated users — joining sessions, modifying cards, deleting projects.

This is not an acceptable trade-off for any web application with user sessions and state.

**Suggested solution:**
Delete line 4 entirely. Rails' `protect_from_forgery with: :exception` is the secure default and applies automatically.

```ruby
# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  include Pundit::Authorization
  # skip_forgery_protection  ← DELETE THIS LINE

  before_action :authenticate_user!
  after_action :verify_authorized, unless: :devise_controller?
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end
end
```

**Why it was added (likely reason):** Turbo Drive/Turbo Streams requires CSRF tokens to be present in `meta` tags and submitted with requests. Rails 7+ and Hotwire handle this automatically via `csrf_meta_tags` in the layout — which is already present in `application.html.erb`. Removing `skip_forgery_protection` will not break Turbo functionality.

**Impact:** Restores fundamental CSRF defense. No functionality should break.

---

### P0-2: Enable CI/CD Pipeline

**File:** `.github/workflows/ci.yml`

**Problem:**
The CI workflow file exists but every meaningful job is commented out. Only a `"Hello World"` placeholder runs. No security scanning, linting, or test execution occurs on any push or pull request. Code quality regressions go undetected.

**Suggested solution:**
Uncomment and restore the security scan and lint jobs. Add a test job.

```yaml
# .github/workflows/ci.yml

name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  scan_ruby:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: .ruby-version
          bundler-cache: true
      - name: Scan for Rails security vulnerabilities
        run: bin/brakeman --no-pager

  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: .ruby-version
          bundler-cache: true
      - name: Run Rubocop
        run: bin/rubocop -f github

  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
    env:
      DATABASE_URL: postgres://postgres:postgres@localhost:5432/card_caster_test
      RAILS_ENV: test
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: .ruby-version
          bundler-cache: true
      - name: Prepare test database
        run: bundle exec rails db:test:prepare
      - name: Run tests
        run: bundle exec rspec
```

**Impact:** Automated security scanning (Brakeman) and linting (Rubocop) will catch issues on every PR. Once tests are written (P0-3), they will also run automatically.

---

### P0-3: Implement Automated Test Suite

**Files:** `spec/` (create new test files)

**Problem:**
RSpec, FactoryBot, Shoulda Matchers, Capybara, and Selenium are all installed. The only test file is `spec/features/sample_spec.rb` with a non-functional placeholder. Zero real coverage exists.

**Suggested solution:**
Start with model specs (fastest to write, highest value) and policy specs. Then add request specs for controller actions.

**Step 1 — Create FactoryBot factories:**

```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    sequence(:email)    { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
  end
end

# spec/factories/projects.rb
FactoryBot.define do
  factory :project do
    sequence(:name) { |n| "Project #{n}" }
    association :creator, factory: :user
    public { true }
  end
end

# spec/factories/game_sessions.rb
FactoryBot.define do
  factory :game_session do
    sequence(:name) { |n| "Session #{n}" }
    association :project
    association :owner, factory: :user
  end
end
```

**Step 2 — Model specs:**

```ruby
# spec/models/game_session_spec.rb
require 'rails_helper'

RSpec.describe GameSession, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:owner).class_name('User') }
    it { is_expected.to have_many(:session_users).dependent(:destroy) }
    it { is_expected.to have_many(:playing_cards).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:project) }
  end

  describe 'callbacks' do
    it 'populates a standard deck after creation' do
      session = create(:game_session)
      expect(session.playing_cards.count).to eq(52)
    end
  end
end
```

```ruby
# spec/models/playing_card_spec.rb
require 'rails_helper'

RSpec.describe PlayingCard, type: :model do
  describe 'validations' do
    it { is_expected.to validate_inclusion_of(:suit).in_array(PlayingCard::SUITS) }
    it { is_expected.to validate_inclusion_of(:rank).in_array(PlayingCard::RANKS) }
  end

  describe 'scopes' do
    let(:session) { create(:game_session) }

    it '.face_up returns only face-up cards' do
      face_up = session.playing_cards.face_up
      expect(face_up.all? { |c| c.face_up }).to be true
    end
  end
end
```

**Step 3 — Policy specs:**

```ruby
# spec/policies/game_session_policy_spec.rb
require 'rails_helper'

RSpec.describe GameSessionPolicy, type: :policy do
  let(:owner)   { create(:user) }
  let(:player)  { create(:user) }
  let(:other)   { create(:user) }
  let(:project) { create(:project, creator: owner) }
  let(:session) { create(:game_session, owner: owner, project: project) }

  subject { described_class.new(user, session) }

  context 'as owner' do
    let(:user) { owner }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:edit) }
  end

  context 'as non-member' do
    let(:user) { other }
    it { is_expected.not_to permit_action(:destroy) }
    it { is_expected.not_to permit_action(:edit) }
  end
end
```

**Impact:** Establishes a test foundation. Prevents regressions. Enables CI test gating on PRs.

---

### P0-4: Configure Content Security Policy

**File:** `config/initializers/content_security_policy.rb`

**Problem:**
The CSP initializer is commented out. Only `frame_ancestors` is active. Without a CSP, the browser has no restrictions on what scripts or styles can be loaded or executed, leaving the application open to XSS attacks.

**Suggested solution:**

```ruby
# config/initializers/content_security_policy.rb
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data, "blob:"
    policy.object_src  :none
    policy.script_src  :self, :https
    policy.style_src   :self, :https, :unsafe_inline  # required for Bootstrap inline styles
    policy.connect_src :self, :https, "wss:"          # required for ActionCable/Turbo
    policy.frame_ancestors :self, "https://envoy.fyi"
  end

  # Nonce-based script/style allowance (required for inline Turbo scripts)
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w[script-src]
end
```

**Note:** Test thoroughly after enabling — Bootstrap and Turbo Drive may require `unsafe-inline` or nonce adjustments. Use `report_only` mode first to identify violations before enforcing.

---

## P1 — Important (Maintainability / Convention / Cleanliness)

---

### P1-1: Fix Template Placeholder in Page Title

**File:** `app/views/layouts/application.html.erb`, line 4

**Problem:**
`<title><%= content_for(:title) || "Rails 8 Template" %></title>` — "Rails 8 Template" is a scaffolding placeholder. It appears in browser tabs and is indexed by search engines.

**Suggested solution:**

```erb
<title><%= content_for(:title) || "Card Caster" %></title>
```

**Impact:** Immediate professionalism improvement. Low effort.

---

### P1-2: Add Alt Tags to All Images

**Files:** All view files containing `<img` tags

**Problem:**
Zero `alt` attributes exist on any image in the application. Card images, avatars, and project thumbnails are invisible to screen readers. This fails WCAG 2.1 Success Criterion 1.1.1 (Non-text Content).

**Suggested solution:**

For playing cards:
```erb
<%# app/views/playing_cards/_playing_card.html.erb %>
<img src="<%= playing_card.display_image %>"
     alt="<%= playing_card.card_name %>"
     class="card-image">
```

For project thumbnails:
```erb
<%# app/views/projects/_project.html.erb %>
<img src="<%= project.thumbnail_url %>"
     alt="<%= project.name %> thumbnail"
     class="project-thumbnail">
```

For decorative images (use empty string — do not omit the attribute):
```erb
<img src="<%= asset_path('decorative-pattern.png') %>" alt="" role="presentation">
```

**Note:** Never omit the `alt` attribute entirely. Use `alt=""` for decorative images so screen readers skip them.

---

### P1-3: Remove or Consolidate Dead Code in SessionUsersController

**File:** `app/controllers/session_users_controller.rb`

**Problem:**
The controller defines full CRUD actions (`index`, `show`, `new`, `edit`, `create`, `update`, `destroy`) but none of these routes are used. `SessionUser` records are created inside `GameSessionsController#join_as_player` (line 129–132) and destroyed in `GameSessionsController#leave` (line 82). The controller and its views are dead code that adds maintenance surface area with no benefit.

**Suggested solution:**

Option A (preferred): Delete the controller and its views entirely.
```bash
rm app/controllers/session_users_controller.rb
rm -rf app/views/session_users/
```

Remove the nested resource from routes:
```ruby
# config/routes.rb — remove or change:
# resources :session_users  # if present
```

Option B: Keep only what is actually routed, delete everything else.

**Impact:** Reduces confusion for future contributors. Eliminates dead code maintenance.

---

### P1-4: Enumerate Required Environment Variables in README

**File:** `README.md`

**Problem:**
The README mentions `bin/setup` but does not list required environment variables. A new developer cloning the repository will not know what `.env` values to set.

**Suggested solution:**
Add a section to README:

```markdown
## Environment Variables

Copy `.env.example` to `.env` and fill in the required values:

| Variable | Description | Required |
|---|---|---|
| `DATABASE_URL` | PostgreSQL connection string | Yes |
| `SECRET_KEY_BASE` | Rails secret key (generate with `rails secret`) | Yes (production) |
| `ACTION_MAILER_HOST` | Domain for mailer links | Yes (production) |
| `CLOUDINARY_URL` | Cloudinary account URL | If using file upload |

> Run `cp .env.example .env` to get started.
```

Create a `.env.example` file with placeholder values (no real secrets):
```
DATABASE_URL=postgres://localhost/card_caster_development
SECRET_KEY_BASE=changeme
ACTION_MAILER_HOST=localhost:3000
```

---

### P1-5: Use Pagy for Pagination (gem already installed)

**Files:** `app/controllers/projects_controller.rb`, `app/views/projects/index.html.erb`

**Problem:**
`pagy` and `kaminari` are both in the Gemfile but neither is used anywhere. Large project or user lists are returned without pagination.

**Suggested solution (using Pagy):**

Remove the unused `kaminari` gem — having both is redundant.

```ruby
# app/controllers/application_controller.rb
include Pagy::Backend

# app/controllers/projects_controller.rb
def index
  @pagy, @projects = pagy(
    Project.includes(:creator).order(created_at: :desc),
    items: 12
  )
end
```

```erb
<%# app/helpers/application_helper.rb — add Pagy frontend %>
<%# app/views/projects/index.html.erb %>
<%= render @projects %>
<%== pagy_nav(@pagy) if @pagy.pages > 1 %>
```

---

### P1-6: Configure Bullet for N+1 Detection

**File:** `config/environments/development.rb`

**Problem:**
`bullet` gem is in the `Gemfile` but has no configuration in `development.rb`. N+1 queries are not being detected in development, even though the gem is installed.

**Suggested solution:**

```ruby
# config/environments/development.rb
config.after_initialize do
  Bullet.enable        = true
  Bullet.alert         = true
  Bullet.bullet_logger = true
  Bullet.console       = true
  Bullet.rails_logger  = true
  Bullet.add_footer    = true
end
```

---

### P1-7: Use Environment Variable for Production Host

**File:** `config/environments/production.rb`, line 60

**Problem:**
`config.action_mailer.default_url_options = { host: "example.com" }` is hardcoded. This is a template placeholder that requires a code change for each deployment environment.

**Suggested solution:**

```ruby
config.action_mailer.default_url_options = {
  host: ENV.fetch("ACTION_MAILER_HOST", "card-caster.example.com")
}
```

---

### P1-8: Remove Unused Gems from Gemfile

**File:** `Gemfile`

**Problem:**
Several gems are installed but not used in any code:
- `ai-chat` (line 61) — no AI integration found
- `kaminari` (line 71) — redundant with `pagy`
- `carrierwave` (line 66) — no uploaders in `app/uploaders/`
- `cloudinary` (line 67) — no uploader configuration
- `ransack` (line 74) — installed but not used

Unused gems increase bundle size, slow boot time, and add CVE exposure surface.

**Suggested solution:**
Remove gems that have no corresponding implementation:
```ruby
# Remove these lines from Gemfile if features are not being built:
# gem "ai-chat"
# gem "kaminari"        # use pagy only
# gem "carrierwave"
# gem "cloudinary"
# gem "ransack"
```

If these features are planned, document them as TODO items in README rather than installing the gems prematurely.

---

### P1-9: Add Troubleshooting Section to README

**File:** `README.md`

**Problem:**
No troubleshooting or FAQ section. New contributors will encounter common setup issues with no documented remediation.

**Suggested solution:**
Add a section:

```markdown
## Troubleshooting

**`PG::ConnectionBad` on setup**
Ensure PostgreSQL is running: `brew services start postgresql@15`

**`ActiveRecord::NoDatabaseError`**
Run `rails db:create db:migrate` before starting the server.

**Devise mailer errors in development**
Set `config.action_mailer.delivery_method = :letter_opener` in `config/environments/development.rb` and add `gem "letter_opener", group: :development`.

**Asset precompilation fails**
Run `bundle exec rails assets:precompile` and check for JavaScript errors in `app/javascript/`.
```

---

## P2 — Polish / UX / Enhancements

---

### P2-1: Implement Client-Side Form Validation

**Files:** `app/views/projects/_form.html.erb`, `app/views/game_sessions/_form.html.erb`

**Problem:**
Forms validate server-side only. Users receive no immediate feedback for empty or invalid fields.

**Suggested solution:**
Create a Stimulus validation controller:

```javascript
// app/javascript/controllers/form_validation_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["field", "submit"]

  validate({ target }) {
    if (!target.checkValidity()) {
      target.classList.add("is-invalid")
      target.classList.remove("is-valid")
    } else {
      target.classList.remove("is-invalid")
      target.classList.add("is-valid")
    }
    this.toggleSubmit()
  }

  toggleSubmit() {
    const valid = this.fieldTargets.every(f => f.checkValidity())
    this.submitTarget.disabled = !valid
  }
}
```

Use in forms:
```erb
<%= form_with model: @project, data: { controller: "form-validation" } do |f| %>
  <%= f.text_field :name,
      required: true,
      minlength: 3,
      data: {
        "form-validation-target": "field",
        action: "blur->form-validation#validate"
      } %>
  <div class="invalid-feedback">Name must be at least 3 characters.</div>

  <%= f.submit "Save", data: { "form-validation-target": "submit" } %>
<% end %>
```

---

### P2-2: Implement Search with Ransack (gem already installed)

**Files:** `app/controllers/projects_controller.rb`, `app/views/projects/index.html.erb`

**Problem:**
Ransack is installed but not used. Users cannot search or filter projects.

**Suggested solution:**

```ruby
# app/controllers/projects_controller.rb
def index
  @q = Project.includes(:creator).public_projects.ransack(params[:q])
  @pagy, @projects = pagy(@q.result(distinct: true).order(created_at: :desc))
end
```

```erb
<%# app/views/projects/index.html.erb %>
<div class="mb-4">
  <%= search_form_for @q, url: projects_path do |f| %>
    <div class="input-group">
      <%= f.search_field :name_cont,
          placeholder: "Search by name",
          class: "form-control" %>
      <%= f.submit "Search", class: "btn btn-outline-secondary" %>
    </div>
  <% end %>
</div>
```

---

### P2-3: Add Loading/Disabled State to Turbo Form Buttons

**Files:** Various form views

**Problem:**
Users can double-click submit buttons during Turbo requests, potentially submitting duplicate actions.

**Suggested solution:**
Use Turbo's built-in `data-turbo-submits-with` attribute:

```erb
<%= f.submit "Join Game",
    class: "btn btn-primary",
    data: { turbo_submits_with: "Joining..." } %>
```

Or for button_to:
```erb
<%= button_to "Flip Card", flip_playing_card_path(card),
    method: :patch,
    form: { data: { turbo_frame: "card_#{card.id}" } },
    data: { turbo_submits_with: "Flipping..." } %>
```

---

### P2-4: Enable PWA Manifest

**Files:** `app/views/layouts/application.html.erb`, `config/routes.rb`

**Problem:**
PWA manifest link is commented out on line 16 of layout. Service worker and manifest infrastructure exist but are not active.

**Suggested solution:**

Uncomment the manifest link:
```erb
<%# app/views/layouts/application.html.erb line 16 %>
<link rel="manifest" href="<%= pwa_manifest_path(format: :json) %>">
```

Update `app/views/pwa/manifest.json.erb` with correct app metadata:
```json
{
  "name": "Card Caster",
  "short_name": "CardCaster",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#000000",
  "icons": [
    { "src": "/icon.png", "sizes": "512x512", "type": "image/png" }
  ]
}
```

---

### P2-5: Add Custom 404 and 500 Error Pages

**Files:** `public/404.html`, `public/500.html`

**Problem:**
Default Rails error pages are shown on errors. They are unstyled and do not match the application.

**Suggested solution:**
Replace `public/404.html` and `public/500.html` with styled pages matching the Card Caster design. These are static files and do not have access to the Rails layout, so include Bootstrap CDN directly:

```html
<!-- public/404.html -->
<!DOCTYPE html>
<html>
<head>
  <title>Page Not Found — Card Caster</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="d-flex align-items-center justify-content-center vh-100">
  <div class="text-center">
    <h1 class="display-1">404</h1>
    <p class="lead">This page doesn't exist.</p>
    <a href="/" class="btn btn-primary">Go Home</a>
  </div>
</body>
</html>
```

---

### P2-6: Add End-to-End Test Plan Document

**File:** `docs/TEST_PLAN.md` (new file) or section in README

**Problem:**
No documented manual test scenarios exist. QA requires a test plan for both development and review.

**Suggested solution:**
Create `docs/TEST_PLAN.md`:

```markdown
# Card Caster — End-to-End Test Plan

## Authentication
- [ ] New user can register with valid credentials
- [ ] Registration fails with duplicate email/username
- [ ] User can log in with correct credentials
- [ ] User cannot log in with incorrect password
- [ ] User can log out

## Projects
- [ ] Authenticated user can create a project
- [ ] Project requires a name (validation error shown)
- [ ] User can edit their own project
- [ ] User cannot edit another user's project
- [ ] User can delete their own project

## Game Sessions
- [ ] User can create a session from a project
- [ ] Another user can join a public session
- [ ] Session owner can toggle another player's role
- [ ] Player can leave a session
- [ ] Owner can delete a session

## Playing Cards
- [ ] Cards are dealt to the table on session creation
- [ ] Player can flip a card (face-up/face-down toggles)
- [ ] Player can rotate a card CW and CCW
- [ ] Player can move a card between zones
- [ ] Non-player cannot interact with cards

## Responsiveness
- [ ] All pages render correctly on mobile (375px)
- [ ] All pages render correctly on tablet (768px)
- [ ] All pages render correctly on desktop (1440px)
```

---

## Summary Table

| Priority | Issue | File | Effort |
|---|---|---|---|
| P0 | Remove `skip_forgery_protection` | `app/controllers/application_controller.rb:4` | 5 min |
| P0 | Enable CI/CD jobs | `.github/workflows/ci.yml` | 30 min |
| P0 | Write automated test suite | `spec/` | 2–3 days |
| P0 | Configure Content Security Policy | `config/initializers/content_security_policy.rb` | 1 hr |
| P1 | Fix "Rails 8 Template" page title | `app/views/layouts/application.html.erb:4` | 5 min |
| P1 | Add alt tags to all images | Multiple view files | 1 hr |
| P1 | Delete unused SessionUsersController | `app/controllers/session_users_controller.rb` | 30 min |
| P1 | Document environment variables | `README.md`, `.env.example` | 30 min |
| P1 | Enable Pagy pagination | `app/controllers/projects_controller.rb` | 1 hr |
| P1 | Configure Bullet for N+1 detection | `config/environments/development.rb` | 15 min |
| P1 | Fix hardcoded mailer host | `config/environments/production.rb:60` | 10 min |
| P1 | Remove unused gems | `Gemfile` | 30 min |
| P1 | Add troubleshooting to README | `README.md` | 1 hr |
| P2 | Client-side form validation | `app/javascript/controllers/` | 2 hr |
| P2 | Implement Ransack search | `app/controllers/projects_controller.rb` | 1 hr |
| P2 | Turbo submit disabled states | Multiple views | 1 hr |
| P2 | Enable PWA manifest | `app/views/layouts/application.html.erb` | 1 hr |
| P2 | Custom error pages | `public/404.html`, `public/500.html` | 1 hr |
| P2 | End-to-end test plan | `docs/TEST_PLAN.md` | 2 hr |
