function update_github () {
    cd $HOME/projects/github/
    for i in *
    do
        echo 'Updating' $i && cd $i && git up && cd -
    done
    cd $HOME
}

function setup-tunnel {
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -C2qTnN -D 8080 $1 -p ${2:-22}
}

function setup-proxy {
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -C2qTnN -L 8080:127.0.0.1:3128 $1
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

function from_timestamp {
    date --date=@$1
}

function unswap {
    sudo swapoff -a && sudo swapon -a
}

function create_checksums {
    for i in *; do sha1sum "$i" >> sha1sums.txt; done && sha1sum -c sha1sums.txt
}

function docker_update_images {
    if [[ $(uname -s) -eq "Darwin" ]]; then
        docker images | grep -v REPOSITORY | grep -v none | awk '{print $1":"$2};' | sort | xargs -n 1 docker pull
    else
        docker images | grep -v REPOSITORY | grep -v none | awk '{print $1":"$2};' | sort | xargs -r -n 1 docker pull
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
}

function erlang_version() {
    erl -eval '{ok, Version} = file:read_file(filename:join([code:root_dir(), "releases", erlang:system_info(otp_release), "OTP_VERSION"])), io:fwrite(Version), halt().' -noshell
}

function kube() {
    if  hash kubectl &> /dev/null; then
        source <(kubectl completion zsh)
    fi

    if [[ -d "${HOME}/projects/github/kubernetes-tools" ]]; then
        source ${HOME}/projects/github/kubernetes-tools/completion/__completion
        export PATH=${PATH}:${HOME}/projects/github/kubernetes-tools/bin
    fi
}

alias start-redis="redis-server /usr/local/etc/redis.conf"
alias start-mongodb="mongod run --config $HOME/.mongod.conf"
alias start-mysql="sudo /usr/bin/mysqld_safe --datadir='/var/lib/mysql'"
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
export KERL_BUILD_DOCS=yes
