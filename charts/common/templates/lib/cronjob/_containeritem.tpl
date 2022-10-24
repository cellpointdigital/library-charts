{{- /* The main container included in the controller */ -}}
{{- define "common.cronjob.containeritem" -}}
  {{- $cronjobValues := list -}}
  {{- if hasKey . "cronjobValues" -}}
    {{- with .cronjobValues -}}
      {{- $cronjobValues = . -}}
    {{- end -}}
  {{- end -}}
- name: {{ include "common.names.fullname" . }}-{{ $cronjobValues.name }}
  image: {{ printf "%s:%s" $cronjobValues.image.repository (default .Chart.AppVersion $cronjobValues.image.tag) | quote }}
  imagePullPolicy: {{ $cronjobValues.image.pullPolicy }}
  {{- with $cronjobValues.command }}
  command:
    {{- if kindIs "string" . }}
    - {{ . }}
    {{- else }}
      {{ toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- with $cronjobValues.args }}
  args:
    {{- if kindIs "string" . }}
    - {{ . }}
    {{- else }}
    {{ toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- with $cronjobValues.securityContext }}
  securityContext:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $cronjobValues.lifecycle }}
  lifecycle:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- if hasKey $cronjobValues "termination" -}}
    {{- with $cronjobValues.termination.messagePath }}
    terminationMessagePath: {{ . }}
    {{- end }}
    {{- with $cronjobValues.termination.messagePolicy }}
    terminationMessagePolicy: {{ . }}
    {{- end }}
  {{- end }}
  stdin: false
  tty: false

  {{- with $cronjobValues.env }}
  env:
    {{- range $k, $v := . }}
      {{- $name := $k }}
      {{- $value := $v }}
      {{- if kindIs "int" $name }}
        {{- $name = required "environment variables as a list of maps require a name field" $value.name }}
      {{- end }}
    - name: {{ quote $name }}
      {{- if kindIs "map" $value -}}
        {{- if hasKey $value "value" }}
            {{- $value = $value.value -}}
        {{- else if hasKey $value "valueFrom" }}
          {{- toYaml $value | nindent 6 }}
        {{- else }}
          {{- dict "valueFrom" $value | toYaml | nindent 6 }}
        {{- end }}
      {{- end }}
      {{- if not (kindIs "map" $value) }}
        {{- if kindIs "string" $value }}
          {{- $value = tpl $value $ }}
        {{- end }}
      value: {{ quote $value }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- if or $cronjobValues.envFrom $cronjobValues.secret }}
  envFrom:
    {{- with $cronjobValues.envFrom }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
    {{- if $cronjobValues.secret }}
    - secretRef:
        name: {{ include "common.names.fullname" . }}
    {{- end }}
  {{- end }}
  ports: []
  {{- with (include "common.controller.volumeMounts" . | trim) }}
  volumeMounts:
    {{- nindent 4 . }}
  {{- end }}
  {{- with $cronjobValues.resources }}
  resources:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end -}}
