module ApiValve
  module Error
    class Base < RuntimeError
      class_attribute :http_status
      self.http_status = :server_error
    end

    Rack::Utils::SYMBOL_TO_STATUS_CODE.each do |sym, code|
      next unless code >= 400
      const_set sym.to_s.camelize, Class.new(Base) { self.http_status = sym }
    end
  end
end
