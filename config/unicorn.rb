APP_PATH = "/srv/overwine.io"

##############################################
# Basic Configuration
##############################################

# Set Application Path
working_directory APP_PATH

# PID file location
pid APP_PATH + "/tmp/unicorn.pid"

# Logging
stderr_path APP_PATH + "/log/unicorn.stderr.log"
stdout_path APP_PATH + "/log/unicorn.stderr.log"

# Adds an address to the existing listener set. May be specified more than once. address may be an Integer port number for a TCP port, an
# "IP_ADDRESS:PORT" for TCP listeners or a pathname for UNIX domain sockets.
listen APP_PATH + "/tmp/unicorn.sock", backlog: 64

# Sets the current number of worker processes. Each worker process will serve exactly one client at a time.
# You can increment or decrement this value at runtime using interrupts (http://unicorn.bogomips.org/SIGNALS.html).
worker_processes 4

# Sets the timeout of worker processes to seconds. Workers handling the request/app.call/response cycle taking longer than this time
# period will be forcibly killed (via SIGKILL). This timeout is enforced by the master process itself and not subject to the scheduling
# limitations by the worker process. Due the low-complexity, low-overhead implementation, timeouts of less than 3.0 seconds can be
# considered inaccurate and unsafe.
timeout 30

##############################################
# Preloader Settings
##############################################

# Enabling this preloads an application before forking worker processes. This allows memory savings when using a copy-on-write-friendly GC
# but can cause bad things to happen when resources like sockets are opened at load time by the master process and shared by multiple
# children. See http://unicorn.bogomips.org/Unicorn/Configurator.html#method-i-preload_app for details.
preload_app true

GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
