class ProductStyleController < ApplicationController

  before_action :validate_user!, :except => [:stylesheet]
  before_action :validate_access!, :except => [:stylesheet]

  def stylesheet
    respond_to do |format|
      format.html do
        root_path = FissionApp::Multiuser::Styler.new.styles_root
        render(
          :file => File.join(root_path, "#{params[:name]}.css"),
          :layout => false,
          :content_type => 'text/css'
        )
      end
    end
  end

end
