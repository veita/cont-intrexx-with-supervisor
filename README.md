# Debian Base

Set a prompt to avoid confusion: `source mkenv.sh`


## Run the image build

To build a Debian 10 Buster base image run

```bash
./debian-base/build-container.sh
```

To build a Debian base with another version run e.g.

```bash
./debian-base/build-container.sh bullseye
```

To build a Debian 10 Intrexx image run

```bash
./debian-intrexx/build-image-10.0.sh
./debian-intrexx/build-image-9.2.sh
```

To build an Intrexx image with another Debian version run e.g.

```bash
./debian-intrexx/build-image-10.0.sh bullseye
./debian-intrexx/build-image-9.2.sh stretch
```


## Run a container
Base system with SSH access (root password: `admin`)

```bash
podman run --detach --rm --cap-add audit_write,audit_control -p=10022:22 localhost/debian-base-buster

ssh -p 10022 root@localhost
```

Intrexx system with SSH access (root password: `admin`)

```bash
podman run --detach --rm --cap-add audit_write,audit_control -p=10022:22 -p=10079-10084:10079-10084 localhost/debian-intrexx-10.0-buster

ssh -p 10022 root@localhost
```


## Safety

Do not run `setup.sh` in your host system.
