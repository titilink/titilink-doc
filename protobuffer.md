- [Use Protocol Buffers Instead of JSON For Your Next Service](http://blog.codeclimate.com/blog/2014/06/05/choose-protocol-buffers/)

- [gRpc](http://www.grpc.io/docs/#hello-grpc)

- [protobuffer](https://developers.google.com/protocol-buffers/docs/proto3)

- [message pack](http://msgpack.org/)

- [cap'n proto](https://capnproto.org/)

bytes------>proto buffer

- first byte for tag and type( last three bits for type, then right shit three bits for tag )

- the next byte for length of proto buffer

- the vaiant first bit for whether or not the nex byte is the same elements

- negative varinat use zig-zag encoding method (n << 1 ^ n >>31   or   n << 1 ^ n >> 63)
