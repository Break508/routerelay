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

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'mesh.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'mesh.pbenum.dart';

class MeshPayload extends $pb.GeneratedMessage {
  factory MeshPayload({
    $core.String? convoyId,
    $core.String? senderId,
    $fixnum.Int64? timestamp,
    $core.int? hopCount,
    MeshPayload_Type? type,
    $core.List<$core.int>? data,
    $core.List<$core.int>? signature,
  }) {
    final result = create();
    if (convoyId != null) result.convoyId = convoyId;
    if (senderId != null) result.senderId = senderId;
    if (timestamp != null) result.timestamp = timestamp;
    if (hopCount != null) result.hopCount = hopCount;
    if (type != null) result.type = type;
    if (data != null) result.data = data;
    if (signature != null) result.signature = signature;
    return result;
  }

  MeshPayload._();

  factory MeshPayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MeshPayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MeshPayload',
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'convoyId')
    ..aOS(2, _omitFieldNames ? '' : 'senderId')
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'timestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(4, _omitFieldNames ? '' : 'hopCount', fieldType: $pb.PbFieldType.OU3)
    ..aE<MeshPayload_Type>(5, _omitFieldNames ? '' : 'type',
        enumValues: MeshPayload_Type.values)
    ..a<$core.List<$core.int>>(
        6, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        7, _omitFieldNames ? '' : 'signature', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MeshPayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MeshPayload copyWith(void Function(MeshPayload) updates) =>
      super.copyWith((message) => updates(message as MeshPayload))
          as MeshPayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MeshPayload create() => MeshPayload._();
  @$core.override
  MeshPayload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MeshPayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MeshPayload>(create);
  static MeshPayload? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get convoyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set convoyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConvoyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConvoyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get senderId => $_getSZ(1);
  @$pb.TagNumber(2)
  set senderId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSenderId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSenderId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get timestamp => $_getI64(2);
  @$pb.TagNumber(3)
  set timestamp($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get hopCount => $_getIZ(3);
  @$pb.TagNumber(4)
  set hopCount($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHopCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearHopCount() => $_clearField(4);

  @$pb.TagNumber(5)
  MeshPayload_Type get type => $_getN(4);
  @$pb.TagNumber(5)
  set type(MeshPayload_Type value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasType() => $_has(4);
  @$pb.TagNumber(5)
  void clearType() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.List<$core.int> get data => $_getN(5);
  @$pb.TagNumber(6)
  set data($core.List<$core.int> value) => $_setBytes(5, value);
  @$pb.TagNumber(6)
  $core.bool hasData() => $_has(5);
  @$pb.TagNumber(6)
  void clearData() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.List<$core.int> get signature => $_getN(6);
  @$pb.TagNumber(7)
  set signature($core.List<$core.int> value) => $_setBytes(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSignature() => $_has(6);
  @$pb.TagNumber(7)
  void clearSignature() => $_clearField(7);
}

class Telemetry extends $pb.GeneratedMessage {
  factory Telemetry({
    $core.double? lat,
    $core.double? lng,
    $core.double? velocity,
    $core.double? heading,
  }) {
    final result = create();
    if (lat != null) result.lat = lat;
    if (lng != null) result.lng = lng;
    if (velocity != null) result.velocity = velocity;
    if (heading != null) result.heading = heading;
    return result;
  }

  Telemetry._();

  factory Telemetry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Telemetry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Telemetry',
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'lat')
    ..aD(2, _omitFieldNames ? '' : 'lng')
    ..aD(3, _omitFieldNames ? '' : 'velocity')
    ..aD(4, _omitFieldNames ? '' : 'heading')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Telemetry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Telemetry copyWith(void Function(Telemetry) updates) =>
      super.copyWith((message) => updates(message as Telemetry)) as Telemetry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Telemetry create() => Telemetry._();
  @$core.override
  Telemetry createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Telemetry getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Telemetry>(create);
  static Telemetry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get lat => $_getN(0);
  @$pb.TagNumber(1)
  set lat($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLat() => $_has(0);
  @$pb.TagNumber(1)
  void clearLat() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get lng => $_getN(1);
  @$pb.TagNumber(2)
  set lng($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLng() => $_has(1);
  @$pb.TagNumber(2)
  void clearLng() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get velocity => $_getN(2);
  @$pb.TagNumber(3)
  set velocity($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasVelocity() => $_has(2);
  @$pb.TagNumber(3)
  void clearVelocity() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get heading => $_getN(3);
  @$pb.TagNumber(4)
  set heading($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHeading() => $_has(3);
  @$pb.TagNumber(4)
  void clearHeading() => $_clearField(4);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
