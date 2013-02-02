require 'rubygems'  # poor people still on 1.8
require 'bundler/setup'
Bundler.require

gem 'redis', '>= 3.0.0'
require 'redis'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

# Start our own redis-server to avoid corrupting any others
REDIS_BIN  = 'redis-server'
REDIS_PORT = ENV['REDIS_PORT'] || 9212
REDIS_HOST = ENV['REDIS_HOST'] || 'localhost'
REDIS_PID  = File.expand_path 'redis.pid', File.dirname(__FILE__)
REDIS_DUMP = File.expand_path 'redis.rdb', File.dirname(__FILE__)
puts "=> Starting redis-server on #{REDIS_HOST}:#{REDIS_PORT}"
fork_pid = fork do
  system "(echo port #{REDIS_PORT}; echo logfile /dev/null; echo daemonize yes; echo pidfile #{REDIS_PID}; echo dbfilename #{REDIS_DUMP}) | #{REDIS_BIN} -"
end
my_pid = Process.pid
puts "my pid: #{my_pid} redis pid: #{fork_pid}"

at_exit do
  if my_pid == Process.pid
    pid = File.read(REDIS_PID).to_i
    puts "=> Killing #{REDIS_BIN} with pid #{pid}"
    Process.kill "TERM", pid
    Process.kill "KILL", pid
    File.unlink REDIS_PID
    File.unlink REDIS_DUMP if File.exists? REDIS_DUMP
  end
end


REDIS_OPTIONS = {
  port: REDIS_PORT,
  host: REDIS_HOST,
  driver: :synchrony
}
