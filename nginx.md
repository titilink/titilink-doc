- ./configure --prefix=/opt/onframework/nginx --add-module=/opt/onframework/buildnginx/tcp_proxy/ --add-module=/opt/onframework/buildnginx/upstrean_check/ --with-http_ssl_module --with-http_flv_module --with-http_stub_status_module --with-http_gzip_static_module --with-pcre=/opt/onframework/buildnginx/pcre --with-zlib=/opt/onframework/buildnginx/zlib --with-openssl=/opt/onframework/buildnginx/openssl

- iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 6443 

- [tcp proxy](https://github.com/yaoweibin/nginx_tcp_proxy_module/tree/master/doc#ngx_tcp_websocket_module)

```
tcp {

  server {
     
  }
 
}
```

```
user onframework;
worker_processes 4;
events {
    use epoll;
    worker_connections  1024;
}
http {
    server_tokens off;
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    log_format main '$remote_addr $request';
    access_log off;
    keepalive_timeout  65;
    proxy_read_timeout 300;
    client_header_timeout 10;
	
    ## console lb
    upstream nlbserver {
        server 10.180.45.227:8086;
        server 10.180.137.221:8086;

        check interval=10000 rise=1 fall=3 timeout=3000;
    }
	
    server {
        listen 443;
        server_name 10.180.45.227;
        ssl on;
	ssl_session_timeout 5m;
	ssl_protocols TLSv1.1 TLSv1.2;
        ssl_ciphers "AES128-SHA:AES256-SHA:AES128-SHA256:AES256-SHA256:HIGH:!MEDIUM:!LOW:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4:@STRENGTH";

        ssl_certificate /opt/onframework/nginx/conf/SSL/server.crt;
        ssl_certificate_key /opt/onframework/nginx/conf/SSL/server.key;
		
	ssl_prefer_server_ciphers on;
        ssl_session_cache shared:SSL:10m;

        proxy_set_header        Host            $host:$server_port;
        proxy_set_header        X-Real-IP       $remote_addr;
        proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
		
	add_header Strict-Transport-Security max-age=63072000;
        add_header X-Frame-Options SAMEORIGIN;
        add_header X-Content-Type-Options nosniff; 
        add_header X-Download-Options "noopen";
        add_header X-XSS-Protection "1; mode=block;";

        ##console   portal
        location /silvan/rest/v1.0 {
            proxy_pass https://nlbserver;
            proxy_redirect off;
        }
		
	error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

    }
    
}

```
