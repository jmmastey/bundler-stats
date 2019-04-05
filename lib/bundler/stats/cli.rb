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

      # TODO: just install table_print, 'eh?
      def draw_stats(gem_stats, summary)
        max_name_length = gem_stats.map { |gem| gem[:name].length }.max

        say "+-#{"-" * max_name_length}-|-----------------|-----------------+"
        say "| %-#{max_name_length}s | Total Deps      | 1st Level Deps  |" % ["Name"]
        say "+-#{"-" * max_name_length}-|-----------------|-----------------+"

        gem_stats.each do |stat_line|
          say "| %-#{max_name_length}s | %-15s | %-15s |" % [stat_line[:name], stat_line[:total_dependencies], stat_line[:first_level_dependencies]]
        end
        say "+-#{"-" * max_name_length}-|-----------------|-----------------+"
        say ""
        say "Declared Gems:     #{summary[:declared]}"
        say "Total Gems:        #{summary[:total]}"
        say ""
        say "Unpinned Versions: #{summary[:unpinned]}"
        say "Github Refs:       #{summary[:github]}"
      end

      def draw_show(stats, target)
        say "bundle-stats for #{target}"
        say ""
        say "depended upon by (#{stats[:top_level_dependencies].count}) | #{stats[:top_level_dependencies].values.map(&:name).join(', ')}\n"
        say "depends on (#{stats[:transitive_dependencies].count})      | #{stats[:transitive_dependencies].map(&:name).join(', ')}\n"
        say "unique to this (#{stats[:potential_removals].count})   | #{stats[:potential_removals].map(&:name).join(', ')}\n"
        say ""
      end

      def draw_versions(stats, target)
        dependers = stats[:top_level_dependencies] # they do the depending
        say "bundle-stats for #{target}"
        say ""
        say "depended upon by (#{stats[:top_level_dependencies].count})\n"
        if dependers.count > 0
          max_name_length = dependers.map { |gem| gem[:name].length }.max

          say "+-#{"-" * max_name_length}-|-------------------+"
          say "| %-#{max_name_length}s | Required Version  |" % ["Name"]
          say "+-#{"-" * max_name_length}-|-------------------+"
          dependers.each do |stat_line|
            say "| %-#{max_name_length}s | %-17s |" % [stat_line[:name], stat_line[:version]]
          end
          say "+-#{"-" * max_name_length}-|-------------------+"
          say ""
        end
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
          return (cwd + "Gemfile") if File.exist?(cwd + "Gemfile")
          cwd = cwd.parent
        end
        raise ArgumentError, "Couldn't find Gemfile in this directory or parents"
      end

      def lockfile_path
        cwd = Pathname.new(".")
        until cwd.realdirpath.root? do
          return (cwd + "Gemfile.lock") if File.exist?(cwd + "Gemfile.lock")
          cwd = cwd.parent
        end
        raise ArgumentError, "Couldn't find Gemfile in this directory or parents"
      end
    end
  end
end
