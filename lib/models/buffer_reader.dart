import 'dart:typed_data';

class BufferReader {
  Uint8List buffer;
  int offset = 0;

  BufferReader(this.buffer);

  int readInt32() {
    if (offset + 4 > buffer.length) {
      throw RangeError('Offset is outside the bounds of the DataView');
    }
    int value = buffer.buffer.asByteData().getInt32(offset, Endian.little);
    offset += 4;
    return value;
  }

  int readUInt32() {
    if (offset + 4 > buffer.length) {
      throw RangeError('Offset is outside the bounds of the DataView');
    }
    int value = buffer.buffer.asByteData().getUint32(offset, Endian.little);
    offset += 4;
    return value;
  }

  int readUInt8() {
    if (offset + 1 > buffer.length) {
      throw RangeError('Offset is outside the bounds of the DataView');
    }
    int value = buffer[offset];
    offset += 1;
    return value;
  }

  Uint8List readSlice(int size) {
    if (offset + size > buffer.length) {
      throw RangeError('Offset is outside the bounds of the DataView');
    }
    Uint8List slice = buffer.sublist(offset, offset + size);
    offset += size;
    return slice;
  }

  BigInt readUInt64() {
    var sublist = buffer.sublist(offset, offset + 8);
    offset += 8;
    return decodeBigInt(sublist);
  }

  BigInt decodeBigInt(Uint8List bytes) {
    BigInt result = BigInt.zero;
    for (int i = 0; i < bytes.length; i++) {
      // Shift the byte to its correct byte position and add it to the result
      result += BigInt.from(bytes[i]) << (8 * i);
    }
    return result;
  }

  List<Uint8List> readVector() {
    var len = readVarInt();
    List<Uint8List> result = [];
    for (int i = 0; i < len; i++) {
      var itemLen = readVarInt();
      result.add(readSlice(itemLen));
    }
    return result;
  }

  int readVarInt() {
    var value = readUInt8();
    if (value < 0xfd) {
      return value;
    } else if (value == 0xfd) {
      return readUInt16();
    } else if (value == 0xfe) {
      return readUInt32();
    } else {
      return readUInt64().toInt();
    }
  }

  int readUInt16() => buffer.buffer.asByteData().getUint16(offset += 2, Endian.little) - 2;
}
