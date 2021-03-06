// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of protoc;

abstract class WellKnownType {
  const WellKnownType();

  List<String> get extraImports => <String>[];

  void generateMethods(IndentingWriter out);
}

class _Any extends WellKnownType {
  const _Any();

  /// Generates methods for the Any message class for packing and unpacking
  /// values.
  @override
  void generateMethods(IndentingWriter out) {
    out.println('''
  /// Unpacks the message in [value] into [instance].
  ///
  /// Throws a [InvalidProtocolBufferException] if [typeUrl] does not correspond
  /// to the type of [instance].
  ///
  /// A typical usage would be `any.unpackInto(new Message())`.
  ///
  /// Returns [instance].
  T unpackInto<T extends $_protobufImportPrefix.GeneratedMessage>(T instance,
      {$_protobufImportPrefix.ExtensionRegistry extensionRegistry = $_protobufImportPrefix.ExtensionRegistry.EMPTY}) {
    $_protobufImportPrefix.unpackIntoHelper(value, instance, typeUrl,
        extensionRegistry: extensionRegistry);
    return instance;
  }

  /// Returns `true` if the encoded message matches the type of [instance].
  ///
  /// Can be used with a default instance:
  /// `any.canUnpackInto(Message.getDefault())`
  bool canUnpackInto($_protobufImportPrefix.GeneratedMessage instance) {
    return $_protobufImportPrefix.canUnpackIntoHelper(instance, typeUrl);
  }

  /// Creates a new [Any] encoding [message].
  ///
  /// The [typeUrl] will be [typeUrlPrefix]/`fullName` where `fullName` is
  /// the fully qualified name of the type of [message].
  static Any pack($_protobufImportPrefix.GeneratedMessage message,
      {String typeUrlPrefix = 'type.googleapis.com'}) {
    return new Any()
      ..value = message.writeToBuffer()
      ..typeUrl = '\${typeUrlPrefix}/\${message.info_.qualifiedMessageName}';
  }''');
  }
}

class _Timestamp extends WellKnownType {
  const _Timestamp();

  List<String> get extraImports =>
      [r"import 'dart:core' as $core show DateTime, Duration;"];

  @override
  void generateMethods(IndentingWriter out) {
    out.println(r'''
  /// Converts an instance to [DateTime].
  ///
  /// The result is in UTC time zone and has microsecond precision, as
  /// [DateTime] does not support nanosecond precision.
  $core.DateTime toDateTime() => new $core.DateTime.fromMicrosecondsSinceEpoch(
      seconds.toInt() * $core.Duration.microsecondsPerSecond + nanos ~/ 1000,
      isUtc: true);

  /// Creates a new instance from [dateTime].
  ///
  /// Time zone information will not be preserved.
  static Timestamp fromDateTime($core.DateTime dateTime) {
    int micros = dateTime.microsecondsSinceEpoch;
    return new Timestamp()
      ..seconds = new Int64(micros ~/ $core.Duration.microsecondsPerSecond)
      ..nanos = (micros % $core.Duration.microsecondsPerSecond).toInt() * 1000;
  }''');
  }
}

const _wellKnownTypes = {
  'google.protobuf.Any': _Any(),
  'google.protobuf.Timestamp': _Timestamp(),
};

WellKnownType wellKnownTypeForFullName(String fullName) =>
    _wellKnownTypes[fullName];
