{{/*
Default macros
*/}}

{{- define "clusterName" -}}
{{- $provider := get .Values .Values.cluster.clusterProvider }}
{{- tpl $provider.clusterNameFmt . | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "clusterFullName" -}}
{{- printf "%s-%s" .Values.customer.customerName (include "clusterName" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "clusterUniqueName" -}}
{{- $clusterFullName := (include "clusterFullName" .) }}
{{- printf "%s-%s" $clusterFullName (sha256sum $clusterFullName | trunc 8)  | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "defaultIngressClassName" -}}
{{- $provider := get .Values .Values.cluster.clusterProvider }}
{{- if .Values.cluster.defaultIngressClassName }}
{{- .Values.cluster.defaultIngressClassName }}
{{- else if $provider.defaultIngressClassName }}
{{- $provider.defaultIngressClassName }}
{{- else if .Values.ingressNginx.enabled }}
{{- default "nginx" .Values.ingressNginx.ingressClassName }}
{{- end }}
{{- end }}

{{- define "defaultStorageClassName" -}}
{{- $provider := get .Values .Values.cluster.clusterProvider }}
{{- if .Values.cluster.defaultStorageClassName }}
{{- .Values.cluster.defaultStorageClassName }}
{{- else if $provider.defaultStorageClassName }}
{{- $provider.defaultStorageClassName }}
{{- end }}
{{- end }}

{{/*
Kustomization
*/}}

{{/*
{{- define "kustomizationBases" -}}
{{- if (first .) }}
{{- range (rest .) }}
- base/{{ . }}
{{- end }}
{{- end }}
{{- end }}

{{- define "kustomizationPatches" -}}
{{- if (first .) }}
{{- range (rest .) }}
- path: overlay/{{ . }}
{{- end }}
{{- end }}
{{- end }}
*/}}

{{- define "fluxValuesFrom" -}}
{{- if .values }}
valuesFrom:
- kind: Secret
  name: {{ .secretName }}-values-{{ toYaml .values | sha256sum | trunc 6 }}
{{- end }}
{{- end }}

{{- define "fluxValuesFromData" -}}
{{- if .values }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ .secretName }}-values-{{ toYaml .values | sha256sum | trunc 6 }}
data:
  values.yaml: {{ toYaml .values | b64enc }}
{{- end }}
{{- end }}
