# frozen_string_literal: true

require 'optparse'
require 'ostruct'

module Chronicle
  class CLI
    def self.start(argv)
      new(argv).run
    rescue UserError => e
      warn "Error: #{e.message}"
      2
    rescue Interrupt
      warn 'Interrupted'
      130
    end

    def initialize(argv)
      @argv = argv.dup
    end

    def run
      cmd = @argv.shift
      case cmd
      when nil, '-h', '--help' then puts global_help
                                    0
      when '--version', '-v' then puts "chronicle #{Chronicle::VERSION}"
                                  0
      when 'init' then cmd_init(@argv)
      when 'add' then cmd_add(@argv)
      when 'list' then cmd_list(@argv)
      when 'search' then cmd_search(@argv)
      when 'export' then cmd_export(@argv)
      else
        raise UserError, "Unknown command '#{cmd}'. Run 'chronicle --help'."
      end
    end

    private

    def store_for(dir)
      Store.new(dir: dir || Chronicle::DEFAULT_DIR)
    end

    def global_help
      <<~TXT
        chronicle #{Chronicle::VERSION}

        Usage:
          chronicle <command> [options]

        Commands:
          init      Initialize a journal directory
          add       Add an entry
          list      List recent entries
          search    Search entries
          export    Export entries (json or jsonl)

        Global options:
          --dir PATH     Use a custom journal directory (default: ~/.chronicle)
          -h, --help     Show help
          -v, --version  Show version

        Run:
          chronicle <command> --help
      TXT
    end

    def parse_common!(_argv, opts)
      parser = OptionParser.new
      parser.on('--dir PATH', 'Journal directory') { |v| opts.dir = v }
      parser.on('-h', '--help', 'Show help') { opts.help = true }
      parser
    end

    def cmd_init(argv)
      opts = OpenStruct.new(dir: nil, timezone: 'UTC', help: false)
      parser = parse_common!(argv, opts)
      parser.banner = 'Usage: chronicle init [options]'
      parser.on('--timezone TZ', 'Timezone label stored in config (default: UTC)') { |v| opts.timezone = v }
      parser.parse!(argv)

      puts parser if opts.help
      return 0 if opts.help

      store_for(opts.dir).init!(timezone: opts.timezone)
      puts "Initialized journal at #{File.expand_path(opts.dir || Chronicle::DEFAULT_DIR)}"
      0
    end

    def cmd_add(argv)
      opts = OpenStruct.new(dir: nil, kind: 'note', tags: [], meta: [], help: false)
      parser = parse_common!(argv, opts)
      parser.banner = 'Usage: chronicle add MESSAGE [options]'
      parser.on('--kind KIND', 'Entry kind (default: note)') { |v| opts.kind = v }
      parser.on('--tag TAG', 'Tag (repeatable)') { |v| opts.tags << v }
      parser.on('--meta KEY=VALUE', 'Metadata (repeatable)') { |v| opts.meta << v }
      parser.parse!(argv)

      puts parser if opts.help
      return 0 if opts.help

      message = argv.join(' ').strip
      raise UserError, 'MESSAGE is required' if message.empty?

      entry = Entry.build(
        message: message,
        kind: opts.kind,
        tags: opts.tags,
        meta: Util.parse_kv_pairs(opts.meta)
      )

      store_for(opts.dir).add!(entry)
      puts Util.json_pretty(entry.to_h)
      0
    end

    def cmd_list(argv)
      opts = OpenStruct.new(dir: nil, limit: 50, kind: nil, tag: nil, help: false, json: false)
      parser = parse_common!(argv, opts)
      parser.banner = 'Usage: chronicle list [options]'
      parser.on('--limit N', Integer, 'Max entries (default: 50)') { |v| opts.limit = v }
      parser.on('--kind KIND', 'Filter by kind') { |v| opts.kind = v }
      parser.on('--tag TAG', 'Filter by tag') { |v| opts.tag = v }
      parser.on('--json', 'Output as JSON') { opts.json = true }
      parser.parse!(argv)

      puts parser if opts.help
      return 0 if opts.help

      entries = store_for(opts.dir).list(limit: opts.limit, kind: opts.kind, tag: opts.tag)
      if opts.json
        puts Util.json_pretty(entries.map(&:to_h))
      else
        puts format_entries(entries)
      end
      0
    end

    def cmd_search(argv)
      opts = OpenStruct.new(dir: nil, limit: 50, kind: nil, tag: nil, help: false, json: false)
      parser = parse_common!(argv, opts)
      parser.banner = 'Usage: chronicle search QUERY [options]'
      parser.on('--limit N', Integer, 'Max entries (default: 50)') { |v| opts.limit = v }
      parser.on('--kind KIND', 'Filter by kind') { |v| opts.kind = v }
      parser.on('--tag TAG', 'Filter by tag') { |v| opts.tag = v }
      parser.on('--json', 'Output as JSON') { opts.json = true }
      parser.parse!(argv)

      puts parser if opts.help
      return 0 if opts.help

      query = argv.join(' ').strip
      raise UserError, 'QUERY is required' if query.empty?

      entries = store_for(opts.dir).search(query, limit: opts.limit, kind: opts.kind, tag: opts.tag)
      if opts.json
        puts Util.json_pretty(entries.map(&:to_h))
      else
        puts format_entries(entries)
      end
      0
    end

    def cmd_export(argv)
      opts = OpenStruct.new(dir: nil, format: 'json', limit: nil, help: false)
      parser = parse_common!(argv, opts)
      parser.banner = 'Usage: chronicle export [options]'
      parser.on('--format FMT', 'json or jsonl (default: json)') { |v| opts.format = v }
      parser.on('--limit N', Integer, 'Limit entries') { |v| opts.limit = v }
      parser.parse!(argv)

      puts parser if opts.help
      return 0 if opts.help

      out = store_for(opts.dir).export(format: opts.format, limit: opts.limit)
      puts out
      0
    end

    def format_entries(entries)
      return '(no entries)' if entries.empty?

      entries.map do |e|
        tags = e.tags.empty? ? '' : " [#{e.tags.join(',')}]"
        "#{e.at} #{e.kind}#{tags} — #{e.message}"
      end.join("\n")
    end
  end
end
