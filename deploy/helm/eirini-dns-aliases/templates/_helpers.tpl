{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "eirini-dns-aliases.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "eirini-dns-aliases.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "eirini-dns-aliases.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Filter a string to an approximation that is acceptable for Kubernetes labels.
*/}}
{{- define "eirini-dns-aliases.filter-for-label" -}}
{{- . | replace "+" "_" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "eirini-dns-aliases.labels" -}}
helm.sh/chart: {{ include "eirini-dns-aliases.chart" . }}
{{ include "eirini-dns-aliases.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | include "eirini-dns-aliases.filter-for-label" | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "eirini-dns-aliases.selectorLabels" -}}
app.kubernetes.io/name: {{ include "eirini-dns-aliases.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "eirini-dns-aliases.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "eirini-dns-aliases.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
The Eirini deployment namespace
*/}}
{{- define "eirini-dns-aliases.deployment-namespace" -}}
{{ required "Missing deployment.eirini_namespace" .Values.deployment.eirini_namespace }}
{{- end -}}
