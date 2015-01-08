require 'settingslogic'
require 'aws-sdk-v1'
require 'json'

module UsbunfreezeDaemon

  class Settings < Settingslogic
    namespace 'config'
  end

  class Server

    attr_accessor :conf_path
    attr_accessor :logger

    def run
      @logger.info "Loading config from #{@conf_path}"
      Settings.source @conf_path

      @logger.info "Running with executable=#{Settings.exec_command}"

      sqs = AWS::SQS.new(access_key_id: Settings.sqs.access_key_id,
      secret_access_key: Settings.sqs.secret_access_key)
      raise 'No SQS object' unless sqs

      @logger.info "Get queue '#{Settings.sqs.queue_name}' ..."
      q = sqs.queues.named(Settings.sqs.queue_name)
      raise 'Cannot get queue' unless q
      raise 'Queue does not exist' unless q.exists?

      interval = [Settings.sqs.interval.to_i, AWS::SQS::Queue::DEFAULT_WAIT_TIME_SECONDS].max
      @logger.info "Start polling queue each #{interval} seconds"

      q.poll(:wait_time_seconds => interval) do |m|
        handle_message m
      end

    rescue => e
      @logger.error "Error:" + e.message
      @logger.error e.backtrace.map{|s| "\t"+s}.join("\n")
      exit 1
    end

    private

    # Handle an incoming SQS message
    # Wrong message is not fatal error
    def handle_message m
      @logger.info "Get a messsage #{m.id}, received at #{Time.now}, sent at #{m.sent_timestamp}"
      @logger.info "Object body: #{m.body}"
      json = JSON.parse(m.body)
      action = json['message'].downcase
      if json['message'].downcase == 'unfreeze'
        @logger.info "Launching a command"
        system(Settings.exec_command)
        @logger.info "Command execution code: #{$?}"
      end
    rescue => e
      @logger.info "Error parsing a message:" + e.message
      @logger.info e.backtrace.map{|s| "\t"+s}.join("\n")
      @logger.info "Continuing..."
    end

  end

end