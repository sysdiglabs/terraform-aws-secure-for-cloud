{{ range .Versions }}
{{ range .CommitGroups -}}
### {{ .Title }}

{{ range .Commits -}}
* {{ if .Scope }}**{{ .Scope }}:** {{ end }}{{ .Subject }}
  {{ if .Body }}> {{ .Body }} {{ end }}
  {{ end }}
  {{ end -}}

{{- if .RevertCommits -}}
### Reverts

{{ range .RevertCommits -}}
* {{ .Revert.Header }}
  {{ end }}
  {{ end -}}

{{- if .NoteGroups -}}
{{ range .NoteGroups -}}
### {{ .Title }}

{{ range .Notes }}
{{ .Body }}
{{ end }}
{{ end -}}
{{ end -}}
{{ end -}}
