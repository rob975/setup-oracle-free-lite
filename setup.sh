#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2025 Roberto Benedetti
set -u

# utility functions
start_group() {
  echo "::group::$1"
}

end_group() {
  echo "::endgroup::"
}

success() {
  echo "✅ $1"
}

failure() {
  echo "❌ $1"
}

VALIDATE=true
validate() {
  if [[ $1 -eq 0 ]]; then
    success "$2"
  else
    failure "$2"
    VALIDATE=false
  fi
}

start_group "🔍 Validating options"

# container runtime value and validation
# podman does not work: https://github.com/oracle/docker-images/issues/2925
CONTAINER_RUNTIME=docker
command -v -- "${CONTAINER_RUNTIME}" >/dev/null
ret=$?
validate ${ret} "Container runtime: ${CONTAINER_RUNTIME}"

# tag value and validation
: "${TAG:=latest-lite}"
[[ ${TAG} =~ -lite(-|$) ]] && ret=0 || ret=1
validate ${ret} "Tag: ${TAG}"

# container name value and validation
: "${CONTAINER_NAME:=oracle-db}"
[[ ${CONTAINER_NAME} =~ ^[a-zA-Z0-9][a-zA-Z0-9_.-]*$ ]] && ret=0 || ret=1
validate ${ret} "Container name: ${CONTAINER_NAME}"

# sys, system and pdbadmin password and validation
: "${ORACLE_PWD:=}"
[[ ${ORACLE_PWD} ]] && secret="********" || secret="<auto generated>"
[[ ${ORACLE_PWD} =~ \" ]] && ret=1 || ret=0
validate ${ret} "Oracle password: ${secret}"

# database name value and validation
: "${ORACLE_PDB:=FREEPDB1}"
ORACLE_PDB=${ORACLE_PDB^^}
[[ ${ORACLE_PDB} =~ ^[A-Z][A-Z0-9_]*$ ]] && ret=0 || ret=1
validate ${ret} "Oracle PDB name: ${ORACLE_PDB}"

# connection port and validation
: "${PORT:=1521}"
[[ ${PORT} =~ ^[1-9][0-9]*$ ]] && ret=0 || ret=1
validate ${ret} "Port: ${PORT}"

# startp scripts path and validation
: "${STARTUP_SCRIPTS:=}"
{ [[ ! ${STARTUP_SCRIPTS} ]] || { [[ ${STARTUP_SCRIPTS:0:1} = "/" ]] &&
  [[ -d ${STARTUP_SCRIPTS} ]]; }; } && ret=0 || ret=1
validate ${ret} "Startup scripts: ${STARTUP_SCRIPTS:-<none>}"

# readiness retries value and validation
: "${READINESS_RETRIES:=10}"
[[ ${READINESS_RETRIES} =~ ^[1-9][0-9]*$ ]] && ret=0 || ret=1
validate ${ret} "Readiness check retries: ${READINESS_RETRIES}"

end_group

# exit with error if any option is not valid
${VALIDATE} || exit 1

start_group "🐳 Running container"

# initialize the array of arguments for the runtime
CONTAINER_ARGS=(
  run -d
  --name "${CONTAINER_NAME}"
  -p "${PORT}:1521"
  -e "ORACLE_PDB=${ORACLE_PDB}"
)

# add password if given
[[ ${ORACLE_PWD} ]] &&
  CONTAINER_ARGS+=(-e "ORACLE_PWD=${ORACLE_PWD}")

# add scripts path if given
[[ ${STARTUP_SCRIPTS} ]] &&
  CONTAINER_ARGS+=(-v "${STARTUP_SCRIPTS}:/opt/oracle/scripts/startup")

# run the container
"${CONTAINER_RUNTIME}" "${CONTAINER_ARGS[@]}" \
  "container-registry.oracle.com/database/free:${TAG}"
ret=$?

end_group

# exit with error if runtime failed to run container
[[ ${ret} -eq 0 ]] || exit 1

start_group "⏰ Waiting for database to be ready"

# In case of success, container logs contain:
#   - the message "DATABASE IS READY TO USE!"
#   - the output of startup scripts
#   - the message "The following output is now a tail of the alert.log:"
# We wait for both messages to be on the safe side.
# The value of the key ".State.Health.Status" returned by inspect command
# cannot be trusted because "healthy" is returned too early.
ret=1
count=0
lines=0
width=${#READINESS_RETRIES}
while [[ ${ret} -ne 0 ]] && [[ ${count} -lt ${READINESS_RETRIES} ]]; do
  ((count++))
  printf "  - Try #%${width}d of %d\n" "${count}" "${READINESS_RETRIES}"
  sleep 10
  lines=$(
    "${CONTAINER_RUNTIME}" logs "${CONTAINER_NAME}" 2>/dev/null |
      grep -Ec '^(DATABASE IS READY TO USE!|The following output is now a tail of the alert\.log:)$'
  )
  [[ ${lines} -eq 2 ]] && ret=0 || ret=1
done

end_group

# report if database is ready or not
if [[ ${ret} -eq 0 ]]; then
  start_group "$(success "Database is ready!")"
else
  status=$("${CONTAINER_RUNTIME}" inspect -f "{{.State.Status}}" \
    "${CONTAINER_NAME}" 2>/dev/null)
  if [[ ${status} = "running" ]]; then
    start_group "$(failure "Database was not ready on time")"
  else
    start_group "$(failure "Container is not running: '${status}'")"
  fi
fi
"${CONTAINER_RUNTIME}" logs "${CONTAINER_NAME}" 2>/dev/null
end_group

# exit with error if database was not ready on time
exit ${ret}
