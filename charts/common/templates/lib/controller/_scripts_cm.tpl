{{/*
ConfigMap for Scripts (e.g. hooks) mounted to controller pod
*/}}
{{- define "common.controller.scripts" -}}
{{/*
Get port for primary service
*/}}
{{- $primaryService := get .Values.service (include "common.service.primary" .) -}}
{{- $primaryPort := "" -}}
{{- if $primaryService -}}
  {{- $primaryPort = get $primaryService.ports (include "common.classes.service.ports.primary" (dict "serviceName" (include "common.service.primary" .) "values" $primaryService)) -}}
{{- end -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "common.names.fullname" . }}-scripts-cm
  labels:
    {{- include "common.labels" . | nindent 4 }}
data:
  check_open_connections_before_termination.sh: |
    #!/bin/sh
    SVC_PORT="${SVC_PORT:-{{ .Values.preStopHook.tcpPort | default $primaryPort.targetPort }}}"
    MAX_PRESTOP_RETRIES="${MAX_PRESTOP_RETRIES:-{{ .Values.preStopHook.retries }}}"

    # Function to get the number of established connections
    get_connection_count() {
      netstat -an | grep ":$SVC_PORT" | grep ESTABLISHED | wc -l
    }

    # Retry loop
    i=1
    while [ "$i" -le "$MAX_PRESTOP_RETRIES" ]; do
      connection_count=$(get_connection_count)

      if [ "$connection_count" -eq 0 ]; then
        echo "No open connections (port: $SVC_PORT). Safe to stop."
        exit 0
      else
        echo "There are still $connection_count open connections (port: $SVC_PORT, retry: $i ), not ready to stop. Sleeping 2s ..."
        sleep 2
      fi
      i=$(( i + 1 ))
    done

    echo "Max retries ($MAX_PRESTOP_RETRIES) reached. Still $connection_count open connections. Proceeding to stop."
    exit 0
  
  #second-srcipt.sh: |
  #  #!/bin/sh
  #  echo "hello"

{{- end }}
