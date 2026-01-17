# Contributing

## Development setup

1. Install Ruby (see `.ruby-version`).
2. Install bundler:
   ```bash
   gem install bundler
   ```
3. Install dependencies:
   ```bash
   bundle install
   ```
4. Run tests:
   ```bash
   bundle exec rake
   ```

## Style

- Prefer clear, small objects.
- Keep public APIs stable; add tests for behavior.
- Run `bundle exec rubocop` before submitting.
