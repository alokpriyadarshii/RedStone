# frozen_string_literal: true
require_relative "test_helper"

class ChronicleUtilTest < Minitest::Test
  def test_parse_kv_pairs_strips_whitespace
    meta = Chronicle::Util.parse_kv_pairs([" key = value "])
    assert_equal({ "key" => "value" }, meta)
  end
end
