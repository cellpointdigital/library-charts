# pack charts library to local *.tgz, this package can be used for local debugging
param( $folder="./" )

#$chartManifest = (Get-ChildItem -Path ./charts -Filter "Chart.yaml" -Recurse).FullName
#$chartYaml = Get-Content $chartManifest
#$chartName = ($chartYaml | Select-String "^name").ToString().split(":")[1].Trim()
#$chartVersion = ($chartYaml | Select-String "^version").ToString().split(":")[1].Trim()
#$libFileName = "$chartName-$chartVersion.tgz"
#$libFile = Join-Path $folder $libFileName

Write-Output "Packing to: $folder"

helm package .\charts\common\ --destination $folder
