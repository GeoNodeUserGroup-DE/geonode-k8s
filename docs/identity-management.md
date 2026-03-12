# Identity Management

This docuentation describes how to integrate different identity backends, which are generally support by geonode, in the geonode helm deployment. As the geonode-k8s chart wants to use the official geonode images provided by geosolutions, this requires that users A build their own images to integrate e.g. further requirements, like python packages or installing contrib modules. This documentation describes howto integrate LDAP and OAUTH2 identity management without changing the geonode images itself, for the sake of slower starttime performance of geonode related containers and jobs.


## LDAP integration

To integrate LDAP into a GeoNOde instance, there are well known ways to do so. The firs

```
  ldap:
    # -- enable ldap AUTHENTICATION_BACKENDS in DJANGO Geonode
    enabled: False
    # -- ldap uri
    uri: ldap://example.com
    # -- ldap user bind dn
    bind_dn: "CN=Users,DC=ad,DC=example,DC=com"
    # -- ldap user search dn
    user_search_dn: "OU=User,DC=ad,DC=example,DC=com"
    # -- ldap user filterstr
    user_search_filterstr: "(sAMAccountName=%(user)s)"
    # -- Mirror groups with ldap (see https://docs.geonode.org/en/master/advanced/contrib/index.html)
    mirror_groups: True
    # -- always update local user database from ldap
    always_update_user: True
    # -- ldap group search dn
    group_search_dn: "OU=Groups,DC=ad,DC=example,DC=com"
    # -- ldap group filterstr
    group_search_filterstr: "(objectClass=group)"
    # -- given name attribute used from ldap
    attr_map_first_name: "givenName"
    # -- last name attribute used from ldap
    attr_map_last_name: "sn"
    # -- email attribute used from ldap
    attr_map_email_addr: mailPrimaryAddress
```

```
  # LDAP Configuration
  LDAP_ENABLED:  {{ include "boolean2str" .Values.geonode.ldap.enabled | quote }}
  LDAP_SERVER_URL: {{ .Values.geonode.ldap.uri | quote }}
  LDAP_BIND_DN: {{ .Values.geonode.ldap.bind_dn | quote }}
  LDAP_USER_SEARCH_DN: {{ .Values.geonode.ldap.user_search_dn | quote }}
  LDAP_USER_SEARCH_FILTERSTR: {{ .Values.geonode.ldap.user_search_filterstr | quote }}
  LDAP_ALWAYS_UPDATE_USER: {{ .Values.geonode.ldap.always_update_user | quote }}
  LDAP_MIRROR_GROUPS: {{ include "boolean2str" .Values.geonode.ldap.mirror_groups | quote }}
  LDAP_GROUP_SEARCH_DN: {{ .Values.geonode.ldap.group_search_dn | quote }}
  LDAP_GROUP_SEARCH_FILTERSTR: {{ .Values.geonode.ldap.group_search_filterstr | quote }}
  
  LDAP_USER_ATTR_MAP_FIRST_NAME: {{ .Values.geonode.ldap.attr_map_first_name | quote }}
  LDAP_USER_ATTR_MAP_LAST_NAME: {{ .Values.geonode.ldap.attr_map_last_name | quote }}
  LDAP_USER_ATTR_MAP_EMAIL_ADDR: {{ .Values.geonode.ldap.attr_map_email_addr | quote }}
  ```