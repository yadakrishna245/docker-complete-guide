# Ruby on Rails Production Dockerfile
# With Puma, asset precompilation, and PostgreSQL support

FROM ruby:3.3-slim AS base
WORKDIR /app
ENV RAILS_ENV=production BUNDLE_WITHOUT="development:test"
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    libpq-dev curl && rm -rf /var/lib/apt/lists/*

# Stage 1: Gems
FROM base AS gems
RUN apt-get update -qq && apt-get install -y --no-install-recommends build-essential
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3

# Stage 2: Assets
FROM base AS assets
COPY --from=gems /usr/local/bundle /usr/local/bundle
COPY . .
RUN SECRET_KEY_BASE=placeholder rails assets:precompile

# Stage 3: Production
FROM base
COPY --from=gems /usr/local/bundle /usr/local/bundle
COPY --from=assets /app/public/assets public/assets
COPY . .
RUN useradd -m rails && chown -R rails:rails /app
USER rails
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s CMD curl -f http://localhost:3000/up || exit 1
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
