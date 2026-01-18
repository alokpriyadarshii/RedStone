# frozen_string_literal: true

require 'json'
require 'yaml'
require 'time'
require 'securerandom'
require 'fileutils'

require_relative 'chronicle/version'
require_relative 'chronicle/errors'
require_relative 'chronicle/util'
require_relative 'chronicle/entry'
require_relative 'chronicle/store'
require_relative 'chronicle/cli'

module Chronicle
  DEFAULT_DIR = File.expand_path('~/.chronicle').freeze
end
