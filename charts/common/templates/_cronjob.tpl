{{/*
Template for single cronjob. Kept for compatibility. "common.cronjobs" can be used instead.
*/}}
{{- define "common.cronjob" }}
{{- $cronJobName := include "common.names.fullname" . -}}
---
apiVersion: {{ template "common.capabilities.cronjob.apiVersion" . }}
kind: CronJob
metadata:
  name: {{ $cronJobName }}
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
  schedule: "{{ .Values.cronjob.schedule }}"
  {{- with .Values.cronjob.concurrencyPolicy }}
  concurrencyPolicy: {{ . }}
  {{- end }}
  {{- with .Values.cronjob.failedJobsHistoryLimit }}
  failedJobsHistoryLimit: {{ . }}
  {{- end }}
  {{- with .Values.cronjob.successfulJobsHistoryLimit }}
  successfulJobsHistoryLimit: {{ . }}
  {{- end }}
  {{- with .Values.cronjob.startingDeadlineSeconds }}
  startingDeadlineSeconds: {{ . }}
  {{- end }}
  {{- with .Values.cronjob.suspend }}
  suspend: {{ . }}
  {{- end }}
  jobTemplate:
    spec:
      {{- with .Values.cronjob.backoffLimit }}
      backoffLimit: {{ . }}
      {{- end }}
      completions: 1
      parallelism: 1
      template:
        metadata:
          labels:
            name: {{ $cronJobName }}
            objectKind: job
        spec:
          {{- include "common.cronjob.pod" . | nindent 10 }}

{{- end }}