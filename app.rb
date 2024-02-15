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
    :"bootstrap.servers" => ENV['KAFKA_BOOTSTRAP_SERVERS'],
    :"group.id" => "consumer-group"
}

KAFKA = Rdkafka::Config.new(KAFKA_CONFIG)

post '/produce/?:count?' do
  count = params[:count].to_i
  count = DEFAULT_COUNT if count <= 0
  delivery_handles = []

  producer = KAFKA.producer
  count.times do |i|
    puts "Producing message #{i}"
    delivery_handles << producer.produce(
        topic:  ENV['KAFKA_TOPIC'],
        payload: "Payload #{i}",
        key:     "Key #{i}"
    )
  end

  delivery_handles.each(&:wait)
  producer.close
  {count: count}.to_json
end

post '/consume/?:count?' do |count|
  consumer = KAFKA.consumer
  consumer.subscribe(ENV['KAFKA_TOPIC'])
  count = params[:count].to_i

  consumed_count = 0
  consumer.each do |message|
    puts "Message received: #{message}"
    consumed_count += 1
    puts "consumed count = #{consumed_count}"
    break if count > 0 && consumed_count >= count
  end

  consumer.commit
  consumer.close
  {count: consumed_count}.to_json

end