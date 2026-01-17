.PHONY: test lint install

test:
	bundle exec rake test

lint:
	bundle exec rubocop

install:
	bundle exec rake install
