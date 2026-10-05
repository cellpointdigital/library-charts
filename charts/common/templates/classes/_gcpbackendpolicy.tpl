{{/*
This template serves as a blueprint for all GCPBackendPolicy objects that are
created within the common library.
GCPBackendPolicy is a GKE Gateway API policy (networking.gke.io/v1) that
attaches to a Service and configures backend-level load balancer behavior,
such as timeouts, connection draining, access logging, session affinity,
Cloud Armor security policies and IAP.
*/}}
{{- define "common.classes.gcpbackendpolicy" -}}
  {{- $fullName := include "common.names.fullname" . -}}
  {{- $policyName := $fullName -}}
  {{- $values := .Values.gcpBackendPolicy -}}

  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.gcpBackendPolicy -}}
      {{- $values = . -}}
    {{- end -}}
  {{ end -}}

  {{- if and (hasKey $values "nameOverride") $values.nameOverride -}}
    {{- $policyName = printf "%v-%v" $policyName $values.nameOverride -}}
  {{- end -}}

  {{/* Resolve the target service name */}}
  {{- $primaryService := get .Values.service (include "common.service.primary" .) -}}
  {{- $targetName := $fullName -}}
  {{- if and (hasKey $primaryService "nameOverride") $primaryService.nameOverride -}}
    {{- $targetName = printf "%v-%v" $fullName $primaryService.nameOverride -}}
  {{- end -}}
  {{- if and $values.targetRef $values.targetRef.name -}}
    {{- $targetName = tpl $values.targetRef.name $ -}}
  {{- end -}}

  {{- $targetKind := "Service" -}}
  {{- if and $values.targetRef $values.targetRef.kind -}}
    {{- $targetKind = $values.targetRef.kind -}}
  {{- end -}}

  {{- $targetGroup := "" -}}
  {{- if and $values.targetRef $values.targetRef.group -}}
    {{- $targetGroup = $values.targetRef.group -}}
  {{- end -}}

  {{- $default := $values.default | default dict -}}
---
apiVersion: {{ include "common.capabilities.gcpbackendpolicy.apiVersion" . }}
kind: GCPBackendPolicy
metadata:
  name: {{ $policyName }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
    {{- with $values.labels }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with $values.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  targetRef:
    group: {{ $targetGroup | quote }}
    kind: {{ $targetKind }}
    name: {{ $targetName }}
  {{- if (compact (values $default)) }}
  default:
    {{- with $default.timeoutSec }}
    timeoutSec: {{ . }}
    {{- end }}
    {{- with $default.connectionDraining }}
    connectionDraining:
      {{- if hasKey . "drainingTimeoutSec" }}
      drainingTimeoutSec: {{ .drainingTimeoutSec }}
      {{- end }}
    {{- end }}
    {{- with $default.logging }}
    logging:
      {{- if hasKey . "enabled" }}
      enabled: {{ .enabled }}
      {{- end }}
      {{- if hasKey . "sampleRate" }}
      sampleRate: {{ int64 .sampleRate }}
      {{- end }}
      {{- with .optionalMode }}
      optionalMode: {{ . }}
      {{- end }}
      {{- with .optionalFields }}
      optionalFields:
        {{- toYaml . | nindent 8 }}
      {{- end }}
    {{- end }}
    {{- with $default.sessionAffinity }}
    sessionAffinity:
      {{- with .type }}
      type: {{ . }}
      {{- end }}
      {{- if hasKey . "cookieTtlSec" }}
      cookieTtlSec: {{ .cookieTtlSec }}
      {{- end }}
    {{- end }}
    {{- with $default.securityPolicy }}
    securityPolicy: {{ . | quote }}
    {{- end }}
    {{- with $default.iap }}
    iap:
      {{- if hasKey . "enabled" }}
      enabled: {{ .enabled }}
      {{- end }}
      {{- with .oauth2ClientSecret }}
      oauth2ClientSecret:
        name: {{ .name | quote }}
      {{- end }}
      {{- with .clientID }}
      clientID: {{ . | quote }}
      {{- end }}
    {{- end }}
    {{- with $default.maxRatePerEndpoint }}
    maxRatePerEndpoint: {{ . }}
    {{- end }}
    {{- with $default.backends }}
    backends:
      {{- toYaml . | nindent 6 }}
    {{- end }}
  {{- end }}
{{ end }}
