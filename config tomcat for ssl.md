- 一、SSL flow
```
客户端向服务端索取公钥并验证公钥
服务端和客户端协商生成会话key
服务端可客户端使用会话key加密通信数据
```
```
client------(加密方法、协议版本、随机数)----------------->server
server------(确认加密方法，发送数字证书，随机数)--------->client
client------(获取证书中的公钥，加密一个新的随机数)------->server

server:通过私钥解密获取随机数，并根据三个随机数生成session key
client:根据三个随机数生成session key

client-------(采用session key加密数据)------------------->server
server-------(采用session key加密数据)------------------->client
```

- 二、SSL认证

#### java应用

生成服务端私钥文件keystore
```
keytool -genkey -alias serverkey -keyalg RSA -validity 365 -keysize 2048 -keystore serverkey.jks -keypass pass@123 
-storepass pass@123 -dname "CN=Gan Ting, OU=DevOps, O=titilink, L=Hang Zhou, ST=Zhe Jiang, C=CN"
# 如果不用签名直接作为服务端证书，到此就ok了
```

根据服务端私钥文件，导出服务端安全证书truststore
```
keytool -export -alias serverkey -keystore serverkey.jks -file serverkey.crt -storepass pass@123
```

##导出待签名证书
##```
##keytool -certreq -alias titilink_server -sigalg SHA256withRSA -file titilink_server.csr -keystore server.keystore
##```
##导入客户端CA证书
##```
##keytool -import -v trustcacerts -alias clientkey -file client.cer -keystore caret.jks 
##-keypass pass@123 -storepass pass@123
##```

生成客户端私钥文件keystore
```
keytool -genkey -alias clientkey -keyalg RSA -validity 365 -keystore clientkey.jks -keypass changeit -storepass changeit 
-dname "CN=Gan Ting, OU=DevOps, O=titilink, L=Hang Zhou, ST=Zhe Jiang, C=CN"
```

导出客户端安全证书truststore
```
keytool -export -alias clientkey -keystore clientkey.jks -file clientkey.crt -storepass changeit
```

服务端私钥导入客户端的安全证书
```
keytool -import -v trustcacerts -alias clientkey -file clientkey.crt -keystore caret.jks -keypass pass@123 -storepass pass@123
keytool -import -alias serverkey -file server.crt -keystore tclient.keystore 
```


##导入服务端证书
##```
##keytool -import -v trustcacerts -alias serverkey -file server.cer -keystore caret.jks -keypass changeit -storepass changeit
##```




使用证书
```
java -Djavax.net.ssl.keyStore=tomcat.keystore -Djavax.net.ssl.keyStorePassword=Tomcat@123 Server
java -Djavax.net.ssl.trustStore=tomcat.truststore -Djavax.net.ssl.trustStorePassword=Tomcat@123 Client
```

#### 非java应用：nginx、nodejs
生成服务端证书
```
openssl genrsa -aes256 -out server.key 2048
```


JAVA_OPTS="${JAVA_OPTS} -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=1616" 
JAVA_OPTS="${JAVA_OPTS} -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=true" 
JAVA_OPTS="${JAVA_OPTS} -Djavax.net.ssl.keyStore=/path/to/tomcat.keystore -Djavax.net.ssl.keyStorePassword=password" 
JAVA_OPTS="${JAVA_OPTS} -Djavax.net.ssl.trustStore=/path/to/tomcat.truststore -Djavax.net.ssl.trustStorePassword=trustword" 
JAVA_OPTS="${JAVA_OPTS} -Dcom.sun.management.jmxremote.ssl.need.client.auth=true"

jconsole -J-Djavax.net.ssl.keyStore=d:/var/jconsole.keystore -J-Djavax.net.ssl.keyStorePassword=Huawei@123 -J-Djavax.net.ssl.trustStore=d:/var/jconsole.truststore -J-Djavax.net.ssl.trustStorePassword=Huawei@123 161.17.249.200:1616


<Connector port="8443" protocol="com.titilink.safetool.DecryptHttp11NioProtocol"
              maxThreads="150" SSLEnabled="true" scheme="https" secure="true"
keystoreFile="./conf/server.keystore" keystorePass="" salt=""
              clientAuth="false" sslProtocol="TLS" sslEnabledProtocols="TLSv1.1,TLSv1.2"
                ciphers="TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256, TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384, TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA, TLS_RSA_WITH_AES_128_CBC_SHA256,TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA256, TLS_RSA_WITH_AES_256_CBC_SHA"
              allowTrace="false" URIEncoding="UTF-8"
              connectionTimeout="20000" xpoweredBy="false" server="127.0.0.1" maxPostSize="10240" maxHttpHeaderSize="8192"/>
