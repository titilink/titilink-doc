<Connector port="7443" protocol="com.titilink.safetool.DecryptHttp11NioProtocol"
              maxThreads="150" SSLEnabled="true" scheme="https" secure="true"
keystoreFile="./conf/server.keystore" keystorePass="aHcaACe0=" salt="B0489A259407FF6C176DB438B85387E4"
              clientAuth="false" sslProtocol="TLS" sslEnabledProtocols="TLSv1.1,TLSv1.2"
                ciphers="TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256, TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384, TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA, TLS_RSA_WITH_AES_128_CBC_SHA256,TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA256, TLS_RSA_WITH_AES_256_CBC_SHA"
              allowTrace="false" URIEncoding="UTF-8"
              connectionTimeout="20000" xpoweredBy="false" server="127.0.0.1"
               redirectPort="8443" maxPostSize="10240" maxHttpHeaderSize="8192"/>
