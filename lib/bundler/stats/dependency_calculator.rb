module Bundler
  module Stats
    class DependencyCalculator
      attr_reader :parser, :tree

      def initialize(lock_path)
        raise ArgumentError unless File.readable?(lock_path)

        lock_contents = File.read(lock_path)
        @parser = Bundler::LockfileParser.new(lock_contents)
        @tree = Bundler::Stats::Tree.new(@parser)
      end
    end
  end
end
