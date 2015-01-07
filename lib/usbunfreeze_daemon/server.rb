module UsbunfreezeDaemon

class Server

  attr_accessor :conf_path

  def run
    puts "Running with conf_path=#{@conf_path}"
    File.open('/tmp/usbunfreeze.log', 'w') do |f|
      loop do
        f.puts "Now is #{Time.now}"
        f.flush
        sleep(1)
      end
    end
  end

end

end