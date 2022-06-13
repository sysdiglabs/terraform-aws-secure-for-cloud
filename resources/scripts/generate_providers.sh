#!/usr/bin/env bash

for path in "$@"
do
  echo "$path"
  terraform-config-inspect --json "$path" | jq -r '
    [.required_providers[].aliases]
    | flatten
    | del(.[] | select(. == null))
    | reduce .[] as $entry (
      {};
      .provider[$entry.name] //= [] | .provider[$entry.name] += [{"alias": $entry.alias}]
    )
  ' > "$path"/aliased-providers.tf.json
done
