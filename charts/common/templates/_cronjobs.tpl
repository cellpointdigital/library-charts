{{/*
Template for multiple cronjobs.
*/}}
{{- define "common.cronjobs" }}
  {{- /* Generate named cronjobs */ -}}
  {{- range $index, $key := (keys .Values.cronjobs | uniq | sortAlpha) }}
    {{- $cronJobItem := get $.Values.cronjobs $key }}
    {{- if not $cronJobItem.name -}}
      {{- $_ := set $cronJobItem "name" $key }}
    {{- end }}
    {{- $_ := unset $ "cronjobValues" -}}
    {{- $_ := set $ "cronjobValues" $cronJobItem -}}
    {{- include "common.cronjobitem" $ }}
  {{- end }}
{{- end }}
