// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_cache_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveCacheEntryAdapter extends TypeAdapter<HiveCacheEntry> {
  @override
  final int typeId = 0;

  @override
  HiveCacheEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveCacheEntry(
      key: fields[0] as String,
      data: fields[1] as dynamic,
      createdAt: fields[2] as DateTime,
      expiresAt: fields[3] as DateTime?,
      headers: (fields[4] as Map?)?.cast<String, String>(),
      etag: fields[5] as String?,
      statusCode: fields[6] as int?,
      contentType: fields[7] as String,
      sizeInBytes: fields[8] as int,
      isBinary: fields[9] as bool,
      filePath: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HiveCacheEntry obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.data)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.expiresAt)
      ..writeByte(4)
      ..write(obj.headers)
      ..writeByte(5)
      ..write(obj.etag)
      ..writeByte(6)
      ..write(obj.statusCode)
      ..writeByte(7)
      ..write(obj.contentType)
      ..writeByte(8)
      ..write(obj.sizeInBytes)
      ..writeByte(9)
      ..write(obj.isBinary)
      ..writeByte(10)
      ..write(obj.filePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveCacheEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
