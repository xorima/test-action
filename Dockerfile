FROM ruby:2.7

COPY main.rb /app/main.rb
COPY lib /app/lib
WORKDIR /app

RUN bundle install

ENTRYPOINT ["ruby", "/app/main.rb"]
