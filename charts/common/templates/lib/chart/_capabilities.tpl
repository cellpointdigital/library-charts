{{/* Allow KubeVersion to be overridden. */}}
{{- define "common.capabilities.kubeVersion" -}}
  {{- default .Capabilities.KubeVersion.Version .Values.kubeVersionOverride -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Ingress objects */}}
{{- define "common.capabilities.ingress.apiVersion" -}}
  {{- print "networking.k8s.io/v1" -}}
  {{- if semverCompare "<1.19" (include "common.capabilities.kubeVersion" .) -}}
    {{- print "beta1" -}}
  {{- end -}}
{{- end -}}

{{/* Check Ingress stability */}}
{{- define "common.capabilities.ingress.isStable" -}}
  {{- if eq (include "common.capabilities.ingress.apiVersion" .) "networking.k8s.io/v1" -}}
    {{- true -}}
  {{- end -}}
{{- end -}}


{{/* Return the appropriate apiVersion for HTTPRoute objects */}}
{{- define "common.capabilities.httproute.apiVersion" -}}
  {{- if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1/HTTPRoute" -}}
    {{- print "gateway.networking.k8s.io/v1" -}}
  {{- else if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1beta1/HTTPRoute" -}}
    {{- print "gateway.networking.k8s.io/v1beta1" -}}
  {{- else -}}
    {{- print "gateway.networking.k8s.io/v1" -}}
  {{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for HealthCheckPolicy objects */}}
{{- define "common.capabilities.healthcheckpolicy.apiVersion" -}}
  {{- if .Capabilities.APIVersions.Has "networking.gke.io/v1/HealthCheckPolicy" -}}
    {{- print "networking.gke.io/v1" -}}
  {{- else if .Capabilities.APIVersions.Has "networking.gke.io/v1beta1/HealthCheckPolicy" -}}
    {{- print "networking.gke.io/v1beta1" -}}
  {{- else -}}
    {{- print "networking.gke.io/v1" -}}
  {{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for HorizontalPodAutoscaler objects */}}
{{- define "common.capabilities.autoscaling.apiVersion" -}}
  {{- print "autoscaling/v2" -}}
  {{- if semverCompare "<1.23" (include "common.capabilities.kubeVersion" .) -}}
    {{- print "beta2" -}}
  {{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for cronjob. */}}
{{- define "common.capabilities.cronjob.apiVersion" -}}
{{- if semverCompare "<1.21-0" (include "common.capabilities.kubeVersion" .) -}}
{{- print "batch/v1beta1" -}}
{{- else -}}
{{- print "batch/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for poddisruptionbudget.
*/}}
{{- define "common.capabilities.policy.apiVersion" -}}
{{- if semverCompare "<1.21-0" (include "common.capabilities.kubeVersion" .) -}}
{{- print "policy/v1beta1" -}}
{{- else -}}
{{- print "policy/v1" -}}
{{- end -}}
{{- end -}}
