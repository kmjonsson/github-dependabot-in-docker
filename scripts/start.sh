#!/bin/bash

GH_OWNER=$GH_OWNER
GH_REPOSITORY=$GH_REPOSITORY
GH_TOKEN=$GH_TOKEN
GH_REG_TOKEN=$GH_REG_TOKEN=

RUNNER_SUFFIX=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 5 | head -n 1)
RUNNER_NAME="${REAL_HOSTNAME:-dependaNode}-${RUNNER_SUFFIX}"

cd /home/docker/actions-runner

if ! [[ -f /secrets/.credentials ]]; then
	if [[ -z "${GH_REG_TOKEN}" ]]; then
		GH_REG_TOKEN=$(curl -sX POST -H "Accept: application/vnd.github.v3+json" -H "Authorization: token ${GH_TOKEN}" https://api.github.com/repos/${GH_OWNER}/${GH_REPOSITORY}/actions/runners/registration-token | jq .token --raw-output)
	fi

	./config.sh --unattended --url https://github.com/${GH_OWNER}/${GH_REPOSITORY} --token ${GH_REG_TOKEN} --name ${RUNNER_NAME} --labels 'dependabot'

	# Save...
	mv .credentials* /secrets/
	mv .runner /secrets/
	exit 0
fi

ln -s /secrets/.runner .
ln -s /secrets/.credentials* .

cleanup() {
    echo "exit runner..."
    kill -HUP $pid
    # ./config.sh remove --unattended --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & 
pid=$!
wait $pid
