FROM ruby:2.5.0-slim

MAINTAINER Leikir Web "web@leikir.io"

ENV INSTALL_PATH /app
ENV RAILS_ENV production
ENV RACK_ENV production

# Install apt based dependencies required to run Rails as
# well as RubyGems. As the Ruby image itself is based on a
# Debian image, we use apt-get to install those.
RUN apt-get update \
  && apt-get install -qq -y --no-install-recommends \
    build-essential \
  \
  # We need bundler
  && gem install bundler --no-ri --no-rdoc \
  \
  && mkdir -p $INSTALL_PATH

# Configure the main working directory. This is the base
# directory used in any further RUN, COPY, and ENTRYPOINT
# commands.
WORKDIR $INSTALL_PATH

# Copy the Gemfile as well as the Gemfile.lock and install
# the RubyGems. This is a separate step so the dependencies
# will be cached unless changes to one of those two files
# are made.
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the main application.
COPY . .

# Expose port 4000 to the Docker host, so we can access it
# from the outside.
EXPOSE 3000

# The main command to run when the container starts. Also
# tell the Rails dev server to bind to all interfaces by
# default.
CMD rm -rf tmp \
  && bundle exec rails server -p 3000 -b 0.0.0.0 \
