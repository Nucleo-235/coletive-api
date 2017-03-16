class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_locale, unless: :devise_controller?
  before_action :persist_locale, unless: :devise_controller?
  before_action :set_editor_config, unless: :devise_controller?
  before_action :set_localizable_page

  VisibleLocales = [ 'pt-BR' ]
  # VisibleLocales = [:en, 'pt-BR']

  def after_sign_up_path_for(resource)
    root_path
  end

  def after_sign_in_path_for(resource)
    root_path
  end

  def after_sign_out_path_for(resource)
    root_path
  end

  private
    def redirect_to_locale_if_not_set
      if params[:locale]
        begin
          I18n.locale = string_to_locale(params[:locale]).to_sym
        rescue
          redirect_to url_for(request.params.merge({ locale: I18n.default_locale }))
        end
        # current_user_or_visitor.update(locale: I18n.locale.to_s)
      else
        locale = request_locale || I18n.default_locale
        redirect_to url_for(request.params.merge({ locale: locale }))
      end
    end

    def get_locale
      # params[:locale] || visitor_locale || request_locale || I18n.default_locale
      params[:locale] ? string_to_locale(params[:locale]) : (session[:locale] || request_locale || I18n.default_locale)
    end

    def set_locale
      current_locale = get_locale.to_sym
      if I18n.available_locales.include? current_locale
        I18n.locale = current_locale
        session[:locale] = current_locale
      else
        redirect_to url_for(request.params.merge({ locale: I18n.default_locale }))
      end
    end

    def persist_locale
      # current_user_or_visitor.update(locale: I18n.locale.to_s) if params[:locale]
    end

    def request_locale
      extra_locales = [:pt]
      locale = http_accept_language.preferred_language_from(I18n.available_locales + extra_locales)
      locale = 'pt-BR' if locale == :pt || locale.to_s.downcase == 'pt-pt' || locale.to_s.downcase == 'pt-br'

      locale = false if !ApplicationController::VisibleLocales.include?(locale) 
      locale
    end

    def default_url_options(options = {})
      args = { locale: get_locale }
      # logger.debug args.to_json
      args
    end

    def string_to_locale(value)
      locale_values = value.split('-')
      if locale_values.length == 2
        return "#{locale_values[0]}-#{locale_values[1].upcase}"
      else
        return locale_values[0]
      end
    end

    def set_editor_config
      @can_edit = current_user && current_user.type == 'Admin' && params[:view_as] != "user"
      @inplace_editing_mode = (@can_edit ? 'edit' : 'read')
    end

    def set_localizable_page
      @global_page = LocalizableValue::LocalizedPage.global_page

      route_control = controller_name ? controller_name : 'root'
      route_action = action_name ? action_name : 'home'
      @current_page = LocalizableValue::LocalizedPage.current_page(route_control, route_action)
    end
end
