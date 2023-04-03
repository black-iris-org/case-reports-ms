# Case Report micro-service

## Installation

- ~~Refer to [flavorjones truffleruby](https://github.com/flavorjones/truffleruby/pkgs/container/truffleruby)~~ 
- ~~Install [graalvm](https://www.graalvm.org/downloads/)~~
- ~~Install truffleruby head version `rvm install truffleruby-head`~~
- Install rbenv
- `rbenv install 3.0.3` 
- Update RubyGems system `gem update --system --force-update`
- Run `bundle install`

#### Ruby version
It was `Truffleruby 23.0.0-dev-2f21e36a`, but we changed to `ruby 3.0.3` because Truffleruby was too slow for us! :(

#### Configuration
- Create your `.env` file
- Install docker
- Run `docker compose up -d`

#### Database creation
- rails `db:create`
