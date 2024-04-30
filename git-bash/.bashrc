source /x/CLI/terminal-config/git-bash/env-variables.sh
source /x/CLI/terminal-config/git-bash/aliases.sh
source /x/CLI/terminal-config/git-bash/terminal-profiles.sh
source /x/CLI/bash-scripts/kubectlextensions.sh
source /x/CLI/bash-scripts/azureextensions.sh
source /x/CLI/bash-scripts/gitlabextensions.sh
source /x/CLI/bash-scripts/dailyextensions.sh
source /x/CLI/bash-scripts/cdp.sh
#
set -f

tfswitch(){
    if [ "$#" -lt 1 ]; then
        echo "Please provide the environment parameter: tfswitch dev/prod/current"
        return
    fi
    .  /x/CLI/bash-scripts/tfswitch/$1-vars.sh
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
  .  /x/CLI/bash-scripts/deploy-app.sh "$@" --chartsPath /g/Gemini/PIPELINES/charts/webapp
}

# # Load Angular CLI autocompletion.
# source <(ng completion script)


