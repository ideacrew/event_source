require 'hrr_rb_ssh'
require 'hrr_rb_sftp'
require 'logger'

options = Hash.new

logger = Logger.new(STDOUT)
logger.level = Logger::INFO

auth_password = HrrRbSsh::Authentication::Authenticator.new { |context|
  user_and_pass = [
    ['user1',  'password1']
  ]
  user_and_pass.any? { |user, pass|
    context.verify user, pass
  }
}
options['authentication_password_authenticator'] = auth_password

subsys = HrrRbSsh::Connection::RequestHandler.new { |ctx|
  ctx.chain_proc { |chain|
    case ctx.subsystem_name
    when 'sftp'
      begin
        sftp_server = HrrRbSftp::Server.new(logger: logger)
        sftp_server.start(ctx.io[0], ctx.io[1], ctx.io[2])
        exitstatus = 0
      rescue
        exitstatus = 1
      end
    else
      # Do something for other subsystem, or just return exitstatus
      exitstatus = 0
    end
    exitstatus
  }
}

options['connection_channel_request_subsystem'] = subsys

server = TCPServer.new 31337
loop do
  Thread.new(server.accept) do |io|
    pid = fork do
      begin
        server = HrrRbSsh::Server.new options
        server.start io
      ensure
        io.close
      end
    end
    io.close
    Process.waitpid pid
  end
end

HrrRbSsh::Server.new options, logger: logger