{{/*
This template serves as a blueprint for horizontal pod autoscaler objects that are created
using the common library.
*/}}
{{- define "common.classes.hpa" -}}
  {{- if .Values.autoscaling.enabled -}}
    {{- $hpaName := include "common.names.fullname" . -}}
    {{- $targetName := include "common.names.fullname" . }}
---
apiVersion: {{ include "common.capabilities.autoscaling.apiVersion" . }}
kind: HorizontalPodAutoscaler
metadata:
  name: {{ $hpaName }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: {{ include "common.names.controllerType" . }}
    name: {{ .Values.autoscaling.target | default $targetName }}
  minReplicas: {{ .Values.autoscaling.minReplicas | default 1 }}
  maxReplicas: {{ .Values.autoscaling.maxReplicas | default 3 }}
  metrics:
    {{- with .Values.autoscaling.metrics }}
      {{- tpl (toYaml .) $ | nindent 4 }}
    {{- end }}
    {{- if .Values.autoscaling.targetCPUUtilizationPercentage }}
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: {{ .Values.autoscaling.targetCPUUtilizationPercentage }}
    {{- end }}
    {{- if .Values.autoscaling.targetMemoryUtilizationPercentage }}
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: {{ .Values.autoscaling.targetMemoryUtilizationPercentage }}
    {{- end }}
    {{- if .Values.autoscaling.targetContainerCPUUtilizationPercentage }}
    - type: ContainerResource
      containerResource:
        name: cpu
        container: {{ include "common.names.fullname" . }}
        target:
          type: Utilization
          averageUtilization:  {{ .Values.autoscaling.targetContainerCPUUtilizationPercentage }}
    {{- end }}
    {{- if .Values.autoscaling.targetContainerMemoryUtilizationPercentage }}
    - type: ContainerResource
      containerResource:
        name: memory
        container: {{ include "common.names.fullname" . }}
        target:
          type: Utilization
          averageUtilization:  {{ .Values.autoscaling.targetContainerMemoryUtilizationPercentage }}
    {{- end }}
  {{- with .Values.autoscaling.behavior }}
  behavior:
    {{- toYaml . | nindent 4 }}
  {{- end }}

  {{- end -}}
{{- end -}}
