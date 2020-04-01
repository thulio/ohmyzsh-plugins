function update_github () {
    cd $HOME/projects/github/
    for i in *
    do
        echo 'Updating' $i && cd $i && git up && cd -
    done
    cd $HOME
}

function update_vim () {
    nvim -i NONE -c PlugUpdate -c quital

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

maiores () {
    echo $
    if [ 'x'$1 = 'x' ]
    then
        ls -G -laGSh | head -n 10
    else
        ls -G -laGSh | head -n $1
    fi
}

function xindent {
    xmlindent -f -nbe $*
}

function clone_site {
    # Usage: clone_site domains_to_keep url
    wget --mirror --convert-links -w 4 $1
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

function fix_elixir_umbrella {
    for app in $(ls apps); do cd "apps/$app" && ln -sf ../../_build . && cd - ; done
}

function uuid() {
    uuidgen | awk '{print tolower($0)}'
}

function tcr-elixir() {
    mix test && git commit -am working || git reset --hard
}

function tcr-pipenv() {
    pipenv run pytest && git commit -am working || git reset --hard
}

function tcr-make() {
    make test && git commit -am working || git reset --hard
}

function clean_docker() {
    docker system prune -f --volumes
    docker run --rm --privileged --pid=host justincormack/nsenter1 /sbin/fstrim /var/lib/docker
}

function erlang_version() {
    erl -eval '{ok, Version} = file:read_file(filename:join([code:root_dir(), "releases", erlang:system_info(otp_release), "OTP_VERSION"])), io:fwrite(Version), halt().' -noshell
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

export ERL_AFLAGS="-kernel shell_history enabled -kernel shell_history_file_bytes 1024000"
