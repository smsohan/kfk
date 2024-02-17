require 'bundler'
Bundler.require
KAFKA_CONFIG = {
  :"bootstrap.servers" => ENV['KAFKA_BOOTSTRAP_SERVERS']
}

KAFKA_CONSUMER_CONFIG = KAFKA_CONFIG.merge(:"group.id" => "consumer-group",
:'enable.auto.commit' => true)
KAFKA_CONSUMER = Rdkafka::Config.new(KAFKA_CONSUMER_CONFIG)

if ENV['APP_ENV'] == 'development'
  begin
    puts "Creating topic in case it doesn't exist #{ENV['KAFKA_TOPIC']}"
    KAFKA_CONSUMER.admin.create_topic(ENV['KAFKA_TOPIC'], 1, 1)
  rescue => exception
    puts "Failed to create topic. Continuing. #{exception.message}"
  end
end

consumer = KAFKA_CONSUMER.consumer
consumer.subscribe(ENV['KAFKA_TOPIC'])

puts "Starting consumer: topic #{ENV['KAFKA_TOPIC']}"
consumed_count = 0
delay = [ENV['DELAY_IN_SECONDS'].to_f, 0.1].max
consumer.each do |message|
  consumed_count += 1
  puts "##{consumed_count}: #{message.key}: #{message.payload}"
  sleep delay
end

Signal.trap('TERM') do
  puts 'Received TERM Signal'
  consumer.close
  exit
end