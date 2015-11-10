require 'nokogiri'

module OSS
  class Response
    extend Forwardable
    attr_reader :response

    def initialize(response)
      @response = response
    end

    def doc
      @doc ||= Nokogiri::XML(@response.body)
    end

    def_delegators :@response, :body, :status
  end
end
