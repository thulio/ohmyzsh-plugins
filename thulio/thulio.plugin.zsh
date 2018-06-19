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
    vim -i NONE -c BundleUpdate -c quitall
    nvim -i NONE -c BundleUpdate -c quital

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

function docker_update_images {
    if [[ $(uname -s) -eq "Darwin" ]]; then
        docker images | grep -v REPOSITORY | grep -v none | awk '{print $1":"$2};' | xargs -n 1 docker pull
    else
        docker images | grep -v REPOSITORY | grep -v none | awk '{print $1":"$2};' | xargs -r -n 1 docker pull
    fi
}

function pyclean {
    find . -type f -name "*.py[co]" -delete
    find . -type d -name "__pycache__" -delete
}

function dash {
    if [ "$(uname -s)" = "Linux" ] ; then
        open dash://${1}:${2}
    fi
}

function setgov ()
{
    echo "$1" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
}

function fix_elixir_umbrella {
    for app in $(ls apps); do cd "apps/$app" && ln -sf ../../_build . && cd - ; done
}

function uuid() {
    # Usage: uuid
    C="89ab"

    for ((N=0;N<16;++N)); do
        B="$((RANDOM%256))"

        case "$N" in
            6)  printf '4%x' "$((B%16))" ;;
            8)  printf '%c%x' "${C:$RANDOM%${#C}:1}" "$((B%16))" ;;

            3|5|7|9)
                printf '%02x-' "$B"
            ;;

            *)
                printf '%02x' "$B"
            ;;
        esac
    done

    printf '\n'
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
if [ "$(uname -s)" = "Linux" ] ; then
    # Simulate OSX's pbcopy and pbpaste on other platforms
    alias pbcopy='xsel --clipboard --input'
    alias pbpaste='xsel --clipboard --output'
    alias charge_iphone='sudo usbmuxd -u -U usbmux'
fi

alias mix_format_modified="(git clean --dry-run | awk '{print $3;}' && git ls-files -m) | egrep '.ex|.exs|.eex' | xargs mix format"

export ERL_AFLAGS="-kernel shell_history enabled"
