{{/* Renders the GCPBackendPolicy objects required by the chart */}}
{{- define "common.gcpbackendpolicy" -}}
  {{- range $name, $policy := .Values.gcpBackendPolicy }}
    {{- if $policy.enabled -}}
      {{- $policyValues := $policy -}}

      {{/* set defaults */}}
      {{- if and (not $policyValues.nameOverride) (ne $name (include "common.gcpbackendpolicy.primary" $)) -}}
        {{- $_ := set $policyValues "nameOverride" $name -}}
      {{- end -}}

      {{- $_ := set $ "ObjectValues" (dict "gcpBackendPolicy" $policyValues) -}}
      {{- include "common.classes.gcpbackendpolicy" $ }}
    {{- end }}
  {{- end }}
{{- end }}

{{/* Return the name of the primary GCPBackendPolicy object */}}
{{- define "common.gcpbackendpolicy.primary" -}}
  {{- $enabled := dict -}}
  {{- range $name, $policy := .Values.gcpBackendPolicy -}}
    {{- if $policy.enabled -}}
      {{- $_ := set $enabled $name . -}}
    {{- end -}}
  {{- end -}}

  {{- $result := "" -}}
  {{- range $name, $policy := $enabled -}}
    {{- if and (hasKey $policy "primary") $policy.primary -}}
      {{- $result = $name -}}
    {{- end -}}
  {{- end -}}

  {{- if not $result -}}
    {{- $result = keys $enabled | sortAlpha | first -}}
  {{- end -}}
  {{- $result -}}
{{- end -}}
