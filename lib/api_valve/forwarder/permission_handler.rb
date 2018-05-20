module ApiValve
  class Forwarder::PermissionHandler
    module RequestIntegration
      private

      def permission_handler
        permission_handler_klass.instance(@original_request, permission_handler_options)
      end

      def permission_handler_klass
        permission_handler_options[:klass] || Forwarder::PermissionHandler
      end

      def permission_handler_options
        @options[:permission_handler] || {}
      end
    end

    def self.instance(request, options)
      request.env['permission_handler'] ||= new(request, options)
    end

    def initialize(request, options = {})
      @request = request
      @options = options
    end

    def request_allowed?
      true
    end
  end
end
