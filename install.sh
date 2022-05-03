#!/usr/bin/env bash
set -euo pipefail

getValues() {
  read -rp "GitHub Username: " user
  read -rp "Projectname: " projectname
  export user
  export projectname
  export origuser="FalcoSuessgott"
  export origprojectname="golang-cli-template"
}
cloneTemplate() {
  git clone "git@github.com:$(tr '[:upper:]' '[:lower:]' <<<"$origuser")/$(tr '[:upper:]' '[:lower:]' <<<"$origprojectname").git" "$projectname"
  cd "$projectname" || exit 1
  rm -rf .git
  echo "Template repo $(pwd) now bare"
}

case $(sed --help 2>&1) in
  *GNU*) sed_i() { sed -i "$@"; } ;;
  *) sed_i() { sed -i '' "$@"; } ;;
esac

findExec() {
  find . -type f -exec bash -c 'prepTemplate "$@"' bash {} \;
}

prepTemplate() {
  local fn="$1"
  sed_i "s/$origprojectname/$projectname/g" "$fn"
  sed_i "s/$origuser/$user/g" "$fn"
}

initNewRepo() {
  git init
  rm -f ./install.sh || true
  git add .
  git commit -m "initial commit"
  if [[ $(command -v "gh") ]]; then
    echo "Creating public repo github.com:$user/$projectname.git using github cli"
    gh repo create --public --source=. --remote=origin "$user/$projectname"
  else
    echo "Adding remote origin without creating repo automatically"
    git remote add origin "git@github.com:$user/$projectname.git"
  fi
}

templateFinish() {
  echo "template successfully installed."
}

main() {
  export -f sed_i
  export -f prepTemplate
  echo "Getting project template values"
  getValues
  echo "Cloning template project"
  cloneTemplate
  echo "Find/Replace template values with new project values."
  findExec
  echo "Init the new project"
  initNewRepo
  templateFinish
}
main "$@"
