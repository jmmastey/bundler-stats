require 'spec_helper'

describe Bundler::Stats::FilePathResolver do
  let(:file_path_resolver) { described_class.new(specific_gemfile_path) }

  context "with undefined specific gemfile path" do
    let(:specific_gemfile_path) { nil }

    before do
      allow(File).to receive(:exist?).and_return(false)
    end

    context "without files found" do
      it do
        expect { file_path_resolver.gemfile_path }.to raise_error(
          ArgumentError, "Couldn't find gems.rb nor Gemfile in this directory or parents"
        )
      end

      it do
        expect { file_path_resolver.lockfile_path }.to raise_error(
          ArgumentError, "Couldn't find gems.locked nor Gemfile.lock in this directory or parents"
        )
      end
    end

    context "with files found" do
      before do
        allow(File).to receive(:exist?).with(Pathname.new("../Gemfile")).and_return(true)
        allow(File).to receive(:exist?).with(Pathname.new("../../gems.locked")).and_return(true)
      end

      it { expect(file_path_resolver.gemfile_path).to eq("../Gemfile") }
      it { expect(file_path_resolver.lockfile_path).to eq("../../gems.locked") }
    end
  end

  context "with specific gemfile path" do
    let(:specific_gemfile_path) { "some-project/Gemfile" }

    context "with valid file path" do
      before do
        allow(File).to receive(:exist?).and_return(true)
      end

      it { expect(file_path_resolver.gemfile_path).to eq("some-project/Gemfile") }
      it { expect(file_path_resolver.lockfile_path).to eq("some-project/Gemfile.lock") }

      context "with gems.rb file" do
        let(:specific_gemfile_path) { "some-project/gems.rb" }

        it { expect(file_path_resolver.gemfile_path).to eq("some-project/gems.rb") }
        it { expect(file_path_resolver.lockfile_path).to eq("some-project/gems.locked") }
      end

      context "with invalid file name" do
        let(:specific_gemfile_path) { "some-project/yeimfile" }

        it do
          expect { file_path_resolver.lockfile_path }.to raise_error(
            ArgumentError, "Invalid file name: yeimfile"
          )
        end
      end
    end

    context "with invalid file path" do
      before do
        allow(File).to receive(:exist?).and_return(false)
      end

      it do
        expect { file_path_resolver.gemfile_path }.to raise_error(
          ArgumentError, "Couldn't find some-project/Gemfile file path"
        )
      end

      it do
        expect { file_path_resolver.lockfile_path }.to raise_error(
          ArgumentError, "Couldn't find some-project/Gemfile.lock file path"
        )
      end
    end
  end
end
