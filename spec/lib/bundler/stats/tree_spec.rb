require 'spec_helper'

describe Bundler::Stats::Tree do
  subject { described_class }
  let(:lock_path) { File.join(File.dirname(__FILE__), "../../../test_gemfile.lock") }
  let(:parser) { Bundler::LockfileParser.new(File.read(lock_path)) }
  let(:tree) { subject.new(lock_path) }

  context "#new" do
    it "initializes only with a parsed lockfile" do
      expect { subject.new("whatever") }.to raise_error(ArgumentError)
    end

    it "initializes properly with the lockfile parser" do
      expect { subject.new(parser) }.not_to raise_error
    end
  end

  context "#first_level_dependencies" do
    it "warns you of missing dependencies from other platforms" do
      tree = subject.new(parser)
      allow(tree).to receive(:warn)

      tree.first_level_dependencies("none")

      expect(tree).to have_received(:warn)
    end

    it "returns empty array for bottom-level dependencies" do
      tree = subject.new(parser)

      target = tree.first_level_dependencies("depth-four")

      expect(target.length).to eq(0)
    end

    it "returns the set of dependencies for second-level deps" do
      tree = subject.new(parser)

      target = tree.first_level_dependencies("depth-three")

      expect(target.length).to eq(1)
    end

    it "does not recurse any further than the first level" do
      tree = subject.new(parser)

      target = tree.first_level_dependencies("depth-one")

      expect(target.length).to eq(2)
    end
  end

  context "#transitive_dependencies" do
    it "warns you of missing dependencies from other platforms" do
      tree = subject.new(parser)
      allow(tree).to receive(:warn)

      tree.transitive_dependencies("none")

      expect(tree).to have_received(:warn)
    end

    it "returns empty array for bottom-level dependencies" do
      tree = subject.new(parser)

      target = tree.transitive_dependencies("depth-four")

      expect(target.length).to eq(0)
    end

    it "returns the set of dependencies for second-level deps" do
      tree = subject.new(parser)

      target = tree.transitive_dependencies("depth-three")

      expect(target.length).to eq(1)
    end

    it "returns a recursive list of those dependencies" do
      tree = subject.new(parser)

      target = tree.transitive_dependencies("depth-one")

      expect(target.length).to eq(3)
    end
  end

  context "#summarize" do
    it "is a hash with some keys" do
      tree = subject.new(parser)

      target = tree.summarize("depth-one")

      expect(target).to be_a(Hash)
    end

    it "calls for other methods to do the actual work" do
      tree = subject.new(parser)
      allow(tree).to receive(:first_level_dependencies) { [] }
      allow(tree).to receive(:transitive_dependencies) { [] }
      allow(tree).to receive(:reverse_dependencies) { [] }

      target = tree.summarize("depth-one")

      expect(tree).to have_received(:first_level_dependencies)
      expect(tree).to have_received(:transitive_dependencies)
      expect(tree).to have_received(:reverse_dependencies)
    end
  end

  context "#reverse_dependencies" do
    it "returns nothing for a top-level dependency" do
      tree = subject.new(parser)

      target = tree.reverse_dependencies("depth-one")

      expect(target).to be_a(Hash)
      expect(target).to be_empty
    end

    it "returns the parent dependency for a second-level dep" do
      tree = subject.new(parser)

      target = tree.reverse_dependencies("depth-two")

      expect(target).to be_a(Hash)
      expect(target).to include("depth-one")
    end
  end

  context "#version_requirements" do
    it "is a hash with some keys" do
      tree = subject.new(parser)

      target = tree.version_requirements("depth-one")

      expect(target).to be_a(Hash)
    end
  end

  context "skip lists" do
    it "still includes the skipped entry" do
      tree = subject.new(parser, skiplist: ["depth-three"])

      target = tree.transitive_dependencies("depth-one")

      expect(target.map(&:name)).to include("depth-three")
    end

    it "stops processing the children of skipped entries" do
      tree = subject.new(parser, skiplist: ["depth-three"])

      target = tree.transitive_dependencies("depth-one")

      expect(target.map(&:name)).not_to include("depth-four")
    end
  end
end
