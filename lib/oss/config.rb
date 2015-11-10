module OSS
  class Config
    OPTIONS = [:endpoint, :access_key_id, :access_key_secret]
    attr_accessor *OPTIONS

    def initialize(options={})
      # TODO: raise error when OPTIONS not valid
      options.each do |key, val|
        self.send("#{key}=", val) if self.respond_to?("#{key}=")
      end
    end
  end
end
