require 'bundler'

module Bundler
  module Stats
    class Calculator
      attr_reader :parser, :tree, :gemfile

      def initialize(gemfile_path, lockfile_path, options = {})
        raise ArgumentError unless File.readable?(lockfile_path)
        raise ArgumentError unless File.readable?(gemfile_path)

        @gemfile = Bundler::Dsl.new.eval_gemfile(gemfile_path)

        lock_contents = File.read(lockfile_path)
        @parser = Bundler::LockfileParser.new(lock_contents)

        skiplist = options.fetch(:skiplist, [])
        @tree = Bundler::Stats::Tree.new(@parser, skiplist: skiplist)
      end

      def single_stat(target)
        @tree.summarize(target).merge({
          all_deps: @tree.transitive_dependencies(target)
        })
      end

      def stats
        { summary: summary,
          gems: gem_stats
        }
      end
      alias_method :to_h, :stats

      def summary
        { total_gems: @gemfile.count,
          unpinned_gems: unpinned_gems.count,
        }
      end

      def unpinned_gems
        @gemfile.reject { |dep| dep.specific? }
      end

      def gem_stats
        stats = @gemfile.map do |gem|
          @tree.summarize(gem.name)
        end
        stats.sort_by { |row| row[:total_dependencies] }
      end
    end
  end
end
