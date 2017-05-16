require_relative "access"

require 'clockwork'
include Clockwork

every(1.hour, 'job', at: ['10:00', '19:00']) 
   `bundle exec ruby src/access.rb`
end
