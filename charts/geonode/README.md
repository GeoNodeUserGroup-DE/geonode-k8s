# geonode-k8s

![Version: 1.2.3-alpha](https://img.shields.io/badge/Version-1.2.3--alpha-informational?style=flat-square)

Helm Chart for Geonode. Supported versions: Geonode: 4.4.0, Geoserver: 2.24.4-v1, pyCSW: 2.6.1

**Homepage:** <https://geonode.org/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| mwallschlaeger | <marcel.wallschlaeger@zalf.de> | <https://github.com/mwallschlaeger> |

## Source Code

* <https://github.com/zalf-rdm/geonode-k8s>
* <https://github.com/geonode/geonode>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | memcached | ~7.5.2 |
| https://charts.bitnami.com/bitnami | rabbitmq | ~15.0.3 |
| https://opensource.zalando.com/postgres-operator/charts/postgres-operator/ | postgres-operator | ~1.12.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| favicon | string | AAABAAMAEBAAAAEAIABoBA ... AAAA== | A base64 encoded favicon |
| geonode.accesscontrol.lockdown | string | `"False"` | Enable/Disable lockdown mode of GeoNode |
| geonode.acme.email | string | `"support@example.com"` | the email to be used to gain certificates |
| geonode.acme.enabled | bool | `false` | enables cert-manager to do ACME challenges (aka certificates via letsencrypt) |
| geonode.acme.stageUrl | string | `"https://acme-staging-v02.api.letsencrypt.org/directory"` | ACME staging environment (use acme-staging to avoid running into rate limits) stageUrl: https://acme-v02.api.letsencrypt.org/directory |
| geonode.celery.container_name | string | `"celery"` | celery container name |
| geonode.celery.imagePullPolicy | string | `"IfNotPresent"` | celery image pull policy |
| geonode.celery.resources.limits.cpu | int | `2` | limit cpu as in resource.requests.cpu (https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |
| geonode.celery.resources.limits.memory | string | `"2Gi"` | limits memory as in resource.limits.memory (https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |
| geonode.celery.resources.requests.cpu | int | `1` | requested cpu as in resource.requests.cpu (https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |
| geonode.celery.resources.requests.memory | string | `"1Gi"` | requested memory as in resource.requests.memory (https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |
| geonode.container_name | string | `"geonode"` | container name |
| geonode.general.api_limit_per_page | int | `1000` | to describe |
| geonode.general.debug | bool | `false` | django debug mode |
| geonode.general.debug_static | bool | `false` | enable django static debug |
| geonode.general.display.comments | bool | `true` | DISPLAY_COMMENTS If set to False comments are hidden. |
| geonode.general.display.dataset_link | bool | `true` | DISPLAY_ORIGINAL_DATASET_LINK If set to False original dataset download is hidden. |
| geonode.general.display.rating | bool | `true` | DISPLAY_RATINGS If set to False ratings are hidden. |
| geonode.general.display.social | bool | `true` | DISPLAY_SOCIAL If set to False social sharing is hidden. |
| geonode.general.display.wms_link | bool | `true` | DISPLAY_WMS_LINKS If set to False direct WMS link to GeoServer is hidden. |
| geonode.general.externalDomain | string | `"geonode"` | external ingress hostname |
| geonode.general.externalScheme | string | `"http"` | external ingress schema. If set to 'https', make sure to configure TLS either by configuring tls certificate or using cert-manager. Available options: (http|https) |
| geonode.general.force_reinit | bool | `true` | set force reinit true so that changing passwords etc. in Values.yaml will take effect after restarting the pod this on the other hand will increase pod initializing time, only change if you know what you are doing |
| geonode.general.freetext_keywords_readonly | bool | `false` | FREETEXT_KEYWORDS_READONLY Make Free-Text Keywords writable from users. Or read-only when set to False. |
| geonode.general.geonode_project | string | `"geonode"` | the name of the geonode project used (keep geonode for base image) |
| geonode.general.max_document_size | int | `10` | max upload document size in MB |
| geonode.general.ogc_request_backoff_factor | float | `0.3` | OGC_REQUEST_BACKOFF_FACTOR |
| geonode.general.ogc_request_max_retries | int | `1` | OGC_REQUEST_MAX_RETRIES |
| geonode.general.ogc_request_pool_connections | int | `10` | OGC_REQUEST_POOL_CONNECTIONS |
| geonode.general.ogc_request_pool_maxsize | int | `10` | OGC_REQUEST_POOL_MAXSIZE |
| geonode.general.ogc_request_timeout | int | `600` | OGC_REQUEST_TIMEOUT |
| geonode.general.publishing.admin_moderate_uploads | bool | `false` | ADMIN_MODERATE_UPLOADS When this variable is set to True, every uploaded resource must be approved before becoming visible to the public users. Until a resource is in PENDING APPROVAL state, only the superusers, owner and group members can access it, unless specific edit permissions have been set for other users or groups. A Group Manager can approve the resource, but he cannot publish it whenever the setting RESOURCE_PUBLISHING is set to True. Otherwise, if RESOURCE_PUBLISHING (helm: resource_publishing_by_staff) is set to False, the resource becomes accessible as soon as it is approved. |
| geonode.general.publishing.resource_publishing_by_staff | bool | `false` | RESOURCE_PUBLISHING By default, the GeoNode application allows GeoNode staff members to publish/unpublish resources. By default, resources are published when created. When this setting is set to True the staff members will be able to unpublish a resource (and eventually publish it back). |
| geonode.general.settings_additions | string | `""` | add additional settings to the settings py. This code will be appended to the end of the geonode settings.py |
| geonode.general.settings_module | string | `"geonode.settings"` | the settings module to load |
| geonode.haystack.enabled | bool | `false` | enable hystack |
| geonode.haystack.engine_index_name | string | `"haystack"` | hystack index name |
| geonode.haystack.engine_url | string | `"http://elasticsearch:9200/"` | hystack url |
| geonode.haystack.search_results_per_page | string | `"200"` | hystack results per page |
| geonode.image.name | string | `"geonode/geonode"` | used geonode image |
| geonode.image.tag | string | `"4.4.1"` | tag of used geonode image |
| geonode.imagePullPolicy | string | `"IfNotPresent"` | image pull policy |
| geonode.imagePullSecret | string | `""` | pull secret to use for geonode image |
| geonode.ingress.annotations | object | `{}` | adds ingress annotations for nginx ingress class |
| geonode.ingress.enabled | bool | `true` | enables external access |
| geonode.ingress.ingressClassName | string | `nil` | define kubernetes ingress class for geonode ingress |
| geonode.ingress.tlsSecret | string | `"geonode-tls-secret"` | tls certificate for geonode ingress https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/ (for the use of cert-manager, configure the acme section properly). is used when geonode.general.externalScheme is set to 'https' |
| geonode.init.container_name | string | `"geonode-wait-for-db-and-rabbit"` | init container name |
| geonode.init.image.name | string | `"jwilder/dockerize"` |  |
| geonode.init.image.tag | string | `"0.6.1"` |  |
| geonode.init.imagePullPolicy | string | `"IfNotPresent"` |  |
| geonode.ldap.always_update_user | bool | `true` | always update local user database from ldap |
| geonode.ldap.attr_map_email_addr | string | `"mailPrimaryAddress"` | email attribute used from ldap |
| geonode.ldap.attr_map_first_name | string | `"givenName"` | given name attribute used from ldap |
| geonode.ldap.attr_map_last_name | string | `"sn"` | last name attribute used from ldap |
| geonode.ldap.bind_dn | string | `"CN=Users,DC=ad,DC=example,DC=com"` | ldap user bind dn |
| geonode.ldap.enabled | bool | `false` | enable ldap AUTHENTICATION_BACKENDS in DJANGO Geonode |
| geonode.ldap.group_search_dn | string | `"OU=Groups,DC=ad,DC=example,DC=com"` | ldap group search dn |
| geonode.ldap.group_search_filterstr | string | `"(objectClass=group)"` | ldap group filterstr |
| geonode.ldap.mirror_groups | bool | `true` | Mirror groups with ldap (see https://docs.geonode.org/en/master/advanced/contrib/index.html) |
| geonode.ldap.uri | string | `"ldap://example.com"` | ldap uri |
| geonode.ldap.user_search_dn | string | `"OU=User,DC=ad,DC=example,DC=com"` | ldap user search dn |
| geonode.ldap.user_search_filterstr | string | `"(sAMAccountName=%(user)s)"` | ldap user filterstr |
| geonode.mail.backend | string | `"django.core.mail.backends.smtp.EmailBackend"` | set mail backend in geonode settings |
| geonode.mail.enabled | bool | `false` | enables mail configuration for geonode |
| geonode.mail.host | string | `"smtp.gmail.com"` | set mail host for genode mail |
| geonode.mail.port | string | `"587"` | mail port fo geonode mail |
| geonode.mail.tls | bool | `true` | activate tls for geonode mail (only tls or ssl can be true not both) |
| geonode.mail.use_ssl | bool | `false` | enable ssl for geonode mail (only tls or ssl can be true not both) |
| geonode.memcached.enabled | bool | `true` | enable memcache, this will spawn one or more seperate memcache container(s) and configure django geonode repsectivly. Dynamic caching (see https://docs.djangoproject.com/en/4.0/topics/cache/) |
| geonode.memcached.lock_expire | string | `"3600"` | memcached lock expire time |
| geonode.memcached.lock_timeout | string | `"10"` | memcached lock timeout |
| geonode.monitoring.centralized_dashboard_enabled | bool | `false` |  |
| geonode.monitoring.data_tls | int | `365` |  |
| geonode.monitoring.enabled | bool | `false` |  |
| geonode.monitoring.user_analytics_enabled | bool | `true` |  |
| geonode.monitoring.user_analytics_gzip | bool | `true` |  |
| geonode.persistant.storageSize | string | `"10Gi"` | size of persistant geonode storage |
| geonode.replicaCount | int | `1` | number of geonode replicas (! not working properly yet) |
| geonode.resources.limits.cpu | int | `2` | limit cpu as in resource.requests.cpu (https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |
| geonode.resources.limits.memory | string | `"2Gi"` | limits memory as in resource.limits.memory (https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |
| geonode.resources.requests.cpu | int | `1` | requested cpu as in resource.requests.cpu (https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |
| geonode.resources.requests.memory | string | `"1Gi"` | requested memory as in resource.requests.memory (https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |
| geonode.secret.bing.apiKey | string | `""` |  |
| geonode.secret.django.secretKey | string | `"myv-y4#7j-d*p-__@j#*3z@!y24fz8%^z2v6atuy4bo9vqr1_a"` |  |
| geonode.secret.existingSecretName | string | `""` | name of an existing Secret to use. Set, if you want to separately maintain the Secret. |
| geonode.secret.ldap.bind_password | string | `"password"` | ldap password |
| geonode.secret.mail.from | string | `"changeme@web.de"` | define from mail-addr |
| geonode.secret.mail.password | string | `"changeme"` | set password for mailuser in geonode |
| geonode.secret.mail.user | string | `"changeme"` | define mail user to send mails from |
| geonode.secret.oauth2.clientId | string | `"Jrchz2oPY3akmzndmgUTYrs9gczlgoV20YPSvqaV"` | oauth2 geoserver clientID (OAUTH2_CLIENT_ID) |
| geonode.secret.oauth2.clientSecret | string | `"rCnp5txobUo83EpQEblM8fVj3QT5zb5qRfxNsuPzCqZaiRyIoxM4jdgMiZKFfePBHYXCLd7B8NlkfDBY9HKeIQPcy5Cp08KQNpRHQbjpLItDHv12GvkSeXp6OxaUETv3"` | oauth2 geoserver secret (OAUTH2_CLIENT_SECRET) |
| geonode.secret.superUser.email | string | `"support@example.com"` | admin user password |
| geonode.secret.superUser.password | string | `"geonode"` | admin panel password |
| geonode.secret.superUser.username | string | `"admin"` | admin username |
| geonode.sentry.build_number | int | `0` | sentry build number |
| geonode.sentry.dsn | string | `""` | sentry dsn url |
| geonode.sentry.enabled | bool | `false` | enable sentry integration for geonode |
| geonode.sentry.environment | string | `"development"` | sentry environment |
| geonode.tasks_post_script | string | `"print(\"tasks_post_script not defined ...\")\n"` | additions to tasks.py script at the beginning of the tasks.py, must be additional code written in python |
| geonode.tasks_pre_script | string | `"print(\"tasks_pre_script not defined ...\")\n"` | additions to tasks.py init script, must be additional code written in python |
| geonode.uwsgi.buffer_size | int | `32768` | the max size of a request (request-body excluded) |
| geonode.uwsgi.cheaper | int | `8` | Minimum number of workers allowed |
| geonode.uwsgi.cheaper_busyness_backlog_alert | int | `16` | Spawn emergency workers if more than this many requests are waiting in the queue |
| geonode.uwsgi.cheaper_busyness_backlog_step | int | `2` | How many emergency workers to create if there are too many requests in the queue |
| geonode.uwsgi.cheaper_busyness_max | int | `70` | Above this threshold, spawn new workers |
| geonode.uwsgi.cheaper_busyness_min | int | `20` | Below this threshold, kill workers (if stable for multiplier cycles) |
| geonode.uwsgi.cheaper_busyness_multiplier | int | `30` | How many cycles to wait before killing workers |
| geonode.uwsgi.cheaper_initial | int | `16` | Workers created at startup |
| geonode.uwsgi.cheaper_overload | int | `1` | Length of a cycle in seconds |
| geonode.uwsgi.cheaper_step | int | `16` | How many workers to spawn at a time |
| geonode.uwsgi.harakiri | int | `800` | forcefully kill workers after 60 seconds (MOSTLY REASON FOR TIMEOUTS WHILE UPLOAD) |
| geonode.uwsgi.max_requests | int | `1000` | Restart workers after this many requests |
| geonode.uwsgi.max_worker_lifetime | int | `3600` | Restart workers after this many seconds |
| geonode.uwsgi.processes | int | `128` | Maximum number of workers allowed |
| geonode.uwsgi.reload_on_rss | int | `2048` | Restart workers after this much resident memory |
| geonode.uwsgi.worker_reload_mercy | int | `60` | How long to wait before forcefully killing workers |
| geonode.version | string | `"4.4.0"` | geonode version, used for some distinguassion between version of GeoNode |
| geonodeFixtures | map of fixture files | `{"somefixture.json":"[\n  {\n    \"pk\": 0,\n    \"model\": \"myapp.sample\"\n    \"description\": \"nice little content\"\n  }\n]\n"}` | Fixture files which shall be made available under /usr/src/geonode/geonode/fixtures (refer to https://docs.djangoproject.com/en/4.2/howto/initial-data/) |
| geoserver.container_name | string | `"geoserver"` | geoserver container name |
| geoserver.extraConfigMap | string | `""` | additional elements to include in the config map provided to GeoServer |
| geoserver.extraPodEnv | string | `""` | Define this for extra GeoServer environment variables Format: extraPodEnv: |   - name: KEY_1     value: "VALUE_1"   - name: KEY_2     value: "VALUE_2" |
| geoserver.force_reinit | bool | `true` | set force reinit true so that changing passwords etc. in Values.yaml will take effect after restarting the pod this on the other hand will increase pod initializing time, only change if you know what you are doing |
| geoserver.image.name | string | `"geonode/geoserver"` | geoserver image docker image (default in zalf namespace because geonode one was not up to date) |
| geoserver.image.tag | string | `"2.24.3-latest"` | geoserver docker image tag |
| geoserver.imagePullPolicy | string | `"IfNotPresent"` | geoserver image pull policy |
| geoserver.imagePullSecret | string | `""` | pull secret to use for geoserver image |
| geoserver.port | int | `8080` | geoserver port |
| geoserver.printing.extraHosts | string | `""` |  |
| geoserver.resources.limits.cpu | int | `2` | limit cpu as in resource.requests.cpu (https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |
| geoserver.resources.limits.memory | string | `"4Gi"` | limits memory as in resource.limits.memory (https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |
| geoserver.resources.requests.cpu | int | `1` | requested cpu as in resource.requests.cpu (https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |
| geoserver.resources.requests.memory | string | `"1Gi"` | requested memory as in resource.requests.memory (https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |
| geoserver.secret.admin_factory_password | string | `"geoserver"` | geoserver factory/previous password. This password is used to change the current password for the geoserver admin_user |
| geoserver.secret.admin_password | string | `"geoserver"` | geoserver admin password, respect admin_factory_password, if you gonna change the password from not factory password |
| geoserver.secret.admin_username | string | `"admin"` | geoserver admin username |
| geoserver.secret.existingSecretName | string | `""` | name of an existing Secret to use. Set, if you want to separately maintain the Secret. |
| geoserver.secret.extraSecrets | string | `""` | additional elements to include in the secret provided to GeoServer, if not using an existing secret |
| geoserver_data.container_name | string | `"geoserver-data-dir"` |  |
| geoserver_data.image.name | string | `"geonode/geoserver_data"` | geoserver image docker image (default in zalf namespace because geonode one was not up to date) |
| geoserver_data.image.tag | string | `"2.24.4-v1"` | geoserver docker image tag |
| geoserver_data.imagePullPolicy | string | `"IfNotPresent"` | geoserver image pull policy |
| global.accessMode | string | `"ReadWriteMany"` | storage access mode used by helm dependency pvc |
| global.storageClass | string | `nil` | storageClass used by helm dependencies pvc |
| memcached.architecture | string | `"high-availability"` | memcached replica. Loadbalanaced via kubernetes. (only one entry in django settings.py) im memcached is activated under geonode.memcached.enabled this takes place |
| memcached.replicaCount | int | `1` |  |
| nginx.access_control_allow.credentials | bool | `false` | control value of Access-Control-Allow-Credentials in nginx configuration |
| nginx.container_name | string | `"nginx"` | nginx container name |
| nginx.external_cors.domain | string | `""` | Target domain for CORS |
| nginx.external_cors.enabled | bool | `false` | Add Access-Control-Allow-Origin directive to allow integration from an external domain |
| nginx.image.name | string | `"nginx"` | nginx docker image |
| nginx.image.tag | string | `"1.25"` | nginx docker image tag |
| nginx.imagePullPolicy | string | `"IfNotPresent"` | nginx image pull policy |
| nginx.imagePullSecret | string | `""` | pull secret to use for nginx image |
| nginx.maxClientBodySize | string | `"2G"` | max file upload size |
| nginx.replicaCount | int | `1` | nginx container replicas |
| nginx.resources.limits.cpu | string | `"800m"` | limit cpu as in resource.requests.cpu (https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |
| nginx.resources.limits.memory | string | `"1Gi"` | limits memory as in resource.limits.memory (https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |
| nginx.resources.requests.cpu | string | `"500m"` | requested cpu as in resource.requests.cpu (https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |
| nginx.resources.requests.memory | string | `"1Gi"` | requested memory as in resource.requests.memory (https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |
| postgres-operator.configLoggingRestApi.api_port | int | `8080` | REST API listener listens to this port |
| postgres-operator.enabled | bool | `true` | enable postgres-operator (this or postgresql.enabled NOT both ) |
| postgres-operator.operatorApiUrl | string | `"http://{{ .Release.Name }}-postgres-operator:8080"` | ??? |
| postgres-operator.podServiceAccount | object | `{"name":""}` | not setting the podServiceAccount name will leed to generation of this name. This allows to run multiple postgres-operators in a single kubernetes cluster. just seperating them by namespace. |
| postgres.external.hostname | string | `"my-external-postgres.com"` |  |
| postgres.external.port | int | `5432` |  |
| postgres.external.secret.existingSecretName | string | `""` | name of an existing Secret to use. Set, if you want to separately maintain the Secret. |
| postgres.external.secret.geodata_password | string | `"geogeonode"` |  |
| postgres.external.secret.geonode_password | string | `"geonode"` |  |
| postgres.external.secret.postgres_password | string | `"postgres"` |  |
| postgres.external.ssl | string | `"prefer"` |  |
| postgres.geodata_databasename_and_username | string | `"geodata"` | geoserver database name and username |
| postgres.geonode_databasename_and_username | string | `"geonode"` | geonode database name and username |
| postgres.operator.numberOfInstances | int | `1` | number of database instances |
| postgres.operator.pod_name | string | `"postgresql"` | pod name for postgres containers == teamID for mainifest |
| postgres.operator.postgres_version | int | `15` | postgres version |
| postgres.operator.storageClass | string | `nil` | postgress pv storageclass |
| postgres.operator.storageSize | string | `"3Gi"` | Database storage size |
| postgres.schema | string | `"public"` | database schema |
| postgres.type | string | `"operator"` | type of used postgres: "operator" or "external". \ if external is used, host, port and password have to be set in postgres.external using values or external secret if operator is used, host port and passwords get set automatically using postgres-operator. If your Kubernetes cluster does not have a running postgres-operator, you can install the postgres-operator with  postgres-operator.enabled = true |
| postgres.username | string | `"postgres"` | postgres username |
| pycsw.config | string | based of pycsw example.cfg: https://github.com/geopython/pycsw/blob/master/docker/pycsw.cfg | pycsw config file parameters, see docs: https://docs.pycsw.org/_/downloads/en/latest/pdf/ |
| pycsw.container_name | string | `"pycsw"` | pycsw container name |
| pycsw.enabled | bool | `true` | enable single pycsw pod |
| pycsw.endpoint | string | `"/catalogue/csw"` | pycsw url below geonode.general.externalDomain |
| pycsw.image.name | string | `"geopython/pycsw"` | pycsw docker image |
| pycsw.image.tag | string | `"2.6.1"` | pycsw docker image tag |
| pycsw.imagePullPolicy | string | `"IfNotPresent"` | pycsw image pull policy |
| pycsw.imagePullSecret | string | `""` | pull secret to use for pycsw image |
| pycsw.init.container_name | string | `"pycsw-wait-for-geonode"` |  |
| pycsw.init.image.name | string | `"alpine/curl"` | pycsw docker image |
| pycsw.init.image.tag | string | `"8.5.0"` | pycsw docker image tag |
| pycsw.init.imagePullPolicy | string | `"IfNotPresent"` | pycsw image pull policy |
| pycsw.mappings | string | copied from 4.1.x: https://github.com/GeoNode/geonode/blob/master/geonode/catalogue/backends/pycsw_local_mappings.py | pycsw config file parameters, see docs: https://docs.pycsw.org/_/downloads/en/latest/pdf/ |
| pycsw.port | int | `8000` | pycsw endpoint port |
| pycsw.replicaCount | int | `1` | pycsw container replicas |
| pycsw.resources.limits.cpu | string | `"500m"` | limit cpu as in resource.requests.cpu (https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |
| pycsw.resources.limits.memory | string | `"1Gi"` | limits memory as in resource.limits.memory (https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |
| pycsw.resources.requests.cpu | string | `"500m"` | requested cpu as in resource.requests.cpu (https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |
| pycsw.resources.requests.memory | string | `"1Gi"` | requested memory as in resource.requests.memory (https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |
| rabbitmq.auth.erlangCookie | string | `"jixYBsiZ9RivaLXC02pTwGjvIo0nHtVu"` |  |
| rabbitmq.auth.existingErlangSecret | string | `""` |  |
| rabbitmq.auth.existingPasswordSecret | string | `""` |  |
| rabbitmq.auth.password | string | `"rabbitpassword"` |  |
| rabbitmq.auth.username | string | `"rabbituser"` |  |
| rabbitmq.enabled | bool | `true` |  |
| rabbitmq.limits.cpu | string | `"750m"` | limit cpu as in resource.requests.cpu (https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |
| rabbitmq.limits.memory | string | `"1Gi"` | limits memory as in resource.limits.memory (https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |
| rabbitmq.persistence.enabled | bool | `false` |  |
| rabbitmq.replicaCount | int | `1` | rabbitmq raplica count |
| rabbitmq.requests.cpu | string | `"500m"` | requested cpu as in resource.requests.cpu (https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |
| rabbitmq.requests.memory | string | `"1Gi"` | requested memory as in resource.requests.memory (https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.13.1](https://github.com/norwoodj/helm-docs/releases/v1.13.1)
