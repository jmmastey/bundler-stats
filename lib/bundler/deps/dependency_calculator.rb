module Bundler
  module Deps
    class DependencyCalculator
      attr_reader :parser, :tree

      def initialize(lock_path)
        raise ArgumentError unless File.readable?(lock_path)

        lock_contents = File.read(lock_path)
        @parser = Bundler::LockfileParser.new(lock_contents)
        @tree   = specs_as_tree(@parser.specs)
      end

      def total_dependencies
        @parser.dependencies.count
      end

      def nonspecific_dependencies
        nonspecific = @parser.dependencies.select { |dep| dep.requirement.specific? }
        nonspecific.count
      end

      private

      def specs_as_tree(specs)
        specs.each_with_object({}) do |spec, hash|
          hash[spec.name] = spec
        end
      end
    end
  end
end
