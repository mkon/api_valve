module ApiValve
  class Proxy
    module Builder
      cattr_accessor :safe_load_classes
      self.safe_load_classes = [::Regexp]

      # Creates an instance from a config hash and takes optional block
      # which is executed in scope of the proxy
      def build(config, &block)
        from_hash(config).tap do |proxy|
          proxy.instance_eval(&block) if block
        end
      end

      def from_config(file_name = nil)
        file_name ||= name.underscore
        path = find_config(file_name)
        raise "Config not found for #{name.underscore}(.yml|.yml.erb) in #{ApiValve.config_paths.inspect}" unless path

        yaml = File.read(path)
        yaml = ERB.new(yaml, trim_mode: '-').result if path.fnmatch? '*.erb'
        from_yaml yaml
      end

      def from_yaml(string)
        from_hash YAML.safe_load(string, permitted_classes: safe_load_classes)
      end

      def from_hash(config)
        config = config.with_indifferent_access
        forwarder = Forwarder.new(forwarder_config(config))
        new(forwarder).tap do |proxy|
          Array.wrap(config[:use]).each { |mw| proxy.use mw }
          add_routes_from_config proxy, config[:routes]
          proxy.use Middleware::PermissionCheck, config[:permission_handler] if config[:permission_handler]
        end
      end

      private

      def add_routes_from_config(proxy, routes_config)
        return proxy.forward_all unless routes_config

        routes_config.each do |route_config|
          method, path_regexp = *route_config.values_at('method', 'path')
          method ||= 'any' # no method defined means all methods
          if route_config['raise']
            proxy.deny method, path_regexp, with: route_config['raise']
          else
            proxy.forward method, path_regexp, route_config.except('method', 'path')
          end
        end
      end

      def find_config(file_name)
        ApiValve.config_paths.each do |dir|
          path = dir.join("#{file_name}.yml")
          return path if path.exist?

          path = dir.join("#{file_name}.yml.erb")
          return path if path.exist?
        end
        nil
      end

      def forwarder_config(config)
        {
          request:  {klass: request},
          response: {klass: response}
        }.with_indifferent_access.deep_merge config.slice(*FORWARDER_OPTIONS)
      end
    end
  end
end
