FROM ruby:2.7

COPY main.rb /app/main.rb
COPY lib /app/lib
COPY Gemfile /app/Gemfile
WORKDIR /app

RUN bundle install

ENTRYPOINT ["ruby", "/app/main.rb"]
