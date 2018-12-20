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

    protected

    attr_reader :env, :options
  end
end
