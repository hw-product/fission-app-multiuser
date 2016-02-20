require 'fission-app'

# Notifications event hook
FissionApp.subscribe(/^after_render/) do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  if(event.payload[:account].open_notifications.count > 0 && event.payload[:response].content_type.include?('javascript'))
    event.payload[:body].first << FissionApp.auto_popup_formatter(
      :dom_id => 'user-menu-toggle',
      :title => 'OMG!',
      :content => 'YOU HAVE MAIL!',
      :location => 'bottom',
      :duration => 30
    )
  end
end
