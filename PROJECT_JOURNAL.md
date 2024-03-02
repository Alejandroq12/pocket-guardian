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

Now, it was time to generate the necessary controllers for my application. This step is crucial for defining the actions and views associated with each model:

```bash
rails generate controller Users show new edit update
```

```bash
rails generate controller Movements index show new create edit update destroy
```

```bash
rails generate controller Groups index show new create edit update destroy
```

With the controllers in place, I proceeded to add the routes to prepare the app for the forthcoming steps. This involved setting up nested resources and ensuring that the URL structure reflects the hierarchical relationship between users, groups, and movements:

```ruby
Rails.application.routes.draw do
  devise_for :users

  # Routes for nested resources, facilitating the association between users, groups, and movements
  resources :users, only: [] do
    resources :groups, only: [:new, :show, :create] do
      resources :movements, only: [:new, :show, :create]
    end
  end

  # Uncommented to further refine the routes for groups and movements, allowing for editing, updating, and destroying
  # resources :groups, only: [:edit, :update, :destroy]
  # resources :movements, only: [:edit, :update, :destroy]

  # Defines the root path for authenticated users, leading them directly to their groups
  authenticated :user do
    root 'groups#index', as: :authenticated_root
  end

  # The default root path directs unauthenticated users to the splash page
  root "splash_page#index"

  # A health check route useful for deployment and monitoring
  get "up" => "rails/health#show", as: :rails_health_check
end
```

This routing configuration not only clarifies the application's navigational structure but also aligns with RESTful principles, ensuring a clear and intuitive user experience. The commented-out routes are placeholders for future enhancements, indicating planned expansions to the app's functionality.

Next, I will add the destroy actions for Movements and Groups
```ruby
Rails.application.routes.draw do
  devise_for :users

  # get 'users/edit/:id', to: 'users#edit', as: :edit_user

  resources :users, only: [] do
    resources :groups, only: [:new, :show, :create, :destroy] do
      resources :movements, only: [:new, :show, :create, :destroy]
    end
  end

  # resources :groups, only: [:edit, :update, :destroy]
  # recources :movements, only: [:edit, :update, :destroy]

  authenticated :user do
    root 'groups#index', as: :authenticated_root
  end

  root "splash_page#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
```

Next, I added the images in `app/assets/images/group_icons` as SVG files. These are the icons that will be used in the group creation form.

I then updated the `Group` model to include validations for the presence of an icon and to ensure the icon selected is from the available choices. I also added a class method to retrieve the filenames of the icons, which will be used in the views with the `image_tag` helper to display them.


```ruby
class Group < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3, maximum: 65 }
  validates :icon, presence: true, inclusion: { in: proc { Group.icon_choices } }

  belongs_to :user
  has_many :movements, dependent: :destroy

  def self.icon_choices
    Dir.glob('app/assets/images/group_icons/*').map { |file| File.basename(file) }
  end
end
```

I updated the `GroupsController` to handle the creation of new groups associated with the current user:
```ruby
class GroupsController < ApplicationController
  def index
    @groups = Group.all
  end

  def show; end

  def new
    @group = current_user.groups.build
  end

  def create
    @group = current_user.groups.build(group_params)
    if @group.save
      redirect_to user_groups_path(current_user), notice: 'Group was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update; end

  def destroy; end

  private

  def group_params
    params.require(:group).permit(:name, :icon)
  end
end
```

In the new group form, I iterated over each available icon, associating each with a radio button and label. This allows users to select an icon visually:


```ruby
<%= form_with(model: [current_user, @group], local: true) do |form| %>
  <h1>Add a new group</h1>

  <div>
    <h2>Choose an icon</h2>
    <% Group.icon_choices.each do |icon| %>
      <%= form.radio_button :icon, icon%>
      <%= label :icon, icon, value: icon %>
      <%= image_tag("group_icons/#{icon}", alt: icon, class: "icon-preview") %>
    <% end %>
  </div>

  <div>
    <%= form.label :name, "Group name" %>
    <%= form.text_field :name %>
  </div>

  <%= form.submit "Create group" %>
<% end %>
```
I added CSS to ensure the icons are displayed at a manageable size within the form:

```css
.icon-preview {
  width: 40px;
}
```

I updated the groups index page to first check if there are any groups. If there are no groups, the text "There are no groups" is displayed, along with a link to add a new group. If there are groups, their details are shown, along with a button to delete each group. Clicking on a group redirects the user to that group's show view.

```ruby
<h1>The Pocket Guardian</h1>
<p>Groups</p>

<% if @groups.empty %>
  <p>There are no groups</p>
  <%= link_to "Add a group", new_user_group_path(current_user), class: "button" %>
<% else %>
  <% @groups.each do |group| %>
  <div>
    <%= link_to user_group_path(current_user, group) %>
      <%= image_tag("group_icons/#{group.name}", alt: group.name, class: "button") %>
      <p><%= group.created_at %></p>
      <p><%= group.name %></p>
      <p><%= "Change later for real total amount in dollars" %></p>
    <% end %>
    <%= button_to "Delete", user_group_path(current_user, group), method: :delete %>
  </div>
  
  <div>
  </div>
  <% end %>
<% end %>
```

I refined the group's show action in the controller to retrieve the specific group associated with the current user and to display its movements ordered from the most recent:

```ruby
  def show
    @group = current_user.groups.find(params[:id])
    @movements = @group.movements.order(created_at: :desc)
  end
```

In the groups index view, I added functionality to display the total sum of the transactions for each group:

```erb
  <p><%= group.movements.sum(:amount) %></p>
```
For the group show view, I enhanced the usability and presentation. A 'Go back' button was implemented to provide easy navigation back to the home page. The group's associated icon and name are prominently displayed. Additionally, if there are movements, the total sum of the transactions is shown. I also prepared an iteration structure for future development, where each movement will be displayed. Finally, a link was added for creating new movements, anticipating the next development phase:

```erb
<div>
  <%= link_to "Go back", authenticated_root_path %>
  <%= image_tag("group_icons/#{@group.icon}", alt: @group.icon, class: "icon-preview") %>
  <h1><%= @group.name %> movements </h1>
  <% if @movements.empty? %>
    <p>There are no movements, yet.</p>
  <% else %>
    <%= @movements.sum(:amount)%>
    <div>
      <%= @movements.each do |movement| %>
      <!-- Display each movement here -->
      <% end %>
    </div>
  <% end %>
  <%= link_to "Add a new movement", new_user_group_movement_path(current_user, @group) %>
</div>
```

I enhanced the Group new view by adding a "Go back" button for improved navigation:

```erb
  <%= link_to  "Go back", authenticated_root_path%>
```

In the Movements controller, I incorporated the new, create, and destroy actions. Additionally, I defined a private method to specify the permitted parameters for creating a Movement:


```ruby
class MovementsController < ApplicationController
  def index; end

  def show; end

  def new
    @group = current_user.groups.find(params[:group_id])
    @movement = @group.movements.build
  end

  def create
    @group = current_user.groups.find(params[:group_id])
    @movement = @group.movements.build(movement_params)
    @movement.author_id = current_user.id
    if @movement.save
      redirect_to user_group_path(current_user, @group), notice: 'Movement created sucessfully'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update; end

  def destroy
    @group = current_user.groups.find(params[:group_id])
    @movement = @group.movements.find(params[:id])
    @movement.destroy
    redirect_to user_group_path(current_user, @group)
  end

  private

  def movement_params
    params.require(:movement).permit(:name, :amount)
  end
end
```

I also added a button to delete movements with a confirmation dialog in the group show view:

```erb
<div>
  <%= link_to "Go back", authenticated_root_path %>
  <%= image_tag("group_icons/#{@group.icon}", alt: @group.icon, class: "icon-preview") %>
  <h1><%= @group.name %> movements </h1>
  <% if @movements.empty? %>
    <p>There are no movements, yet.</p>
  <% else %>
    <%= @movements.sum(:amount)%>
    <div>
      <% @movements.each do |movement| %>
        <p><%= movement.name %></p>
        <p><%= movement.created_at %></p>
        <p>$<%= movement.amount %></p>
        <%= button_to "Delete movement", user_group_movement_path(current_user, @group, movement), method: :delete,
                       data: { turbo_confirm: "Are you sure you want to delete this movement?" },
                       aria: { label: "Delete #{movement.name}" } %>
      <% end %>
    </div>
  <% end %>
  <%= link_to "Add a new movement", new_user_group_movement_path(current_user, @group) %>
</div>
```

 I crafted a new movement view where users can create a new instance of the movement class, associated with the current user and a group:
 
```erb
<div>
  <% if @movement.errors.any? %>
  <div id="error_explanation">
    <h2><%= pluralize(@movement.errors.count, "error") %> prohibited this movement from being saved:</h2>
    <ul>
    <% @movement.errors.full_messages.each do |message| %>
      <li><%= message %></li>
    <% end %>
    </ul>
  </div>
<% end %>

  <h1>Add a new movement</h1>
  <%= form_with(model: @movement, url: user_group_movements_path(current_user, @group), local: true) do |form| %>
    <div>
      <%= form.label :name %>
      <%= form.text_field :name %>
    </div>

    <div>
      <%= form.label :amount %>
      <%= form.number_field :amount %>
    </div>
      <%= form.submit "Add a movement" %>
  <% end %>
  <%= link_to "Go back", user_group_path(current_user, @group) %>
</div>
```

I installed and configured the Bullet gem to enhance performance and detect N+1 query issues in the development and test environments. I added the Bullet gem to the Gemfile and executed `bundle install`.

```Gemfile
group :development do
  gem 'bullet'
```

I configured Bullet in `config/environments/development.rb` to notify me about potential inefficiencies:

```ruby
  config.after_initialize do
    Bullet.enable        = true
    Bullet.alert         = true
    Bullet.bullet_logger = true
    Bullet.console       = true
    Bullet.rails_logger  = true
    Bullet.add_footer    = true
    Bullet.unused_eager_loading_enable = true
    Bullet.n_plus_one_query_enable     = true
  end
```

Similarly, I set up Bullet in `config/environments/test.rb` to raise errors for N+1 queries, ensuring optimal performance:

```ruby
  config.after_initialize do
    Bullet.enable        = true
    Bullet.bullet_logger = true
    Bullet.raise         = true # raise an error if n+1 query occurs
    Bullet.unused_eager_loading_enable = true
    Bullet.n_plus_one_query_enable     = true
  end
```

In the group show view, I improved memory usage by replacing `@movements.empty?` with `@movements.any?` to check for the presence of movements:

```erb
<div>
  <%= link_to "Go back", authenticated_root_path %>
  <%= image_tag("group_icons/#{@group.icon}", alt: @group.icon, class: "icon-preview") %>
  <h1><%= @group.name %> movements </h1>
  <% if @movements.any? %>
    <%= @movements.sum(:amount)%>
    <div>
      <% @movements.each do |movement| %>
        <p><%= movement.name %></p>
        <p><%= movement.created_at %></p>
        <p>$<%= movement.amount %></p>
        <%= button_to "Delete movement", user_group_movement_path(current_user, @group, movement), method: :delete,
                       data: { turbo_confirm: "Are you sure you want to delete this movement?" },
                       aria: { label: "Delete #{movement.name}" } %>
      <% end %>
    </div>
  <% else %>
    <p>There are no movements, yet.</p>
  <% end %>
  <%= link_to "Add a new movement", new_user_group_movement_path(current_user, @group) %>
</div>
```

For the groups index view, I optimized memory usage by using `@groups.any?` and implementing a precalculated sum of movements' transactions using a raw SQL query:

```erb
<h1>The Pocket Guardian</h1>
<p>Groups</p>

<% if @groups.any? %>
 <% @groups.each do |group| %>
    <!-- Display each group information here  -->
    <div>
      <%= link_to user_group_path(current_user, group) do %>
        <%= image_tag("group_icons/#{group.icon}", alt: group.name, class: "icon-preview") %>
        <p><%= group.created_at %></p>
        <p><%= group.name %></p>
        <p><%= group.movements_sum %></p>
      <% end %>
      <%= button_to "Delete",  user_group_path(current_user, group), method: :delete %>
    </div>
    <div>
      <%= link_to "Add a group", new_user_group_path(current_user), class: "button" %>
      <%= link_to "New movement", new_user_group_movement_path(current_user, group)%>
    </div>
  <% end %>
<% else %>
   <p>There are no groups.</p>
  <%= link_to "Add a group", new_user_group_path(current_user), class: "button" %>
<% end %>

```

In the Groups controller, I added the destroy action to allow deletion of groups and implemented a raw SQL query to fetch data more efficiently, thereby avoiding multiple queries:

```ruby
class GroupsController < ApplicationController
  def index
    # @groups = Group.all
    @groups = Group
      .select('groups.*, COALESCE(SUM(movements.amount), 0) as movements_sum')
      .left_joins(:movements)
      .group('groups.id')
  end

  def show
    @group = current_user.groups.find(params[:id])
    @movements = @group.movements.order(created_at: :desc)
  end

  def new
    @group = current_user.groups.build
  end

  def create
    @group = current_user.groups.build(group_params)
    if @group.save
      redirect_to user_groups_path(current_user), notice: 'Group was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update; end

  def destroy
    @group = current_user.groups.find(params[:id])
    @group.destroy
    redirect_to authenticated_root_path, notice: 'Group was sucessfuly deleted'
  end

  private

  def group_params
    params.require(:group).permit(:name, :icon)
  end
end
```

I added CSS classes following BEM convention to the splash page view, I also added semantic HTML and improved accesibility:

```erb
<div class="container splash_page">
  <section class="splash_page__container">
    <h1 class="title splash_page__title" tabindex="0" >The Pocket Guardian</h1>
    <div class="buttons splash_page__buttons" role="navigation" aria-lable="Primary">
      <%= link_to "LOG IN", new_user_session_path, method: :get, class: "button splash_page__login-button", role: "button", aria_label: "Log in to your acount", tab_index: '1' %>
      <%= link_to "SIGN UP", new_user_registration_path, method: :get, class: "button splash_page__signup-button", role: "buton", aria_label: "Sign up for a new account", tab_index: '2' %>
    </div>
  </section>
</div>
```

I added styles to the splash page: 
```css
.splash_page {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
  padding: 360px 15px 150px 15px;
}

.splash_page__container {
  margin: 0 auto;
  max-width: 600px;
  width: 100%;
  text-align: center;
}

.splash_page__title {
  color: var(--gray-text-color);
  margin-bottom: 280px;
  font-size: calc(var(--font-size-base) + 14px);
}

.splash_page__buttons {
  display: block;
  justify-content: center;
  align-items: center;
  flex-direction: column;
}

.splash_page__login-button,
.splash_page__signup-button {
  display: block;
  margin: 10px auto;
  color: var(--white-text-color);
  background-color: var(--blue-main-color);
  border: 2px solid var(--blue-main-color);
  padding: 17px 25px;
  width: 100%;
  border-radius: 4px;
  text-align: center;
  text-decoration: none;
  transition: all 0.3s ease;
}

.splash_page__signup-button {
  color: var(--gray-text-color);
  background-color: transparent;
  border: 2px solid transparent;
}

.splash_page__login-button:hover,
.splash_page__signup-button:hover {
  cursor: pointer;
  font-weight: bold;
  border: 2px solid var(--green-second-color);
}

```

I added some global styles in application.css:
```css
:root {
  --gray-background-color: rgb(235, 235, 235);
  --blue-main-color: #3778c2;
  --green-second-color: #5fb523;
  --gray-text-color: #434b54;
  --white-text-color: #ffffff;
  --black-color: #000000;
  --font-size-base: 16px;
}

*,
*::before,
*::after {
  padding: 0;
  margin: 0;
  box-sizing: border-box;
  font-family: proxima-nova, sans-serif;
}

body {
  background-color: var(--gray-background-color);
}

.icon-preview {
  width: 40px;
}
```

I added some media queries to the splash page:

```css

@media (min-width: 361px) {
  .splash_page__title {
    font-size: calc(var(--font-size-base) + 16px);
  }
}

@media (min-width: 481px) {
  .splash_page__title {
    font-size: calc(var(--font-size-base) + 20px);
  }

  .splash_page__login-button,
  .splash_page__signup-button {
    width: 95%;
    padding: 19px 24px;
    font-size: calc(var(--font-size-base) + 1px);
  }
}

@media (min-width: 600px) {
  .splash_page__title {
    font-size: calc(var(--font-size-base) + 24px);
  }

  .splash_page__login-button,
  .splash_page__signup-button {
    width: 90%;
    padding: 21px 26px;
    font-size: calc(var(--font-size-base) + 2px);
  }
}

@media (min-width: 769px) {
  .splash_page {
    padding: 60px;
  }

  .splash_page__title {
    font-size: calc(var(--font-size-base) + 34px);
  }

  .splash_page__login-button,
  .splash_page__signup-button {
    width: 80%;
    padding: 22px 27px;
    font-size: calc(var(--font-size-base) + 3px);
  }
}

@media (min-width: 992px) {
  .splash_page__container {
    max-width: 750px;
  }

  .splash_page__title {
    font-size: calc(var(--font-size-base) + 43px);
  }

  .splash_page__login-button,
  .splash_page__signup-button {
    width: 70%;
    padding: 23px 28px;
    font-size: calc(var(--font-size-base) + 4px);
  }
}

@media (min-width: 1400px) {
  .splash_page__container {
    max-width: 1100px;
  }

  .splash_page__title {
    font-size: calc(var(--font-size-base) + 50px);
  }

  .splash_page__login-button,
  .splash_page__signup-button {
    width: 50%;
    padding: 25px 29px;
    font-size: calc(var(--font-size-base) + 5px);
  }
}

@media (min-width: 1600px) {
  .splash_page__container {
    max-width: 1300px;
  }

  .splash_page__title {
    font-size: calc(var(--font-size-base) + 68px);
  }

  .splash_page__login-button,
  .splash_page__signup-button {
    width: 48%;
    padding: 26px 31px;
    font-size: calc(var(--font-size-base) + 6px);
  }
}

```

I added styles for the log in:
```css
/* Session - login */
.login_page {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
  padding: 0;
}

.login_page__container {
  margin: 0 auto;
  max-width: 600px;
  text-align: center;
  width: 100%;
}

.login_page__title {
  color: var(--gray-text-color);
  font-size: calc(var(--font-size-base) + 18px);
  margin: 18px 0;
}

.login_page__form {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.login_form__fields--email,
.login_form__fields--password {
  width: 100%;
}

.login_form__field_email--field,
.login_form__field_password--field {
  padding: 16px 17px;
  width: 100%;
  border: none;
  margin: 1px 0;
}

.login_form__check_box--remember {
  margin-top: 16px;
  margin-bottom: 12px;
  color: var(--gray-text-color);
}

.login_form__submit--button {
  margin: 10px 0;
  padding: 13px 20px;
  background-color: var(--blue-main-color);
  border: 2px solid var(--blue-main-color);
  color: var(--white-text-color);
  font-size: calc(var(--font-size-base) + 1px);
  width: auto;
  min-width: 140px;
  border-radius: 4px;
  transition: background-color 0.3s, border-color 0.3s, color 0.3s;
}

.login_form__submit--button:hover {
  cursor: pointer;
  font-weight: bold;
  background-color: var(--white-text-color);
  color: var(--blue-main-color); 
  border: 2px solid var(--green-second-color);
}

.login_page__shared_link {
  text-decoration: none;
  color: var(--gray-text-color);
  display: inline-block;
  margin: 8px 0;
  transition: color 0.3s;
}

.login_page__shared_link--login:hover,
.login_page__shared_link--signup:hover,
.login_page__shared_link--forgot-password:hover,
.login_page__shared_link--confirmation:hover,
.login_page__shared_link--unlock:hover {
  color: var(--black-color);
}

/* Media queries */
@media (min-width: 361px) {
  .login_form__field_email--field,
  .login_form__field_password--field {
    padding: 17px 18px;
  }
}

@media (min-width: 481px) {
  .login_page__title {
    font-size: calc(var(--font-size-base) + 20px);
  }

  .login_form__fields--email,
  .login_form__fields--password {
    width: 90%;
  }

  .login_form__field_email--field,
  .login_form__field_password--field {
    padding: 19px 20px;
    font-size: calc(var(--font-size-base) + 3px);
  }

  .login_form__check_box--remember {
    font-size: calc(var(--font-size-base) + 1px);
  }

  .login_form__submit--button {
    font-size: calc(var(--font-size-base) + 2px);
  }

  .login_page__shared_link {
    font-size: calc(var(--font-size-base) + 1px);
  }
}

@media (min-width: 600px) {
  .login_page__title {
    font-size: calc(var(--font-size-base) + 23px);
  }

  .login_form__field_email--field,
  .login_form__field_password--field {
    font-size: calc(var(--font-size-base) + 4px);
  }

  .login_form__check_box--remember {
    font-size: calc(var(--font-size-base) + 2px);
  }

  .login_form__submit--button {
    padding: 14px 21px;
    font-size: calc(var(--font-size-base) + 3px);
    min-width: 142px;
  }

  .login_page__shared_link {
    font-size: calc(var(--font-size-base) + 2px);
  }
}

@media (min-width: 769px) {
  .login_page__title {
    font-size: calc(var(--font-size-base) + 22px);
  }

  .login_form__field_email--field,
  .login_form__field_password--field {
    font-size: calc(var(--font-size-base) + 5px);
  }

  .login_form__check_box--remember {
    font-size: calc(var(--font-size-base) + 3px);
  }

  .login_form__submit--button {
    padding: 14px 21px;
    font-size: calc(var(--font-size-base) + 4px);
    min-width: 146px;
  }

  .login_page__shared_link {
    font-size: calc(var(--font-size-base) + 3px);
  }
}

@media (min-width: 992px) {
  .login_page__title {
    font-size: calc(var(--font-size-base) + 23px);
  }

  .login_form__field_email--field,
  .login_form__field_password--field {
    font-size: calc(var(--font-size-base) + 7px);
  }

  .login_form__check_box--remember {
    font-size: calc(var(--font-size-base) + 4px);
  }

  .login_form__submit--button {
    padding: 14px 21px;
    font-size: calc(var(--font-size-base) + 5px);
    min-width: 148px;
  }

  .login_page__shared_link {
    font-size: calc(var(--font-size-base) + 4px);
  }
}

@media (min-width: 1400px) {
  .login_page__title {
    font-size: calc(var(--font-size-base) + 24px);
  }

  .login_form__field_email--field,
  .login_form__field_password--field {
    font-size: calc(var(--font-size-base) + 8px);
  }

  .login_form__check_box--remember {
    font-size: calc(var(--font-size-base) + 5px);
  }

  .login_form__submit--button {
    font-size: calc(var(--font-size-base) + 6px);
    min-width: 150px;
  }

  .login_page__shared_link {
    font-size: calc(var(--font-size-base) + 5px);
  }
}

@media (min-width: 1600px) {
  .login_page__title {
    font-size: calc(var(--font-size-base) + 26px);
  }

  .login_form__field_email--field,
  .login_form__field_password--field {
    font-size: calc(var(--font-size-base) + 10px);
  }

  .login_form__check_box--remember {
    font-size: calc(var(--font-size-base) + 6px);
  }

  .login_form__submit--button {
    font-size: calc(var(--font-size-base) + 7px);
    min-width: 153px;
  }

  .login_page__shared_link {
    font-size: calc(var(--font-size-base) + 6px);
  }
}
```
I added class followint BEM convention to the log in form:
```erb
<div class="login_page">
  <section class="login_page__container">
    <h2 class="login_page__title">Log in</h2>
    <%= form_for(resource, as: resource_name, url: session_path(resource_name), html: { class: 'form login_page__form' }) do |f| %>
      <div class="field login_form__fields--email">
        <%= f.email_field :email, placeholder: 'Email', autofocus: true, autocomplete: "email", class: 'login_form__field_email--field' %>
      </div>
    
      <div class="field login_form__fields--password">
        <%= f.password_field :password, placeholder: 'Password', autocomplete: "current-password", class: 'login_form__field_password--field' %>
      </div>
    
      <% if devise_mapping.rememberable? %>
        <div class="field login_form__check_box--remember">
          <%= f.check_box :remember_me, class: 'login_form__check_box--box' %>
          <%= f.label :remember_me, class: 'login_form__check_box--label' %>
        </div>
      <% end %>
    
      <div class="actions login_form__submit_button--container">
        <%= f.submit "Log in", class: 'login_form__submit--button' %>
      </div>
    <% end %>
    <div>
      <%= render "devise/shared/links" %>
    </div>
  </section>
</div>
```
I added classes to the sessions shared links following the BEM convention:
```erb
<%- if controller_name != 'sessions' %>
  <%= link_to "Log in", new_session_path(resource_name), class: 'login_page__shared_link login_page__shared_link--login' %><br />
<% end %>

<%- if devise_mapping.registerable? && controller_name != 'registrations' %>
  <%= link_to "Sign up", new_registration_path(resource_name), class: 'login_page__shared_link login_page__shared_link--signup' %><br />
<% end %>

<%- if devise_mapping.recoverable? && controller_name != 'passwords' && controller_name != 'registrations' %>
  <%= link_to "Forgot your password?", new_password_path(resource_name), class: 'login_page__shared_link login_page__shared_link--forgot-password' %><br />
<% end %>

<%- if devise_mapping.confirmable? && controller_name != 'confirmations' %>
  <%= link_to "Didn't receive confirmation instructions?", new_confirmation_path(resource_name), class: 'login_page__shared_link login_page__shared_link--confirmation' %><br />
<% end %>

<%- if devise_mapping.lockable? && resource_class.unlock_strategy_enabled?(:email) && controller_name != 'unlocks' %>
  <%= link_to "Didn't receive unlock instructions?", new_unlock_path(resource_name), class: 'login_page__shared_link login_page__shared_link--unlock' %><br />
<% end %>

<%- if devise_mapping.omniauthable? %>
  <%- resource_class.omniauth_providers.each do |provider| %>
    <%= button_to "Sign in with #{OmniAuth::Utils.camelize(provider)}", omniauth_authorize_path(resource_name, provider), data: { turbo: false }, class: 'login_page__shared_link login_page__shared_link--omniauth'  %><br />
  <% end %>
<% end %>
```

I added classes to the sign up page following the BEM convention:
```erb
<div class="signup_page">
  <div class="signup_page__container">
    <h2 class="signup_page__title">Register</h2>
    <%= form_for(resource, as: resource_name, url: registration_path(resource_name), html: {class: 'form signup_page__form'}) do |f| %>
      <%= render "devise/shared/error_messages", resource: resource %>
    
      <div class="signup_form__container">
        <h3 class="signup_form__title--avatar">Choose an avatar: </h3>
        <div class="signup_form__container--avatar">
          <% User.profile_images.each_with_index do |profile_image, index| %>
            <% radio_id = "profile_image_#{index}" %>
            <%= f.radio_button :profile_image, profile_image, id: radio_id, class: 'signup_form__radio--button' %>
            <%= f.label :profile_image, class: "signup_form__label--avatar", for: radio_id do %>
              <%= image_tag("profile_images/#{profile_image}", alt: profile_image, class: "signup_form__image--avatar") %>
            <% end %>
          <% end %>
          </div>
      </div>
    
      <div class="field signup_form__fields--name">
        <%= f.text_field :name, autofocus: true, autocomplete: "name", placeholder: "Full name", class: 'signup_form__field_name--field' %>
      </div>
    
      <div class="field signup_form__fields--email">
        <%= f.email_field :email, autocomplete: "email", placeholder: "Email", class: 'signup_form__field_email--field'  %>
      </div>
    
      <div class="field signup_form__fields--password">
        <%= f.password_field :password, autocomplete: "new-password", placeholder: "Password (#{@minimum_password_length} characters minimum).", class: 'signup_form__field_password--field' %>
      </div>
    
      <div class="field signup_form__fields--password">
        <%= f.password_field :password_confirmation, autocomplete: "new-password", placeholder: "Password confirmation", class: 'signup_form__field_password--field' %>
      </div>
    
      <div class="actions signup_form__submit_button--container">
        <%= f.submit "Sign up", class: 'signup_form__submit--button'  %>
      </div>
    <% end %>
    
    <%= render "devise/shared/links" %>
  </div>
</div>
```
I added the profile_image property as a permitted parameter for sign up and edit:

```ruby
class ApplicationController < ActionController::Base
  protect_from_forgery prepend: true
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden, content_type: 'application/json' }
      format.html { redirect_to main_app.root_url, alert: exception.message }
      format.js { head :forbidden, content_type: 'application/javascript' }
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name profile_image])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name profile_image])
  end

  def after_sign_in_path_for(_resource)
    authenticated_root_path
  end

  def after_sign_up_path_for(_resource)
    authenticated_root_path
  end
end
```
I updated the styles to avoid repetition and make the Sign up form responsive:
```css
/* Sessions, registrations, and password forms */
.login_page,
.signup_page,
.forgot_password_page,
.resend_confirmation_password_page,
.change_password_page {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
  width: 100%;
  padding: 260px 0;
  overflow-y: scroll;
}

.login_page__container,
.signup_page__container,
.forgot_password_page__container,
.resend_confirmation_password_page__container,
.change_password_page__container {
  margin: 0 auto;
  max-width: 600px;
  text-align: center;
  width: 100%;
}

.login_page__title,
.signup_page__title,
.forgot_password_title,
.resend_confirmation_password__title,
.change_password__title {
  color: var(--gray-text-color);
  font-size: calc(var(--font-size-base) + 18px);
  margin-top: 10px;
  margin-bottom: 10px;
  position: relative;
}

.login_page__title,
.forgot_password_title,
.resend_confirmation_password__title,
.change_password__title {
  margin-top: 0;
}

.login_page__form,
.signup_page__form,
.forgot_password_page__form,
.resend_confirmation_password_page__form,
.change_password_page__form {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.login_form__fields--email,
.login_form__fields--password,
.signup_form__fields--name,
.signup_form__fields--email,
.signup_form__fields--password,
.forgot_password_form__fields--email,
.resend_confirmation_password_form__fields--email,
.change_password_form__fields--password,
.change_password_form__fields--password_confirmation {
  width: 100%;
}

.login_form__field_email--field,
.login_form__field_password--field,
.signup_form__field_name--field,
.signup_form__field_email--field,
.signup_form__field_password--field,
.forgot_password_form__field_email--field,
.resend_confirmation_password_form__field_email--field,
.change_password_form__field_password--field,
.change_password_form__field_password_confirmation--field {
  padding: 16px 17px;
  width: 100%;
  border: none;
  margin: 1px 0;
}

.login_form__check_box--remember {
  margin-top: 16px;
  margin-bottom: 12px;
  color: var(--gray-text-color);
}

.login_form__submit--button,
.signup_form__submit--button,
.forgot_password_form__submit--button,
.resend_confirmation_password_form__submit--button,
.change_password_form__submit--button {
  margin: 10px 0;
  padding: 13px 20px;
  background-color: var(--blue-main-color);
  border: 2px solid var(--blue-main-color);
  color: var(--white-text-color);
  font-size: calc(var(--font-size-base) + 1px);
  width: auto;
  min-width: 140px;
  border-radius: 4px;
  transition: background-color 0.3s, border-color 0.3s, color 0.3s;
}

.login_form__submit--button:hover,
.signup_form__submit--button:hover,
.forgot_password_form__submit--button:hover
.resend_confirmation_password_form__submit--button:hover,
.change_password_form__submit--button:hover {
  cursor: pointer;
  font-weight: bold;
  background-color: var(--white-text-color);
  color: var(--blue-main-color);
  border: 2px solid var(--green-second-color);
}

.login_page__shared_link {
  text-decoration: none;
  color: var(--gray-text-color);
  display: inline-block;
  margin: 8px 0;
  transition: color 0.3s;
}

.login_page__shared_link--login:hover,
.login_page__shared_link--signup:hover,
.login_page__shared_link--forgot-password:hover,
.login_page__shared_link--confirmation:hover,
.login_page__shared_link--unlock:hover {
  color: var(--black-color);
}

/* Specific for sign-up page */
.signup_form__container--avatar {
  display: flex;
  justify-content: center;
  margin-bottom: 20px;
  overflow-x: auto;
  border: 1px solid var(--light-gray-text-color);
  border-radius: 10px;
  box-shadow: inset 0 0 10px rgba(0, 0, 0, 0.15);
  background: var(--white-text-color);
  scrollbar-width: thin;
  scrollbar-color: var(--gray-text-color) var(--white-text-color);
  padding: 10px;
  max-width: 285px;
  width: auto;
}

/* Styles for Webkit browsers like Chrome, Safari */
.signup_form__container--avatar::-webkit-scrollbar {
  height: 8px;
}

.signup_form__container--avatar::-webkit-scrollbar-track {
  border-radius: 10px;
}

.signup_form__container--avatar::-webkit-scrollbar-thumb {
  background-color: var(--gray-text-color);
  border-radius: 10px;
  border: 2px solid var(--white-text-color);
}

.signup_form__radio--button {
  display: none;
}

.signup_form__label--avatar {
  display: flex;
  cursor: pointer;
  transition: transform 0.2s ease-in-out;
}

.signup_form__label--avatar:hover {
  transform: translateY(-2px);
}

.signup_form__image--avatar {
  width: 45px;
  margin: 3px;
  padding: 1px;
  border: 2px solid transparent;
  transition: border-color 0.25s ease-in-out;
}

.signup_form__radio--button:checked + .signup_form__label--avatar .signup_form__image--avatar {
  border-color: var(--green-second-color);
  transform: scale(1.1);
}

.signup_form__title--avatar {
  color: var(--gray-text-color);
  font-size: calc(var(--font-size-base));
  margin: 0;
}

/* Media queries */
@media (min-width: 361px) {
  .login_page,
  .signup_page,
  .forgot_password_page,
  .resend_confirmation_password_page,
  .change_password_page {
    padding: 275px 0;
  }

  .login_page__title,
  .signup_page__title,
  .forgot_password_title,
  .resend_confirmation_password__title,
  .change_password__title {
    font-size: calc(var(--font-size-base) + 19px);
  }

  .login_form__field_email--field,
  .login_form__field_password--field,
  .signup_form__field_name--field,
  .signup_form__field_email--field,
  .signup_form__field_password--field,
  .forgot_password_form__field_email--field,
  .resend_confirmation_password_form__field_email--field,
  .change_password_form__field_password--field,
  .change_password_form__field_password_confirmation--field {
    padding: 17px 18px;
  }
}

@media (min-width: 481px) {
  .login_page,
  .signup_page,
  .forgot_password_page,
  .resend_confirmation_password_page,
  .change_password_page {
    padding: 300px 20px;
  }

  .login_page__title,
  .signup_page__title,
  .forgot_password_title,
  .resend_confirmation_password__title,
  .change_password__title {
    font-size: calc(var(--font-size-base) + 20px);
  }

  .signup_form__title--avatar {
    font-size: calc(var(--font-size-base) + 1px);
    margin: 1px 0;
  }

  .signup_form__container--avatar {
    padding: 10px;
    max-width: 380px;
    width: auto;
  }

  .login_form__fields--email,
  .login_form__fields--password,
  .signup_form__fields--name,
  .signup_form__fields--email,
  .signup_form__fields--password,
  .forgot_password_form__fields--email,
  .resend_confirmation_password_form__fields--email,
  .change_password_form__fields--password,
  .change_password_form__fields--password_confirmation {
    width: 90%;
  }

  .login_form__field_email--field,
  .login_form__field_password--field,
  .signup_form__field_name--field,
  .signup_form__field_email--field,
  .signup_form__field_password--field,
  .forgot_password_form__field_email--field,
  .resend_confirmation_password_form__field_email--field,
  .change_password_form__field_password--field,
  .change_password_form__field_password_confirmation--field {
    padding: 19px 20px;
    font-size: calc(var(--font-size-base) + 3px);
  }

  .login_form__check_box--remember {
    font-size: calc(var(--font-size-base) + 1px);
  }

  .login_form__submit--button,
  .signup_form__submit--button,
  .forgot_password_form__submit--button,
  .resend_confirmation_password_form__submit--button,
  .change_password_form__submit--button {
    font-size: calc(var(--font-size-base) + 1px);
  }
}

@media (min-width: 600px) {
  .login_page,
  .signup_page,
  .forgot_password_page,
  .resend_confirmation_password_page,
  .change_password_page {
    padding: 320px 25px;
  }

  .login_page__title,
  .signup_page__title,
  .forgot_password_title,
  .resend_confirmation_password__title,
  .change_password__title {
    font-size: calc(var(--font-size-base) + 23px);
  }

  .signup_form__title--avatar {
    font-size: calc(var(--font-size-base) + 2px);
    margin-bottom: 3px;
  }

  .signup_form__container--avatar {
    max-width: 470px;
  }

  .login_form__field_email--field,
  .login_form__field_password--field,
  .signup_form__field_name--field,
  .signup_form__field_email--field,
  .signup_form__field_password--field,
  .forgot_password_form__field_email--field,
  .resend_confirmation_password_form__field_email--field,
  .change_password_form__field_password--field,
  .change_password_form__field_password_confirmation--field {
    font-size: calc(var(--font-size-base) + 4px);
  }

  .login_form__check_box--remember {
    font-size: calc(var(--font-size-base) + 2px);
  }

  .login_form__submit--button,
  .signup_form__submit--button,
  .forgot_password_form__submit--button,
  .resend_confirmation_password_form__submit--button,
  .change_password_form__submit--button {
    padding: 14px 21px;
    font-size: calc(var(--font-size-base) + 3px);
    min-width: 142px;
  }

  .login_page__shared_link {
    font-size: calc(var(--font-size-base) + 2px);
  }
}

@media (min-width: 769px) {
  .login_page,
  .signup_page,
  .forgot_password_page,
  .resend_confirmation_password_page,
  .change_password_page {
    padding: 330px 25px;
  }

  .login_page__title,
  .signup_page__title,
  .forgot_password_title,
  .resend_confirmation_password__title,
  .change_password__title {
    font-size: calc(var(--font-size-base) + 24px);
  }

  .signup_form__title--avatar {
    font-size: calc(var(--font-size-base) + 3px);
    margin-bottom: 4px;
  }

  .signup_form__container--avatar {
    max-width: 500px;
  }

  .signup_form__image--avatar {
    width: 50px;
  }

  .login_form__field_email--field,
  .login_form__field_password--field,
  .signup_form__field_name--field,
  .signup_form__field_email--field,
  .signup_form__field_password--field,
  .forgot_password_form__field_email--field,
  .resend_confirmation_password_form__field_email--field,
  .change_password_form__field_password--field,
  .change_password_form__field_password_confirmation--field {
    font-size: calc(var(--font-size-base) + 5px);
  }

  .login_form__check_box--remember {
    font-size: calc(var(--font-size-base) + 3px);
  }

  .login_form__submit--button,
  .signup_form__submit--button,
  .forgot_password_form__submit--button,
  .resend_confirmation_password_form__submit--button,
  .change_password_form__submit--button {
    padding: 14px 21px;
    font-size: calc(var(--font-size-base) + 4px);
    min-width: 146px;
  }

  .login_page__shared_link {
    font-size: calc(var(--font-size-base) + 3px);
  }
}

@media (min-width: 992px) {
  .login_page,
  .signup_page,
  .forgot_password_page,
  .resend_confirmation_password_page,
  .change_password_page {
    padding: 335px 40px;
  }

  .login_page__title,
  .signup_page__title,
  .forgot_password_title,
  .resend_confirmation_password__title,
  .change_password__title {
    font-size: calc(var(--font-size-base) + 24px);
  }

  .signup_form__title--avatar {
    font-size: calc(var(--font-size-base) + 4px);
    margin-bottom: 5px;
  }

  .signup_form__image--avatar {
    width: 52px;
  }

  .login_form__field_email--field,
  .login_form__field_password--field,
  .signup_form__field_name--field,
  .signup_form__field_email--field,
  .signup_form__field_password--field,
  .forgot_password_form__field_email--field,
  .resend_confirmation_password_form__field_email--field,
  .change_password_form__field_password--field,
  .change_password_form__field_password_confirmation--field {
    font-size: calc(var(--font-size-base) + 7px);
  }

  .login_form__check_box--remember {
    font-size: calc(var(--font-size-base) + 4px);
  }

  .login_form__submit--button,
  .signup_form__submit--button,
  .forgot_password_form__submit--button,
  .resend_confirmation_password_form__submit--button,
  .change_password_form__submit--button {
    padding: 14px 21px;
    font-size: calc(var(--font-size-base) + 5px);
    min-width: 148px;
  }

  .login_page__shared_link {
    font-size: calc(var(--font-size-base) + 4px);
  }
}

@media (min-width: 1400px) {
  .login_page,
  .signup_page,
  .forgot_password_page,
  .resend_confirmation_password_page,
  .change_password_page {
    padding: 355px 40px;
  }

  .login_page__title,
  .signup_page__title,
  .forgot_password_title,
  .resend_confirmation_password__title,
  .change_password__title {
    font-size: calc(var(--font-size-base) + 25px);
  }

  .signup_form__title--avatar {
    font-size: calc(var(--font-size-base) + 5px);
    margin-bottom: 6px;
  }

  .signup_form__image--avatar {
    width: 55px;
  }

  .login_form__field_email--field,
  .login_form__field_password--field,
  .signup_form__field_name--field,
  .signup_form__field_email--field,
  .signup_form__field_password--field,
  .forgot_password_form__field_email--field,
  .resend_confirmation_password_form__field_email--field,
  .change_password_form__field_password--field,
  .change_password_form__field_password_confirmation--field {
    font-size: calc(var(--font-size-base) + 8px);
  }

  .login_form__check_box--remember {
    font-size: calc(var(--font-size-base) + 5px);
  }

  .login_form__submit--button,
  .signup_form__submit--button,
  .forgot_password_form__submit--button,
  .resend_confirmation_password_form__submit--button,
  .change_password_form__submit--button {
    font-size: calc(var(--font-size-base) + 6px);
    min-width: 150px;
  }

  .login_page__shared_link {
    font-size: calc(var(--font-size-base) + 5px);
  }
}

@media (min-width: 1600px) {
  .login_page__title,
  .signup_page__title,
  .forgot_password_title,
  .resend_confirmation_password__title,
  .change_password__title {
    font-size: calc(var(--font-size-base) + 26px);
  }

  .signup_form__title--avatar {
    font-size: calc(var(--font-size-base) + 6px);
    margin-bottom: 7px;
  }

  .signup_form__image--avatar {
    width: 56px;
  }

  .login_form__field_email--field,
  .login_form__field_password--field,
  .signup_form__field_name--field,
  .signup_form__field_email--field,
  .signup_form__field_password--field,
  .forgot_password_form__field_email--field,
  .resend_confirmation_password_form__field_email--field,
  .change_password_form__field_password--field,
  .change_password_form__field_password_confirmation--field {
    font-size: calc(var(--font-size-base) + 10px);
  }

  .login_form__check_box--remember {
    font-size: calc(var(--font-size-base) + 6px);
  }

  .login_form__submit--button,
  .signup_form__submit--button,
  .forgot_password_form__submit--button,
  .resend_confirmation_password_form__submit--button,
  .change_password_form__submit--button {
    font-size: calc(var(--font-size-base) + 7px);
    min-width: 153px;
  }

  .login_page__shared_link {
    font-size: calc(var(--font-size-base) + 6px);
  }
}
```
I added classes to the resend confirmation password page following the BEM convention:
```erb
<div class="resend_confirmation_password_page">
  <section class="resend_confirmation_password_page__container">
    <h2 class="resend_confirmation_password__title">Resend confirmation instructions</h2>
    
    <%= form_for(resource, as: resource_name, url: confirmation_path(resource_name), html: { class: 'resend_confirmation_password_page__form', method: :post }) do |f| %>
      <%= render "devise/shared/error_messages", resource: resource %>
    
      <div class="field resend_confirmation_password_form__fields--email">
        <%= f.email_field :email, placeholder: 'Email', autofocus: true, autocomplete: "email", class: 'resend_confirmation_password_form__field_email--field', value: (resource.pending_reconfirmation? ? resource.unconfirmed_email : resource.email) %>
      </div>
    
      <div class="actions resend_confirmation_password_form__submit_button--container">
        <%= f.submit "Resend confirmation instructions", class: "resend_confirmation_password_form__submit--button" %>
      </div>
    <% end %>
    
    <div>
      <%= render "devise/shared/links" %>
    </div>
  </section>
</div>
```

I added classes to the forgot password page following the BEM convention:
```erb
<div class="forgot_password_page">
  <section class="forgot_password_page__container">
    <h2 class="forgot_password_title">Forgot your password?</h2>
    
    <%= form_for(resource, as: resource_name, url: password_path(resource_name), html: { class: 'form forgot_password_page__form', method: :post }) do |f| %>
      <%= render "devise/shared/error_messages", resource: resource %>
    
      <div class="field forgot_password_form__fields--email">
        <%= f.email_field :email, placeholder: 'Email', autofocus: true, autocomplete: "email", class: 'forgot_password_form__field_email--field' %>
      </div>
    
      <div class="actions forgot_password_form__submit_button--container">
        <%= f.submit "Send me reset password instructions", class: "forgot_password_form__submit--button" %>
      </div>
    <% end %>
    
    <div>
      <%= render "devise/shared/links" %>
    </div>
  </section>
</div>
```


I added classes to the change your password page following the BEM convention:

```erb
<div class="change_password_page">
  <section class="change_password_page__container">
    <h2 class="change_password__title">Change your password</h2>
    
    <%= form_for(resource, as: resource_name, url: password_path(resource_name), html: { class: 'change_password_page__form', method: :put }) do |f| %>
      <%= render "devise/shared/error_messages", resource: resource %>
      <%= f.hidden_field :reset_password_token %>
    
      <div class="field change_password_form__fields--password">
        <%= f.password_field :password, placeholder: "New password (#{@minimum_password_length} characters minimum).", autofocus: true, autocomplete: "new-password", class: 'change_password_form__field_password--field' %>
      </div>
    
      <div class="field change_password_form__fields--password_confirmation">
        <%= f.password_field :password_confirmation, autocomplete: "new-password", placeholder: "Confirm new password", class: 'change_password_form__field_password_confirmation--field' %>
      </div>
    
      <div class="actions change_password_form__submit_button--container">
        <%= f.submit "Change my password", class: 'change_password_form__submit--button' %>
      </div>
    <% end %>
    
    <div>
      <%= render "devise/shared/links" %>
    </div>
  </section>
</div>
```
I created the navigation bar:
```erb
<% if user_signed_in? || !current_page?(root_path) || current_page?(new_user_session_path) || current_page?(new_user_registration_path) %>
  <nav class="nav_bar" aria-label="Main navigation">
    <div class="nav_bar__container">
      <% if !current_page?(authenticated_root_path) %>
        <%= link_to "javascript:history.back()", class: 'nav_bar__back_button', aria_label: "Go back", role: "button" do %>
          <span aria-hidden="true"><</span>
          <span class="visually-hidden">Back</span>
        <% end %>
      <% elsif user_signed_in? && current_page?(authenticated_root_path) %>
          <button type="button" class="hamburger_button" aria-label="Menu">
          <span class="button__bar"></span>
          <span class="button__bar"></span>
          <span class="button__bar"></span>
        </button>
      <% elsif !user_signed_in? && (current_page?(new_user_session_path) || current_page?(new_user_registration_path)) %>
        <%= link_to "javascript:history.back()", class: 'nav_bar__back_button', aria_label: "Go back", role: "button" do %>
          <span aria-hidden="true"><</span>
          <span class="visually-hidden">Back</span>
        <% end %>
      <% end %>
      <!-- Title based on page -->
      <div class="nav_bar__title" role="heading" aria-level="1">
        <% if user_signed_in? && current_page?(authenticated_root_path) %>
          <h1>Groups</h1>
        <% elsif user_signed_in? && current_page?(new_user_group_path) %>
          <h1>Add a new group</h1>
        <% elsif user_signed_in? && current_page?(user_group_path(current_user, @group)) %>
          <h1>Movements</h1>
        <% elsif user_signed_in? && current_page?(new_user_group_movement_path) %>
          <h1>Add a new movement</h1>
        <% elsif current_page?(new_user_session_path) || controller_name == "sessions" %>
          <h1 class="login_page__title">Login</h1>
        <% elsif current_page?(new_user_registration_path) || controller_name == "registrations" %>
          <h1 class="signup_page__title">Register</h1>
        <% elsif controller_name == "confirmations" && (action_name == "new" || action_name == "create") %>
          <h1 class="resend_confirmation_password__title">Resend confirmation instructions</h1>
        <% elsif controller_name == "passwords" && (action_name == "new" || action_name == "create") %>
          <h1 class="forgot_password_title">Forgot your password?</h1>
        <% elsif controller_name == "passwords" && (action_name == "edit" || action_name == "update") %>
          <h1 class="change_password__title">Change your password</h1>
        <% end %>
      </div>
    </div>
  </nav>
<% end %>

```

I added styles with the navigation bar:

```css
.nav_bar {
  background-color: var(--blue-main-color);
  width: 100%;
  position: relative;
}

.visually-hidden {
  display: none;
}

.nav_bar__container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
  height: 105px;
  padding: 12px;
  position: relative;
}

.nav_bar__back_button {
  text-decoration: none;
  color: var(--white-text-color);
  font-size: calc(var(--font-size-base) + 18px);
  position: absolute;
  left: 15px;
  z-index: 10;
  font-weight: bold;
}

.nav_bar__title {
  width: 100%;
  text-align: center;
  position: absolute;
  left: 0;
  right: 0;
  margin: auto;
}

.hamburger_button {
  display: flex;
  flex-direction: column;
  background-color: transparent;
  border: none;
  cursor: pointer;
}

.hamburger_button .button__bar {
  display: flex;
  width: calc(var(--font-size-base) + 18px);
  height: calc(var(--font-size-base) - 13px);
  margin: 8px auto;
  background-color: var(--white-text-color);
  border-radius: 2px;
}

/* Todo: Add media queries to improve layout */

```