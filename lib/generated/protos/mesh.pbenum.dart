// This is a generated file - do not edit.
//
// Generated from protos/mesh.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class MeshPayload_Type extends $pb.ProtobufEnum {
  static const MeshPayload_Type SOS =
      MeshPayload_Type._(0, _omitEnumNames ? '' : 'SOS');
  static const MeshPayload_Type TELEMETRY =
      MeshPayload_Type._(1, _omitEnumNames ? '' : 'TELEMETRY');
  static const MeshPayload_Type TEXT =
      MeshPayload_Type._(2, _omitEnumNames ? '' : 'TEXT');
  static const MeshPayload_Type OGM =
      MeshPayload_Type._(3, _omitEnumNames ? '' : 'OGM');

  static const $core.List<MeshPayload_Type> values = <MeshPayload_Type>[
    SOS,
    TELEMETRY,
    TEXT,
    OGM,
  ];

  static final $core.List<MeshPayload_Type?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static MeshPayload_Type? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MeshPayload_Type._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
