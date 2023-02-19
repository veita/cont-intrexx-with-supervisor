# Intrexx

Container image for Intrexx versions with a Supervisor service.

## Services

* SSHD
* Postfix
* PostgreSQL
* Intrexx Supervisor
* Intrexx Solr Service

The installation does not contain any portal.

## Base image

The base image is `localhost/debian-systemd-${SUITE}` where `${SUITE}` is either `BUSTER`,
or `BULLSEYE`, or `BOOKWORM`.

The base image is provided by the [debian-systemd](https://github.com/veita/debian-systemd)
project.


## Building the container

```bash
git clone https://github.com/veita/cont-intrexx-with-supervisor.git intrexx-with-supervisor
cd intrexx-with-supervisor
./build-image-10.0.sh
```


## Running the container

Run the container, e.g. with

```bash
podman run --detach --rm --cap-add audit_write,audit_control -p=10022:22 -p=10079-10084:10079-10084 localhost/debian-intrexx-10.0-bullseye
```

`podman ps` reports the exposed ports of the running container:

```
CONTAINER ID  IMAGE                                   COMMAND     CREATED        STATUS            PORTS                                                        NAMES
229f33f0d414  localhost/debian-intrexx-10.0-bullseye  /sbin/init  6 seconds ago  Up 5 seconds ago  0.0.0.0:10022->22/tcp, 0.0.0.0:10079-10081->10079-10081/tcp  intrexx-10.0
```


## Creating new Portals

### Using the Intrexx Manager
* Remotely connect with (portable) Intrexx Manager to the exposed Manager API port (e.g. 10079)
* Create the portal with PostgreSQL database (user `postgres`, arbitrary password)
* Choose the exposed port (e.g. 10081) for the portal's base URL
* Connect the browser with the portal through the exposed port (base URL)

It is also possible to run Nginx as a frontend web server.

### By script
Login via SSH (root password: `admin`), then execute the portal build script, e.g.
```bash
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 10022 root@localhost
/setup/portal/blank/setup.sh
```
