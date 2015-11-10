require 'json'
require 'faraday'

require 'oss/version'
require 'oss/error'
require 'oss/utils'
require 'oss/config'
require 'oss/response'
require 'oss/client'
# require 'oss/api'
require 'oss/bucket'
require 'oss/base'

module OSS
  class << self
    def new(options)
      OSS::Base.new(options)
    end
  end
end
