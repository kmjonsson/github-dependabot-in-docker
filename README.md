
```
docker build --build-arg RUNNER_VERSION=2.333.1 --tag docker-github-runner-lin .

docker run \
	--name dependabot \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v /usr/bin/docker:/usr/bin/docker \
	-v $(pwd)/secrets-0:/secrets \
	--add-group docker \
	-d docker-github-runner-lin

# Setup
docker run -it \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v /usr/bin/docker:/usr/bin/docker \
	    -v $(pwd)/secrets-0:/secrets \
        -e REAL_HOSTNAME="$(hostname -s)" \
        -e RUNNER_SUFFIX="0" \
        -e GH_TOKEN="$(< token)" -e GH_OWNER='kmjonsson' -e GH_REPOSITORY='dependabot-lek-docker' docker-github-runner-lin

docker run -it \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v /usr/bin/docker:/usr/bin/docker \
	    -v $(pwd)/secrets-0:/secrets \
        -e RUNNER_SUFFIX="0" \
	    -e REAL_HOSTNAME="$(hostname -s)" \
        -e GH_REG_TOKEN="$(< reg_token)" -e GH_OWNER='kmjonsson' -e GH_REPOSITORY='dependabot-lek-docker' docker-github-runner-lin

docker exec -it dependabot-0 bash -i
```

# systemd

## /etc/systemd/system/dependabot\@.service

```
[Unit]
Description="Dependabot @ %H - %i"

[Service]
Type=oneshot
RemainAfterExit=yes
# Remove dangling runners
ExecStartPre=bash -c 'docker rm dependabot-%i || true'
# Start runner
ExecStart=docker run --name dependabot-%i \
    -v /var/run/docker.sock:/var/run/docker.sock -v /usr/bin/docker:/usr/bin/docker \
	-v /export/services/action-runner/secrets-%i:/secrets \
    -e RUNNER_SUFFIX="%i" \
	--group-add docker \
    -d docker-github-runner-lin
# Stop and remove runner
ExecStop=bash -c 'docker stop -t 30 dependabot-%i; docker rm dependabot-%i'
``
