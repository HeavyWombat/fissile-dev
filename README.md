> **Disclaimer:** This is intended to show case the typical `fissile` flow from creating a BOSH release to generating a set of Helm Charts. The actual result may be deployable to a Kubernetes cluster, but it was never tested to run or produce any meaningful results once deployed.

# Fissile development playground
This repo contains the simplest possible configuration to run [fissile](https://github.com/SUSE/fissile) commands.
It can be used to test changes done to fissile.

There are two sets of configuration to make this work:
- Under `configuration`, you will find the role manifest as well as the dark and light opinions.
- The remaining configuration is done through `direnv`, which uses the `.envrc` file in the root directory.

Following the steps, you will find the generated content under `output`.

## Setup fissile from source
Copied from the [fissile](https://github.com/SUSE/fissile) README:
```
$ go get -d github.com/SUSE/fissile
$ cd $GOPATH/src/github.com/SUSE/fissile
$ make tools
$ make docker-deps
$ make all
```

## Setup this playground
Initialise the submodule:
```
$ git submodule update --init releases/nginx-release
Submodule path 'releases/nginx-release': checked out 'e7964688b369b42e73282c8c282ea4b76053a95c'
```

Create a dev release of `nginx` (requires that you have a BOSH v2 CLI installed):
```
$ ( cd releases/nginx-release/ && bosh2 create-release )
Blob download 'nginx/headers-more-nginx-module-0.30.tar.gz' (28 kB) (id: 3eba8c40-b5d6-412d-6726-29129f517b48 sha1: a188a399f3e365a0831585a9d7aa0e6ed1a75f0d) started
Blob download 'nginx/headers-more-nginx-module-0.30.tar.gz' (id: 3eba8c40-b5d6-412d-6726-29129f517b48) finished
Blob download 'nginx/nginx-1.12.2.tar.gz' (982 kB) (id: bacb2565-ea90-470b-623f-2a8f878394ce sha1: 6b41d63befa4f52b0724b533e6292a6671b71fdc) started
Blob download 'nginx/nginx-1.12.2.tar.gz' (id: bacb2565-ea90-470b-623f-2a8f878394ce) finished
Blob download 'nginx/nginx-upload-module-2.2.tar.gz' (28 kB) (id: f5650638-2a55-4602-424d-1b1e6e2d1e8f sha1: 74ccd116525a155db76f92a1cd484d9516a70398) started
Blob download 'nginx/nginx-upload-module-2.2.tar.gz' (id: f5650638-2a55-4602-424d-1b1e6e2d1e8f) finished
Blob download 'nginx/pcre-8.40.tar.gz' (2.1 MB) (id: 3c5c62a0-dfdc-46ca-7279-d80161300987 sha1: 10384eb3d411794cc15f55b9d837d3f69e35391e) started
Blob download 'nginx/pcre-8.40.tar.gz' (id: 3c5c62a0-dfdc-46ca-7279-d80161300987) finished
Blob download 'patches/nginx-upload-module.patch' (657 B) (id: 27c1b860-1fcf-418a-7342-fca9ac3576c6 sha1: b8733bdb3f0c55a821add0476fb2b477a5a42634) started
Blob download 'patches/nginx-upload-module.patch' (id: 27c1b860-1fcf-418a-7342-fca9ac3576c6) finished
Adding job 'nginx/e7dc968f9daf5b31ff4ad6edf048306f45a70bbb'...
Added job 'nginx/e7dc968f9daf5b31ff4ad6edf048306f45a70bbb'

Added dev release 'nginx/1.12.2+dev.1'

Name         nginx
Version      1.12.2+dev.1
Commit Hash  e796468

Job                                             Digest                                    Packages
nginx/e7dc968f9daf5b31ff4ad6edf048306f45a70bbb  bd50c0fc7bff938c6d2d344337d9eaa65e352998  nginx

1 jobs

Package                                         Digest                                    Dependencies
nginx/d6ddf5c4782669341b260a27c53208d32a17b3a5  497718001a8e18a9bc7b7d3fd0bfdb2b48190ed0  -

1 packages

Succeeded
```

Enable the `.envrc` settings by running the following command:
```
direnv allow
```
_Note:_ You need the `direnv` hook of bash to be working, you can enable it by running `eval "$(direnv hook bash)"`

Make sure you have the configured stemcell available:
```
$ docker pull $FISSILE_STEMCELL
```

Once you have a BOSH dev release, `fissile` build packages can work:
```
$ fissile build packages
Compiling packages for releases:
         nginx (1.12.2+dev.1)
compile: nginx/nginx
done:    nginx/nginx
result   > success: nginx/nginx
```

Other `fissile` commands should work as well:
```
$ fissile show release
Dev release nginx (1.12.2+dev.1)
nginx (e7dc968f9daf5b31ff4ad6edf048306f45a70bbb):
There are 1 jobs present.

Dev release nginx (1.12.2+dev.1)
nginx (d6ddf5c4782669341b260a27c53208d32a17b3a5)
There are 1 packages present.
```

Run `fissile build helm` to generate the Helm templates, you should see something like the following:
```
$ fissile build helm
Writing config output/helm/templates/secrets.yaml
Writing config output/helm/templates/registry-secret.yaml
Writing config output/helm/values.yaml
Writing config output/helm/templates/nginx.yaml for role nginx
```
By default, fissile will colocate the _templates_ dir and the _values.yaml_ under the `FISSILE_OUTPUT_DIR` env variable.

To have a complete helm charts, you will need to run the following script, `./bin/create-chart.sh`. This will generate the missing _Chart.yaml_ file.

## What is missing
This README lacks the steps to create (`fissile build images`) and push your newly created image to a Docker registry of your choice. After that, you should be able to use Helm to install the release to any Kubernetes cluster.
