require 'oss-ruby'

```
oss = OSS.new({
  endpoint: 'oss-cn-hangzhou.aliyuncs.com',
  app_key: 'your key',
  api_secret: 'your secret'
})
```

```
oss.create_bucket("bucketname","private")
```
