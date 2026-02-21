# Red-stone

set -euo pipefail

---

## 1) Go to project folder (adjust if you're already there)

cd "Redstone"

---

## 2) Install Ruby (>= 3.1) and ensure it’s on PATH (macOS/Homebrew)

brew install ruby
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="$(ruby -e 'print Gem.bindir'):$PATH"
ruby -v

# If bundler isn't available:
gem install bundler

---

## 3) Install deps (incl dev deps for tests)

bundle config set --local path vendor/bundle >/dev/null 2>&1 || true
bundle install

---

## 4) Run tests

bundle exec rake test

---

## 5) Build + install the gem locally

bundle exec rake install

---

## 6) Choose how to run the CLI (from source vs installed)

# From source (works even if Bundler doesn’t treat exe/ as an “executable”):
CLI="bundle exec ruby exe/chronicle"
[ -f exe/chronicle ] || CLI="bundle exec ruby bin/chronicle"

# Or after install, you can also use:
# CLI="bundle exec chronicle"

---

## 7) Initialize your journal

$CLI init
# Creates: ~/.chronicle

---

## 8) Demo commands

$CLI add "Shipped v0.1.0" --kind release --tag ruby --tag cli
$CLI add "Today I fixed Ruby 4.0 ostruct/rdoc and ran the project successfully" --kind note --tag debug --tag setup

$CLI list --limit 20
$CLI search "shipped"

---

## 9) Export entries

$CLI export --format json  > export.json
$CLI export --format jsonl > export.jsonl
ls -1 export.json export.jsonl

---

## 10) Validate exports (optional but recommended)

$CLI export --format json  | ruby -rjson -e 'JSON.parse(STDIN.read); puts "json ok"'
$CLI export --format jsonl | ruby -rjson -e 'STDIN.each_line { |l| JSON.parse(l) }; puts "jsonl ok"'
