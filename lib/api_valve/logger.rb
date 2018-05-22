require 'active_support/tagged_logging'
require 'logger'

module ApiValve
  class Logger < ::Logger
    include ActiveSupport::TaggedLogging

    class Formatter < ActiveSupport::Logger::SimpleFormatter
      include ActiveSupport::TaggedLogging::Formatter
    end

    def initialize(target = STDOUT)
      super(target)
      self.formatter = Formatter.new
    end

    # some rack apps have weird ways to write to rack.logger
    alias puts error
    alias write info
  end
end
