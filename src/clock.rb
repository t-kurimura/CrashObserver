require_relative "access"

require 'clockwork'
include Clockwork

every(1.hour, 'job', at: ['10:00', '19:00']) do
  print_crash_info
end
