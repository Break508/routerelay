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
  ],
};

/// Descriptor for `MeshPayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List meshPayloadDescriptor = $convert.base64Decode(
    'CgtNZXNoUGF5bG9hZBIbCgljb252b3lfaWQYASABKAlSCGNvbnZveUlkEhsKCXNlbmRlcl9pZB'
    'gCIAEoCVIIc2VuZGVySWQSHAoJdGltZXN0YW1wGAMgASgEUgl0aW1lc3RhbXASGwoJaG9wX2Nv'
    'dW50GAQgASgNUghob3BDb3VudBIlCgR0eXBlGAUgASgOMhEuTWVzaFBheWxvYWQuVHlwZVIEdH'
    'lwZRISCgRkYXRhGAYgASgMUgRkYXRhEhwKCXNpZ25hdHVyZRgHIAEoDFIJc2lnbmF0dXJlIjEK'
    'BFR5cGUSBwoDU09TEAASDQoJVEVMRU1FVFJZEAESCAoEVEVYVBACEgcKA09HTRAD');

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
