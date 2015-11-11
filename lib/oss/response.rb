module OSS
  class APIError
    attr_reader :code, :message, :request_id, :host_id

    def inspect
      %(#<#{self.class} message="#{self.message}">)
    end

    def initialize(doc)
      @code       = doc.xpath('//Code').text
      @message    = doc.xpath('//Message').text
      @request_id = doc.xpath('//RequestId').text
      @host_id    = doc.xpath('//HostId').text
    end
  end

  class Response
    extend Forwardable
    attr_reader :response

    def initialize(response)
      @response = response
    end

    def doc
      @doc ||= Nokogiri::XML(@response.body)
    end

    def error
      return nil if status.to_s.start_with?('2')
      @error ||= OSS::APIError.new(doc)
    end

    def_delegators :@response, :body, :headers, :status
    def_delegators :doc, :xpath
  end
end
