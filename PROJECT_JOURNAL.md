## Project Journal

### 01 - Create the Project
- Command used to create the project:
  ```
  rails new pocket-guardian --database=postgresql
  ```

### 02 - Add GitHub Actions
- In the root directory, create the folder `.github`, then inside create the folder `workflows` and paste the following:

```yml
  name: Linters

on: pull_request

env:
  FORCE_COLOR: 1

jobs:
  rubocop:
    name: Rubocop
    runs-on: ubuntu-22.04
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-ruby@v1
        with:
          ruby-version: 3.1.x
      - name: Setup Rubocop
        run: |
          gem install --no-document rubocop -v '>= 1.0, < 2.0' # https://docs.rubocop.org/en/stable/installation/
          [ -f .rubocop.yml ] || wget https://raw.githubusercontent.com/microverseinc/linters-config/master/ror/.rubocop.yml
      - name: Rubocop Report
        run: rubocop --color
  stylelint:
    name: Stylelint
    runs-on: ubuntu-22.04
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: "18.x"
      - name: Setup Stylelint
        run: |
          npm install --save-dev stylelint@13.x stylelint-scss@3.x stylelint-config-standard@21.x stylelint-csstree-validator@1.x
          [ -f .stylelintrc.json ] || wget https://raw.githubusercontent.com/microverseinc/linters-config/master/ror/.stylelintrc.json
      - name: Stylelint Report
        run: npx stylelint "**/*.{css,scss}"
  nodechecker:
    name: node_modules checker
    runs-on: ubuntu-22.04
    steps:
      - uses: actions/checkout@v3
      - name: Check node_modules existence
        run: |
          if [ -d "node_modules/" ]; then echo -e "\e[1;31mThe node_modules/ folder was pushed to the repo. Please remove it from the GitHub repository and try again."; echo -e "\e[1;32mYou can set up a .gitignore file with this folder included on it to prevent this from happening in the future." && exit 1; fi
```

### 03 - Set Up Linters

#### Rubocop
**Note**: The npm package manager will create a `node_modules` directory to install all of your dependencies. You shouldn't commit that directory. To avoid that, you can create a `.gitignore` file and add `node_modules/` to it.

**.gitignore**
```
node_modules/
```

**Rubocop**
- Add this line to the Gemfile:
  ```ruby
  gem 'rubocop', '>= 1.0', '< 2.0'
  ```
- Run `bundle install`.
- Copy `.rubocop.yml` to the root directory of your project.
- Paste this code inside `rubocop.yml`
  
```yml
  AllCops:
  NewCops: enable
  Exclude:
    - "db/**/*"
    - "bin/*" 
    - "config/**/*"
    - "Guardfile"
    - "Rakefile"
    - "node_modules/**/*"

  DisplayCopNames: true

Layout/LineLength:
  Max: 120
Metrics/MethodLength:
  Include:
    - "app/controllers/*"
    - "app/models/*"
  Max: 20
Metrics/AbcSize:
  Include:
    - "app/controllers/*"
    - "app/models/*"
  Max: 50
Metrics/ClassLength:
  Max: 150
Metrics/BlockLength:
  AllowedMethods: ['describe']
  Max: 30

Style/Documentation:
  Enabled: false
Style/ClassAndModuleChildren:
  Enabled: false
Style/EachForSimpleLoop:
  Enabled: false
Style/AndOr:
  Enabled: false
Style/DefWithParentheses:
  Enabled: false
Style/FrozenStringLiteralComment:
  EnforcedStyle: never

Layout/HashAlignment:
  EnforcedColonStyle: key
Layout/ExtraSpacing:
  AllowForAlignment: false
Layout/MultilineMethodCallIndentation:
  Enabled: true
  EnforcedStyle: indented
Lint/RaiseException:
  Enabled: false
Lint/StructNewOverride:
  Enabled: false
Style/HashEachMethods:
  Enabled: false
Style/HashTransformKeys:
  Enabled: false
Style/HashTransformValues:
  Enabled: false
```

- Run `rubocop` to check for linter errors and fix them.

#### Stylelint
- Install Stylelint and its dependencies:
  ```shell
  npm install --save-dev stylelint@13.x stylelint-scss@3.x stylelint-config-standard@21.x stylelint-csstree-validator@1.x
  ```
- Copy `.stylelintrc.json` to the root directory of your project.
- Paste the following inside `.stylelintrc.json`:

```json
{
  "extends": ["stylelint-config-standard"],
  "plugins": ["stylelint-scss", "stylelint-csstree-validator"],
  "rules": {
    "at-rule-no-unknown": [
      true,
      {
        "ignoreAtRules": [
          "tailwind",
          "apply",
          "variants",
          "responsive",
          "screen"
        ]
      }
    ],
    "scss/at-rule-no-unknown": [
      true,
      {
        "ignoreAtRules": [
          "tailwind",
          "apply",
          "variants",
          "responsive",
          "screen"
        ]
      }
    ],
    "csstree/validator": true
  },
  "ignoreFiles": ["build/**", "dist/**", "**/reset*.css", "**/bootstrap*.css"]
}
```

**Important**: Do not make changes in config files as they represent style guidelines shared with your team, which includes all Microverse students. If you think a change is necessary, open a Pull Request in the repository and inform your code reviewer.

- Run `npx stylelint "**/*.{css,scss}"` at the root of your project directory to check for linter errors and fix them.

### 04 - Model Creation
Proceed to create the models according to the Entity Relationship Diagram (ERD).
![Entity Relationship Diagram](erd.png)

#### User Model Creation
Command to generate the User model:
```
rails g model User name:string
```
In the User model, it is specified that a user may have many groups. The `dependent: :destroy` option ensures data integrity by removing orphan groups when the user associated with those groups is deleted. Similarly, it is defined that a user may have many movements, with the foreign key set as `author_id`, and uses `dependent: :destroy` to prevent orphaned data.
```ruby
class User < ApplicationRecord
  has_many :groups, dependent: :destroy
  has_many :movements, foreign_key: 'author_id', dependent: :destroy
end
```
The migration for the User model only includes the addition of a name attribute as a string:
```ruby
class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
```

#### Group Model Creation
Command to generate the Group model:
```
rails g model Group name:string icon:string user:references
```
In the Group model, it is indicated that a group belongs to a user and may have many movements. The `dependent: :destroy` option is used here as well to assure data integrity.
```ruby
class Group < ApplicationRecord
  belongs_to :user
  has_many :movements, dependent: :destroy
end
```
The migration for the Group model specifies the name and icon as strings, and includes a foreign key to the user table, which cannot be null:
```ruby
class CreateGroups < ActiveRecord::Migration[7.1]
  def change
    create_table :groups do |t|
      t.string :name
      t.string :icon
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
```

#### Movement Model Creation
Command to generate the Movement model:
```
rails g model Movement name:string amount:decimal author:references group:references
```
The Movement model specifies that a movement may belong to an author of the class User, with the foreign key set as `author_id`. It also establishes that a movement belongs to a group.
```ruby
class Movement < ApplicationRecord
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
  belongs_to :group
end
```
In the migration for the Movement model, it is ensured that the foreign key for the author references the users table, maintaining alignment with the ERD:
```ruby
class CreateMovements < ActiveRecord::Migration[7.1]
  def change
    create_table :movements do |t|
      t.string :name
      t.decimal :amount, precision: 10, scale: 2
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.references :group, null: false, foreign_key: true

      t.timestamps
    end
  end
end
```
### 04 - Model validations

#### User model validations
I added validation for the name to make sure that it is present, that its length is between 3 and 65 characters:

```ruby
class User < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3, maximum: 65 }

  has_many :groups, dependent: :destroy
  has_many :movements, foreign_key: 'author_id', dependent: :destroy
end

```
#### Group model validations
I added validation for the name to make sure that it is present, that its length is between 3 and 65 characters:

```ruby
class Group < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3, maximum: 65 }
  validates :icon, presence: true
  belongs_to :user
  has_many :movements, dependent: :destroy
end
```

#### Group movements validations
I added validation for the name to make sure that it is present, that its length is between 3 and 65 characters. I validated yhe amount to make sure it is present, that it is a number, that it is greater than zero and it has a maximum length of ten. Also, I validated that user_id and group_id must be present:

```ruby
class Movement < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3, maximum: 65 }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :group_id, presence: true

  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
  belongs_to :group
end

```

### 05 - Authentication with Devise

First, I added Devise to my Gemfile and installed it:

```bash
bundle add devise
rails generate devise:install
```

**Correct Configuration Steps I Followed:**

Correctly configure Devise:

1. **Default URL Options**: 
   I ensured default URL options were defined in my environments files. Here's what I added for the development environment in `config/environments/development.rb`:

   ```ruby
   config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
   ```

   For production, I knew `:host` should be set to my application's actual host.

   *This step was required for all applications.*

2. **Root URL Definition**: 
   I defined `root_url` in `config/routes.rb` as follows:

   ```ruby
   root to: "home#index"
   ```

   *This was not required for API-only Applications.*

In my case I used root to: 'splash_page#index' because this was aligned with my project logic.

In my application setup, I configured it like this:

```ruby
Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  authenticated :user do
    root 'home#index', as: :authenticated_root
  end
  root "splash_page#index"
end
```

This configuration was done to correctly display the splash page before authentication, effectively separating the concerns of authentication flow and content access.

Then, I created the controller for the splash page:

```ruby
class SplashPageController < ApplicationController
  def index; end
end
```

Next, I modified the application controller to redirect the user after sign-in or sign-up:

```ruby
class ApplicationController < ActionController::Base
  protected

  def after_sign_in_path_for(_resource)
    authenticated_root_path
  end

  def after_sign_up_path_for(_resource)
    authenticated_root_path
  end
end
```

I then created the view for the splash page in `/app/views/splash_page/index.html.erb`:

```erb
<div>
  <h1>The Pocket Guardian</h1>
  <%= button_to "LOGIN", new_user_session_path %>
  <%= button_to "SIGN UP", new_user_registration_path %>
</div>
```

Next, I reset styles in the global `app/assets/application.css` file to make styling easier:

```css
*,
*::before,
*::after {
  padding: 0;
  margin: 0;
  box-sizing: border-box;
}
```

### 3. Adding Flash Messages for Devise

I integrated flash messages to display notifications for various actions, aligning with the correct Devise configuration:

```erb
<p class="notice"><%= notice %></p>
<p class="alert"><%= alert %></p>
```

Following this setup, I executed the command to scaffold the User model with Devise:

```bash
rails generate devise User
```

This command added the necessary Devise modules to the User model and generated the migration `add_devise_to_users`.

Before running the migration, I uncommented the following lines in the migration file to add Devise to Users:

```ruby
t.string   :confirmation_token
t.datetime :confirmed_at
t.datetime :confirmation_sent_at
t.string   :unconfirmed_email

add_index :users, :email,                unique: true
add_index :users, :reset_password_token, unique: true
add_index :users, :confirmation_token,   unique: true
```

Next, I executed the migration with:

```bash
rails db:migrate
```

And then I generated the Devise views:

```bash
rails generate devise:views
```

Finally, I added buttons to navigate to the corresponding sign-in and sign-up pages in `/views/splash_page/index.html.erb`:

```erb
<div>
  <h1>The Pocket Guardian</h1>
  <%= button_to "LOGIN", new_user_session_path, method: :get %>
  <%= button_to "SIGN UP", new_user_registration_path, method: :get %>
</div>
```

I enhanced security and user management in the application controller by adding protection against CSRF attacks, enforcing user authentication, and allowing specific permitted parameters for user registration and account updates:

```ruby
class ApplicationController < ActionController::Base
  # Protects from Cross-Site Request Forgery (CSRF) attacks
  protect_from_forgery with: :exception, prepend: true
  
  # Ensures users are authenticated before accessing any action
  before_action :authenticate_user!
  
  # Configures additional parameters for user sign-up and account updates
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # Allows custom fields (e.g., name) in addition to the default email and password
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  # Redirects users to a specified path after sign-in
  def after_sign_in_path_for(_resource)
    authenticated_root_path
  end

  # Redirects users to a specified path after sign-up
  def after_sign_up_path_for(_resource)
    authenticated_root_path
  end
end
```

This implementation not only secures the application from common web vulnerabilities but also ensures a seamless user experience by redirecting users to their intended destination post-authentication or registration.

Next, I bypassed authentication for the splash page to allow unauthenticated users to view it:

```ruby
class SplashPageController < ApplicationController
  # Skips user authentication only for the splash page
  skip_before_action :authenticate_user!
  def index; end
end
```

I then enhanced the sign-up page by adding a field for the user's name with autofocus, alongside the standard email field, for a more user-friendly registration process:

```erb
<div class="field">
  <%= f.label :name %><br />
  <%= f.text_field :name, autofocus: true, autocomplete: "name" %>
</div>

<div class="field">
  <%= f.label :email %><br />
  <%= f.email_field :email, autocomplete: "email" %>
</div>
```

Following that, I configured email confirmation functionality for both the development and test environments to streamline the user verification process without needing an external mail service during testing:

1. I added the `letter_opener` gem to my Gemfile and executed `bundle install` to facilitate email previews directly in the browser.

2. Then, I set up the action mailer settings in both `config/environments/development.rb` and `config/environments/test.rb` by adding:

```ruby
config.action_mailer.delivery_method = :letter_opener
config.action_mailer.perform_deliveries = true
config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
```

This configuration allows for immediate feedback on email functionalities without leaving the development environment, enhancing the testing and development workflow.

I integrated CanCanCan for role-based authorization by first adding it to the Gemfile:

```ruby
gem 'cancancan'
```

Subsequently, I executed `bundle install` to ensure the gem was properly installed in my project environment.

Following the installation, I generated the `Ability` model to define user permissions using the command:

```bash
rails g cancan:ability
```

Within the `Ability` class, I specified authorization rules allowing users to both read and manage their movements and groups, effectively implementing role-based access control:

```ruby
class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    return unless user.persisted?

    can :manage, Movement, user_id: user.id
    can :manage, Group, user_id: user.id
  end
end
```

To handle exceptions and provide feedback for unauthorized access attempts, I added error handling in the `ApplicationController`. This ensures that users receive appropriate notifications and are redirected accordingly when attempting to access restricted resources:

```ruby
rescue_from CanCan::AccessDenied do |exception|
  respond_to do |format|
    format.json { head :forbidden, content_type: 'application/json' }
    format.html { redirect_to main_app.root_url, alert: exception.message }
    format.js { head :forbidden, content_type: 'application/javascript' }
  end
end
```

This approach not only secures the application by enforcing authorization checks but also enhances the user experience by providing clear feedback in case of access restrictions.
