Blueprinter.configure do |config|
  config.datetime_format = ->(datetime) { datetime.nil? ? datetime : datetime.strftime("%Y-%m-%dT%H:%M:%S.%LZ") }
end