 FROM ruby:3.1.2
 RUN apt-get update && apt-get install -y nodejs
 WORKDIR /app
 COPY Gemfile* ./
 RUN bundle install
 COPY . ./
 EXPOSE 3000
 ENTRYPOINT ["./docker-entrypoint.sh"]