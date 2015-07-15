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
      host_key = Rails.application.config.fission.github.keys.detect do |k|
        File.fnmatch(k, host_key)
      end
      host_key ||= 'default'
      env['omniauth.strategy'].options[:client_id] = Rails.application.config.fission.github[host_key][:key]
      env['omniauth.strategy'].options[:client_secret] = Rails.application.config.fission.github[host_key][:secret]
      env['omniauth.strategy'].options[:scope] = 'user:email,repo'
    }
  )
end

OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}

OmniAuth.config.logger = Rails.logger
