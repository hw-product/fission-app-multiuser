class NotificationsDashboardCell < DashboardCell

  def show(args)
    super
    @notifications = current_user.all_open_notifications.order(
      :created_at.desc
    ).limit(5)
    render
  end

end
