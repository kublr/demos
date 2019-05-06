{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "pyspark-notebook.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pyspark-notebook.fullname" -}}
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
{{- define "pyspark-notebook.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "pyspark-notebook.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "pyspark-notebook.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the ConfigMap to use
*/}}
{{- define "pyspark-notebook.configMap.name" -}}
{{ default (include "pyspark-notebook.fullname" .) .Values.configMap.name }}
{{- end -}}

{{/*
Create the name of the Jupyter service
*/}}
{{- define "pyspark-notebook.jupyter.service.name" -}}
{{ template "pyspark-notebook.fullname" . }}-jupyter
{{- end -}}

{{/*
Create the name of the Jupyter notebook persistence volume claim
*/}}
{{- define "pyspark-notebook.jupyter.pvc.name" -}}
{{ template "pyspark-notebook.fullname" . }}-jupyter-notebook-volume
{{- end -}}
