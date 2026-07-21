{{/*
This template serves as a blueprint for all HealthCheckPolicy objects that are
created within the common library.
HealthCheckPolicy is a GKE Gateway API policy (networking.gke.io/v1) that
attaches to a Service and configures backend health checks on GCP load balancers.
*/}}
{{- define "common.classes.healthcheckpolicy" -}}
  {{- $fullName := include "common.names.fullname" . -}}
  {{- $policyName := $fullName -}}
  {{- $values := .Values.healthCheckPolicy -}}

  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.healthCheckPolicy -}}
      {{- $values = . -}}
    {{- end -}}
  {{ end -}}

  {{- if and (hasKey $values "nameOverride") $values.nameOverride -}}
    {{- $policyName = printf "%v-%v" $policyName $values.nameOverride -}}
  {{- end -}}

  {{/* Resolve the target service name */}}
  {{- $targetName := $fullName -}}
  {{- if $values.targetRef -}}
    {{- if $values.targetRef.name -}}
      {{- $targetName = tpl $values.targetRef.name $ -}}
    {{- end -}}
  {{- else -}}
    {{- $primaryService := get .Values.service (include "common.service.primary" .) -}}
    {{- if and (hasKey $primaryService "nameOverride") $primaryService.nameOverride -}}
      {{- $targetName = printf "%v-%v" $fullName $primaryService.nameOverride -}}
    {{- end -}}
  {{- end -}}

  {{- $targetKind := "Service" -}}
  {{- if and $values.targetRef $values.targetRef.kind -}}
    {{- $targetKind = $values.targetRef.kind -}}
  {{- end -}}

  {{- $targetGroup := "" -}}
  {{- if and $values.targetRef $values.targetRef.group -}}
    {{- $targetGroup = $values.targetRef.group -}}
  {{- end -}}
---
apiVersion: {{ include "common.capabilities.healthcheckpolicy.apiVersion" . }}
kind: HealthCheckPolicy
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
  default:
    checkIntervalSec: {{ $values.default.checkIntervalSec | default 15 }}
    timeoutSec: {{ $values.default.timeoutSec | default 15 }}
    healthyThreshold: {{ $values.default.healthyThreshold | default 1 }}
    unhealthyThreshold: {{ $values.default.unhealthyThreshold | default 2 }}
    {{- with $values.default.logConfig }}
    logConfig:
      enabled: {{ .enabled | default false }}
    {{- end }}
    config:
      type: {{ $values.default.config.type | default "HTTP" }}
      {{- $checkType := $values.default.config.type | default "HTTP" }}
      {{- if eq $checkType "HTTP" }}
      httpHealthCheck:
        port: {{ ($values.default.config.httpHealthCheck | default dict).port | default (include "common.healthcheckpolicy.defaultPort" .) }}
        requestPath: {{ ($values.default.config.httpHealthCheck | default dict).requestPath | default "/healthz" | quote }}
        {{- with ($values.default.config.httpHealthCheck | default dict).host }}
        host: {{ . | quote }}
        {{- end }}
      {{- else if eq $checkType "HTTPS" }}
      httpsHealthCheck:
        port: {{ ($values.default.config.httpsHealthCheck | default dict).port | default (include "common.healthcheckpolicy.defaultPort" .) }}
        requestPath: {{ ($values.default.config.httpsHealthCheck | default dict).requestPath | default "/healthz" | quote }}
        {{- with ($values.default.config.httpsHealthCheck | default dict).host }}
        host: {{ . | quote }}
        {{- end }}
      {{- else if eq $checkType "HTTP2" }}
      http2HealthCheck:
        port: {{ ($values.default.config.http2HealthCheck | default dict).port | default (include "common.healthcheckpolicy.defaultPort" .) }}
        requestPath: {{ ($values.default.config.http2HealthCheck | default dict).requestPath | default "/healthz" | quote }}
        {{- with ($values.default.config.http2HealthCheck | default dict).host }}
        host: {{ . | quote }}
        {{- end }}
      {{- else if eq $checkType "GRPC" }}
      grpcHealthCheck:
        port: {{ ($values.default.config.grpcHealthCheck | default dict).port | default (include "common.healthcheckpolicy.defaultPort" .) }}
        {{- with ($values.default.config.grpcHealthCheck | default dict).grpcServiceName }}
        grpcServiceName: {{ . | quote }}
        {{- end }}
      {{- else if eq $checkType "TCP" }}
      tcpHealthCheck:
        port: {{ ($values.default.config.tcpHealthCheck | default dict).port | default (include "common.healthcheckpolicy.defaultPort" .) }}
        {{- with ($values.default.config.tcpHealthCheck | default dict).request }}
        request: {{ . | quote }}
        {{- end }}
        {{- with ($values.default.config.tcpHealthCheck | default dict).response }}
        response: {{ . | quote }}
        {{- end }}
      {{- end }}
{{ end }}

{{/* Helper: resolve the primary service port for use as the default health check port */}}
{{- define "common.healthcheckpolicy.defaultPort" -}}
  {{- $primaryService := get .Values.service (include "common.service.primary" .) -}}
  {{- $primaryPort := get $primaryService.ports (include "common.classes.service.ports.primary" (dict "values" $primaryService)) -}}
  {{- $primaryPort.port -}}
{{- end -}}
