{{- /* The cronjob item based on values from "cronjobValues" */ -}}
{{- define "common.cronjobitem" }}
  {{- $cronjobValues := list -}}
  {{- if hasKey . "cronjobValues" -}}
    {{- with .cronjobValues -}}
      {{- $cronjobValues = . -}}
    {{- end -}}
  {{ end }}
---
apiVersion: {{ template "common.capabilities.cronjob.apiVersion" . }}
kind: CronJob
metadata:
  name: {{ $cronjobValues.name }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
    {{- with .Values.controller.labels }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
    chartName: {{ $.Chart.Name }}
    objectKind: cronjob
  {{- with .Values.controller.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  schedule: "{{ $cronjobValues.schedule }}"
  {{- with $cronjobValues.concurrencyPolicy }}
  concurrencyPolicy: {{ . }}
  {{- end }}
  {{- with $cronjobValues.failedJobsHistoryLimit }}
  failedJobsHistoryLimit: {{ . }}
  {{- end }}
  {{- with $cronjobValues.successfulJobsHistoryLimit }}
  successfulJobsHistoryLimit: {{ . }}
  {{- end }}
  {{- with $cronjobValues.startingDeadlineSeconds }}
  startingDeadlineSeconds: {{ . }}
  {{- end }}
  {{- with $cronjobValues.suspend }}
  suspend: {{ . }}
  {{- end }}
  jobTemplate:
    spec:
      {{- with $cronjobValues.backoffLimit }}
      backoffLimit: {{ . }}
      {{- end }}
      completions: 1
      parallelism: 1
      template:
        metadata:
          labels:
            name: {{ $cronjobValues.name }}
            objectKind: job
        spec:
          {{- include "common.cronjob.poditem" . | nindent 10 }}
{{- end }}
