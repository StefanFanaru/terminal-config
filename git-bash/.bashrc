#! /bin/bash
source ./env-variables.sh
source ./aliases.sh
source ./terminal-profiles.sh

source X:/CLI/bash-scripts/kubectlextensions.sh
source X:/CLI/bash-scripts/kubectlextensions.sh
source X:/CLI/bash-scripts/azureextensions.sh
source X:/CLI/bash-scripts/gitlabextensions.sh
source X:/CLI/bash-scripts/dailyextensions.sh
source X:/CLI/bash-scripts/cdp.sh

set -f

tfswitch(){
    if [ "$#" -lt 1 ]; then
        echo "Please provide the environment parameter: tfswitch dev/prod/current"
        return
    fi
    .  X:/CLI/bash-scripts/tfswitch/$1-vars.sh
}

currentSub(){
    echo $CURRENT_SUB
}

destroy(){
    .  ./destroy.sh "$1"
}

clearTerraform(){
   rm -rf .terraform
   rm -rf .terraform.lock.hcl
}

deploy(){
  .  X:/CLI/bash-scripts/deploy-app.sh "$@" --chartsPath /g/Gemini/PIPELINES/charts/webapp
}

# # Load Angular CLI autocompletion.
# source <(ng completion script)


