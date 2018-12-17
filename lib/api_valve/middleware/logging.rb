class ApiValve::Middleware
  class Logging
    include ActiveSupport::Configurable

    class Log
      INCOMING = %(Started %s "%s" for %s at %s).freeze
      COMPLETE = %(Completed %s %s in %dms\n).freeze
      URL_PARAMS = %(URL params %s).freeze
      REQUEST_PAYLOAD = %(Request payload\n%s).freeze
      REQUEST_HEADERS = %(Request HTTP Headers %s).freeze
      RESPONSE_HEADERS = %(Response HTTP headers %s).freeze
      RESPONSE_PAYLOAD = %(Response payload\n%s).freeze
      NON_STANDARD_REQUEST_HEADERS = %w(CONTENT_LENGTH CONTENT_TYPE).freeze

      attr_accessor :began_at, :env, :status, :response_headers, :response_payload

      def initialize(options = {})
        assign options
      end

      def assign(options = {})
        options.each do |k, v|
          public_send "#{k}=", v
        end
      end

      def before_request
        log_request
        log_url_params
        log_request_headers if Logging.log_request_headers
        log_request_payload if Logging.log_request_body
      end

      def after_request
        log_response_headers if Logging.log_response_headers
        log_response_payload if Logging.log_response_body
        log_response
      end

      private

      delegate :logger, to: ApiValve

      def log_request
        logger.info INCOMING % [
          env['REQUEST_METHOD'],
          [env['PATH_INFO'], env['QUERY_STRING'].presence].compact.join('?'),
          (env['HTTP_X_FORWARDED_FOR'] || env['REMOTE_ADDR']),
          began_at.strftime('%Y-%m-%d %H:%M:%S %z')
        ]
      end

      def log_url_params
        return unless env['QUERY_STRING'].present?

        logger.info URL_PARAMS % Rack::Utils.parse_nested_query(env['QUERY_STRING']).inspect
      end

      def log_request_headers
        headers = {}
        env.each_pair do |k, v|
          next unless k =~ /^HTTP_/ && v.present?
          next if v.blank? || (!k.start_with?('HTTP_') && !NON_STANDARD_REQUEST_HEADERS.include?(k))

          headers[k] = v
        end
        return if headers.empty?

        logger.debug REQUEST_HEADERS % headers
      end

      def log_request_payload
        return unless %w(PATCH POST PUT).include? env['REQUEST_METHOD']

        logger.debug REQUEST_PAYLOAD % env['rack.input'].read(1000)
        env['rack.input'].rewind
      end

      def log_response_headers
        return if response_headers&.empty?

        logger.debug RESPONSE_HEADERS % response_headers.inspect
      end

      def log_response_payload
        return if response_payload&.empty?

        logger.debug RESPONSE_PAYLOAD % response_payload.first(config_log_body_size)
      end

      def log_response
        logger.info COMPLETE % [
          status,
          Rack::Utils::HTTP_STATUS_CODES[status],
          (Time.now - began_at) * 1000
        ]
      end
    end

    config_accessor(:log_request_headers) { false }
    config_accessor(:log_request_body) { false }
    config_accessor(:log_response_headers) { false }
    config_accessor(:log_response_body) { false }

    def initialize(app)
      @app = app
    end

    def call(env)
      env['rack.logger'] = ApiValve.logger
      env['rack.errors'] = ApiValve.logger
      ApiValve.logger.tagged(Thread.current[:request_id]) do
        log = Log.new(began_at: Time.now, env: env)
        log.before_request
        status, headers, body = @app.call(env)
        log.assign status: status, response_headers: headers, response_payload: body
        log.after_request
        [status, headers, body]
      end
    end
  end
end
