# frozen_string_literal: true

module Chronicle
  class Entry
    REQUIRED_KEYS = %w[id at kind tags message meta].freeze

    attr_reader :id, :at, :kind, :tags, :message, :meta

    def initialize(id:, at:, kind:, tags:, message:, meta:)
      @id = String(id)
      @at = String(at)
      @kind = String(kind)
      @tags = Util.normalize_tags(tags)
      @message = String(message)
      @meta = meta || {}
      validate!
    end

    def self.build(message:, kind: 'note', tags: [], meta: {})
      new(
        id: SecureRandom.uuid,
        at: Util.iso8601_now,
        kind: kind,
        tags: tags,
        message: message,
        meta: meta
      )
    end

    def to_h
      {
        'id' => id,
        'at' => at,
        'kind' => kind,
        'tags' => tags,
        'message' => message,
        'meta' => meta
      }
    end

    def to_json_line
      "#{JSON.generate(to_h)}\n"
    end

    def self.from_hash(h)
      missing = REQUIRED_KEYS.reject { |k| h.key?(k) }
      raise StoreError, "Entry missing keys: #{missing.join(', ')}" unless missing.empty?

      new(
        id: h.fetch('id'),
        at: h.fetch('at'),
        kind: h.fetch('kind'),
        tags: h.fetch('tags'),
        message: h.fetch('message'),
        meta: h.fetch('meta')
      )
    end

    def self.from_json_line(line)
      from_hash(JSON.parse(line))
    rescue JSON::ParserError => e
      raise StoreError, "Invalid JSONL line: #{e.message}"
    end

    private

    def validate!
      Time.iso8601(at) # validates
      raise UserError, 'kind cannot be empty' if kind.strip.empty?
      raise UserError, 'message cannot be empty' if message.strip.empty?
      raise UserError, 'meta must be a Hash' unless meta.is_a?(Hash)

      true
    rescue ArgumentError => e
      raise UserError, "invalid timestamp: #{e.message}"
    end
  end
end
