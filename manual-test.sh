export LIB_CHART_VERSION=$(helm show chart ./charts/common/ | grep version | awk '{print $2}')
echo "This library version: [$LIB_CHART_VERSION]"

echo "Packing charts to tgz file for test-app to ./test-app/charts"
helm package ./charts/common/ --destination ./test-app/charts

cd ./test-app

echo "===== Modify test-app chart to use library-chart $LIB_CHART_VERSION ====="
cp ./Chart.yaml ./Chart.yaml.orig
sed -i "s/\$LIB_CHART_VERSION/$LIB_CHART_VERSION/g" ./Chart.yaml

helm dependency list
#helm template . --values ./ci/test-app-values.yaml --debug | tee test-manifest.yaml
helm template . --values ../examples/httproute-values.yaml | tee test-manifest.yaml

echo "===== Restore original test-app Chart.yaml ====="
cp ./Chart.yaml.orig ./Chart.yaml

#helm show chart ./charts/common/ | grep version | awk '{print $2}'

#echo "This library version: [$(helm show chart ./charts/common/ | grep version | awk '{print $2}')]"
