require 'bundler'

module Bundler
  module Stats
    class Calculator
      attr_reader :parser, :tree, :gemfile

      def initialize(gemfile_path, lockfile_path)
        raise ArgumentError unless File.readable?(lockfile_path)
        raise ArgumentError unless File.readable?(gemfile_path)

        @gemfile = Bundler::Dsl.new.eval_gemfile(gemfile_path)
        lock_contents = File.read(lockfile_path)
        @parser = Bundler::LockfileParser.new(lock_contents)
        @tree = Bundler::Stats::Tree.new(@parser)
      end

      def stats
        { summary: {},
          gems: gem_stats
        }
      end
      alias_method :to_h, :stats

      def gem_stats
        @gemfile.each_with_object({}) do |gem, result|
          result[gem.name] = @tree.summarize(gem.name)
        end
      end
    end
  end
end
