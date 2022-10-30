{{- /*
The pod definition included in the cronjob.
*/ -}}
{{- define "common.cronjob.pod" -}}
  {{- with .Values.cronjob.imagePullSecrets }}
imagePullSecrets:
    {{- toYaml . | nindent 2 }}
  {{ end -}}
serviceAccountName: {{ include "common.names.serviceAccountName" . }}
restartPolicy: {{ .Values.cronjob.restartPolicy | default "Never" }}
automountServiceAccountToken: {{ .Values.cronjob.automountServiceAccountToken }}
  {{- with .Values.cronjob.podSecurityContext }}
securityContext:
    {{- toYaml . | nindent 2 }}
  {{- end }}
  {{- with .Values.cronjob.priorityClassName }}
priorityClassName: {{ . }}
  {{- end }}
  {{- with .Values.cronjob.runtimeClassName }}
runtimeClassName: {{ . }}
  {{- end }}
  {{- with .Values.cronjob.schedulerName }}
schedulerName: {{ . }}
  {{- end }}
  {{- with .Values.cronjob.hostNetwork }}
hostNetwork: {{ . }}
  {{- end }}
  {{- with .Values.cronjob.hostname }}
hostname: {{ . }}
  {{- end }}
  {{- if .Values.cronjob.dnsPolicy }}
dnsPolicy: {{ .Values.cronjob.dnsPolicy }}
  {{- else if .Values.cronjob.hostNetwork }}
dnsPolicy: ClusterFirstWithHostNet
  {{- else }}
dnsPolicy: ClusterFirst
  {{- end }}
  {{- with .Values.cronjob.dnsConfig }}
dnsConfig:
    {{- toYaml . | nindent 2 }}
  {{- end }}
enableServiceLinks: {{ .Values.cronjob.enableServiceLinks }}
  {{- with .Values.cronjob.termination.gracePeriodSeconds }}
terminationGracePeriodSeconds: {{ . }}
  {{- end }}
  {{- if .Values.cronjob.initContainers }}
initContainers:
    {{- $initContainers := list }}
    {{- range $index, $key := (keys .Values.cronjob.initContainers | uniq | sortAlpha) }}
      {{- $container := get $.Values.cronjob.initContainers $key }}
      {{- if not $container.name -}}
        {{- $_ := set $container "name" $key }}
      {{- end }}
      {{- $initContainers = append $initContainers $container }}
    {{- end }}
    {{- tpl (toYaml $initContainers) $ | nindent 2 }}
  {{- end }}
containers:
  {{- include "common.cronjob.container" . | nindent 2 }}
  {{- with .Values.cronjob.additionalContainers }}
    {{- $additionalContainers := list }}
    {{- range $name, $container := . }}
      {{- if not $container.name -}}
        {{- $_ := set $container "name" $name }}
      {{- end }}
      {{- $additionalContainers = append $additionalContainers $container }}
    {{- end }}
    {{- tpl (toYaml $additionalContainers) $ | nindent 2 }}
  {{- end }}
  {{- with (include "common.controller.volumes" . | trim) }}
volumes:
    {{- nindent 2 . }}
  {{- end }}
  {{- with .Values.cronjob.hostAliases }}
hostAliases:
    {{- toYaml . | nindent 2 }}
  {{- end }}
  {{- with .Values.cronjob.nodeSelector }}
nodeSelector:
    {{- toYaml . | nindent 2 }}
  {{- end }}
  {{- with .Values.cronjob.affinity }}
affinity:
    {{- toYaml . | nindent 2 }}
  {{- end }}
  {{- with .Values.cronjob.topologySpreadConstraints }}
topologySpreadConstraints:
    {{- toYaml . | nindent 2 }}
  {{- end }}
  {{- with .Values.cronjob.tolerations }}
tolerations:
    {{- toYaml . | nindent 2 }}
  {{- end }}
{{- end -}}
