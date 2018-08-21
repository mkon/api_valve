module ApiValve
  class Error < RuntimeError
    class_attribute :http_status, :code, :title, :default_message
    self.http_status = :server_error

    def initialize(*args)
      @options = args.extract_options!
      super(args.first || default_message)
    end

    Rack::Utils::SYMBOL_TO_STATUS_CODE.each do |sym, code|
      next unless code >= 400
      const_set sym.to_s.camelize, Class.new(self) { self.http_status = sym }
    end
  end
end
