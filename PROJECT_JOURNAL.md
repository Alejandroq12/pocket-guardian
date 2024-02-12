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
Proceed to create the models according to the Entity Relationship Diagram.
