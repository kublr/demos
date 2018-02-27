{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- .Values.nameOverride | default .Chart.Name | trunc 24 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 24 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- .Values.nameOverride | default ( printf "%s-%s" .Release.Name .Chart.Name ) | trunc 24 | trimSuffix "-" -}}
{{- end -}}

{{- define "servicename" -}}
{{- $defaultServiceName := printf "%s-%s" .Release.Name .Chart.Name -}}
{{- $servicename := default $defaultServiceName .Values.serviceNameOverride -}}
{{- printf "%s" $servicename | trunc 24 | trimSuffix "-" -}}
{{- end -}}
