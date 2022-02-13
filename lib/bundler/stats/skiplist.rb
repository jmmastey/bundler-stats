class Bundler::Stats::Skiplist
  attr_reader :regex_list

  def initialize(list = '')
    @regex_list = if list.respond_to?(:regex_list)
      list.regex_list
    elsif list.respond_to?(:split)
      list
        .gsub(/\s+/, '')
        .split(",")
        .map { |str| glob_to_regex(str) }
    else
      (list || []).map { |str| glob_to_regex(str) }
    end
  end

  def filter(gem_list)
    gem_list.reject { |gem| self.include?(gem) }
  end

  def include?(target)
    @regex_list.any? { |pattern| pattern =~ target.name }
  end

  private

  def glob_to_regex(str)
    str.gsub!('*','.*') # weird globbish behavior

    /^#{str}$/
  end
end
