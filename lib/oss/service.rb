module OSS
  class Service
    def initialize(config)
      @config = config
    end

    def client(options = {})
      OSS::Client.new(@config, options)
    end
  end
end
