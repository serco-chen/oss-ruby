require 'nokogiri'

module OSS
  class Error < StandardError
    def inspect
      %(#<#{self.class} message="#{self.message}">)
    end
  end

  # Wrap Faraday client error
  class HTTPClientError < Error
    def initialize(exception)
      @exception = exception
      super(exception.message)
    end

    def backtrace
      if @exception
        @exception.backtrace
      else
        super
      end
    end
  end
end
