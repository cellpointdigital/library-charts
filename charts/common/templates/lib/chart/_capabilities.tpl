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


{{/* Return the appropriate apiVersion for HorizontalPodAutoscaler objects */}}
{{- define "common.capabilities.autoscaling.apiVersion" -}}
  {{- print "autoscaling/v2" -}}
  {{- if semverCompare "<1.23" (include "common.capabilities.kubeVersion" .) -}}
    {{- print "beta2" -}}
  {{- end -}}
{{- end -}}
