module ApiValve
  # This class is responsible to decide if a request is allowed or not, and can
  # be extended with more ACL related features, for example returning a list of
  # attributes that can be read or written.

  class Forwarder::PermissionHandler
    InsufficientPermissions = Class.new(Error::Forbidden)

    module RequestIntegration
      private

      def permission_handler
        permission_handler_klass.instance(original_request, permission_handler_options)
      end

      def permission_handler_klass
        permission_handler_options[:klass] || Forwarder::PermissionHandler
      end

      def permission_handler_options
        options[:permission_handler] || {}
      end
    end

    attr_reader :request, :options

    delegate :env, to: :request

    # Returns an instance of the PermissionHandler, cached in the request env
    # This allows re-use of the PermissionHandler by both Request and Response instances
    def self.instance(request, options)
      request.env['permission_handler'] ||= new(request, options)
    end

    def initialize(request, options = {})
      @request = request
      @options = options
    end

    # Run permission checks
    # Simple implementation is always true. Override in your implementation.
    # For example raise ApiValve::Error::Forbidden in certain conditions
    def check_permissions!
      true
    end
  end
end
