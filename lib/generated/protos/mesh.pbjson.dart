// This is a generated file - do not edit.
//
// Generated from protos/mesh.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use meshPayloadDescriptor instead')
const MeshPayload$json = {
  '1': 'MeshPayload',
  '2': [
    {'1': 'convoy_id', '3': 1, '4': 1, '5': 9, '10': 'convoyId'},
    {'1': 'sender_id', '3': 2, '4': 1, '5': 9, '10': 'senderId'},
    {'1': 'timestamp', '3': 3, '4': 1, '5': 4, '10': 'timestamp'},
    {'1': 'hop_count', '3': 4, '4': 1, '5': 13, '10': 'hopCount'},
    {
      '1': 'type',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.MeshPayload.Type',
      '10': 'type'
    },
    {'1': 'data', '3': 6, '4': 1, '5': 12, '10': 'data'},
    {'1': 'signature', '3': 7, '4': 1, '5': 12, '10': 'signature'},
  ],
  '4': [MeshPayload_Type$json],
};

@$core.Deprecated('Use meshPayloadDescriptor instead')
const MeshPayload_Type$json = {
  '1': 'Type',
  '2': [
    {'1': 'SOS', '2': 0},
    {'1': 'TELEMETRY', '2': 1},
    {'1': 'TEXT', '2': 2},
    {'1': 'OGM', '2': 3},
    {'1': 'TILE_REQUEST', '2': 4},
    {'1': 'TILE_RESPONSE', '2': 5},
    {'1': 'VOICE', '2': 6},
  ],
};

/// Descriptor for `MeshPayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List meshPayloadDescriptor = $convert.base64Decode(
    'CgtNZXNoUGF5bG9hZBIbCgljb252b3lfaWQYASABKAlSCGNvbnZveUlkEhsKCXNlbmRlcl9pZB'
    'gCIAEoCVIIc2VuZGVySWQSHAoJdGltZXN0YW1wGAMgASgEUgl0aW1lc3RhbXASGwoJaG9wX2Nv'
    'dW50GAQgASgNUghob3BDb3VudBIlCgR0eXBlGAUgASgOMhEuTWVzaFBheWxvYWQuVHlwZVIEdH'
    'lwZRISCgRkYXRhGAYgASgMUgRkYXRhEhwKCXNpZ25hdHVyZRgHIAEoDFIJc2lnbmF0dXJlImEK'
    'BFR5cGUSBwoDU09TEAASDQoJVEVMRU1FVFJZEAESCAoEVEVYVBACEgcKA09HTRADEhAKDFRJTE'
    'VfUkVRVUVTVBAEEhEKDVRJTEVfUkVTUE9OU0UQBRIJCgVWT0lDRRAG');

@$core.Deprecated('Use telemetryDescriptor instead')
const Telemetry$json = {
  '1': 'Telemetry',
  '2': [
    {'1': 'lat', '3': 1, '4': 1, '5': 1, '10': 'lat'},
    {'1': 'lng', '3': 2, '4': 1, '5': 1, '10': 'lng'},
    {'1': 'velocity', '3': 3, '4': 1, '5': 1, '10': 'velocity'},
    {'1': 'heading', '3': 4, '4': 1, '5': 1, '10': 'heading'},
  ],
};

/// Descriptor for `Telemetry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List telemetryDescriptor = $convert.base64Decode(
    'CglUZWxlbWV0cnkSEAoDbGF0GAEgASgBUgNsYXQSEAoDbG5nGAIgASgBUgNsbmcSGgoIdmVsb2'
    'NpdHkYAyABKAFSCHZlbG9jaXR5EhgKB2hlYWRpbmcYBCABKAFSB2hlYWRpbmc=');

@$core.Deprecated('Use tileRequestDescriptor instead')
const TileRequest$json = {
  '1': 'TileRequest',
  '2': [
    {'1': 'z', '3': 1, '4': 1, '5': 5, '10': 'z'},
    {'1': 'x', '3': 2, '4': 1, '5': 5, '10': 'x'},
    {'1': 'y', '3': 3, '4': 1, '5': 5, '10': 'y'},
  ],
};

/// Descriptor for `TileRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tileRequestDescriptor = $convert.base64Decode(
    'CgtUaWxlUmVxdWVzdBIMCgF6GAEgASgFUgF6EgwKAXgYAiABKAVSAXgSDAoBeRgDIAEoBVIBeQ'
    '==');

@$core.Deprecated('Use tileResponseDescriptor instead')
const TileResponse$json = {
  '1': 'TileResponse',
  '2': [
    {'1': 'z', '3': 1, '4': 1, '5': 5, '10': 'z'},
    {'1': 'x', '3': 2, '4': 1, '5': 5, '10': 'x'},
    {'1': 'y', '3': 3, '4': 1, '5': 5, '10': 'y'},
    {'1': 'tile_data', '3': 4, '4': 1, '5': 12, '10': 'tileData'},
  ],
};

/// Descriptor for `TileResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tileResponseDescriptor = $convert.base64Decode(
    'CgxUaWxlUmVzcG9uc2USDAoBehgBIAEoBVIBehIMCgF4GAIgASgFUgF4EgwKAXkYAyABKAVSAX'
    'kSGwoJdGlsZV9kYXRhGAQgASgMUgh0aWxlRGF0YQ==');
