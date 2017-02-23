require "resque/tasks"
task "resque:setup" => :environment
require "/home/user/rails/idealview/lib/resque_process_email.rb"
