function is_osx {
    if [[ $(uname -s) -eq "Darwin" ]]; then
        return 1;
    else
        return 0;
    fi
}

function git-svn-diff {
    # git-svn-diff
    # Generate an SVN-compatible diff against the tip of the tracking branch
    TRACKING_BRANCH=`git config --get svn-remote.svn.fetch | sed -e 's/.*:refs\/remotes\///'`
    REV=`git svn find-rev $(git rev-list --date-order --max-count=1 $TRACKING_BRANCH)`
    git diff --no-prefix $(git rev-list --date-order --max-count=1 $TRACKING_BRANCH) $* |
    sed -e "s/^+++ .*/&	(working copy)/" -e "s/^--- .*/&	(revision $REV)/" \
    -e "s/^diff --git [^[:space:]]*/Index:/" \
    -e "s/^index.*/===================================================================/"
}

function git-svn-up {
    branch=`git branch 2>/dev/null  | grep \* | sed -e 's/\*//' -e 's/\s*//'`
    echo "Current branch: $branch"
    echo "Stashing changes";
    git stash clear;
    git stash;
    echo "Pulling from master";
    git checkout master && git svn fetch && git svn rebase
    git checkout $branch && git rebase master && git stash apply
}

function pipe-tar {
    tar --exclude-vcs -zcf - $1 | cat | tar -zxf - -C $2 && sync
}

function svn_mod {
    svn status | grep "^M\|^D\|^!" |  cut -d' ' -f 8
}

function svn_cleanup {
    for i in $(svn stat | grep ^? | cut -d' ' -f8); do rm -rf $i; done
}

function svn_diff {
    svn diff | vim -
}

function svn_missing()
{
    svn --no-ignore status | grep "^?\|^I" | cut -d' ' -f 8
}

function kde_astyle {
    astyle --indent=spaces=4 --brackets=linux \
       --indent-labels --pad=oper --unpad=paren \
       --one-line=keep-statements --convert-tabs \
       --indent-preprocessor $*

}

function mp4_to_mp3 {
    for i in *.mp4; do
      faad "$i"
      x=`echo "$i"|sed  -e 's/.mp4/.wav/'`
      y=`echo "$i"|sed  -e 's/.mp4/.mp3/'`
      lame -h -b 256 "$x" "$y"
    done
}

function qtinstall {
    ./configure --prefix=/opt/qt-4.7 --opensource --confirm-license -nomake demos -nomake examples -nomake docs -no-rpath -silent -optimized-qmake  -qt-sql-sqlite -qt-sql-sqlite -qt3support
}

function proxy-wrapper {
    nc -x127.0.0.1:8080 -X5 $*
}

function addToPythonPath {
    if [ -n $1 ]; then
        export PYTHONPATH=$1:$PYTHONPATH
    fi
}

function update_github () {
    cd $HOME/projects/github/
    for i in *
    do
        echo 'Updating' $i && cd $i && git up && cd -
    done
    cd $HOME
}

function update_vim () {
    pushd $HOME/.vim/ >/dev/null
    git up
    popd >/dev/null
}

function ssh-append-key {
    cat ~/.ssh/id_rsa.pub | ssh $1@$2 'cat >> .ssh/authorized_keys'
}

function setup-tunnel {
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -C2qTnN -D 8080 $1 -p ${2:-22}
}

function setup-proxy {
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -C2qTnN -L 8080:127.0.0.1:3128 $1
}

function parse_git_branch {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(git::\1)/'
}

function parse_svn_branch {
  parse_svn_url | sed -e 's#^'"$(parse_svn_repository_root)"'##g' | awk -F / '{print "(svn::"$1 "/" $2 ")"}'
}

function parse_svn_url {
  svn info 2>/dev/null | grep -e '^URL*' | sed -e 's#^URL: *\(.*\)#\1#g '
}

function parse_svn_repository_root() {
  svn info 2>/dev/null | grep -e '^Repository Root:*' | sed -e 's#^Repository Root: *\(.*\)#\1\/#g '
}

function pip_update {
  pip freeze -l | cut -d'=' -f 1 | xargs pip install -U
}

function dpkg-clean {
    dpkg -l | grep ^rc | cut -d' ' -f 3 | xargs -r sudo dpkg --purge
}

maiores () {
    echo $
    if [ 'x'$1 = 'x' ]
    then
        ls -G -laGSh | head -n 10
    else
        ls -G -laGSh | head -n $1
    fi
}

function setdsm() {
    # add the current directory and the parent directory to PYTHONPATH
    # sets DJANGO_SETTINGS_MODULE
    export PYTHONPATH=$PYTHONPATH:$PWD/..
    export PYTHONPATH=$PYTHONPATH:$PWD
    if [ -z "$1" ]; then
        x=${PWD/\/[^\/]*\/}
        export DJANGO_SETTINGS_MODULE=$x.settings
    else
        export DJANGO_SETTINGS_MODULE=$1
    fi

    echo "DJANGO_SETTINGS_MODULE set to $DJANGO_SETTINGS_MODULE"
}

function activate_tunlr {
    echo "nameserver 69.197.169.9\nnameserver 192.95.16.109" | sudo tee  /etc/resolv.conf > /dev/null
}

function deactivate_tunlr {
    echo "nameserver 8.8.8.8\nnameserver 8.8.4.4" | sudo tee  /etc/resolv.conf > /dev/null
}

function get_swap {
    # Get current swap usage for all running processes
    # Erik Ljungstrom 27/05/2011
    SUM=0
    OVERALL=0
    for DIR in `find /proc/ -maxdepth 1 -type d | egrep "^/proc/[0-9]"` ; do
      PID=`echo $DIR | cut -d / -f 3`
      PROGNAME=`ps -p $PID -o comm --no-headers`
      for SWAP in `grep Swap $DIR/smaps 2>/dev/null| awk '{ print $2 }'`
        do
          let SUM=$SUM+$SWAP
        done
        echo "PID=$PID - Swap used: $SUM - ($PROGNAME )"
        let OVERALL=$OVERALL+$SUM
        SUM=0

      done
    echo "Overall swap used: $OVERALL"
}

function xindent {
    xmlindent -f -nbe $*
}

function clone_site {
 # Usage: clone_site domains_to_keep url
 wget --mirror --convert-links -w 4 $1
}

function fix_pip {
    curl http://python-distribute.org/distribute_setup.py | python
    rm distribute-*.tar.gz
}

function xgh {
    curl -s 'http://xgh.herokuapp.com/' | sed -e 's/<p><b>//' -e 's/<\/b><\/p>//' | grep '^[0-9]' | sort -R | head -n 1
}

function from_timestamp {
    date --date=@$1
}

function unquarentine {
  find . -type f -print0 | xargs -0 xattr -d com.apple.quarantine
}

function clear_zsh_history {
    ## Script to accumulate unique .zsh_history entries in ~/.allhistory
    (cat $HOME/.zsh_history | sed -e 's/[^;]*;//' && cat $HOME/.allhistory) | sort | uniq >   $HOME/.allhistory.new
    rm $HOME/.allhistory
    mv $HOME/.allhistory.new $HOME/.allhistory
}

function activate_tunlr_osx {
  sudo networksetup -setdnsservers Wi-Fi 184.82.222.5, 199.167.30.144
}

function deactivate_tunlr_osx {
  sudo networksetup -setdnsservers Wi-Fi 208.67.222.22, 8.8.8.8, 8.8.4.4
}

function unswap {
  sudo swapoff -a && sudo swapon -a
}


function flip_the_table {
cat <<EOF
(╯°□°）╯︵ ┻━┻
EOF
}

function chillout {
cat <<EOF
┬─┬ノ( º _ ºノ)
EOF
}

function shrugs {
cat <<EOF
¯\_(ツ)_/¯
EOF
}

function lenny {
cat <<EOF
( ͡° ͜ʖ ͡°)
EOF
}

function connect_to_remote_docker {
  if [ "$#" -ne 4 ]; then
    echo "Usage: connect_to_remote_docker HOST_USER HOST_IP CONTAINER_USER CONTAINER_IP"
  else
    ssh -o ProxyCommand="ssh  $1@$2  nc %h %p" $3@$4
  fi
}

function create_checksums {
  for i in *; do sha1sum "$i" >> sha1sums.txt; done && sha1sum -c sha1sums.txt
}

function sha2sum {
	sha2 -q "$1" | (grep -q -f /dev/stdin "$2" && echo "OK") ||  echo "Mismatch"
}

function start-docker {
    if [[ is_osx -eq 0 ]]; then
        docker-machine start default > /dev/null
        eval "$(docker-machine env default)" > /dev/null
    fi
}

function docker_clear_images {
    if [[ is_osx -eq 0 ]]; then
        docker images -qf dangling=true | xargs docker rmi
    else
        docker images -qf dangling=true | xargs -r docker rmi
    fi
}

function docker_update_images {
    if [[ is_osx -eq 0 ]]; then
        docker images | grep -v REPOSITORY | grep -v none | awk '{print $1":"$2};' | xargs -n 1 docker pull
    else
        docker images | grep -v REPOSITORY | grep -v none | awk '{print $1":"$2};' | xargs -r -n 1 docker pull
    fi
}

alias json='python -mjson.tool | pygmentize -f terminal256 -l javascript -O style=native'
alias start-redis="redis-server /usr/local/etc/redis.conf"
alias start-mongodb="mongod run --config $HOME/.mongod.conf"
alias start-mysql="sudo /usr/bin/mysqld_safe --datadir='/var/lib/mysql'"
alias pinstall="pip install -M"
alias ssh="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ServerAliveInterval=120"
alias ll='ls -lh'
alias m0="mplayer -idx -volume 0"
alias shit_done="git log --author=$USER --format="-%B" --since=-30days --reverse"
# Simulate OSX's pbcopy and pbpaste on other platforms
if [[ is_osx -eq 1 ]]; then
    alias pbcopy='xsel --clipboard --input'
    alias pbpaste='xsel --clipboard --output'
fi
