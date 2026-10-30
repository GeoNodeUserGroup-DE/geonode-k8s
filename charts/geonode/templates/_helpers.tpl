
# define pod names (equal service names)
{{- define "geoserver_pod_name" -}}
{{ .Release.Name }}-geoserver
{{- end -}}

{{- define "geonode_pod_name" -}}
{{ .Release.Name }}-geonode
{{- end -}}

{{- define "postgres_pod_name" -}}
{{ .Release.Name }}-postgres
{{- end -}}

{{- define "nginx_pod_name" -}}
{{ .Release.Name }}-nginx
{{- end -}}

{{- define "pycsw_pod_name" -}}
{{ .Release.Name }}-pycsw
{{- end -}}

# define secret names
{{- define "geoserver_secret_name" -}}
{{ .Release.Name }}-geoserver-secret
{{- end -}}

{{- define "geonode_secret_name" -}}
{{ .Release.Name }}-geonode-secret
{{- end -}}



# Database definitions
{{- define "database_hostname" -}}
{{- if (eq .Values.postgres.type "operator") -}}
{{ include "postgres_pod_name" . }}
{{- else if (eq .Values.postgres.type "external") -}}
{{- .Values.postgres.external.hostname -}}
{{- end -}}
{{- end -}}

{{- define "database_port" -}}
{{- if (eq .Values.postgres.type "operator") -}}
5432
{{- else if (eq .Values.postgres.type "external") -}}
{{ .Values.postgres.external.port }}
{{- end -}}
{{- end -}}

{{- define "database_ssl" -}}
{{- if (eq .Values.postgres.type "operator") -}}
require
{{- else if (eq .Values.postgres.type "external") -}}
{{ .Values.postgres.external.ssl }}
{{- end -}}
{{- end -}}

# secret key reference for the password of user:  .Values.postgres.username
{{- define "database_postgres_password_secret_key_ref" -}}
{{- if (eq .Values.postgres.type "operator") -}}
"{{ .Values.postgres.username }}.{{ include "postgres_pod_name" . }}.credentials.postgresql.acid.zalan.do"
{{- else if and (eq .Values.postgres.type "external") (not .Values.postgres.external.secret.existingSecretName ) -}}
"{{ .Release.Name }}-postgres-external-secrets"
{{- else -}}
"{{.Values.postgres.external.secret.existingSecretName }}"
{{- end -}}
{{- end -}}

# secret key reference for the password of user:  .Values.postgres.geonode_databasename_and_username
{{- define "database_geonode_password_secret_key_ref" -}}
{{- if (eq .Values.postgres.type "operator") -}}
"{{ .Values.postgres.geonode_databasename_and_username }}.{{ include "postgres_pod_name" . }}.credentials.postgresql.acid.zalan.do"
{{- else if and (eq .Values.postgres.type "external") (not .Values.postgres.external.secret.existingSecretName ) -}}
"{{ .Release.Name }}-geonode-external-secrets"
{{- else -}}
"{{.Values.postgres.external.secret.existingSecretName }}"
{{- end -}}
{{- end -}}

# secret key reference for the password of user: .Values.postgres.geodata_databasename_and_username
{{- define "database_geodata_password_secret_key_ref" -}}
{{- if (eq .Values.postgres.type "operator") -}}
"{{ .Values.postgres.geodata_databasename_and_username }}.{{ include "postgres_pod_name" . }}.credentials.postgresql.acid.zalan.do"
{{- else if and (eq .Values.postgres.type "external") (not .Values.postgres.external.secret.existingSecretName ) -}}
"{{ .Release.Name }}-geodata-external-secrets"
{{- else if .Values.postgres.external.secret.existingSecretName -}}
"{{.Values.postgres.external.secret.existingSecretName }}"
{{- end -}}
{{- end -}}

# define password key name in geonode postgres secret
{{- define "database_geonode_password_key_ref" -}}
{{- if (eq .Values.postgres.type "operator") -}}
password
{{- else if (eq .Values.postgres.type "external") -}}
geonode-password
{{- end -}}
{{- end -}}

# define password key name in geodata postgres secret
{{- define "database_geodata_password_key_ref" -}}
{{- if (eq .Values.postgres.type "operator") -}}
password
{{- else if (eq .Values.postgres.type "external") -}}
geodata-password
{{- end -}}
{{- end -}}

# define password key name in postgres postgres secret
{{- define "database_postgres_password_key_ref" -}}
{{- if (eq .Values.postgres.type "operator") -}}
password
{{- else if (eq .Values.postgres.type "external") -}}
postgres-password
{{- end -}}
{{- end -}}

# Volume names
{{- define "pvc_statics_name" -}}
pvc-{{ .Release.Name }}-geonode-statics
{{- end -}}

{{- define "pvc_geoserver_data_name" -}}
pvc-{{ .Release.Name }}-geonode-geoserver-data
{{- end -}}

{{- define "pvc_backup_restore_name" -}}
pvc-{{ .Release.Name }}-geonode-backup-restore
{{- end -}}

{{- define "pvc_data_name" -}}
pvc-{{ .Release.Name }}-geonode-data
{{- end -}}

# ports and endpoints
{{- define "rabbit_host" -}}
{{ .Release.Name }}-rabbitmq:5672
{{- end -}}

{{- define "redis_host" -}}
{{ .Release.Name }}-redis:6379
{{- end -}}

{{- define "broker_url" -}}
{{- if .Values.rabbitmq.enabled -}}
amqp://{{ .Values.rabbitmq.auth.username }}:{{ .Values.rabbitmq.auth.password }}@{{ include "rabbit_host" . }}/
{{- else if .Values.redis.enabled -}}
{{- if .Values.redis.auth.enabled -}}
redis://:{{ .Values.redis.auth.password }}@{{ include "redis_host" . }}/0
{{- else -}}
redis://{{ include "redis_host" . }}/0
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "result_backend_url" -}}
{{- if .Values.redis.enabled -}}
{{- if .Values.redis.auth.enabled -}}
redis://:{{ .Values.redis.auth.password }}@{{ include "redis_host" . }}/1
{{- else -}}
redis://{{ include "redis_host" . }}/1
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "public_url" -}}
{{ .Values.geonode.general.externalScheme }}://{{ .Values.geonode.general.externalDomain }}
{{- end -}}

# function
{{- define "boolean2str" -}}
{{ . | ternary "True" "False" }}
{{- end -}}

{{- define "settings_module" -}}
{{- if (not .Values.geonode.general.settings_module) -}}
{{ .Values.geonode.general.geonode_project }}.settings
{{- else -}}
{{ .Values.geonode.general.settings_module }}
{{- end -}}
{{- end -}}

{{- define "geonode_root_path" -}}
/usr/src/{{ .Values.geonode.general.geonode_project }}
{{- end -}}

{{- define "geonode_path" -}}
/usr/src/{{ .Values.geonode.general.geonode_project }}/{{ .Values.geonode.general.geonode_project }}
{{- end -}}

{{- define "initial_data_path" -}}
{{- if (eq .Values.geonode.general.geonode_project "geonode") -}}
geonode/base/fixtures/initial_data.json
{{- else -}}
initial_data.json
{{- end -}}
{{- end -}}

# Hard co-location affinity for workloads sharing RWO block-storage PVCs
# (statics, geoserver-data, data). Anchors all consumers to the node of the
# geonode pod, since RWO volumes can only be mounted on a single node.
{{- define "geonode.colocation_affinity" -}}
{{- if .Values.geonode.colocation.enabled }}
affinity:
  podAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchLabels:
          org.geonode.instance: "{{ include "geonode_pod_name" . }}"
      topologyKey: kubernetes.io/hostname
{{- end }}
{{- end -}}

# Tolerations for workload pods. Renders a tolerations block; emits nothing when the list is empty.
{{- define "geonode.tolerations" -}}
{{- with .Values.global.tolerations }}
tolerations:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Convert a memory quantity (whole number with Gi, Mi, G or M) to Mi.
Expects a dict with the keys "name" (values path used in errors) and "value".
*/}}
{{- define "memory_in_mi" -}}
{{- $value := toString .value -}}
{{- if not (regexMatch "^[0-9]+(Gi|Mi|G|M)$" $value) -}}
{{- fail (printf "%s must be a whole number with the unit Gi, Mi, G or M, got: %s" .name $value) -}}
{{- end -}}
{{- $number := regexFind "^[0-9]+" $value | atoi -}}
{{- if hasSuffix "Gi" $value -}}
{{- mul $number 1024 -}}
{{- else if hasSuffix "Mi" $value -}}
{{- $number -}}
{{- else if hasSuffix "G" $value -}}
{{- div (mul $number 1000000000) 1048576 -}}
{{- else -}}
{{- div (mul $number 1000000) 1048576 -}}
{{- end -}}
{{- end -}}

{{/*
Refuse to deploy GeoServer with a heap or container limit that is too small.
The container limit also has to hold memory outside the Java heap (metaspace,
thread stacks, native rendering), so it must exceed the heap by the headroom.
*/}}
{{- define "geoserver_validate_heap" -}}
{{- $minHeapMi := 1024 -}}
{{- $minHeadroomMi := 1024 -}}
{{- $heap := .Values.geoserver.heap -}}
{{- $limit := .Values.geoserver.resources.limits.memory -}}
{{- range $name, $value := dict "initialSize" $heap.initialSize "maxSize" $heap.maxSize -}}
{{- if not (regexMatch "^[0-9]+(Gi|Mi)$" (toString $value)) -}}
{{- fail (printf "geoserver.heap.%s must be a whole number with the unit Gi or Mi, got: %v" $name $value) -}}
{{- end -}}
{{- end -}}
{{- $initialMi := include "memory_in_mi" (dict "name" "geoserver.heap.initialSize" "value" $heap.initialSize) | atoi -}}
{{- $maxMi := include "memory_in_mi" (dict "name" "geoserver.heap.maxSize" "value" $heap.maxSize) | atoi -}}
{{- $limitMi := include "memory_in_mi" (dict "name" "geoserver.resources.limits.memory" "value" $limit) | atoi -}}
{{- if lt $maxMi $minHeapMi -}}
{{- fail (printf "geoserver.heap.maxSize is %s, but GeoServer needs at least %dMi of Java heap" $heap.maxSize $minHeapMi) -}}
{{- end -}}
{{- if gt $initialMi $maxMi -}}
{{- fail (printf "geoserver.heap.initialSize (%s) must not be larger than geoserver.heap.maxSize (%s), the JVM would not start" $heap.initialSize $heap.maxSize) -}}
{{- end -}}
{{- if lt $limitMi (add $maxMi $minHeadroomMi | int) -}}
{{- fail (printf "geoserver.resources.limits.memory is %s, but it must be at least %dMi: geoserver.heap.maxSize (%s) plus %dMi for memory outside the Java heap. Raise the limit or lower geoserver.heap.maxSize" $limit (add $maxMi $minHeadroomMi) $heap.maxSize $minHeadroomMi) -}}
{{- end -}}
{{- end -}}
