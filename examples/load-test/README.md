# Load Testing

The load testing is based directly off of https://phoenixframework.org/blog/the-road-to-2-million-websocket-connections.

Tsung is used to coordinate load testing across a cluster. Tsung runs the following:

* Controller - coordinates work across all clients
* Client - executes requests to the server
* Server - host/port combination that responds to requests, does not have Tsung installed

The controller / clients all need to have Tsung installed and to also be networked together so that `ssh ip` works without any errors.

## Setting up Server

The server is installed by copying all of agent/setup.sh onto the Ubuntu node. Tsung is not used, but it's okay to keep it there for simplicity.

Run `/usr/local/bin/elixir --name pushex@push.server --cookie cookie -S mix run --no-halt` to start up the server.

Open another console and run `epmd -names` to open a remote observer, following https://gist.github.com/pnc/9e957e17d4f9c6c81294.

SSH forward a conenction to the push_server `ssh -L 4369:localhost:4369 -L FROM_ABOVE:localhost:FROM_ABOVE root@push_server`

`erl -name debug@push.server -setcookie cookie -hidden -run observer` & Node > Connect to `pushex@push.server` (local /etc/hosts must have push.server)

## Setting up Agent

The server is installed by copying all of agent/setup.sh onto the Ubuntu node.

The SSH key setup is a bit of a pain currently.

```
# Only run on 1
ssh-keygen -C 'tsung' -t rsa -b 2048 -N "" -f /root/.ssh/id_rsa

# Run on each
nano ~/.ssh/id_rsa # Copy private key
nano ~/.ssh/id_rsa.pub # Copy public key
chmod 600 ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub  >> /root/.ssh/authorized_keys
```

## Setting up Controller

```
cd examples/load-test/agent/
# Add all clients/server IP to the single_client.xml file
tsung -I CONTROLLER_IP -f single_client.xml start # Runs a test
```

Visit CONTROLLER_IP:8091 for the Tsung dashboard
