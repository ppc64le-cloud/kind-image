#!/bin/bash

LAST_VERSIONS_FILE=".last_k8s_versions.txt"

echo "📡 Fetching latest stable Kubernetes versions..."

# Fetch releases and sort them according to versions.
curl -s "https://api.github.com/repos/kubernetes/kubernetes/releases?per_page=10" |
  jq -r '.[].tag_name' |
  grep -v -- '-alpha' | grep -v -- '-beta' | grep -v -- '-rc' |
  sort -V > new_releases.txt

# Make sure history file exists
touch "$LAST_VERSIONS_FILE"

# Compare current with saved list
comm -23 new_releases.txt <(sort -V "$LAST_VERSIONS_FILE") > compared_versions.txt

if [[ -s new_versions.txt ]]; then
  echo "✅ New stable Kubernetes versions found:"
  cat compared_versions.txt
else
  echo "❌ No new stable versions found."
fi

# Simulate triggering builds
echo
while read -r version; do
  echo "🛠️  Would trigger build for: $version"
done < compared_versions.txt

# Update saved list
cp new_releases.txt "$LAST_VERSIONS_FILE"
