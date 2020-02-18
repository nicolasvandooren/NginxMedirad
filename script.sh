#!/bin/bash

#######################################################################################
#ELASTIC SEARCH

missing_env_var_secret=false

if ! [ -z "$MEDIRAD_NGINX_ENABLE_ELASTIC" ]; then
    if [ "$MEDIRAD_NGINX_ENABLE_ELASTIC" = true ]; then

        echo "Start init filebeat"
        missing_env_var_secret=false

        if [ -z $MEDIRAD_NGINX_LOGSTASH_URL ]; then
          echo "Missing MEDIRAD_NGINX_LOGSTASH_URL environment variable"
          missing_env_var_secret=true
        else
           echo -e "environment variable MEDIRAD_NGINX_LOGSTASH_URL OK"
           sed -i "s|\${logstash_url}|$MEDIRAD_NGINX_LOGSTASH_URL|" /etc/filebeat/filebeat.yml
        fi

        if [[ -z $MEDIRAD_NGINX_ELASTIC_INSTANCE ]]; then
           echo "Missing MEDIRAD_NGINX_ELASTIC_INSTANCE environment variable"
           missing_env_var_secret=true
        else
            echo -e "environment variable MEDIRAD_NGINX_ELASTIC_INSTANCE \e[92mOK\e[0m"
            sed -i "s|\${instance}|$MEDIRAD_NGINX_ELASTIC_INSTANCE|" /etc/filebeat/filebeat.yml
        fi


        #if missing env var or secret => exit
        if [ $missing_env_var_secret = true ]; then
          exit 1
        else
           echo "all elastic secrets and all env var OK"
        fi

        filebeat modules disable system
        service filebeat restart

        echo "Ending setup FILEBEAT"
    fi
else
    echo "[INFO] : Missing MEDIRAD_NGINX_ENABLE_ELASTIC environment variable. Elastic is not enable."
fi

#######################################################################################

CLIENT_SECRET=$(cat /run/secrets/client_secret)
sed -i "s|\${server_name}|$IRDBB_ROOT_HOST|g" /usr/local/openresty/nginx/conf/nginx.conf
sed -i "s|\${client_secret}|$CLIENT_SECRET|g" /usr/local/openresty/nginx/conf/nginx.conf

./usr/local/openresty/bin/openresty -g 'daemon off;'
