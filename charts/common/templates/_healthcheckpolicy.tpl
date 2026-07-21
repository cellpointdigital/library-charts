{{/* Renders the HealthCheckPolicy objects required by the chart */}}
{{- define "common.healthcheckpolicy" -}}
  {{- range $name, $policy := .Values.healthCheckPolicy }}
    {{- if $policy.enabled -}}
      {{- $policyValues := $policy -}}

      {{/* set defaults */}}
      {{- if and (not $policyValues.nameOverride) (ne $name (include "common.healthcheckpolicy.primary" $)) -}}
        {{- $_ := set $policyValues "nameOverride" $name -}}
      {{- end -}}

      {{- $_ := set $ "ObjectValues" (dict "healthCheckPolicy" $policyValues) -}}
      {{- include "common.classes.healthcheckpolicy" $ }}
    {{- end }}
  {{- end }}
{{- end }}

{{/* Return the name of the primary HealthCheckPolicy object */}}
{{- define "common.healthcheckpolicy.primary" -}}
  {{- $enabled := dict -}}
  {{- range $name, $policy := .Values.healthCheckPolicy -}}
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
    {{- $result = keys $enabled | first -}}
  {{- end -}}
  {{- $result -}}
{{- end -}}
