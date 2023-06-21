# Helm Library chart to simplify deployments

Use it as a dependency in `Chart.yaml`, e.g.:
```
dependencies:
  - name: common
    version: 0.1.6
    repository: https://cellpointdigital.github.io/library-charts/
```
and then include in templates
```
{{ include "common.all" . }}
```
All supported options are listed in [values.yaml](charts/common/values.yaml)
