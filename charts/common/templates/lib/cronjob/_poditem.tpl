{{- /*
The pod definition included in the controller.
*/ -}}
{{- define "common.cronjob.poditem" -}}
  {{- $cronjobValues := list -}}
  {{- if hasKey . "cronjobValues" -}}
    {{- with .cronjobValues -}}
      {{- $cronjobValues = . -}}
    {{- end -}}
  {{ end }}
  {{- with $cronjobValues.imagePullSecrets }}
imagePullSecrets:
    {{- toYaml . | nindent 2 }}
  {{ end -}}
serviceAccountName: {{ include "common.names.serviceAccountName" . }}
restartPolicy: {{ $cronjobValues.restartPolicy | default "Never" }}
automountServiceAccountToken: {{ $cronjobValues.automountServiceAccountToken }}
  {{- with $cronjobValues.podSecurityContext }}
securityContext:
    {{- toYaml . | nindent 2 }}
  {{- end }}
  {{- with $cronjobValues.priorityClassName }}
priorityClassName: {{ . }}
  {{- end }}
  {{- with $cronjobValues.runtimeClassName }}
runtimeClassName: {{ . }}
  {{- end }}
  {{- with $cronjobValues.schedulerName }}
schedulerName: {{ . }}
  {{- end }}
  {{- with $cronjobValues.hostNetwork }}
hostNetwork: {{ . }}
  {{- end }}
  {{- with $cronjobValues.hostname }}
hostname: {{ . }}
  {{- end }}
  {{- if $cronjobValues.dnsPolicy }}
dnsPolicy: {{ $cronjobValues.dnsPolicy }}
  {{- else if $cronjobValues.hostNetwork }}
dnsPolicy: ClusterFirstWithHostNet
  {{- else }}
dnsPolicy: ClusterFirst
  {{- end }}
  {{- with $cronjobValues.dnsConfig }}
dnsConfig:
    {{- toYaml . | nindent 2 }}
  {{- end }}
enableServiceLinks: {{ $cronjobValues.enableServiceLinks }}
  {{- if hasKey $cronjobValues "termination" -}}
    {{- with $cronjobValues.termination.gracePeriodSeconds }}
terminationGracePeriodSeconds: {{ . }}
    {{- end }}
  {{- end }}
  {{- if $cronjobValues.initContainers }}
initContainers:
    {{- $initContainers := list }}
    {{- range $index, $key := (keys $cronjobValues.initContainers | uniq | sortAlpha) }}
      {{- $container := get $cronjobValues.initContainers $key }}
      {{- if not $container.name -}}
        {{- $_ := set $container "name" $key }}
      {{- end }}
      {{- $initContainers = append $initContainers $container }}
    {{- end }}
    {{- tpl (toYaml $initContainers) $ | nindent 2 }}
  {{- end }}
containers:
  {{- include "common.cronjob.containeritem" . | nindent 2 }}
  {{- with $cronjobValues.additionalContainers }}
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
  {{- with $cronjobValues.hostAliases }}
hostAliases:
    {{- toYaml . | nindent 2 }}
  {{- end }}
  {{- with $cronjobValues.nodeSelector }}
nodeSelector:
    {{- toYaml . | nindent 2 }}
  {{- end }}
  {{- with $cronjobValues.affinity }}
affinity:
    {{- toYaml . | nindent 2 }}
  {{- end }}
  {{- with $cronjobValues.topologySpreadConstraints }}
topologySpreadConstraints:
    {{- toYaml . | nindent 2 }}
  {{- end }}
  {{- with $cronjobValues.tolerations }}
tolerations:
    {{- toYaml . | nindent 2 }}
  {{- end }}
{{- end -}}
