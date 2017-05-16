require_relative "access"

require 'clockwork'
include Clockwork


every(20.minutes, 'hello.job') do
  `bundle exec ruby src/access.rb`
end
