#!/bin/bash
# This script will initialize the boilerplate

BOLD=""
UNDERLINE=""
STANDOUT=""
DEFAULT=""
BLACK=""
RED=""
GREEN=""
YELLOW=""
BLUE=""
MAGENTA=""
CYAN=""
WHITE=""

# Check if stdout is a terminal...
if [ -t 1 ]; then
    # See if it supports colors...
    ncolors=$(tput colors)

    if [ -n "$ncolors" ] && [ $ncolors -ge 8 ]; then
        BOLD="$(tput bold)"
        UNDERLINE="$(tput smul)"
        STANDOUT="$(tput smso)"
        DEFAULT="$(tput sgr0)"
        BLACK="$(tput setaf 0)"
        RED="$(tput setaf 1)"
        GREEN="$(tput setaf 2)"
        YELLOW="$(tput setaf 3)"
        BLUE="$(tput setaf 4)"
        MAGENTA="$(tput setaf 5)"
        CYAN="$(tput setaf 6)"
        WHITE="$(tput setaf 7)"
    fi
fi


function usage {
    printf """${BOLD}${GREEN}LumBoilerplate initialization${DEFAULT}

${UNDERLINE}${MAGENTA}${BOLD}Usage${DEFAULT}:
npm run -s init -- [--debug] [--help] [--skip-setup] [-n|--name <name>|\"default\"] [-d|--description <description>|\"default\"] [-u|--github-username <github username>|\"default\"] [-r|--repository <repository>|\"default\"] [-p|--prefix <prefix>|\"default\"] [-s|--separator <separator>|\"default\"] [-b|--base-url <base url>|\"default\"]

${UNDERLINE}${BLUE}Options${DEFAULT}:
\t${CYAN}--debug${DEFAULT}\t\t\t\t\t\t\tDebug this initialization script
\t${CYAN}--help${DEFAULT}\t\t\t\t\t\t\tPrint this help message.
\t${CYAN}-n, --name ${YELLOW}<name>|\"default\"${DEFAULT}\t\t\t\tThe name of the project (if \"default\", will be the name of the current directory).
\t${CYAN}-d, --description ${YELLOW}<description>|\"default\"${DEFAULT}\t\tThe description of the project (if \"default\", will be 'This is the description of <Project's name>).
\t${CYAN}-u, --github-username ${YELLOW}<github username>|\"default\"${DEFAULT}\tThe Github username of the repository of the project (if \"default\", will be your current username).
\t${CYAN}-r, --repository ${YELLOW}<repository>|\"default\"${DEFAULT}\t\t\tThe name of the repository of the project (if \"default\", will be the name of the current directory).
\t${CYAN}-p, --prefix ${YELLOW}<prefix>|\"default\"${DEFAULT}\t\t\t\tThe prefix for the components selector (if \"default\", will be derived from the name of the project).
\t${CYAN}-s, --separator ${YELLOW}<separator>|\"default\"${DEFAULT}\t\t\tThe separator of the components selector (between prefix and component selector) (if \"default\", will be '-').
\t${CYAN}-b, --base-url ${YELLOW}<base url>|\"default\"${DEFAULT}\t\t\tThe base URL of the project (if \"default\", will be '/').
\t${CYAN}--skip-git${DEFAULT}\t\t\t\t\t\tSkip the Git repository setup (initialization, initial commit, ...).
\t${CYAN}--skip-setup${DEFAULT}\t\t\t\t\t\tSkip the NPM setup (package installation, cleanup, ...).
"""
}

function exitIfError() {
    if [ $? -ne 0 ]; then
        printf "${BOLD}${RED}Error with code $?"
        if [ -n "$1" ]; then
            printf "${DEFAULT} ${RED}while ${1,,}"
        fi
        printf "${DEFAULT}\n"
        exit $?
    fi
}

function readWithDefault() {
    if [ -n "${!2}" ]; then
        return 0
    fi

    if [ -n "$1" ] && [ -n "$2" ]; then
        defaultVarName="default${2^}"

        printf "${YELLOW}${1}?${DEFAULT} "
        if [ -n "${!defaultVarName}" ]; then
            printf "(${BOLD}${CYAN}${!defaultVarName}${DEFAULT}) "
        fi

        IFS= read -r inputValue
        if [ -n "$inputValue" ]; then
            eval $2=`echo -ne \""${inputValue}"\"`
        else
            eval $2=`echo -ne \""${!defaultVarName}"\"`
        fi
    fi
}

function readBooleanWithDefault() {
    if [ "${!2,,}" == "y" ] || [ "${!2,,}" == "n" ]; then
        return 0
    fi

    if [ -n "$1" ] && [ -n "$2" ]; then
        defaultVarName="default${2^}"

        choices="(${BOLD}${CYAN}${!defaultVarName^^}${DEFAULT}/n)"
        if [ "${!defaultVarName,,}" == "n" ]; then
            choices="(y/${BOLD}${CYAN}${!defaultVarName^^}${DEFAULT})"
        fi

        IFS= read -r -p "${YELLOW}${1}?${DEFAULT} ${choices} " inputValue
        if [ -n "$inputValue" ]; then
            if [ "${inputValue,,}" != 'y' ] && [ "${inputValue,,}" != 'n' ]; then
                readBooleanWithDefault "$1" "$2"
                return
            fi

            eval $2=`echo -ne \""${inputValue,,}"\"`
        else
            eval $2=`echo -ne \""${!defaultVarName,,}"\"`
        fi
    fi
}


CONTRIBUTING_FILE="./CONTRIBUTING.md"
HUMANS_FILE="./src/client/meta/humans.txt"
INDEX_FILE="./src/client/index.html"
PACKAGE_FILE="./package.json"
README_FILE="./README.md"
ROADMAP_FILE="./ROADMAP.md"
SELECTORS_FILE="./src/client/app/core/settings/selectors.settings.ts"
SETTINGS_FILE="./src/client/app/core/settings/common.settings.ts"
TSLINT_FILE="./tslint.json"


originalName='LumBoilerplate'
originalDescription=''
originalGithubUsername='lumapps'
originalRepository='boilerplate'
originalComponentsNamePrefix='lb'
originalComponentsNameSeparator='-'
originalBaseUrl='/'


skipGit=false
skipSetup=false


defaultName="${PWD##*/}"
defaultDescription="This is the description of ${defaultName}"
defaultGithubUsername=$(whoami)
defaultGithubUsername="${defaultGithubUsername,,}"
defaultRepository="${defaultName,,}"
defaultComponentsNamePrefix=$(echo $defaultName | sed 's/\(\w\|-_ \)[^A-Z\-_ ]*\([^A-Z]\|$\)/\1/g')
defaultComponentsNamePrefix="${defaultComponentsNamePrefix,,}"
defaultComponentsNameSeparator="${originalComponentsNameSeparator,,}"
defaultBaseUrl="${originalBaseUrl,,}"


while [[ $# -ge 1 ]]; do
    key="$1"

    case $key in
        --debug)
            set -x
            ;;

        --help)
            usage
            exit 0
            ;;

        -n|--name)
            name="$2"
            shift
            ;;

        -d|--description)
            description="$2"
            shift
            ;;

        -u|--github-username)
            if [ "$2" == "default" ]; then
                githubUsername="$defaultGithubUsername"
            else
                githubUsername="$2"
            fi

            shift
            ;;

        -r|--repository)
            if [ "$2" == "default" ]; then
                repository="$defaultRepository"
            else
                repository="$2"
            fi

            shift
            ;;

        -p|--prefix)
            componentsNamePrefix="$2"
            shift
            ;;

        -s|--separator)
            if [ "$2" == "default" ]; then
                componentsNameSeparator="$defaultComponentsNameSeparator"
            else
                componentsNameSeparator="$2"
            fi

            shift
            ;;

        -b|--base-url)
            if [ "$2" == "default" ]; then
                baseUrl="$defaultBaseUrl"
            else
                baseUrl="$2"
            fi

            shift
            ;;

        --skip-git)
            skipGit=true
            ;;

        --skip-setup)
            skipSetup=true
            ;;

        *)
            # unknown option
            ;;
    esac

    shift
done


printf "${BOLD}Welcome to the initialization of the ${BLUE}boilerplate${WHITE}!${DEFAULT}\n"
printf "We will ask you some question to help you setup your new project. Ready?\n\n"


readWithDefault "What is the plain human readable name of your project" "name"
cleanName=$(echo -e "${name}" | tr -d '[[:space:]]' | tr -dc '[:alnum:]\n\r-_' | tr '[:upper:]' '[:lower:]')

defaultDescription="This is the description of ${name}"
if [ "$description" == "default" ]; then
    description="$defaultDescription"
fi
readWithDefault "How would you describe your project" "description"

readWithDefault "What is your GitHub username or organisation" "githubUsername"
githubUsername="${githubUsername,,}"

readWithDefault "What is your GitHub repository name" "repository"
repository="${repository,,}"

defaultComponentsNamePrefix=$(echo $name | sed 's/\(\w\|-_ \)[^A-Z\-_ ]*\([^A-Z]\|$\)/\1/g')
defaultComponentsNamePrefix="${defaultComponentsNamePrefix,,}"
if [ "$componentsNamePrefix" == "default" ]; then
    componentsNamePrefix="${defaultComponentsNamePrefix}"
fi
readWithDefault "What prefix do you want to use for the components name" "componentsNamePrefix"
componentsNamePrefix="${componentsNamePrefix,,}"

readWithDefault "What prefix do you want to use for the components name" "componentsNameSeparator"
componentsNameSeparator="${componentsNameSeparator,,}"

readWithDefault "What will your base URL be" "baseUrl"
baseUrl="${baseUrl,,}"


printf "\n"
printf "We are now ready to initialize the boilerplate for your project \"${BOLD}${name}${DEFAULT}\". Please wait...\n\n"


if [ "$skipGit" = false ]; then
    printf "Preparing git... "
        rm -Rf ".git"
        exitIfError "Deleting git"
        git init -q
        exitIfError "Initializing git"
    printf "${BLUE}Done${DEFAULT}\n"
fi


printf "Removing useless files... "
    rm -Rf "./dist"
    exitIfError "Deleting 'dist'"

    rm -Rf "./src/client/token.json"
    exitIfError "Deleting 'token.json'"

    rm -Rf "./src/client/app/home"
    exitIfError "Deleting 'home'"
    rm -Rf "./src/client/app/to-do"
    exitIfError "Deleting 'to-do'"
    rm -Rf "./src/client/app/about"
    exitIfError "Deleting 'about'"

    rm -Rf "./src/client/app/core/constants/actions.ts"
    exitIfError "Deleting core constant 'action'"
    rm -Rf "./src/client/app/core/messages/token.message.ts"
    exitIfError "Deleting core message 'token'"
    rm -Rf "./src/client/app/core/reducers/token.reducer.ts"
    exitIfError "Deleting core reducer 'token'"
    rm -Rf "./src/client/app/core/services/http-interceptor.service.ts"
    exitIfError "Deleting core service 'HTTP-Interceptor'"
    rm -Rf "./src/client/app/core/services/token.service.ts"
    exitIfError "Deleting core service 'Token'"

    rm -Rf "./tests/client/e2e/pages/home.page.ts"
    exitIfError "Deleting E2E 'Home' page"
    rm -Rf "./tests/client/e2e/specs/home.spec.ts"
    exitIfError "Deleting E2E 'Home' specs"

    rm -Rf "./tests/client/e2e/report"
    exitIfError "Deleting E2E report"
    rm -Rf "./tests/client/unit/report"
    exitIfError "Deleting Unit report"
    rm -Rf "./tests/client/*Report.tar.gz"
    exitIfError "Deleting tests reports archives"

    rm -Rf "build.*"
    exitIfError "Deleting build files"
printf "${BLUE}Done${DEFAULT}\n"


printf "Emptying some files... "
    printf "# humanstxt.org\n# The humans responsible & technology colophon\n\n# TEAM\n\n\n# THANKS\n\n    AngularClass -- @AngularClass\n    Lumapps -- @lumapps\n    PatrickJS -- @gdi2290\n\n# TECHNOLOGY COLOPHON\n\n    HTML5, CSS3, SASS\n    Angular2, TypeScript, Webpack\n" > $HUMANS_FILE
    exitIfError "Emptying humans file"

    mv $README_FILE README.boilerplate.md
    exitIfError "Copying readme file"
    touch $README_FILE
    exitIfError "Creating new readme file"
printf "${BLUE}Done${DEFAULT}\n"


printf "Removing useless code... "
    grep -v "ToDoModule" ./src/client/app/app.module.ts > temp && mv temp ./src/client/app/app.module.ts
    exitIfError "Removing ToDo module in 'app' module"

    rm -Rf "./src/client/app/app.component.*"
    exitIfError "Removing original 'app' component files"

    ./scaffold.sh -- --force -n "App" -p "default" --at-root -t "Component" --not-core -s 'default' --without-module --on-init --no-on-destroy --no-on-change --no-activated-route --no-constructor &> /dev/null
    exitIfError "Scaffolding new 'app' component"
    sed -i "7i/*\n* Global styles\n */\nimport 'core/styles/app.scss';\n\n" ./src/client/app/app.component.ts

    grep -v "HttpInterceptorService" ./src/client/app/core/modules/core.module.ts > temp && mv temp ./src/client/app/core/modules/core.module.ts
    exitIfError "Removing HTTP-Interceptor service in core 'core' module"
    grep -v "TokenService" ./src/client/app/core/modules/core.module.ts > temp && mv temp ./src/client/app/core/modules/core.module.ts
    exitIfError "Removing Token service in core 'core' module"
    grep -v "tokenReducer" ./src/client/app/core/modules/core.module.ts > temp && mv temp ./src/client/app/core/modules/core.module.ts
    exitIfError "Removing 'tokenReducer' in core 'core' module"
    grep -v "StoreModule" ./src/client/app/core/modules/core.module.ts > temp && mv temp ./src/client/app/core/modules/core.module.ts
    exitIfError "Removing Store module in core 'core' module"
printf "${BLUE}Done${DEFAULT}\n"


if [ -n "$name" ]; then
    printf "Customizing project name... "

    printf "# ${name}\n\n" > $README_FILE
    exitIfError "Writing project name in readme file"

    FILES_WITH_NAME=$(grep -rl "${originalName}" .)
    for fileName in $FILES_WITH_NAME; do
        if [ "$fileName" != "./init.sh" ] && [ "$fileName" != "./README.boilerplate.md" ]; then
            sed -i "s/${originalName}/${name}/g" $fileName
            exitIfError "Replacing original name in ${fileName}"
        fi
    done
    printf "${BLUE}Done${DEFAULT}\n"
fi


printf "Customizing GitHub and StackOverflow... "
    if [ -n "${githubUsername}" ]; then
        sed -i "s/${originalGithubUsername}\//${githubUsername}\//g" $CONTRIBUTING_FILE
        exitIfError "Replacing original github username in contributing file"
    fi

    if [ -n "${repository}" ]; then
        sed -i "s/${originalRepository}/${repository}/g" $CONTRIBUTING_FILE
        exitIfError "Replacing original repository in contributing file"
    fi
printf "${BLUE}Done${DEFAULT}\n"


printf "Customizing NPM... "
    if [ -n "$name" ]; then
        sed -i "s/${originalName,,}/${cleanName,,}/g" $PACKAGE_FILE
        exitIfError "Replacing original name in package file"
    fi
    if [ -n "${description}" ]; then
        sed -i "s/\"description\".*/\"description\": \"${description}\",/g" $PACKAGE_FILE
        exitIfError "Replacing original description in package file"
    fi
    if [ -n "${githubUsername}" ]; then
        sed -i "s/${originalGithubUsername}\//${githubUsername}\//g" $PACKAGE_FILE
        exitIfError "Replacing original github username in package file"
    fi
    if [ -n "${repository}" ]; then
        sed -i "s/${originalRepository}/${repository}/g" $PACKAGE_FILE
        exitIfError "Replacing original repository in package file"
    fi
    gitUserName=$(git config user.name)
    gitUserEmail=$(git config user.email)
    sed -i "s/\"author\".*/\"author\": \"${gitUserName} <${gitUserEmail}> (https:\/\/github.com\/${githubUsername})\",/g" $PACKAGE_FILE
    exitIfError "Replacing original authors in package file"
printf "${BLUE}Done${DEFAULT}\n"


printf "Customizing Readme... "
    printf "[![Commitizen friendly](https://img.shields.io/badge/commitizen-friendly-brightgreen.svg?style=flat-square)](http://commitizen.github.io/cz-cli/)\n" >> $README_FILE
    if [ -n "$description" ]; then
        printf "\n${description}\n" >> $README_FILE
        exitIfError "Writing description in readme file"
    fi
printf "${BLUE}Done${DEFAULT}\n"


printf "Customizing app settings... "
    printf "export const BASE_HREF: string = '${baseUrl}';\n" > $SETTINGS_FILE
    exitIfError "Customizing base href in app settings"
printf "${BLUE}Done${DEFAULT}\n"


printf "Customizing selectors... "
    printf "export const SELECTOR_PREFIX: string = '${componentsNamePrefix}';\n" > $SELECTORS_FILE
    exitIfError "Customizing selector prefix in app settings"
    printf "export const SELECTOR_SEPARATOR: string = '${componentsNameSeparator}';\n\n" >> $SELECTORS_FILE
    exitIfError "Customizing selector separator in app settings"
    printf "export const APP_SELECTOR: string = 'app';\n" >> $SELECTORS_FILE
    exitIfError "Customizing app component selector in app settings"

    sed -i "s/${originalComponentsNamePrefix}${originalComponentsNameSeparator}app/${componentsNamePrefix}${componentsNameSeparator}app/g" $INDEX_FILE
    exitIfError "Customizing app component in index file"

    sed -i "s/\"${originalComponentsNamePrefix}\"/\"${componentsNamePrefix}\"/g" $TSLINT_FILE
    exitIfError "Customizing selector prefix in TSLint configuration"
printf "${BLUE}Done${DEFAULT}\n"


if [ "$skipSetup" = false ]; then
    printf "Cleaning and setting up the boilerplate\n"
        npm run -s setup
        exitIfError "Setting up NPM"
    printf "${BLUE}Done${DEFAULT}\n"
fi

if [ "$skipGit" = false ]; then
    printf "Creating the first git commit...\n"
        git add .
        exitIfError "Adding project in git repository"
        git commit -q -m "feat(${repository}): initialization of the repository with boilerplate"
    printf "${BLUE}Done${DEFAULT}\n"
fi


printf "\n"
printf "${GREEN}Your project has been successfully initialized!${DEFAULT}\n\n"
printf "You can now start coding. Run ${BOLD}npm run -s start${DEFAULT} to start the server with all coding stuff you need.\n"
printf "Then go to ${BOLD}http://localhost:8880/${DEFAULT} to access your project.\n"
printf "You can also run ${BOLD}npm run help${DEFAULT} to have a list of all commands available.\n\n"

printf "You can now delete this initialization script: ${BOLD}rm -f ./init.sh${DEFAULT}.\n\n"

printf "${BOLD}${MAGENTA}Have fun coding with this boilerplate!${DEFAULT}\n"

exit 0
