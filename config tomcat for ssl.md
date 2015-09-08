- SSL flow
```
客户端香服务端索取公钥并验证公钥
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

- SSL认证

生成证书
```
keytool -genkey -alias tomcat -keyalg RSA -validity 365 -keystore tomcat.keystore -keypass Tomcat@123 -storepass Tomcat@123 -dname "CN=Gan Ting, OU=DevOps, O=titilink, L=Hang Zhou, ST=Zhe Jiang, C=CN"
```

导出证书
```
keytool -export -alias tomcat -keystore tomcat.keystore -file tomcat.cer -storepass Tomcat@123
```

导入证书
```
keytool -import -alias tomcat -file tomcat.cer -keystore tomcat.truststore -storepass Tomcat@123
```

使用证书
```
java -Djavax.net.ssl.keyStore=tomcat.keystore -Djavax.net.ssl.keyStorePassword=Tomcat@123 Server
java -Djavax.net.ssl.trustStore=tomcat.truststore -Djavax.net.ssl.trustStorePassword=Tomcat@123 Client
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
