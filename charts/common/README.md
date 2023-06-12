Helm Library chart to simplify deployments

Use it as a dependency in `Chart.yaml`, e.g.:
```
dependencies:
  - name: common
    version: 0.1.4
    repository: https://cellpointdigital.github.io/library-charts/
```
and then include in templates
```
{{ include "common.all" . }}
```
