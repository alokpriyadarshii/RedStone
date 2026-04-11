# RedStone

RedStone is a small Ruby project that packages a dependency light journaling library and CLI named `chronicle`.

It stores timestamped entries in monthly JSONL files, supports filtering and regex style search, and can export data as JSON or JSONL. The codebase is structured like a production ready Ruby gem, with tests, linting config, a Dockerfile, and a small command line interface.

## What it does

- Initializes a local journal directory
- Adds structured journal entries with:
  - `message`
  - `kind`
  - `tags`
  - free-form `meta` key/value pairs
- Lists recent entries
- Searches entries by message, tags, and metadata
- Exports entries as `json` or `jsonl`
- Stores data locally in plain files under a user-controlled directory

## Project naming

The repository is named **RedStone**, but the actual Ruby package and CLI are named **`chronicle`**:

- gem name: `chronicle`
- executable: `chronicle`
- main library namespace: `Chronicle`

## Tech stack

- Ruby 3.2+
- Minitest
- Rake
- RuboCop
- JSONL file storage
- No database required

## Project structure

```text
RedStone/
├── bin/chronicle            # CLI entry point
├── lib/chronicle/           # Core library code
├── test/                    # Test suite
├── chronicle.gemspec        # Gem packaging metadata
├── Gemfile                  # Development dependencies
├── Rakefile                 # Tasks for test/install
├── Dockerfile               # Containerized execution
├── export.json              # Sample export artifact
└── export.jsonl             # Sample export artifact
```

## Installation

### Option 1: Run from source

Clone the repository and install dependencies:

```bash
git clone https://github.com/alokpriyadarshii/RedStone.git
cd RedStone
gem install bundler
bundle install
```

Run the CLI from source:

```bash
bundle exec ruby bin/chronicle --help
```

### Option 2: Build and install the gem locally

```bash
gem install bundler
bundle install
gem build chronicle.gemspec
gem install --no-document ./chronicle-0.1.0.gem
```

Then use:

```bash
chronicle --help
```

## Quick start

Initialize a journal directory:

```bash
ruby bin/chronicle init --dir ./journal
```

Add entries:

```bash
ruby bin/chronicle add "Shipped v0.1.0" --dir ./journal --kind release --tag ruby --tag cli --meta env=dev
ruby bin/chronicle add "Investigate export bug" --dir ./journal --kind task --tag bug --meta priority=high
```

List entries:

```bash
ruby bin/chronicle list --dir ./journal --limit 10
```

Search entries:

```bash
ruby bin/chronicle search shipped --dir ./journal
ruby bin/chronicle search bug --dir ./journal --tag bug
```

Export data:

```bash
ruby bin/chronicle export --dir ./journal --format json
ruby bin/chronicle export --dir ./journal --format jsonl
```

## CLI commands

### `init`

Create the journal directory structure and write a YAML config.

```bash
chronicle init --dir ./journal --timezone UTC
```

### `add`

Create a new entry.

```bash
chronicle add "Daily standup complete" \
  --dir ./journal \
  --kind note \
  --tag work \
  --tag team \
  --meta status=done
```

### `list`

List recent entries, newest first.

```bash
chronicle list --dir ./journal --limit 20
chronicle list --dir ./journal --kind release
chronicle list --dir ./journal --tag work --json
```

### `search`

Search across entry messages, tags, and metadata. The implementation attempts to treat the query as a case-insensitive regular expression; if the regex is invalid, it falls back to a literal escaped search.

```bash
chronicle search release --dir ./journal
chronicle search "ship|release" --dir ./journal
chronicle search urgent --dir ./journal --kind task --tag ops
```

### `export`

Export journal data.

```bash
chronicle export --dir ./journal --format json
chronicle export --dir ./journal --format jsonl --limit 100
```

## Storage format

After initialization, the journal directory looks like this:

```text
journal/
├── config.yml
└── entries/
    └── YYYY-MM.jsonl
```

Each line in a monthly `jsonl` file is a single entry object like:

```json
{
  "id": "0ceaa84d-d903-44b5-86a7-1aee8f7986d1",
  "at": "2026-04-11T07:35:32Z",
  "kind": "release",
  "tags": ["cli", "ruby"],
  "message": "Shipped v0.1.0",
  "meta": {
    "env": "dev"
  }
}
```

## Development

Install dependencies:

```bash
bundle install
```

Run tests:

```bash
ruby -Ilib -e 'Dir["test/*_test.rb"].each { |f| require_relative f }'
```

Or with Rake/Bundler:

```bash
bundle exec rake test
```

Lint:

```bash
bundle exec rubocop
```

Build and install locally:

```bash
bundle exec rake install
```

## Docker

Build the image:

```bash
docker build -t redstone .
```

Run the CLI inside the container:

```bash
docker run --rm -it redstone --help
```

## Verified behavior

The current codebase was checked for the following:

- test suite passes
- gem builds successfully
- CLI commands `init`, `add`, `list`, `search`, and `export` run successfully from source

## Current limitations

- Search is linear over stored entries and is not indexed
- Entries are appended to local files; there is no remote sync
- Timezone is stored in config, but timestamps are written using UTC
- Gem metadata still contains placeholder author/contact/homepage values
- The project includes a runtime dependency on `ostruct` even though it is part of the standard library in modern Ruby distributions
