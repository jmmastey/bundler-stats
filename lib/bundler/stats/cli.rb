require 'thor'
require 'bundler'

require 'bundler/stats'

module Bundler
  module Stats
    class CLI < ::Thor

      default_task :stats
      map '--version' => :version, "-v" => :version


      desc 'stats', 'Displays basic stats about the gems in your Gemfile'
      def stats
        gemfile_path = "./Gemfile"
        lockfile_path = "./Gemfile.lock"


        calculator = Bundler::Stats::Calculator.new(gemfile_path, lockfile_path)
        stats       = calculator.stats
        write_header
        stats[:gems].each do |name, stat_line|
          write_row([name, stat_line[:total_dependencies], stat_line[:first_level_dependencies]])
        end
        write_separator
        say
      end

      desc 'version', 'Prints the bundler-stats version'
      def version
        say "bundler-stats #{VERSION}"
      end

      private

      def write_header
        write_separator
        say "| Name                         | Total Deps      | 1st Level Deps  |"
        write_separator
      end

      def write_separator
        say "+------------------------------|-----------------|-----------------+"
      end

      def write_row(data)
        say "| %-28s | %-15s | %-15s |" % data
      end
    end
  end
end
