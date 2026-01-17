# frozen_string_literal: true

module Chronicle
  module Util
    module_function

    def iso8601_now
      Time.now.utc.iso8601
    end

    def ensure_dir(path)
      FileUtils.mkdir_p(path)
      path
    end

    def atomic_write(path, content)
      dir = File.dirname(path)
      ensure_dir(dir)
      tmp = File.join(dir, ".#{File.basename(path)}.tmp-#{SecureRandom.hex(8)}")
      File.write(tmp, content, mode: "wb")
      FileUtils.mv(tmp, path)
    ensure
      FileUtils.rm_f(tmp) if tmp && File.exist?(tmp)
    end

    def json_pretty(obj)
      JSON.pretty_generate(obj)
    end

    def normalize_tags(tags)
      Array(tags).flat_map { |t| t.to_s.split(",") }
                 .map(&:strip)
                 .reject(&:empty?)
                 .uniq
                 .sort
    end

    def parse_kv_pairs(pairs)
      return {} if pairs.nil? || pairs.empty?

      pairs.each_with_object({}) do |pair, acc|
        k, v = pair.split("=", 2)
        raise UserError, "Invalid meta '#{pair}'. Use key=value." if k.nil? || k.empty? || v.nil?
        acc[k] = v
      end
    end
  end
end
