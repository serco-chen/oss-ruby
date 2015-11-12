module OSS
  module Utils
    # turn symbol keys to string keys, shallow mode
    def indifferent_hash(hash)
      Hash[hash.map {|k, v| Symbol === k ? [k.to_s, v] : [k, v] }]
    end

    def content_md5_header(content)
      Digest::MD5.base64digest(content)
    end

    extend self
  end
end
