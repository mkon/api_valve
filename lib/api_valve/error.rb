module ApiValve
  class Error < RuntimeError
    class_attribute :http_status, :code, :title, :default_message
    self.http_status = :server_error

    Client = Class.new(self)
    Server = Class.new(self)

    Rack::Utils::SYMBOL_TO_STATUS_CODE.each do |sym, code|
      case code
      when 400..499
        const_set sym.to_s.camelize, Class.new(Client) { self.http_status = sym }
      when 500..599
        const_set sym.to_s.camelize, Class.new(Server) { self.http_status = sym }
      end
    end

    NotRouted = Class.new(self) do
      self.http_status = 404
    end

    def initialize(*args)
      @options = args.extract_options!
      super(args.first || default_message)
    end

    def code
      @options[:code] || self.class.code
    end

    def title
      @options[:title] || self.class.title
    end
  end
end
