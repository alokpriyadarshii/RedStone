# frozen_string_literal: true

require_relative "test_helper"
require "open3"

class ChronicleCliTest < Minitest::Test
  def test_cli_init_add_list
    Dir.mktmpdir do |dir|
      exe = File.expand_path("../bin/chronicle", __dir__)

      out, err, status = Open3.capture3(exe, "init", "--dir", dir)
      assert status.success?, err
      assert_includes out, "Initialized"

      out, err, status = Open3.capture3(exe, "add", "Hello world", "--dir", dir, "--kind", "note", "--tag", "ruby")
      assert status.success?, err
      assert_includes out, "\"message\": \"Hello world\""

      out, err, status = Open3.capture3(exe, "list", "--dir", dir, "--limit", "1")
      assert status.success?, err
      assert_includes out, "Hello world"
    end
  end

  def test_cli_unknown_command
    exe = File.expand_path("../bin/chronicle", __dir__)
    _out, _err, status = Open3.capture3(exe, "nope")
    refute status.success?
  end
end
