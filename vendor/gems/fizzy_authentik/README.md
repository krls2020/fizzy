# fizzy_authentik

Drop-in Authentik (OpenID Connect) SSO for Fizzy. Mounts at `/auth/authentik`
and auto-provisions Fizzy identities for Authentik logins.

## Install

Add to host `Gemfile`:

```ruby
gem "fizzy_authentik", path: "vendor/gems/fizzy_authentik"
```

Render the sign-in button in `app/views/sessions/new.html.erb` (or anywhere):

```erb
<%= render "fizzy_authentik/button" %>
```

That's the entire footprint in the host app.

## Configure

Environment variables (all required unless noted):

| Var | Purpose |
| --- | --- |
| `AUTHENTIK_ISSUER` | OIDC issuer URL (ends with `/`) |
| `AUTHENTIK_CLIENT_ID` | OAuth2 client id from Authentik provider |
| `AUTHENTIK_CLIENT_SECRET` | OAuth2 client secret |
| `APP_URL` | Public base URL of the Fizzy app |
| `SSO_DEFAULT_ACCOUNT_EXTERNAL_ID` | Optional. If set, unknown emails are auto-added as members of this Fizzy Account. Empty = reject unknown emails. |

With `AUTHENTIK_CLIENT_ID` unset, the plugin is dormant — no middleware
registered, no routes, the partial renders nothing.

## Routes

- `GET/POST /auth/authentik` — OmniAuth request phase, redirects to Authentik
- `GET /auth/authentik/callback` — OmniAuth callback, signs the user in
- `GET /auth/failure` — redirect target on SSO error

## Behavior

1. Authentik authenticates the user and returns `email` + `name` claims.
2. The plugin looks up `Identity` by email. If found → start Fizzy session.
3. If not found and `SSO_DEFAULT_ACCOUNT_EXTERNAL_ID` is set → create Identity
   and a `:member` User in that Account, then start session.
4. Otherwise → redirect to sign-in with an error.

## Upgrade safety

The plugin ships as a Rails Engine. It does not patch host files. When
upstream Fizzy updates, the only two lines to rebase are the `Gemfile` entry
and the partial render in the sign-in view.
