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
      def stats
        stats = calculator.stats

        if options[:format] =~ /json/i
          say JSON.pretty_generate(stats)
        else
          draw_stats(stats[:gems], stats[:summary])
        end
      end

      desc 'show TARGET', 'Prints the dependency tree for a single gem in your Gemfile'
      method_option :format, aliases: "-f", description: "Output format, either JSON or text"
      def show(target)
        stats = calculator.single_stat(target)
        if options[:format] =~ /json/i
          say JSON.pretty_generate(stats)
        else
          draw_show(stats, target)
        end
      end

      desc 'version', 'Prints the bundler-stats version'
      def version
        say "bundler-stats #{VERSION}"
      end

      private

      def draw_stats(gem_stats, summary)
        say "+------------------------------|-----------------|-----------------+"
        say "| Name                         | Total Deps      | 1st Level Deps  |"
        say "+------------------------------|-----------------|-----------------+"
        gem_stats.each do |stat_line|
          say "| %-28s | %-15s | %-15s |" % [stat_line[:name], stat_line[:total_dependencies], stat_line[:first_level_dependencies]]
        end
        say "+------------------------------|-----------------|-----------------+"
        say ""
        say "Declared Gems: %s, %s unpinned" % summary.values
        say ""
      end

      def draw_show(stats, target)
        say "bundle-stats for #{target}"
        say ""
        say "depended upon by (#{stats[:top_level_dependencies].count}) | #{stats[:top_level_dependencies].values.map(&:name).join(', ')}"
        say "depends on (#{stats[:all_deps].count})      | #{stats[:all_deps].map(&:name).join(', ')}"
        say ""
      end

      def calculator
        @calculator ||= Bundler::Stats::Calculator.new(gemfile_path, lockfile_path)
      end

      # TODO walk upward
      def gemfile_path
        "./Gemfile"
      end

      # TODO walk upward
      def lockfile_path
        "./Gemfile.lock"
      end
    end
  end
end
