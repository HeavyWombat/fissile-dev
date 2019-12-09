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
$ go get -d code.cloudfoundry.org/fissile
$ cd $GOPATH/src/code.cloudfoundry.org/fissile
$ make tools docker-deps all
```

## Setup this playground
Initialise the submodules:
```
$ git submodule update --init --recursive
Submodule path 'releases/bpm': checked out '92b3b92dfb19977d1fc0b2647b82df5cb6d1413e'
Submodule path 'releases/loggregator-agent': checked out '89c8672487e38bc9476346ddcc0194cedaca1c8e'
Submodule 'src/code.cloudfoundry.org/go-batching' (https://github.com/cloudfoundry/go-batching) registered for path 'releases/loggregator-agent/src/code.cloudfoundry.org/go-batching'
[...]
```

Create a dev release of all releases (requires that you have a BOSH v2 CLI installed):
```
$ for I in releases/*; do ( cd $I && bosh create-release ); done
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
