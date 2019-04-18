class Bundler::Stats::Remover
  ERR_MESSAGE = "Trying to check whether dep can be removed, but was unable " \
    "to resolve whether it is used by `%s`. It may not be in your Gemfile.lock. " \
    "This often happens when a dependency isn't installed on your platform."

  def initialize(tree, top_level)
    @tree           = tree
    @top_level      = top_level
    @trace_warnings = []
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

      next if candidate == deleted
      next if candidate == "bundler"
      return true if candidate == target

      if modified_tree[candidate].nil?
        warn_of_bad_tracing(candidate)
      else
        deps_to_check += modified_tree[candidate].dependencies
      end
    end

    false
  end

  private

  def warn_of_bad_tracing(candidate)
    return if @trace_warnings.include? candidate

    STDERR.puts(ERR_MESSAGE % [candidate])
    @trace_warnings << candidate
  end
end
