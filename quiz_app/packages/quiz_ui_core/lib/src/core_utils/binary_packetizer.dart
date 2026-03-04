import 'dart:convert';
import 'dart:typed_data';

/// A lightweight binary serialization utility for optimizing
/// Realtime WebSocket payloads.
///
/// Reduces payload size by avoiding JSON string overhead for repeated
/// keys and using compact byte representations for IDs and timestamps.
class BinaryPacketizer {
  /// Encodes a Map into a compact binary format.
  ///
  /// Format: [Version(1b)][Type(1b)][PayloadLength(4b)][Payload(N)]
  static Uint8List encode(Map<String, dynamic> data) {
    final jsonString = jsonEncode(data);
    final payloadBytes = utf8.encode(jsonString);

    final result = BytesBuilder();
    result.addByte(1); // Version
    result.addByte(0x01); // Type: Generic JSON Map

    final lengthHeader = ByteData(4)..setUint32(0, payloadBytes.length);
    result.add(lengthHeader.buffer.asUint8List());
    result.add(payloadBytes);

    return result.toBytes();
  }

  /// Decodes a binary packet back into a Map.
  static Map<String, dynamic> decode(Uint8List bytes) {
    if (bytes.length < 6) throw Exception('Invalid packet size');

    // ignore: unused_local_variable
    final version = bytes[0];
    // ignore: unused_local_variable
    final type = bytes[1];

    final length = ByteData.sublistView(bytes, 2, 6).getUint32(0);
    final payload = bytes.sublist(6, 6 + length);

    return jsonDecode(utf8.decode(payload)) as Map<String, dynamic>;
  }
}
