module Bundler
  module Stats
    class Remover
      def initialize(tree, top_level)
        @tree       = tree
        @top_level  = top_level
      end

      def potential_removals(target)
        candidates = @tree.transitive_dependencies(target)
        candidates.reject do |candidate|
          still_used?(candidate.name, deleted: target)
        end
      end

      # TODO: woo naive algorithm
      # TODO: circular dependencies would be an issue here
      # TODO: also probably use something like transitive_dependencies
      # to leverage the abilities in tree...
      def still_used?(target, deleted: nil)
        modified_tree = @tree.tree.clone
        modified_tree.delete(deleted)

        deps_to_check = (@top_level - [Gem::Dependency.new(deleted)])

        while !deps_to_check.empty? do
          candidate = deps_to_check.pop.name

          next if [deleted, "bundler"].include? candidate
          return true if candidate == target
          next if modified_tree[candidate].nil?

          deps_to_check += modified_tree[candidate].dependencies
        end

        false
      end
    end
  end
end

