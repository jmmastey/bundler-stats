require 'bundler'
require 'bundler/deps'
require 'pry'

describe Bundler::Deps::Tree do
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

  context "#transitive_dependencies" do
    it "errors for non-existent dependencies" do
      tree = subject.new(parser)

      expect { tree.transitive_dependencies("none") }.to raise_error(ArgumentError)
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
end
