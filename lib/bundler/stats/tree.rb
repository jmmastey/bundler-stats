class Bundler::Stats::Tree
  def initialize(parser)
    raise ArgumentError unless parser.is_a? Bundler::LockfileParser

    @parser = parser
    @tree   = specs_as_tree(@parser.specs)
  end

  def summarize(target)
    { total_dependencies: transitive_dependencies(target).count,
      first_level_dependencies: first_level_dependencies(target).count
    }
  end

  def first_level_dependencies(target)
    raise ArgumentError, "Unknown gem #{target}" unless @tree.has_key? target
    @tree[target].dependencies
  end

  def transitive_dependencies(target)
    raise ArgumentError, "Unknown gem #{target}" unless @tree.has_key? target

    top_level = @tree[target].dependencies
    top_level + top_level.inject([]) do |arr, dep|
      # turns out bundler refuses to include itself in the dependency tree,
      # which is sneaky
      next arr if dep.name == "bundler"

      arr += transitive_dependencies(dep.name)
    end.uniq
  end

  private

  def specs_as_tree(specs)
    specs.each_with_object({}) do |spec, hash|
      hash[spec.name] = spec
    end
  end
end
