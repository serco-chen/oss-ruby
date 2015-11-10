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

  # Wrap error responded from server side
  class APIError < Error
    attr_reader :status, :code, :request_id, :host_id
    def initialize(response)
      doc = Nokogiri::XML(response.body)
      @status  = response.status
      @code    = doc.xpath("//Code").text
      @message = doc.xpath("//Message").text
      @request_id = doc.xpath("//RequestId").text
      @host_id = doc.xpath("//HostId").text

      super(@message)
    end
  end
end
