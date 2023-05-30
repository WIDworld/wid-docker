# Dockerized wid-world with continuous integration


## Purpose

These short instructions should get you up and running fairly quickly with the `wid-world` codebase. It is fully self-contained, though it requires the Dropbox `W2ID` data directories to be locally available as we will mount these directly into the image.

This repository is generated from `AEADataEditor/stata-project-with-docker`. 

## Requirements

You will need 

- [ ] A Stata license file `stata.lic`. You will find this in your local Stata install directory.
- [ ] WIL Dropbox access and sufficient storage space on your local machine to download.

To run this locally on your computer, you will need

- [ ] [Docker](https://docs.docker.com/get-docker/).

To run this in the cloud, you will need

- [ ] A Github account, if you want to use the cloud functionality explained here as-is. Other methods do exist.
- [ ] A Docker Hub account, to store the image. Other "image registries" exist and can be used, but are not covered in these instructions.


## Steps

### Creating an image locally

1. [ ] Clone directory.
2. [ ] [Adjust the `Dockerfile`](#adjust-the-dockerfile).
4. [ ] [Build the Docker image](#build-the-image)
5. [ ] [Run the Docker image](#run-the-image)

### Leveraging cloud functionality

6. [ ] Upload the image to Docker Hub
7. [ ] Sync your code with your Github repository (which you created in Step 1, by using the template or forking)
8. [ ] Configure your Stata license in the cloud (securely)
9. [ ] Verify that the code runs in the cloud

If you want to go the extra step

10. [ ] Setup building the Docker image in the cloud

## Details

### Adjust the Dockerfile

The [Dockerfile](Dockerfile) contains instructions to build the container. You can edit it locally by opening it on your local clone of this repository, preferably on a user-specific branch, to make adjustments that match your own needs and preferences.

#### Set Stata version

To specify the Stata version of your choice, go to [https://hub.docker.com/u/dataeditors](https://hub.docker.com/u/dataeditors), click on the version you want to use (the one you have a license for), then go to "tags" and see what is the latest available tag for this version. Then, edit the Dockerfile to match, e.g.

```
# Local Stata version
ARG SRCVERSION = MY_STATA_VERSION

# Matching Stata version tag from https://hub.docker.com/u/dataeditors
ARG SRCTAG = MATCHING_DATAEDITORS_STATA_VERSION_TAG
```

which will resolve to e.g.

```
FROM dataeditors/stata16:2022-10-14
```

### Build the image

By default, the build process is documented in [`build.sh`](build.sh) and works on Linux and macOS, but all commands can be run individually as well. Running this script will create a docker image with instructions to build your container.

#### Set initial configurations

You can edit the contents of the [`config.txt`](init.config.txt):

```{bash}
MYHUBID=mcamacho10                    # Docker username 
MYIMG=wid-world                       # Image name
STATALIC=/usr/local/Stata/stata.lic   # Local filepath to Stata license!
DROPBOX=${HOME}/Dropbox/W2ID          # Local filepath to data Dropbox!
```

Where 

- `MYHUBID` is your login on Docker Hub. Only necessary to push/pull from DockerHub.
- `MYIMG` is the name by which you will refer to this image. A very convenient `MYIMG` name might be the same as the Github repository name, but it can be anything. 
- `STATALIC` contains the path to your Stata license. We need this to both build and later run the image.
- `DROPBOX` contains the path to the shared Dropbox directory cloned onto your local computer. We will mount this to the image.

#### Run [`build.sh`](build.sh)

Running the shell script [`build.sh`](build.sh) will leverage the existing Stata Docker image, add your project-specific details as specified in the [`Dockerfile`](Dockerfile), install any Stata packages as specified in the setup program, and store the project-specific Docker image locally on your computer. You will then be able to use that image to run your project's code **in the cloud or on the same machine as you built it**.

1. Open the terminal
2. Navigate to the cloned repository, where folder where [`build.sh`](build.sh) is stored:

```
cd /my/file/path/to/wid-docker/
```

3. Run the shell script:

```
source build.sh
```


### Run the image

The script [`run.sh`](run.sh) will pick up the configuration information in `config.txt`, and run your project inside the container image. If you have a terminal session open where you have already followed steps 1-3 in [Build the image](#build-the-image), you can simple run `source run.sh`. Otherwise, follow steps 1 and 2 above and then run `source run.sh`.

- The image maps the familiar `wid-world/` sub-directory in the sample repository into the image as `/wid-world`. As a result, output will appear **locally** in e.g. `wid-world/work-data` and be preserved once the Docker image is stopped (and deleted).
- If you need additional sub-directories availabe in the image, you will need to map them, using additional `-v` lines.

## Cloud functionality

Following sections are still @TODO.

Once you have ascertained that everything is working fine, you can let the cloud run the Docker image in the future. Note that this assumes that all data can be either downloaded on the fly, or is available in the `wid-docker` directory within Github (only recommended for quite small data). We will need to set-up remote Dropbox access (or AWS S3 type storage) for this. 

To run code in the cloud, we will leverage a Github functionality called "[Github Actions](https://docs.github.com/en/actions/quickstart)". Similar systems elsewhere might be called "pipelines", "workflows", etc. The terminology below is focused on Github Actions, but generically, this can work on any one of those systems.

### Setting up Github Actions and Configure the Stata license in the cloud

Your Stata license is valuable, and should not be posted to Github! However, we need it there in order to run the Docker image. Github and other cloud providers have the ability to store "secure" environment variables, that are made available to their systems. Github calls these "[secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)" because, well, they are meant to remain secret. However, secrets are text, not files. So we need a workaround to store our Stata license as a file in the cloud. You will need a Bash shell for the following step. You can either do it from the command line, using the [`gh` command line tool](https://github.com/cli/cli), or generate the text, and copy and paste it in the web interface, as described [here](https://docs.github.com/en/actions/security-guides/encrypted-secrets).

To run the image,  the license needs to be available to the Github Action as `STATA_LIC_BASE64` in "base64" format. From a Linux/macOS command line, you can generate it like this:
 
```bash
 gh secret set STATA_LIC_BASE64 -b"$(cat stata.lic | base64)" -v all -o WIDWorld
```

where `stata.lic` is your Stata license file, and `YOURORG` is your organization (can be dropped if running in your personal account).


### Publish the image 

In order to run this in the cloud, the "cloud" needs to be able to access the image you just created. You thus need to upload it to [Docker Hub](https://hub.docker.com/). You may need to login to do this.


```
source config.txt
docker push $MYHUBID/${MYIMG}:$TAG
```

### Sync your Git repository

We assume you created a Git repository. If not, do it now! Assuming you have committed all files (in particular, `config.txt`, `run.sh`, and all your Stata code), you should push it to your Github repository:

```
git push
```

Note that this also enables you to use that same image on other computers you have access to, without rebuilding it: Simply `clone` your Github repository, and run `run.sh`. This will download the image we uploaded in the previous step, and run your code. This might be useful if you are running on a university cluster, or your mother-in-law's laptop during Thanksgiving. However, here we concentrate on the cloud functionality.

### Getting it to work in the cloud

By default, this template repository has a pre-configured Github Actions workflow, stored in [`.github/workflows/compute.yml`](.github/workflows/compute.yml). There are, again, a few key parameters that can be configured. The first is the `on` parameter, which configures when actions are triggered. In the case of the template file,

```
on:
  push:
    branches:
      - 'main'
  workflow_dispatch:
```

which instructs the Github Action (run Stata on the code) to be triggered either by a commit to the `main` branch, or to be manually triggered, by going to the "Actions" tab in the Github Repository. The latter is very helpful for debugging!

### Results

If you only run the code for testing purposes, you may simply be interested in whether or not the tests run successfully, and not in the outputs per se. However, if you wish to use this to actually run your code and retain meaningful results, then the last part of the [`.github/workflows/compute.yml`](.github/workflows/compute.yml) is relevant:

```
      - name: Deploy
        uses: peaceiris/actions-gh-pages@v3.8.0
        with:
           github_token: ${{ secrets.GITHUB_TOKEN }}
           publish_dir: .
           publish_branch: results 
           keep_files: true
```
In this case, once the code has run, the entire repository is pushed back to the "[results](https://github.com/AEADataEditor/stata-project-with-docker/tree/results)" branch. Alternatives consist in building and displaying a web page with results (in which case you might want to use the standard `gh-pages` branch), or actually compiling a LaTeX paper with all the results. 

If you are not interested in the outcomes, then simply deleting those lines is sufficient.

If you want to be really fancy (we are), then you show a badge showing the latest result of the `compute` run (which in our case, demonstrates that this project is reproducible!): [![Compute analysis](https://github.com/AEADataEditor/stata-project-with-docker/actions/workflows/compute.yml/badge.svg)](https://github.com/AEADataEditor/stata-project-with-docker/actions/workflows/compute.yml). 

## Going the extra step

If we can run the Docker image in the cloud, can we also create the Docker image in the cloud? The answer, of course, is yes. 


### Configurating Docker builds in the cloud

This is pre-configured in [`.github/workflows/build.yml`](.github/workflows/build.yml). Reviewing this file shows a slightly different trigger:

```
on:
  push:
    branches:
      - 'main'
    paths:
      - 'Dockerfile'
  workflow_dispatch: 
```

Here, only changes to the `Dockerfile` trigger a rebuild. While that may seem reasonable, we might also want to include `setup.do`, or other files that affect the Docker image. However, we can also manually trigger the rebuild in the "Actions" tab.

### Additional secrets

We will need two additional  "secrets", in order to be able to push to the Docker Hub from the cloud.

```
DOCKERHUB_USERNAME
DOCKERHUB_TOKEN
```

See [the Docker Hub documentation](https://docs.docker.com/docker-hub/access-tokens/) on how to generate the latter.

### Running it

The [`.github/workflows/build.yml`](.github/workflows/build.yml) workflow will run through all the necessary steps to publish an image. Note that there's a slight difference in what it does: it will always create a "latest" tag, not a date- or release-specific tag. However, you can always associate a specific tag with the latest version manually. And because we are really fancy, we also have a badge for that: 
[![Build docker image](https://github.com/AEADataEditor/stata-project-with-docker/actions/workflows/build.yml/badge.svg)](https://github.com/AEADataEditor/stata-project-with-docker/actions/workflows/build.yml).

### Not running it

If you do not wish to build in the cloud, simply deleting [`.github/workflows/build.yml`](.github/workflows/build.yml) will disable that functionality.

## Other options

We have described how to do this in a fairly general way. However, other methods to accomplish the same goal exist. Interested parties should check out the [ledwindra](https://github.com/ledwindra/continuous-integration-stata) and [labordynamicsinstitute](https://github.com/labordynamicsinstitute/continuous-integration-stata) versions of a pre-configured "Github Action" that does not require the license file, but instead requires the license information (several more secrets to configure). If "continuous integration" is not a concern but a cloud-based Stata+Docker setup is of interest, both [CodeOcean](https://codeocean.com) and (soon) [WholeTale](https://wholetale.org) offer such functionality.

## Conclusion

The ability to conduct "continuous integration" in the cloud with Stata is a powerful tool to ensure that the project is reproducible at any time, and to learn early on when reproducibility is broken. For small projects, this template repository and tutorial is sufficient to get you started. For more complex projects, running it locally based on this template will also ensure reproducibility. 


