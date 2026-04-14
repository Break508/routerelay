import 'package:flutter_test/flutter_test.dart';
import 'package:fixnum/fixnum.dart';
import 'package:routerelay/generated/protos/mesh.pb.dart';

void main() {
  test('MeshPayload serialization and deserialization should work', () {
    final original = MeshPayload()
      ..convoyId = "test-convoy"
      ..senderId = "user-1"
      ..timestamp = Int64(123456789)
      ..hopCount = 0
      ..type = MeshPayload_Type.OGM;

    final bytes = original.writeToBuffer();
    final decoded = MeshPayload.fromBuffer(bytes);

    expect(decoded.convoyId, original.convoyId);
    expect(decoded.senderId, original.senderId);
    expect(decoded.timestamp, original.timestamp);
    expect(decoded.type, original.type);
    expect(decoded.hopCount, original.hopCount);
  });
}
