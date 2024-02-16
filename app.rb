require 'bundler'
Bundler.require

require 'sinatra'

set :bind, '0.0.0.0'
set :port, ENV['PORT']

DEFAULT_COUNT = 1_000

get '/' do
    %{
        POST /produce[/count] to emit #count messages to the queue, default 1,000
        POST /consume[/count] to receive #count messages to the queue, default is all
    }
end

KAFKA_CONFIG = {
  :"bootstrap.servers" => ENV['KAFKA_BOOTSTRAP_SERVERS']
}
KAFKA_CONSUMER_CONFIG = KAFKA_CONFIG.merge(:"group.id" => "consumer-group")

KAFKA = Rdkafka::Config.new(KAFKA_CONFIG)
KAFKA_CONSUMER = Rdkafka::Config.new(KAFKA_CONSUMER_CONFIG)

post '/produce/?:count?' do
  count = params[:count].to_i
  count = DEFAULT_COUNT if count <= 0
  delivery_handles = []

  producer = KAFKA.producer
  prefix = "[#{rand(1000)}]"
  stream do |out|
    count.times do |i|
      out.puts "producing #{prefix} #{i}"
      delivery_handles << producer.produce(
        topic:  ENV['KAFKA_TOPIC'],
        payload: "Payload #{i}",
        key:     "#{prefix} #{i}"
      )
      out.flush
    end
    delivery_handles.each(&:wait)
    producer.close
  end

end

post '/consume/?:count?' do |count|
  consumer = KAFKA_CONSUMER.consumer
  consumer.subscribe(ENV['KAFKA_TOPIC'])
  count = params[:count].to_i

  consumed_count = 0
  stream do |out|
    consumer.each do |message|
      consumed_count += 1
      out.puts "##{consumed_count}: #{message}"
      out.flush
      break if count > 0 && consumed_count >= count
    end

    consumer.commit
    consumer.close
  end

end