import 'dart:async';
import 'dart:io';

import 'package:pure_ftp/src/socket/common/client_raw_socket.dart';

class ClientRawSocketImpl extends ClientRawSocket {
  late RawSocket _socket;
  bool _secure = false;

  @override
  Future<void> close() => _socket.close();

  Future<void> connect(String host, int port, {Duration? timeout}) async {
    _socket = await RawSocket.connect(host, port, timeout: timeout);
  }

  @override
  List<int>? readMessage([int? length]) {
    final read =
        _secure ? _socket.read(length) : _socket.readMessage(length)?.data;
    if (read == null) {
      return null;
    }
    return List.from(read);
  }

  @override
  Future<ClientRawSocket> secureSocket(
      {bool ignoreCertificateErrors = false}) async {
    _socket = await RawSecureSocket.secure(_socket,
        onBadCertificate: (_) => ignoreCertificateErrors);
    _secure = true;
    return this;
  }

  @override
  void write(List<int> data, [int offset = 0, int? count]) =>
      _socket.write(data, offset, count);

  @override
  Future<void> shutdown(ClientSocketDirection how) async =>
      _socket.shutdown(how.toPlatform);
}

extension _MapDirection on ClientSocketDirection {
  SocketDirection get toPlatform {
    switch (this) {
      case ClientSocketDirection.read:
        return SocketDirection.receive;
      case ClientSocketDirection.write:
        return SocketDirection.send;
      case ClientSocketDirection.readWrite:
        return SocketDirection.both;
    }
  }
}
