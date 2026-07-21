{{/*
This template serves as a blueprint for all HTTPRoute objects that are created within the common library.
*/}}
{{- define "common.classes.httproute" -}}
  {{- $fullName := include "common.names.fullname" . -}}
  {{- $httprouteName := $fullName -}}
  {{- $values := .Values.httproute -}}

  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.httproute -}}
      {{- $values = . -}}
    {{- end -}}
  {{ end -}}

  {{- if and (hasKey $values "nameOverride") $values.nameOverride -}}
    {{- $httprouteName = printf "%v-%v" $httprouteName $values.nameOverride -}}
  {{- end -}}

  {{- $primaryService := get .Values.service (include "common.service.primary" .) -}}
  {{- $defaultServiceName := $fullName -}}
  {{- if and (hasKey $primaryService "nameOverride") $primaryService.nameOverride -}}
    {{- $defaultServiceName = printf "%v-%v" $defaultServiceName $primaryService.nameOverride -}}
  {{- end -}}
  {{- $defaultServicePort := get $primaryService.ports (include "common.classes.service.ports.primary" (dict "values" $primaryService)) -}}
---
apiVersion: {{ include "common.capabilities.httproute.apiVersion" . }}
kind: HTTPRoute
metadata:
  name: {{ $httprouteName }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
    {{- with $values.labels }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with $values.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if $values.parentRefs }}
  parentRefs:
    {{- range $values.parentRefs }}
    - kind: Gateway
      name: {{ tpl .name $ | quote }}
      {{- if .namespace }}
      namespace: {{ tpl .namespace $ | quote }}
      {{- end }}
      {{- if .sectionName }}
      sectionName: {{ .sectionName | quote }}
      {{- end }}
      {{- if .port }}
      port: {{ .port }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- if $values.hostnames }}
  hostnames:
    {{- range $values.hostnames }}
    - {{ tpl . $ | quote }}
    {{- end }}
  {{- end }}
  rules:
  {{- $rules := $values.rules | default (list (dict)) }}
  {{- range $rules }}
    - matches:
      {{- if .matches }}
        {{- range .matches }}
        - path:
            type: {{ default "PathPrefix" (.path | default dict).type | default "PathPrefix" }}
            value: {{ tpl ((.path | default dict).value | default "/") $ | quote }}
          {{- if .headers }}
          headers:
            {{- range .headers }}
            - name: {{ .name | quote }}
              value: {{ tpl .value $ | quote }}
            {{- end }}
          {{- end }}
          {{- if .queryParams }}
          queryParams:
            {{- range .queryParams }}
            - name: {{ .name | quote }}
              value: {{ tpl .value $ | quote }}
            {{- end }}
          {{- end }}
          {{- if .method }}
          method: {{ .method | quote }}
          {{- end }}
        {{- end }}
      {{- else }}
        - path:
            type: PathPrefix
            value: "/"
      {{- end }}
      {{- if .filters }}
      filters:
        {{- toYaml .filters | nindent 8 }}
      {{- end }}
      backendRefs:
        {{- if .backendRefs }}
        {{- range .backendRefs }}
        {{- $service := default $defaultServiceName (tpl .name $) -}}
        {{- $port := default $defaultServicePort.port .port }}
        - name: {{ $service }}
          port: {{ $port }}
          {{- if .weight }}
          weight: {{ .weight }}
          {{- end }}
        {{- end }}
        {{- else }}
        - name: {{ $defaultServiceName }}
          port: {{ $defaultServicePort.port }}
        {{- end }}
  {{- end }}
{{ end }}
