
#!/bin/bash

set -e


DOMAIN=github.com
SCHEME=https

USER=1
ACCESS_TOKEN=1



PWD="$(pwd)"

projects=$(
curl -s \
  --header "PRIVATE-TOKEN: ${ACCESS_TOKEN}" \
  "${SCHEME}://${DOMAIN}/api/v4/projects?per_page=1000" \
  | tr ',' '\n' \
  | grep 'path_with_namespace' \
  | cut -d'"' -f4
)


echo "${projects}" | while IFS= read -r project; do
  echo ""
  echo "project: ${project}"

  if [ -d "${project}" ]; then
    cd "${project}"
    git pull
    cd "${PWD}"
  else
      mkdir -p "${project}"
      git clone "${SCHEME}://${USER}:${ACCESS_TOKEN}@${DOMAIN}/${project}" "${project}"
  fi

done
