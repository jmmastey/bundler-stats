require 'bundler'
require 'bundler/stats'

LazyLazySpec = Struct.new(:name, :dependencies)
FakeLockfileParser = Struct.new(:specs)

describe Bundler::Stats::Remover do
  subject { described_class }

  def dep(name)
    Gem::Dependency.new(name)
  end

  let(:full_tree) do
    { "rails"       => LazyLazySpec.new("rails", [ dep("actionpack"), dep("rack") ]),
      "sass-rails"  => LazyLazySpec.new("sass-rails", [ dep("rails"), dep("rack") ]),
      "actionpack"  => LazyLazySpec.new("actionpack", [ dep("actionview") ]),
      "actionview"  => LazyLazySpec.new("actionview", []),
      "rack"        => LazyLazySpec.new("rack", [dep("rack-test")]),
      "rack-test"   => LazyLazySpec.new("rack-test", []),
    }
  end
  let(:tree) { Bundler::Stats::Tree.new(FakeLockfileParser.new(full_tree.values)) }

  let(:top_level) do
    [ dep("rails"), dep("sass-rails") ]
  end

  context "#potential_removals" do
    it "returns an empty array if this dependency has no children deps" do
      remover = subject.new(tree, top_level)

      target = remover.potential_removals("rack-test")

      expect(target).to eq([])
    end

    it "doesn't return any child dependencies that are also top level dependencies themselves" do
      remover = subject.new(tree, top_level)

      target = remover.potential_removals("sass-rails")

      expect(target).not_to include(dep("rails"))
    end

    it "returns only the direct dependencies that aren't used by any other dep" do
      remover = subject.new(tree, top_level)

      target = remover.potential_removals("rails")

      expect(target).to include(dep("actionpack"))
      expect(target).not_to include(dep("rack"))
    end

    it "returns only the indirect dependencies that aren't used by any other dep" do
      remover = subject.new(tree, top_level)

      target = remover.potential_removals("rails")

      expect(target).to include(dep("actionview"))
      expect(target).not_to include(dep("rack-test"))
    end
  end

  context "#still_used?" do
    it "returns false if the candidate isn't even in the tree" do
      remover = subject.new(tree, top_level)

      target = remover.still_used?("action-pants", deleted: "rails")

      expect(target).to be_falsy
    end

    it "returns true if the candidate is used directly by another dep" do
      remover = subject.new(tree, top_level)

      target = remover.still_used?("rack", deleted: "rails")

      expect(target).to be_truthy
    end

    it "returns true if the candidate is used indirectly by another dep" do
      remover = subject.new(tree, top_level)

      target = remover.still_used?("rack-test", deleted: "rails")

      expect(target).to be_truthy
    end

    it "returns false if the candidate is only used directly by the deleted dep" do
      remover = subject.new(tree, top_level)

      target = remover.still_used?("actionpack", deleted: "rails")

      expect(target).to be_falsy
    end

    it "returns false if the candidate is only used indirectly by the deleted dep" do
      remover = subject.new(tree, top_level)

      target = remover.still_used?("actionview", deleted: "rails")

      expect(target).to be_falsy
    end

    it "raises an error if the top level dependency isn't in the lockfile" do
      top_level << dep("tzinfo")
      remover = subject.new(tree, top_level)
      allow(remover).to receive(:warn_of_bad_tracing)

      remover.still_used?("actionview", deleted: "rails")

      expect(remover).to have_received(:warn_of_bad_tracing)
    end
  end
end
