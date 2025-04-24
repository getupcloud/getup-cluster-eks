{{/* Basic */}}

{{- define "clusterLongName" -}}
{{ printf "%s-%s" .Values.cluster_name .Values.aws_region | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "clusterFullName" -}}
{{ printf "%s-%s-%s" .Values.customer_name .Values.cluster_name .Values.aws_region | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "clusterSlug" -}}
{{ printf "%s-%s-%s" .Values.customer_name .Values.cluster_name .Values.aws_region | lower | sha256sum | trunc 8 }}
{{- end -}}

{{- define "ingressClassName" -}}
{{- if .Values.default_ingress_class_name }}
{{- .Values.default_ingress_class_name }}
{{- else if .Values.ingressNginx.enabled }}
{{- printf "nginx" }}
{{- else if .Values.awsLoadBalancerController.enabled }}
{{- printf "alb" }}
{{- end}}
{{- end -}}

{{/*
Kustomization
*/}}

{{- define "kustomizationBases" -}}
{{- if (first .) }}
{{- range (rest .) }}
- base/{{ . }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "kustomizationPatches" -}}
{{- if (first .) }}
{{- range (rest .) }}
- path: overlay/{{ . }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "fluxValuesFrom" -}}
{{ if .values }}
valuesFrom:
- kind: Secret
  name: {{ .secretName }}-extra-values
{{ end }}
{{- end -}}

{{- define "fluxValuesFromData" -}}
{{ if .values }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ .secretName }}-extra-values
data:
  values.yaml: {{ toYaml .values | b64enc }}
{{ end }}
{{- end -}}
