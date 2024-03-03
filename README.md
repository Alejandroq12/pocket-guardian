# the-pocker-guardian

<a name="readme-top"></a>
<div align="center">
    <img src="logo-julio.png" alt="main-logo" width="500"  height="auto" />
  <br/>
  <h3><b>The Pocker Guardian</b></h3>
</div>
# 📗 Table of Contents

- [the-pocker-guardian](#the-pocker-guardian)
- [📗 Table of Contents](#-table-of-contents)
- [📖 The Pocker Guardian ](#-the-pocker-guardian-)
  - [🛠 Built With ](#-built-with-)
    - [Tech Stack ](#tech-stack-)
    - [Key Features ](#key-features-)
  - [💻 Getting Started ](#-getting-started-)
    - [Prerequisites](#prerequisites)
    - [Setup](#setup)
    - [Install](#install)
    - [Database](#database)
    - [Usage](#usage)
    - [Run tests](#run-tests)
    - [Run linter](#run-linter)
    - [Deployment](#deployment)
    - [Video presentation](#video-presentation)
  - [👥 Authors ](#-authors-)
  - [🔭 Future Features ](#-future-features-)
  - [🤝 Contributing ](#-contributing-)
  - [⭐️ Show your support ](#️-show-your-support-)
  - [🙏 Acknowledgments ](#-acknowledgments-)
  - [❓ FAQ ](#-faq-)
  - [📝 License ](#-license-)
  - [📝 Project journal ](#-project-journal-)

# 📖 The Pocker Guardian <a name="about-project"></a>

The Pocker Guardian is a full-stack web application that I created from scratch. My goal is to share knowledge and educate people about money management through quality content. To bring this beautiful piece of technology to life, I am using Ruby on Rails.

## 🛠 Built With <a name="built-with"></a>

### Tech Stack <a name="tech-stack"></a>

  <ul>
    <li><a href="https://rubyonrails.org/">Ruby on Rails 7.1.2</a></li>
    <li><a href="https://www.postgresql.org/">PostgreSQL</a></li>
  </ul>

### Key Features <a name="key-features"></a>

- **It allows the user to create transaction groups.**
- **It allows the user to know the total amount spent.**

<p align="right">(<a href="#readme-top">back to top</a>)</p>


## 💻 Getting Started <a name="getting-started"></a>

To get a local copy up and running, follow these steps.

### Prerequisites

In order to run this project you need:

[Install Ruby](https://www.ruby-lang.org/en/documentation/installation/)

### Setup

```sh
cd my-folder
git clone https://github.com/Alejandroq12/pocket-guardian.git
```

### Install

Install all necessary dependencies listed in the `Gemfile`.

```sh
bundle install
```

Install all necessary dependencies listed in the `package.json`.

```sh
npm install
```

### Database


```sh
sudo service postgresql start
```

Create database:

```sh
rails db:create
```

Run migrations:

```sh
rails db:migrate
```

Add the seeds:

```sh
rails db:seed
```

### Usage

To run the project, navigate to the project directory and execute the following command:

```sh
rails server
```

### Run tests

To execute all test suites in the application, use the following command in your terminal:

```sh
rspec
```

### Run linter

To run linter, run the following command:

```sh
rubocop

```
```sh
npx stylelint "**/*.{css,scss}"
```

### Deployment

Check my project:
[The Guardian Pocket](https://pocket-guardian-fec21289dfe6.herokuapp.com/)

### Video presentation

Check my video:
[Video presentation](https://www.loom.com/share/1cb735ebf6dc4c8abbf97b4d1b0e12db?sid=dfd22f65-7c8a-4fc7-ac8b-a308e7f8194f)

<p align="right">(<a href="#readme-top">back to top</a>)</p>


## 👥 Authors <a name="authors"></a>

👤 **Julio Quezada**

- GitHub: [Alejandroq12](https://github.com/Alejandroq12)
- Twitter: [@JulioAle54](https://twitter.com/JulioAle54)
- LinkedIn: [Julio Quezada](https://www.linkedin.com/in/quezadajulio/)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## 🔭 Future Features <a name="future-features"></a>

- [ ] **I will add the hamburger button.**
- [ ] **I will add cool statistics.**


<p align="right">(<a href="#readme-top">back to top</a>)</p>

## 🤝 Contributing <a name="contributing"></a>

Contributions, issues, and feature requests are welcome!

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- SUPPORT -->

## ⭐️ Show your support <a name="support"></a>

If you like this project please give a star.
Thanks in advance.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ACKNOWLEDGEMENTS -->

## 🙏 Acknowledgments <a name="acknowledgements"></a>

I would like to thank all of my colleagues who inspire to do my best everyday.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- FAQ (optional) -->

## ❓ FAQ <a name="faq"></a>

**What did you learn?**

During the development of this project, I have acquired knowledge in various areas, including the creation of data models, data validation, and testing. I have also learned about processing data, building controllers, controller specs, designing views, and correctly implementing forms. One of the most significant achievements for me was understanding routing. Initially, I struggled with understanding how routes function in Rails. However, it's now clear to me how routes operate and how they should be used. For example, if I want to create a new transaction, I now know how to use the route assigned to the POST method, which corresponds to the 'create' action in the specific controller.


<p align="right">(<a href="#readme-top">back to top</a>)</p>

## 📝 License <a name="license"></a>

This project is [MIT](./LICENSE) licensed.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## 📝 Project journal <a name="project-journal"></a>

This readme serves as the project journal in which I document the creation process of this project. This approach will help me learn faster, as humans sometimes forget details, and it will also enable other developers to understand the development process. [PROJECT_JOURNAL](./PROJECT_JOURNAL).

<p align="right">(<a href="#readme-top">back to top</a>)</p>
