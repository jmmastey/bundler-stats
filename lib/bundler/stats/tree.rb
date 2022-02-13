class Bundler::Stats::Tree
  attr_accessor :tree, :skiplist

  ERR_MESSAGE = "The dependency `%s` wasn't found. It may not be present in " \
                "your Gemfile.lock. This often happens when a dependency isn't " \
                "installed on your platform."

  def initialize(parser, skiplist: '')
    raise ArgumentError unless parser.respond_to?(:specs)

    @parser   = parser
    @tree     = specs_as_tree(@parser.specs)
    @skiplist = Bundler::Stats::Skiplist.new(skiplist)
  end

  def summarize(target)
    transitive_dependencies = transitive_dependencies(target)

    { name: target,
      total_dependencies: transitive_dependencies.count,
      first_level_dependencies: first_level_dependencies(target).count,
      top_level_dependencies: reverse_dependencies(target),
      transitive_dependencies: transitive_dependencies,
    }
  end

  def version_requirements(target)
    transitive_dependencies = transitive_dependencies(target)
    resolved_version = @tree[target].version if @tree.has_key?(target)

    { name: target,
      resolved_version: resolved_version,
      total_dependencies: transitive_dependencies.count,
      first_level_dependencies: first_level_dependencies(target).count,
      top_level_dependencies: reverse_dependencies_with_versions(target),
      transitive_dependencies: transitive_dependencies,
    }
  end

  def first_level_dependencies(target)
    unless @tree.has_key? target
      warn(ERR_MESSAGE % [target])
      return []
    end

    @tree[target].dependencies
  end

  def transitive_dependencies(target)
    unless @tree.has_key? target
      warn(ERR_MESSAGE % [target])
      return []
    end

    top_level = skiplist.filter(@tree[target].dependencies)
    all_level = top_level + top_level.inject([]) do |arr, dep|
      # turns out bundler refuses to include itself in the dependency tree,
      # which is sneaky
      next arr if dep.name == "bundler"
      next arr if skiplist.include? dep

      arr += transitive_dependencies(dep.name)
    end

    all_level.uniq { |d| d.name }
  end

  # TODO: this is a very stupid way to walk this tree
  def reverse_dependencies(target)
    @tree.select do |name, dep|
      all_deps = transitive_dependencies(name)
      all_deps.any? { |dep| dep.name == target }
    end
  end

  def reverse_dependencies_with_versions(target)
    @tree.map do |name, dep|
      transitive_dependencies(name).map do |transitive_dependency|
        if transitive_dependency.name == target
          {
            name: dep.name,
            version: transitive_dependency.requirement.to_s,
            requirement: transitive_dependency.requirement
          }
        else
          nil
        end
      end
    end.flatten.compact.sort do |a,b|
      a[:requirement].as_list <=> b[:requirement].as_list
    end
  end

  private

  def warn(str)
    STDERR.puts(str)
  end

  def specs_as_tree(specs)
    specs.each_with_object({}) do |spec, hash|
      hash[spec.name] = spec
    end
  end
end
