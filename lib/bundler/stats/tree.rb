class Bundler::Stats::Tree
  def initialize(parser)
    raise ArgumentError unless parser.is_a? Bundler::LockfileParser

    @parser = parser
    @tree   = specs_as_tree(@parser.specs)
  end

  def transitive_dependencies(target)
    raise ArgumentError unless @tree.has_key? target

    top_level = @tree[target].dependencies
    top_level + top_level.inject([]) do |arr, dep|
      arr += transitive_dependencies(dep.name)
    end
  end

  private

  def specs_as_tree(specs)
    specs.each_with_object({}) do |spec, hash|
      hash[spec.name] = spec
    end
  end
end
