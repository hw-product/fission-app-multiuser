# Configuration for OmniAuth support

require 'omniauth'
require 'omniauth-github'

Rails.application.config.middleware.use OmniAuth::Builder do
  if(Rails.env.production? || ENV['FISSION_AUTHENTICATION_OMNIAUTH'] == 'true')
    Rails.application.config.omniauth_provider = :identity
  else
    Rails.application.config.omniauth_provider = :developer
  end
  provider(
    :github,
    :setup => lambda {|env|
      host_key = env['SERVER_NAME']
      unless(Rails.application.config.fission.github.keys.include?(host_key))
        host_key = 'default'
      end
      params = Rack::Utils.parse_query(URI.parse(env['REQUEST_URI']).query)
      case params['access']
      when 'public'
        scope = 'user,public_repo'
      when 'all'
        scope = 'user,repo'
      else
        scope = ''
      end
      env['omniauth.strategy'].options[:client_id] = Rails.application.config.fission.github[host_key][:key]
      env['omniauth.strategy'].options[:client_secret] = Rails.application.config.fission.github[host_key][:secret]
      env['omniauth.strategy'].options[:scope] = scope unless scope.empty?
    }
  )
end

OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}

OmniAuth.config.logger = Rails.logger
