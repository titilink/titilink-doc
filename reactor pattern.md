### why reactor pattern
```
1、old thread model waste cpu time for unneccessary operation by context switch
2、one Reactor will keep looking for events and will inform the corresponding event handler 
   to handle it once the event gets triggered
```

### participants of reactor pattern
```
1、Reactor  A Reactor runs in a separate thread and its job is to react to IO events by dispatching the work to the appropriate handler. 
2、Handler  A Handler performs the actual work to be done with an IO event
```

### thread pool & concurrency
```
Now what does a Thread pool has to do with this? Let me explain. 
The beauty of non blocking architecture is that we can write the server to run in a single 
Thread while catering all the requests from clients. Just forget about the Thread pool for a while. 
Naturally when concurrency is not used to design a server it should obviously be less responsive to events. 
In this scenario when the system runs in a single Thread the Reactor will not respond to other events until the Handler 
to which the event is dispatched is done with the event.
Why? Because we are using one Thread to handle all the events. We naturally have to go one by one.
```

### flow
```
reactor------>acceptor----->handler
                               |
                               |
                      <--------|
```

### long connection for netty
#### server side
- modify socket buffer size
```
sudo vim /etc/sysctl.conf
```
#### test client side
- modify max port number
```
sudo vim /etc/sysctl.conf
     net.ipv4.ip_local_port_range = 1024 65535 
/sbin/sysctl -p
```
- modify socket max handler
```
sudo vim /etc/security/limits.conf
     yourusername    soft    nofile  100000  
     yourusername    hard    nofile  100000  
```
- when kernel larger than 2.6.31, modify the macro value of socket handler
```
sudo vim /proc/sys/fs/nr_open
     2,000,000
```
#### nginx server code
- use nginx status module monitor connection
