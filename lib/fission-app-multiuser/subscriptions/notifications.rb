require 'fission-app'

# Notifications event hook
FissionApp.subscribe(/fission_app$/) do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  if(event.payload[:account])
    event_matchers = Fission::Data::Models::AppEventMatcher.all.find_all do |aem|
      File.fnmatch(aem.pattern, event.name)
    end
    event_matchers.each do |aem|
      aem.notifications.each do |notification|
        unless(notification.accounts.include?(event.payload[:account]))
          notification.add_account event.payload[:account]
        end
      end
    end
  end
end
