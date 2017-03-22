require "spec_helper"

describe CarrierWave::AttachmentScanner do
  class TestUploader < CarrierWave::Uploader::Base
    include CarrierWave::AttachmentScanner

    def root
      File.expand_path('../../../tmp', __FILE__)
    end

    storage :file

    def scan_error_message(result)
      "custom_error: #{result['status']}"
    end
  end

  describe '.included' do
    context 'when the URI is missing' do
      before do
        expect(CarrierWave::AttachmentScanner::Config).to receive(:url).and_return(nil)
      end

      it 'raises an AttachmentScannerError' do
        expect do
          class TestUploaderConfig < CarrierWave::Uploader::Base
            include CarrierWave::AttachmentScanner
          end
        end.to raise_error(ArgumentError, "AttachmentScanner URL is required")
      end
    end

    context 'when the API Token is missing' do
      before do
        expect(CarrierWave::AttachmentScanner::Config).to receive(:api_token).and_return(nil)
      end

      it 'raises an AttachmentScannerError' do
        expect do
          class TestUploaderConfig < CarrierWave::Uploader::Base
            include CarrierWave::AttachmentScanner
          end
        end.to raise_error(ArgumentError, "AttachmentScanner API Token is required")
      end
    end
  end

  context '#store!' do
    subject { TestUploader.new }
    after { file.close if file }

    context 'with a valid file' do
      let(:file) { open_fixture('plain.txt') }

      it 'raises nothing' do
        expect { subject.store!(file) }.not_to raise_error
      end
    end

    context 'with the eicar file' do
      let(:file) { open_fixture('eicar.com') }

      it 'raises an IntegrityError' do
        expect { subject.store!(file) }.to raise_error(CarrierWave::IntegrityError)
      end

      it 'sets a custom error message' do
        expect { subject.store!(file) }
          .to raise_error(CarrierWave::AttachmentScanner::AttachmentScannerError) do |error|
            expect(error.message).to eq('custom_error: found')
          end
      end

      it 'sets the scan status' do
        expect { subject.store!(file) }
          .to raise_error(CarrierWave::AttachmentScanner::AttachmentScannerError) do |error|
            expect(error.matches).to match_array(["Eicar-Test-Signature"])
          end
      end

      it 'sets the scan matches' do
        expect { subject.store!(file) }
          .to raise_error(CarrierWave::AttachmentScanner::AttachmentScannerError) do |error|
            expect(error.matches).to match_array(["Eicar-Test-Signature"])
          end
      end
    end

    context 'with a double sanitized file' do
      let(:file) { open_fixture('plain.txt') }
      let(:sanitized) { CarrierWave::SanitizedFile.new(CarrierWave::SanitizedFile.new(file)) }

      it 'raises nothing' do
        expect { subject.store!(sanitized) }.not_to raise_error
      end
    end

    context 'when the file is a StringIO' do
      let(:file) { StringIO.new('test') }
      let(:file_hash) { { tempfile: file, filename: 'test.txt', original_filename: 'test.txt', content_type: 'text/plain' } }
      let(:sanitized) { CarrierWave::SanitizedFile.new(file_hash) }

      it 'raises nothing' do
        expect { subject.store!(sanitized) }.not_to raise_error
      end
    end

    context 'with no file' do
      let(:file) { nil }

      it 'returns nil and raises no error' do
        expect(subject.store!(file)).to be_nil
      end
    end
  end
end
