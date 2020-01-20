FROM ruby:2.5

COPY . /app
WORKDIR /app

RUN bundle install
RUN ls
RUN ls /app

ENTRYPOINT ["ruby", "main.rb"]
