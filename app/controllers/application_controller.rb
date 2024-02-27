class ApplicationController < ActionController::Base
  protect_from_forgery prepend: true
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden, content_type: 'application/json' }
      format.html { redirect_to main_app.root_url, alert: exception.message }
      format.js { head :forbidden, content_type: 'application/javascript' }
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name profile_image])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name profile_image])
  end

  def after_sign_in_path_for(_resource)
    authenticated_root_path
  end

  def after_sign_up_path_for(_resource)
    authenticated_root_path
  end
end
