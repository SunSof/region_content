
# Региональный контент

Проект представляет собой сервис для написания и управления постами пользователей с привязкой к регионам России. В приложении реализованы следующие функции:
Посты и их состояния
Роли пользователей: обычные пользователи и администраторы
Регистрация и аутентификация
Фильтрация и поиск постов
Возможность формировать отчет в виде xlsx 

## Requirements

- Ruby version 3.1.2
- Rails version 7.1.3
- PostgreSQL 

## Installation

1. Clone the repository: [`git clone ttps://github.com/SunSof/region_content.git`]
2. Install dependencies: `bundle install`
3. Setup database: `rails db:create` `rails db:migrate` `rails db:seed`

## Running

Start the Rails server: `bin/dev`

## Testing

Run tests with RSpec: `rspec spec`
