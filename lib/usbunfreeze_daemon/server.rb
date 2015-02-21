require 'settingslogic'
require 'aws-sdk'
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

      sqs = Aws::SQS::Client.new(region: Settings.sqs.region,
                                 access_key_id: Settings.sqs.access_key_id,
                                 secret_access_key: Settings.sqs.secret_access_key)
      raise 'No SQS object' unless sqs

      @logger.info "Get queue '#{Settings.sqs.queue_name}' ..."
      q = sqs.get_queue_url(queue_name: Settings.sqs.queue_name)
      raise 'Cannot get queue' unless q

      interval = [Settings.sqs.interval.to_i, 5].max
      @logger.info "Start polling queue each #{interval} seconds"

      while true do
          sleep interval
          messages = sqs.receive_message(queue_url: q.data.queue_url, wait_time_seconds: interval)
          if not messages.messages.empty?
              m = messages.messages.first
              handle_message m
              resp = sqs.delete_message(queue_url: q.data.queue_url, receipt_handle: m.receipt_handle)
              @logger.info "Deleting message returned data: #{resp.data}" unless resp.data
          end
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
      @logger.info "Get a messsage #{m.message_id}, received at #{Time.now}"
      @logger.info "Object body: #{m.body}"
      json = JSON.parse(m.body)
      action = json['message'].downcase
      if json['timestamp']
          @logger.info "Message was sent at #{json['timestamp']}"
      end
      if action == 'unfreeze'
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
