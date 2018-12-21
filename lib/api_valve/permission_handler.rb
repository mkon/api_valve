module ApiValve
  class PermissionHandler
    def initialize(env, options = {})
      @env = env
      @options = options.with_indifferent_access
    end

    # Run permission checks
    # Simple implementation is always true. Override in your implementation.
    def allowed?
      true
    end

    # Returns string message why access was denied
    # Rendered on the API.
    # Override in your implementation.
    def message
      'Insufficient permissions'
    end

    protected

    attr_reader :env, :options
  end
end
