{{- /* The main container included in the controller */ -}}
{{- define "common.cronjob.container" -}}
- name: {{ include "common.names.fullname" . }}
  image: {{ printf "%s:%s" .Values.cronjob.image.repository (default .Chart.AppVersion .Values.cronjob.image.tag) | quote }}
  imagePullPolicy: {{ .Values.cronjob.image.pullPolicy }}
  {{- with .Values.cronjob.command }}
  command:
    {{- if kindIs "string" . }}
    - {{ . }}
    {{- else }}
      {{ toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- with .Values.cronjob.args }}
  args:
    {{- if kindIs "string" . }}
    - {{ . }}
    {{- else }}
    {{ toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- with .Values.cronjob.securityContext }}
  securityContext:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.cronjob.lifecycle }}
  lifecycle:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.cronjob.termination.messagePath }}
  terminationMessagePath: {{ . }}
  {{- end }}
  {{- with .Values.cronjob.termination.messagePolicy }}
  terminationMessagePolicy: {{ . }}
  {{- end }}
  stdin: false
  tty: false

  {{- with .Values.cronjob.env }}
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
  {{- if or .Values.cronjob.envFrom .Values.cronjob.secret }}
  envFrom:
    {{- with .Values.cronjob.envFrom }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
    {{- if .Values.cronjob.secret }}
    - secretRef:
        name: {{ include "common.names.fullname" . }}
    {{- end }}
  {{- end }}
  ports: []
  {{- with (include "common.controller.volumeMounts" . | trim) }}
  volumeMounts:
    {{- nindent 4 . }}
  {{- end }}
  {{- with .Values.cronjob.resources }}
  resources:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end -}}
