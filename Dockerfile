FROM ruby:2.5

COPY . /app
WORKDIR /app

RUN bundle install

ENTRYPOINT ["ruby", "main.rb"]
