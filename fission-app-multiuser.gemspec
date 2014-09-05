$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__)) + '/lib/'
require 'fission-app-multiuser/version'
Gem::Specification.new do |s|
  s.name = 'fission-app-multiuser'
  s.version = FissionApp::Multiuser::VERSION.version
  s.summary = 'Fission App Mulitple Users'
  s.author = 'Heavywater'
  s.email = 'fission@hw-ops.com'
  s.homepage = 'http://github.com/heavywater/fission-app-multiuser'
  s.description = 'Fission application multi user support'
  s.require_path = 'lib'
  s.add_dependency 'fission-data'
  s.add_dependency 'fission-app'
  s.add_dependency 'omniauth', '~> 1.1'
  s.add_dependency 'omniauth-github'
  s.files = Dir['**/*']
end
