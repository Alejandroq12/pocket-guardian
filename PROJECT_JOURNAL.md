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