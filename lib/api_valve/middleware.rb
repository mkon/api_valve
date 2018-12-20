module ApiValve
  class Middleware
    autoload :ErrorHandling,   'api_valve/middleware/error_handling'
    autoload :Logging,         'api_valve/middleware/logging'
    autoload :PermissionCheck, 'api_valve/middleware/permission_check'
    autoload :Router,          'api_valve/middleware/router'

    Item = Struct.new(:klass, :proc)

    def initialize
      @registry = []
    end

    def insert_after(other, middleware, *args, &block)
      @registry.insert position(other) + 1, to_item(middleware, *args, &block)
    end

    def insert_before(other, middleware, *args, &block)
      @registry.insert position(other), to_item(middleware, *args, &block)
    end

    def to_app(root_app)
      @registry.reverse.inject(root_app) { |memo, obj| obj.proc.call memo }
    end

    def to_s
      @registry.map(&:klass).join("\n")
    end

    def use(middleware, *args, &block)
      @registry << to_item(middleware, *args, &block)
    end

    private

    def position(klass)
      @registry.index { |item| item.klass == klass }
    end

    def to_item(middleware, *args, &block)
      Item.new(middleware, proc { |app| middleware.new(app, *args, &block) })
    end
  end
end
