{{- define "inventaire.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "inventaire.fullname" -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "inventaire.labels" -}}
app.kubernetes.io/name: {{ include "inventaire.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
{{- end -}}
{{- define "inventaire.selectorLabels" -}}
app.kubernetes.io/name: {{ include "inventaire.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
