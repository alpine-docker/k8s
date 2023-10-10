image="alpine/k8s"

# jq 1.6
DEBIAN_FRONTEND=noninteractive
#sudo apt-get update && sudo apt-get -q -y install jq
curl -sL https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -o jq
mv jq /usr/bin/jq
chmod +x /usr/bin/jq

# Get the list of all releases tags, excludes alpha, beta, rc tags
releases=$(curl -s https://api.github.com/repos/kubernetes/kubernetes/releases | jq -r '.[].tag_name | select(test("alpha|beta|rc") | not)')

# Loop through the releases and extract the minor version number
for release in $releases; do
  minor_version=$(echo $release | awk -F'.' '{print $1"."$2}')

  # Check if the minor version is already in the array of minor versions
  if [[ ! " ${minor_versions[@]} " =~ " ${minor_version} " ]]; then
    minor_versions+=($minor_version)
  fi
done

# Sort the unique minor versions in reverse order
sorted_minor_versions=($(echo "${minor_versions[@]}" | tr ' ' '\n' | sort -rV))

# Loop through the first 4 unique minor versions and get the latest version for each
for i in $(seq 0 3); do
  minor_version="${sorted_minor_versions[$i]}"
  latest_version=$(echo "$releases" | grep "^$minor_version\." | sort -rV | head -1 | sed 's/v//')
  latest_versions+=($latest_version)
done

echo "${latest_versions[*]}"
