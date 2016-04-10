require 'bundler'
require 'bundler/stats'

describe Bundler::Stats::Calculator do
  subject { described_class }
  let(:gemfile_path) { File.join(File.dirname(__FILE__), "../../../test_gemfile") }
  let(:lockfile_path) { File.join(File.dirname(__FILE__), "../../../test_gemfile.lock") }
  let(:calculator) { subject.new(lockfile_path) }

  context "#new" do
    it "is displeased about unreadable lockfiles" do
      expect { subject.new(gemfile_path, "/not/a/file/path") }.to raise_error(ArgumentError)
    end

    it "is displeased about unreadable gemfiles, too" do
      expect { subject.new("/not/a/file/path", lockfile_path) }.to raise_error(ArgumentError)
    end

    it "creates a parser instance" do
      target = subject.new(gemfile_path, lockfile_path)

      expect(target.parser).to be_a(Bundler::LockfileParser)
    end

    it "creates a tree instance" do
      target = subject.new(gemfile_path, lockfile_path)

      expect(target.tree).to be_a(Bundler::Stats::Tree)
    end

    it "creates a parsed gemfile instance" do
      target = subject.new(gemfile_path, lockfile_path)

      expect(target.gemfile).to be_a(Array)
    end
  end

  describe "#stats" do
    it "returns a hash with some keys" do
      calculator = subject.new(gemfile_path, lockfile_path)

      target = calculator.stats

      expect(target).to be_a(Hash)
      expect(target.keys).to eq([:summary, :gems])
    end

    it "asks for gem stats" do
      calculator = subject.new(gemfile_path, lockfile_path)
      allow(calculator).to receive(:gem_stats).and_return(rbis: 35)

      target = calculator.stats

      expect(calculator).to have_received(:gem_stats)
      expect(target[:gems]).to eq(rbis: 35)
    end

    it "asks for a summary" do
      calculator = subject.new(gemfile_path, lockfile_path)
      allow(calculator).to receive(:summary).and_return(rbis: 35)

      target = calculator.stats

      expect(calculator).to have_received(:summary)
      expect(target[:summary]).to eq(rbis: 35)
    end
  end

  context "#gem_stats" do
    it "includes entries for each gem" do
      calculator = subject.new(gemfile_path, lockfile_path)

      target = calculator.gem_stats

      expect(target).to be_a(Array)
      expect(target.length).to eq(calculator.gemfile.length)
    end
  end

  context "#summary" do
    it "is a hash" do
      calculator = subject.new(gemfile_path, lockfile_path)

      target = calculator.summary

      expect(target).to be_a(Hash)
      expect(target).to include(:total_gems)
      expect(target).to include(:unpinned_gems)
    end
  end
end
