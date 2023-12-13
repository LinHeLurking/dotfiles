HOST_IP=$(cat /etc/resolv.conf | grep nameserver | awk '{ print $2 }')
WSL_IP=$(hostname -I | awk '{print $1}')
PROXY_PORT=1091
 
PROXY_HTTP="http://${HOST_IP}:${PROXY_PORT}"
 
set_proxy(){
    export http_proxy="${PROXY_HTTP}"
    export HTTP_PROXY="${PROXY_HTTP}"
 
    export https_proxy="${PROXY_HTTP}"
    export HTTPS_proxy="${PROXY_HTTP}"
 
    export ALL_PROXY="${PROXY_SOCKS5}"
    export all_proxy=${PROXY_SOCKS5}
 
    git config --global http.proxy ${PROXY_HTTP}
    git config --global https.proxy ${PROXY_HTTP}
 
    # git ssh proxy
    sed -i "s/# ProxyCommand/ProxyCommand/" ~/.ssh/config
    sed -i -E "s/ProxyCommand nc -X connect -x [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+ %h %p/ProxyCommand nc -X connect -x ${HOST_IP}:${PROXY_PORT} %h %p/" ~/.ssh/config
}
 
unset_proxy(){
    unset http_proxy
    unset HTTP_PROXY
    unset https_proxy
    unset HTTPS_PROXY
    unset ALL_PROXY
    unset all_proxy
 
    git config --global --unset http.proxy ${PROXY_HTTP}
    git config --global --unset https.proxy ${PROXY_HTTP}
 
    sed -i -E "s/ProxyCommand nc -X connect -x [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+ %h %p/# ProxyCommand nc -X connect -x 0.0.0.0:0 %h %p/" ~/.ssh/config
}
 
test_proxy(){
    echo "Host ip:" ${HOST_IP}
    echo "WSL ip:" ${WSL_IP}
    echo "Current proxy:" ${https_proxy}
}
