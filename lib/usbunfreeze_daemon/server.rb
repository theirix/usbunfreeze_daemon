require 'settingslogic'
require 'aws-sdk-v1'
require 'json'

module UsbunfreezeDaemon

  class Settings < Settingslogic
    namespace 'config'
  end

  class Server

    attr_accessor :conf_path

    def run
      puts "Loading config from #{@conf_path}"
      Settings.source @conf_path

      puts "Running with executable=#{Settings.exec_command}"

      sqs = AWS::SQS.new(access_key_id: Settings.sqs.access_key_id,
      secret_access_key: Settings.sqs.secret_access_key)
      raise 'No SQS object' unless sqs

      puts "Get queue '#{Settings.sqs.queue_name}' ..."
      q = sqs.queues.named(Settings.sqs.queue_name)
      raise 'Cannot get queue' unless q
      raise 'Queue does not exist' unless q.exists?

      interval = [Settings.sqs.interval.to_i, AWS::SQS::Queue::DEFAULT_WAIT_TIME_SECONDS].max
      puts "Start polling queue each #{interval} seconds"

      q.poll(:wait_time_seconds => interval) do |m|
        handle_message m
      end

    rescue => e
      STDERR.puts "Error:" + e.message
      STDERR.puts e.backtrace.map{|s| "\t"+s}.join("\n")
      exit 1
    end

    private

    # Handle an incoming SQS message
    # Wrong message is not fatal error
    def handle_message m
      puts "Get a messsage #{m.id}, received at #{Time.now}, sent at #{m.sent_timestamp}"
      puts "Object body: #{m.body}"
      json = JSON.parse(m.body)
      action = json['message'].downcase
      if json['message'].downcase == 'unfreeze'
        puts "Launching a command"
        system(Settings.exec_command)
        puts "Command execution code: #{$?}"
      end
    rescue => e
      puts "Error parsing a message:" + e.message
      puts e.backtrace.map{|s| "\t"+s}.join("\n")
      puts "Continuing..."
    end

  end

end