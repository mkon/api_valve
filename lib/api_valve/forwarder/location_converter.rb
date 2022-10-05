module ApiValve
  class Forwarder::LocationConverter
    def initialize(location, options)
      @location = location
      @options = options
    end

    def call
      if other_host? || same_prefix?
        @location.to_s
      else
        convert_location
      end
    end

    private

    def local_prefix
      @options[:local_prefix].presence
    end

    def other_host?
      @location.host && @options[:response_uri].host != @location.host
    end

    def same_prefix?
      local_prefix == target_prefix
    end

    def target_prefix
      @options[:target_prefix].presence
    end

    def convert_location
      @location.to_s.gsub(/^#{@options[:target_prefix]}/, @options[:local_prefix])
    end
  end
end
