require 'bundler'

module Bundler
  module Stats
    class Calculator
      attr_reader :parser, :tree, :gemfile, :remover

      def initialize(gemfile_path, lockfile_path, options = {})
        raise ArgumentError unless File.readable?(lockfile_path)
        raise ArgumentError unless File.readable?(gemfile_path)

        @gemfile = Bundler::Dsl.new
        @gemfile.eval_gemfile(gemfile_path)
        @gemfile = @gemfile.dependencies
        raise ArgumentError, "Couldn't parse Gemfile at #{gemfile_path.realdirpath}" unless @gemfile

        lock_contents = File.read(lockfile_path)
        @parser = Bundler::LockfileParser.new(lock_contents)

        skiplist = options.fetch(:skiplist, [])
        @tree = Bundler::Stats::Tree.new(@parser, skiplist: skiplist)

        @remover = Bundler::Stats::Remover.new(@tree, @gemfile)
      end

      def summarize(target)
        @tree.summarize(target).merge({
          potential_removals: @remover.potential_removals(target)
        })
      end

      def versions(target)
        @tree.version_requirements(target).merge({
          potential_removals: @remover.potential_removals(target)
        })
      end

      def stats
        { summary: summary,
          gems: gem_stats
        }
      end
      alias_method :to_h, :stats

      def summary
        { declared: @gemfile.count,
          unpinned: unpinned_gems.count,
          total: @parser.specs.count,
          github: github_gems.count,
        }
      end

      def github_gems
        @gemfile.select do |dep|
          dep.source && dep.source.options.include?("github")
        end
      end

      def unpinned_gems
        @gemfile.reject { |dep| dep.specific? }
      end

      def gem_stats
        stats = @gemfile.map do |gem|
          @tree.summarize(gem.name)
        end
        stats.sort_by { |row| row[:total_dependencies] }.reverse
      end
    end
  end
end
