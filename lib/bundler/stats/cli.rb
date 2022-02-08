require 'json'
require 'thor'
require 'bundler'

require 'bundler/stats'

module Bundler
  module Stats
    class CLI < ::Thor
      default_task :stats
      map '--version' => :version, "-v" => :version

      desc 'stats', 'Displays basic stats about the gems in your Gemfile'
      method_option :format, aliases: "-f", description: "Output format, either JSON or text"
      method_option :nofollow, description: "A comma delimited list of dependencies not to follow."
      def stats
        calculator = build_calculator(options)
        stats = calculator.stats

        if options[:format] =~ /json/i
          say JSON.pretty_generate(stats)
        else
          draw_stats(stats[:gems], stats[:summary])
        end
      end

      desc 'show TARGET', 'Prints the dependency tree for a single gem in your Gemfile'
      method_option :format, aliases: "-f", description: "Output format, either JSON or text"
      method_option :nofollow, description: "A comma delimited list of dependencies not to follow."
      def show(target)
        calculator = build_calculator(options)
        stats = calculator.summarize(target)

        if options[:format] =~ /json/i
          say JSON.pretty_generate(stats)
        else
          draw_show(stats, target)
        end
      end

      desc 'versions TARGET', 'Shows versions requirements for target in other dependencies'
      method_option :format, aliases: "-f", description: "Output format, either JSON or text"
      method_option :nofollow, description: "A comma delimited list of dependencies not to follow."
      def versions(target)
        calculator = build_calculator(options)
        stats = calculator.versions(target)

        if options[:format] =~ /json/i
          say JSON.pretty_generate(stats)
        else
          draw_versions(stats, target)
        end
      end

      desc 'version', 'Prints the bundler-stats version'
      def version
        say "bundler-stats #{VERSION}"
      end

      private

      def draw_stats(gem_stats, summary)
        max_name_length = gem_stats.map { |gem| gem[:name].length }.max

        say Printer.new(
          headers: ["Name", "Total Deps", "1st Level Deps"],
          data: gem_stats.map { |stat_line|
            [stat_line[:name], stat_line[:total_dependencies], stat_line[:first_level_dependencies]]
        }).to_s

        say Printer.new(
          headers: nil,
          borders: false,
          data: [
            ["Declared Gems",      summary[:declared]],
            ["Total Gems",         summary[:total]],
            ["", ""],
            ["Unpinned Versions",  summary[:unpinned]],
            ["Github Refs",        summary[:github]],
        ]).to_s
        say ""
      end

      def draw_show(stats, target)
        say "bundle-stats for #{target}"
        say ""

        say Printer.new(
          data: [
            ["Depended Upon By (#{stats[:top_level_dependencies].count})",  stats[:top_level_dependencies].values.map(&:name)],
            ["Depends On (#{stats[:transitive_dependencies].count})",       stats[:transitive_dependencies].map(&:name)],
            ["Unique to This (#{stats[:potential_removals].count})",        stats[:potential_removals].map(&:name)],
        ]).to_s
      end

      def draw_versions(stats, target)
        dependers = stats[:top_level_dependencies] # they do the depending
        say "bundle-stats for #{target}"
        say Printer.new(
          headers: nil,
          borders: false,
          data: [
            ["Depended Upon By", stats[:top_level_dependencies].count],
            ["Resolved Version", stats[:resolved_version]],
        ]).to_s

        if dependers.count > 0
          say ""
          say Printer.new(
            headers: ["Name", "Required Version"],
            data: dependers.map { |stat_line|
              [stat_line[:name], stat_line[:version]]
          }).to_s
        end

        say ""
      end

      def build_calculator(options)
        if !options[:nofollow].nil?
          skiplist = options[:nofollow].gsub(/\s+/, '').split(",")
        else
          skiplist = []
        end

        @calculator ||= Bundler::Stats::Calculator.new(gemfile_path, lockfile_path, skiplist: skiplist)
      end

      def gemfile_path
        cwd = Pathname.new("./")
        until cwd.realdirpath.root? do
          %w(gems.rb Gemfile).each do |gemfile|
            return (cwd + gemfile) if File.exist?(cwd + gemfile)
          end
          cwd = cwd.parent
        end
        raise ArgumentError, "Couldn't find gems.rb nor Gemfile in this directory or parents"
      end

      def lockfile_path
        cwd = Pathname.new(".")
        until cwd.realdirpath.root? do
          %w(gems.locked Gemfile.lock).each do |lockfile|
            return (cwd + lockfile) if File.exist?(cwd + lockfile)
          end
          cwd = cwd.parent
        end
        raise ArgumentError, "Couldn't find gems.locked nor Gemfile.lock in this directory or parents"
      end
    end
  end
end
