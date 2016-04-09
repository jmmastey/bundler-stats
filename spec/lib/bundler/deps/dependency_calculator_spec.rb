require 'bundler'
require 'bundler/deps'
require 'pry'

describe Bundler::Deps::DependencyCalculator do
  subject { described_class }
  let(:gemfile_path) { File.join(File.dirname(__FILE__), "../../../test_gemfile.lock") }
  let(:lockfile_path) { File.join(File.dirname(__FILE__), "../../../test_gemfile") }
  let(:calculator) { subject.new(lockfile_path) }

  context "#new" do
    it "requires a readable lockfile" do
      expect(File.readable?(lockfile_path)).to be_truthy
      expect { subject.new(lockfile_path) }.not_to raise_error
    end

    it "is displeased about unreadable lockfiles" do
      expect { subject.new("/not/a/file/path") }.to raise_error(ArgumentError)
    end

    it "creates a parser instance" do
      target = subject.new(lockfile_path)

      expect(target.parser).to be_a(Bundler::LockfileParser)
    end

    it "creates a tree instance" do
      target = subject.new(lockfile_path)

      expect(target.tree).to be_a(Bundler::Deps::Tree)
    end

    it "creates a parsed gemfile instance" do
      target = subject.new(lockfile_path)

      expect(target.tree).to be_a(Bundler::Deps::Tree)
    end
  end
end
