Gem::Specification.new do |s|
  s.name        = "fizzy_authentik"
  s.version     = "0.1.0"
  s.summary     = "Authentik (OpenID Connect) SSO plugin for Fizzy"
  s.description = "Mounts /auth/authentik into the host app and provisions Fizzy identities from Authentik logins."
  s.authors     = [ "ZCP" ]
  s.license     = "MIT"

  s.files = Dir[ "{app,config,lib}/**/*", "README.md" ]

  s.required_ruby_version = ">= 3.2"

  s.add_dependency "rails", ">= 7.0"
  s.add_dependency "omniauth", "~> 2.1"
  s.add_dependency "omniauth_openid_connect", ">= 0.8"
end
