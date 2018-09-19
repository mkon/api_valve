module ApiValve
  class Cascade
    def initialize(*proxies)
      @proxies = Array.wrap(proxies).flatten
    end

    def call(env)
      @proxies.each do |proxy|
        return proxy.call env
      rescue Error::NotRouted
        next
      end
      render_error Error::NotFound.new
    end

    protected

    def render_error(error)
      self.class.const_get(ApiValve.error_responder).new(error).call
    end
  end
end
