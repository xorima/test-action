FROM ruby:2.7

COPY . /app
WORKDIR /app

RUN bundle install

ENTRYPOINT ["ruby", "/app/main.rb"]
