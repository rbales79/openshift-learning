{{- define "demo-nginx.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "demo-nginx.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "demo-nginx.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "demo-nginx.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: {{ include "demo-nginx.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "demo-nginx.selectorLabels" -}}
app.kubernetes.io/name: {{ include "demo-nginx.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
