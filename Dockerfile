FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ruby-full \
    build-essential \
    zlib1g-dev && \ 
    rm -rf /var/lib/apt/lists/*

# Add a non-root user
RUN useradd -m jekyll

# Set up Ruby environment
ENV GEM_HOME="/usr/local/bundle"
ENV PATH="$GEM_HOME/bin:$PATH"

# Ensure GEM_HOME is owned by the non-root user
RUN mkdir -p "$GEM_HOME" && chown -R jekyll "$GEM_HOME"

# Set working directory (safe temp for bundler install)
WORKDIR /tmp/jekyll

# Copy Gemfile and Gemfile.lock only
COPY --chown=jekyll:jekyll Gemfile Gemfile.lock ./

# Switch to non-root user before installing gems
USER jekyll

# Install Jekyll and Bundler
RUN gem install \
    bundler && \
    bundle install

# Create and set working directory
WORKDIR "/srv/jekyll"

# Required to resolve "Invalid US-ASCII character" error
ENV LANG C.UTF-8

# Default command (can be overridden)
CMD ["bundle", "exec", "jekyll", "serve", "--host=0.0.0.0"]