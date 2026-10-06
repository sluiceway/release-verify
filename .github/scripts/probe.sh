#!/usr/bin/env bash
# Asks GitHub for the open pull requests with parts of Sluiceway's query, one
# part at a time, and prints which ones the token may read.
set -u
probe() {
  local name="$1" fields="$2"
  local query="query(\$owner:String!,\$repo:String!){repository(owner:\$owner,name:\$repo){pullRequests(states:OPEN,first:5){nodes{number commits(last:1){nodes{commit{$fields}}}}}}}"
  local out
  out=$(gh api graphql -f query="$query" -F owner="${GITHUB_REPOSITORY%/*}" -F repo="${GITHUB_REPOSITORY#*/}" 2>&1)
  if echo "$out" | grep -q '"errors"\|Resource not accessible'; then
    echo "PROBE $name: REFUSED: $(echo "$out" | tr -d '\n' | head -c 400)"
  else
    echo "PROBE $name: ok: $(echo "$out" | tr -d '\n' | head -c 400)"
  fi
}
probe "oid only" "oid"
probe "rollup state" "statusCheckRollup{state}"
probe "rollup CheckRun" "statusCheckRollup{state contexts(first:100){nodes{__typename ... on CheckRun{status conclusion}}}}"
probe "rollup StatusContext" "statusCheckRollup{state contexts(first:100){nodes{__typename ... on StatusContext{state}}}}"
probe "rollup both" "statusCheckRollup{state contexts(first:100){nodes{__typename ... on CheckRun{status conclusion} ... on StatusContext{state}}}}"
probe "status (legacy)" "status{state}"
probe "checkSuites" "checkSuites(first:5){nodes{status conclusion}}"
