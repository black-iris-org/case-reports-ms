# Case Report micro-service

## Installation

- Refer to [flavorjones truffleruby](https://github.com/flavorjones/truffleruby/pkgs/container/truffleruby) 
- Install [graalvm](https://www.graalvm.org/downloads/)
 
### Instructions For Mac:
- Install truffleruby head version `rvm install truffleruby-head`
- Update RubyGems system `gem update --system --force-update`
- Run `bundle install`

#### Ruby version
Truffleruby 23.0.0-dev-2f21e36a

#### Configuration
- Create your `.env` file
- Install docker
- Run `docker compose up -d`

#### Database creation
- rails `db:create`
