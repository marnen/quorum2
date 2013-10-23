# Security patch from http://seclists.org/oss-sec/2013/q4/118
# TODO: remove when upgrading to Rails 3.2 or higher.

require 'action_mailer'

module ActionMailer
  class LogSubscriber < ActiveSupport::LogSubscriber
    def deliver(event)
      recipients = Array.wrap(event.payload[:to]).join(', ')
      info("\nSent mail to #{recipients} (#{event.duration.round(1)}ms)")
      debug(event.payload[:mail])
    end
  end
end