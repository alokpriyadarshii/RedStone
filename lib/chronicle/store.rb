# frozen_string_literal: true

module Chronicle
  class Store
    CONFIG_FILE = "config.yml"

    attr_reader :dir

    def initialize(dir: Chronicle::DEFAULT_DIR)
      @dir = File.expand_path(dir)
    end

    def init!(timezone: "UTC")
      Util.ensure_dir(entries_dir)
      write_config!("timezone" => timezone)
      true
    end

    def add!(entry)
      ensure_initialized!
      path = entries_path_for(entry.at)
      Util.ensure_dir(File.dirname(path))
      File.open(path, "ab") do |f|
        f.write(entry.to_json_line)
        f.flush
        f.fsync rescue nil
      end
      entry
    end

    def list(limit: 50, kind: nil, tag: nil)
      ensure_initialized!
      limit = normalize_limit(limit)
      enum_entries
        .lazy
        .select { |e| kind.nil? || e.kind == kind }
        .select { |e| tag.nil? || e.tags.include?(tag) }
        .then { |enum| limit ? enum.take(limit) : enum }
        .to_a
    end

    def search(query, limit: 50, kind: nil, tag: nil)
      ensure_initialized!
      q = query.to_s.strip
      raise UserError, "query cannot be empty" if q.empty?
      rx = begin
        Regexp.new(q, Regexp::IGNORECASE)
      rescue RegexpError
        Regexp.new(Regexp.escape(q), Regexp::IGNORECASE)
      end
      limit = normalize_limit(limit)
      
      enum_entries
        .lazy
        .select { |e| kind.nil? || e.kind == kind }
        .select { |e| tag.nil? || e.tags.include?(tag) }
        .select { |e| e.message.match?(rx) || e.tags.any? { |t| t.match?(rx) } || e.meta.any? { |k, v| k.to_s.match?(rx) || v.to_s.match?(rx) } }
        .then { |enum| limit ? enum.take(limit) : enum }
        .to_a
    end

    def export(format: :json, limit: nil)
      ensure_initialized!
      limit = normalize_limit(limit)
      entries = enum_entries
      entries = entries.take(limit) if limit

      fmt = format.to_s.downcase
      case fmt
      when "json"
        JSON.generate(entries.map(&:to_h))
      when :jsonl
        entries.map(&:to_json_line).join
      else
        raise UserError, "Unknown export format '#{format}'. Use json or jsonl."
      end
    end

    def config
      @config ||= begin
        path = File.join(dir, CONFIG_FILE)
        YAML.safe_load(File.read(path), permitted_classes: [Time], aliases: false) || {}
      rescue Errno::ENOENT
        raise ConfigError, "Missing config. Run 'chronicle init'."
      end
    end

    private

    def entries_dir
      File.join(dir, "entries")
    end

    def ensure_initialized!
      config # loads or raises
      Util.ensure_dir(entries_dir)
    end

    def write_config!(hash)
      path = File.join(dir, CONFIG_FILE)
      Util.atomic_write(path, hash.to_yaml)
    end

    def entries_path_for(iso8601_at)
      t = Time.iso8601(iso8601_at).utc
      File.join(entries_dir, t.strftime("%Y-%m") + ".jsonl")
    end

    def enum_entries
      # newest first: iterate files in reverse chronological order
      files = Dir[File.join(entries_dir, "*.jsonl")].sort.reverse

      Enumerator.new do |y|
        files.each do |file|
          # read file lines newest first without loading all entries
          # (for typical small files, this is fine; for huge files you'd implement a reverse reader)
          lines = File.readlines(file, chomp: true)
          lines.reverse_each do |line|
            next if line.strip.empty?
            y << Entry.from_json_line(line)
          end
        end
      end
    rescue Errno::ENOENT
      [].to_enum
    end
    
    def normalize_limit(limit)
      return nil if limit.nil?
      limit = Integer(limit)
      raise UserError, "limit must be a positive integer" if limit <= 0
      limit
    rescue ArgumentError, TypeError
      raise UserError, "limit must be a positive integer"
    end
  end
end
