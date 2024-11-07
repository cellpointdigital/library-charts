{{/*
This template defines the TwingateResource and TwingateResourceAccess objects for Twingate integration.
*/}}
{{- define "common.twingate" }}
---
apiVersion: twingate.com/v1beta
kind: TwingateResource
metadata:
  name: {{ .Release.Name }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- with .Values.twingate.labels }}
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.twingate.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  name: {{ .Release.Name }}
  address: {{ $primaryIngress := include "common.ingress.primary" $ }}{{ $ingressValue := index .Values.ingress $primaryIngress }}{{ (index $ingressValue.hosts 0).host }}

---
apiVersion: twingate.com/v1beta
kind: TwingateResourceAccess
metadata:
  name: {{ .Release.Name }}-twingate-access
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- with .Values.twingate.labels }}
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.twingate.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  resourceRef:
    name: {{ .Release.Name }}
    namespace: {{ .Release.Namespace }}
  {{- if .Values.twingate.principalId }}
  principalId: {{ .Values.twingate.principalId }}
  {{- else }}
  principalExternalRef:
    type: group
    name: {{ .Values.twingate.groupName | default .Release.Namespace }}
  {{- end }}
{{- end }}
