require 'fission-app'

# Notifications event hook
FissionApp.subscribe(/^(before|after)_render/) do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  type = event.payload[:response].content_type
  if(type.include?('javascript') || type.include?('html'))
    if((n_count = event.payload[:account].open_notifications.count) > 0)
      item = FissionApp.auto_popup_formatter(
        :dom_id => 'user-menu',
        :title => 'Notifications',
        :content => "New notifications <a href=\"/notifications\">(#{n_count})</a>",
        :location => 'bottom',
        :duration => 10
      )
      if(type.include?('javascript'))
        event.body.first << item
      else
        event.payload[:user].run_state.script_inject << item
      end
    end
  end
end
