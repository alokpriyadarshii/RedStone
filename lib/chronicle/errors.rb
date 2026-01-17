# frozen_string_literal: true

module Chronicle
  class Error < StandardError; end
  class UserError < Error; end
  class ConfigError < Error; end
  class StoreError < Error; end
end
