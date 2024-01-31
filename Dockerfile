FROM ruby:3.1.3-slim

RUN apt update && apt upgrade -y

RUN apt install -y \
    build-essential \
    libpq-dev \
    postgresql-client \
    nodejs

WORKDIR /src

COPY Gemfile* /

RUN bundle install

COPY . .

CMD ["bin/plumber", "run"]