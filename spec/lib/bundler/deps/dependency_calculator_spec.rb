require 'bundler'
require 'bundler/deps'
require 'pry'

describe Bundler::Deps::DependencyCalculator do
  subject { described_class }
  let(:lock_path) { File.join(File.dirname(__FILE__), "../../../test_gemfile.lock") }
  let(:calculator) { subject.new(lock_path) }

  context "#new" do
    it "requires a readable lockfile" do
      expect(File.readable?(lock_path)).to be_truthy
      expect { subject.new(lock_path) }.not_to raise_error
    end

    it "is displeased about unreadable lockfiles" do
      expect { subject.new("/not/a/file/path") }.to raise_error(ArgumentError)
    end

    it "creates a parser instance" do
      target = subject.new(lock_path)

      expect(target.parser).to be_a(Bundler::LockfileParser)
    end
  end

  context "#total_dependencies" do
    it "counts all the dependencies" do
      expect(calculator.total_dependencies).to eq 46
    end
  end

  context "#nonspecific_dependencies" do
    it "counts all the dependencies with no version specification" do
      expect(calculator.nonspecific_dependencies).to be < 46
    end
  end
end
