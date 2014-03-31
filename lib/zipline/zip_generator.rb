# this class acts as a streaming body for rails
# initialize it with an array of the files you want to zip
# right now only carrierwave is supported with file storage or S3
module Zipline
  class ZipGenerator
    # takes an array of pairs [[uploader, filename], ... ]
    def initialize(files)
      @files = files
    end

    # TODO: Inherit from IO or StringIO instead
    def to_s
      ''.tap do |buf|
        dup.each { |data| buf << data }
      end
    end

    def each(&block)
      output = new_output(&block)
      OutputStream.open(output) do |zip|
        @files.each do |file, name|
          # TODO: check this before hitting #each (init maybe)
          unless file.is_a?(IO) || file.is_a?(StringIO)
            fail(ArgumentError, 'Bad File/Stream')
          end


          write_file(zip, file, name)
        end
      end
    end

    def new_output(&block)
      FakeStream.new(&block)
    end

    def write_file(zip, file, name)
      zip.put_next_entry name, file.size

      while (buffer = file.read(2048))
        zip << buffer
      end
    end
  end
end
