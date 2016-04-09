module Bundler
  module Deps
    class DependencyCalculator
      attr_reader :parser, :tree

      def initialize(lock_path)
        raise ArgumentError unless File.readable?(lock_path)

        lock_contents = File.read(lock_path)
        @parser = Bundler::LockfileParser.new(lock_contents)
      end

      def total_dependencies
        @parser.dependencies.count
      end

      def nonspecific_dependencies
        nonspecific = @parser.dependencies.select { |dep| dep.requirement.specific? }
        nonspecific.count
      end
    end
  end
end
