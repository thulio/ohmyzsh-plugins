alias bp="bpython2"
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

function buildPython3k {
    echo "Building Python 3K";
    echo $(pwd)
    mkdir -p build;
    cd build;
    ../configure --with-pydebug --prefix=/dev/null
    make -j8 -l4
    echo Finished!
}

function addToPythonPath {
    if [ -n $1 ]; then
        export PYTHONPATH=$1:$PYTHONPATH
    fi
}

function update_github () {
    cd $HOME/projects/github/
    for i in `ls --color=never`
    do
        echo 'Updating' $i && cd $i && git pull && cd -
    done
    cd $HOME
}

function update_vim () {
    cd $HOME/.vim/bundle/
    for i in `ls --color=never`
    do
        echo 'Updating' $i && cd $i && git pull && cd -
    done
    cd $HOME
}


function ssh-append-key {
    cat ~/.ssh/id_rsa.pub | ssh $1@$2 'cat >> .ssh/authorized_keys'
}

function setup-tunnel {
    ssh -C2qTnN -D 8080 $1
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
    echo "nameserver 184.82.222.5\nnameserver 199.167.30.144" | sudo tee  /etc/resolv.conf > /dev/null
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

function indent {
    xmlindent -f -nbe $*
}

function clone_site {
 # Usage: clone_site domains_to_keep url
 wget \
     --recursive \
     --no-clobber \
     --page-requisites \
     --html-extension \
     --convert-links \
     --restrict-file-names=windows \
     --no-parent \
     --domains $1 \
     $2
}

function fix_pip {
 curl http://python-distribute.org/distribute_setup.py | python
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

alias json='python -mjson.tool | pygmentize -f terminal256 -l javascript -O style=native'
alias pacman=pacman-color