# frozen_string_literal: true

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb']
  t.warning = true
end

desc 'Run tests'
task default: :test

desc 'Install the gem locally'
task :install do
  sh 'gem build chronicle.gemspec'
  gem_file = Dir['chronicle-*.gem'].max_by { |f| File.mtime(f) }
  sh "gem install --no-document #{gem_file}"
end
