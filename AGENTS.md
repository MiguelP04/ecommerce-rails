# AGENTS.md - Ecommerce Rails

## Project Overview

This is a Rails 7.2 API-only ecommerce application with PostgreSQL, using RSpec for testing and RuboCop for linting.

**Tech Stack:** Ruby 3.3.0 | Rails 7.2 | PostgreSQL | RSpec | RuboCop

---

## Build/Lint/Test Commands

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific spec file
bundle exec rspec spec/models/post_spec.rb

# Run specific test by line number
bundle exec rspec spec/models/post_spec.rb:5

# Run tests with documentation format
bundle exec rspec --format documentation

# Run tests and show slowest examples
bundle exec rspec --profile

# Run tests in random order (recommended for CI)
bundle exec rspec --order random
```

### Linting

```bash
# Run RuboCop linter
bundle exec rubocop

# Auto-fix linting issues (safe fixes only)
bundle exec rubocop -a

# Auto-fix and commit (requires interactive input)
bundle exec rubocop -A

# Run specific cop or folder
bundle exec rubocop app/models/
```

### Database

```bash
# Run migrations
rails db:migrate

# Reset database and load schema
rails db:reset

# Prepare test database
rails db:test:prepare

# Drop, create, migrate, and seed
rails db:setup
```

### Security Scanning

```bash
# Run Brakeman security scanner
bundle exec brakeman
```

### Development Server

```bash
# Start Rails server
rails server

# Start with specific port
rails server -p 3001
```

---

## Code Style Guidelines

### General Conventions

- Uses **RuboCop Rails Omakase** (Rails default style)
- **4 spaces** for indentation (no tabs)
- Maximum line length: 120 characters (RuboCop default)
- Use **snake_case** for method names, variables, and file names
- Use **PascalCase** for class and module names
- Use **SCREAMING_SNAKE_CASE** for constants
- **Single quotes** for strings without interpolation; **double quotes** otherwise
- Always use explicit `return` statements in methods (not idiomatic Ruby implicit returns in complex methods)

### Ruby/Rails Patterns

```ruby
# Good: Use symbol keys for enum definitions
enum :status, { draft: 0, published: 1 }

# Good: Private methods at end of class with proper indentation
class User < ApplicationRecord
  before_validation :generate_jti, on: :create

  validates :email, presence: true, uniqueness: true

  private

  def generate_jti
    self.jti ||= SecureRandom.uuid
  end
end

# Good: Prefer delegate and concerns for shared behavior
# Good: Use scope for commonly used queries
scope :published, -> { where(status: :published) }

# Good: Use before_validation (not after_initialize) for auto-generating values
# Good: Use dependent: :destroy for has_many associations
```

### Model Conventions

```ruby
class Product < ApplicationRecord
  belongs_to :category

  has_many :product_variants, dependent: :destroy
  has_many_attached :images
  has_one_attached :cover_image

  acts_as_taggable_on :tags

  before_validation :generate_slug, on: :create

  validates :title, :slug, presence: true
  validates :slug, uniqueness: true

  private

  def generate_slug
    self.slug ||= title.parameterize if title.present?
  end
end
```

### Controller Conventions

- This is an **API-only** application (`config.api_only = true`)
- Inherit from `ApplicationController` (API mode, no sessions/cookies)
- Use JSON responses with `render json:`

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Models | PascalCase singular | `Product`, `OrderItem` |
| Tables | snake_case plural | `order_items` |
| Controllers | snake_case plural + `_controller` | `posts_controller.rb` |
| Views | snake_case/controller_action | `posts/index.json.jbuilder` |
| Migrations | `create_` or `action_` | `create_products.rb` |
| Specs | `*_spec.rb` matching model | `product_spec.rb` |
| Factories | snake_case singular | `product.rb` |

### Test Conventions

```ruby
require 'rails_helper'

RSpec.describe Product, type: :model do
  describe "validations" do
    it "requires title to be present" do
      product = build(:product, title: nil)
      expect(product).not_to be_valid
    end
  end

  describe "associations" do
    it "has many variants" do
      expect(described_class.new).to have_many(:product_variants)
    end
  end
end
```

### Test Best Practices

- Use **FactoryBot** for test data: `create(:product)`, `build(:user)`
- Use `describe`/`context` for grouping, `it` for individual tests
- Use meaningful descriptions: `"broadcasts when status changes to published"`
- Use `have_broadcasted_to` matcher for ActionCable tests
- Use `be_valid` matcher for validation tests
- Use `create_list(:factory, 3)` for multiple records
- Keep tests isolated; don't depend on test execution order

### Error Handling

```ruby
# Use standard Rails patterns for error handling
# In controllers, use rescue_from for handling exceptions
# Use flash messages only in non-API contexts
# Return appropriate HTTP status codes in API responses
```

### File Organization

```
app/
├── controllers/
│   └── application_controller.rb
├── models/
│   ├── application_record.rb
│   └── *.rb
├── services/
│   └── *.rb
└── views/
    └── (JSON builders if used)

spec/
├── models/
│   └── *_spec.rb
├── factories/
│   └── *.rb
├── rails_helper.rb
└── spec_helper.rb
```

### Gems in Use

| Gem | Purpose |
|-----|---------|
| `pg` | PostgreSQL adapter |
| `puma` | Web server |
| `ancestry` | Tree structure for categories |
| `acts-as-taggable-on` | Product tagging |
| `image_processing` | Image variants |
| `factory_bot_rails` | Test fixtures |
| `rspec-rails` | Testing framework |
| `brakeman` | Security scanning |
| `rubocop-rails-omakase` | Code style |
| `faker` | Generate fake test data |
| `bullet` | N+1 query detection |
| `bootsnap` | Faster boot times |

---

## Important Notes

- **API-only mode**: No views, sessions, or cookies. Use `render json:` for responses.
- **PostgreSQL only**: No SQLite support.
- **FactoryBot is configured** in `rails_helper.rb` with `config.include FactoryBot::Syntax::Methods`.
- **Transactional fixtures** are enabled by default for tests.
- **Autoload lib/**: Classes in `lib/` are autoloaded (except `assets`, `tasks`).
- **Always run migrations** before running tests: `rails db:migrate db:test:prepare`.
- **Use `bundle exec`** for all rake tasks and gem commands.
