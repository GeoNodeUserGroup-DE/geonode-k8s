# Setup GeoNode-K8s to Work with Keycloak backend

OpenID Connect integration, for SSIO applications such as keycloak, into Django applications are usually implemented using the django.allauth package. This requires a number of configurations to be added to settings.py. Geonode-k8s provides the capability to add configuration to your settings.py, also without predefined environment variable parsing. There for the `.geonode.general.settings_additions` value can be used. The python code defined inside this value will be attached to the end of the settings.py of geonode.

In the example below, a simple OpenID Connect endpoint is configured, forcing email authentication with `ACCOUNT_EMAIL_REQUIRED = True` and `ACCOUNT_AUTHENTICATION_METHOD = "email"`. A social account provider is configured within `SOCIALACCOUNT_PROVIDERS`. This is an OpenID Connect provider (see [django-allauth documentation](https://docs.allauth.org/en/latest/socialaccount/providers/openid_connect.html)). The example uses placeholders (e.g., `$KEYCLOAK_PROVIDER_ID`, `$KEYCLOAK_CLIENT_ID`) which you must replace with the actual values from your Keycloak client configuration.

```
geonode:
  general:
    settings_additions: |-
      ACCOUNT_EMAIL_REQUIRED = True
      ACCOUNT_AUTHENTICATION_METHOD = "email"
      SOCIALACCOUNT_PROVIDERS = {
        "openid_connect": {
          "OAUTH_PKCE_ENABLED": True,
          "APPS": [
            {
              "provider_id": "$KEYCLOAK_PROVIDER_ID",
              "name": "$PROVIDER_NAME",
              "client_id": "$KEYCLOAK_CLIENT_ID",
              "secret": "$KEYCLOAK_CLIENT_SECRET",
              "settings": {
                  "server_url": "https://identity.example.keycloak.org/realms/$KEYCLOAK_REALM/.well-known/openid-configuration",
              },
            }
          ]
        }
      }
      INSTALLED_APPS += ('allauth.socialaccount.providers.openid_connect',)
      AUTHENTICATION_BACKENDS += ('allauth.account.auth_backends.AuthenticationBackend', )
      CSRF_TRUSTED_ORIGINS = ['https://identity.example.keycloak.org']
```