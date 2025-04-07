/// Encodes and Decodes bytes using the
/// Base58 alghorithm
///
/// https://en.wikipedia.org/wiki/Base58

// Original implementation taken from: https://github.com/Alja7dali/swift-base58

import CryptoKit
import Bits

private let Base58EncodingTable: [Byte: Byte] = [
    0: .one,  1: .two,   2: .three,  3: .four,
    4: .five, 5: .six,   6: .seven,  7: .eight,
    8: .nine, 9: .A,    10: .B,     11: .C,
    12: .D,    13: .E,   14: .F,     15: .G,
    16: .H,    17: .J,   18: .K,     19: .L,
    20: .M,    21: .N,   22: .P,     23: .Q,
    24: .R,    25: .S,   26: .T,     27: .U,
    28: .V,    29: .W,   30: .X,     31: .Y,
    32: .Z,    33: .a,   34: .b,     35: .c,
    36: .d,    37: .e,   38: .f,     39: .g,
    40: .h,    41: .i,   42: .j,     43: .k,
    44: .m,    45: .n,   46: .o,     47: .p,
    48: .q,    49: .r,   50: .s,     51: .t,
    52: .u,    53: .v,   54: .w,     55: .x,
    56: .y,    57: .z
]

private let _encode: (Byte) -> Byte = {
    Base58EncodingTable[$0] ?? .max
}

private let Base58DecodingTable: [Byte: Byte] = [
    .one:  0, .two:  1, .three:  2,  .four: 3,
    .five:  4, .six:  5, .seven:  6, .eight: 7,
    .nine:  8,   .A:  9,     .B: 10,     .C: 11,
    .D: 12,   .E: 13,     .F: 14,     .G: 15,
    .H: 16,   .J: 17,     .K: 18,     .L: 19,
    .M: 20,   .N: 21,     .P: 22,     .Q: 23,
    .R: 24,   .S: 25,     .T: 26,     .U: 27,
    .V: 28,   .W: 29,     .X: 30,     .Y: 31,
    .Z: 32,   .a: 33,     .b: 34,     .c: 35,
    .d: 36,   .e: 37,     .f: 38,     .g: 39,
    .h: 40,   .i: 41,     .j: 42,     .k: 43,
    .m: 44,   .n: 45,     .o: 46,     .p: 47,
    .q: 48,   .r: 49,     .s: 50,     .t: 51,
    .u: 52,   .v: 53,     .w: 54,     .x: 55,
    .y: 56,   .z: 57
]

private let _decode: (Byte) -> Byte? = {
    Base58DecodingTable[$0]
}

public enum Base58DecodingError: Error {
    case invalidByte(Byte)
}



public enum Base58UncheckError: Error {
    case invalidPayload
}

public enum Base58 {
    public static func encode(
        _ bytes: Bytes,
        alphabet mapper: Optional<(Byte) -> Byte> = .none
    ) -> Bytes {
        let mapper = mapper ?? _encode
        
        var zerosCount = 0
        
        while bytes[zerosCount] == 0 {
            zerosCount += 1
        }
        
        let bytesCount = bytes.count - zerosCount
        let b58Count = ((bytesCount * 138) / 100) + 1
        var b58 = Bytes(repeating: 0, count: b58Count)
        var count = 0
        
        var x = zerosCount
        while x < bytesCount {
            var carry = Int(bytes[x]), i = 0, j = b58Count - 1
            while j > -1 {
                if carry != 0 || i < count {
                    carry += 256 * Int(b58[j])
                    b58[j] = Byte(carry % 58)
                    carry /= 58
                    i += 1
                }
                j -= 1
            }
            count = i
            x += 1
        }
        
        // skip leading zeros
        var leadingZeros = 0
        while b58[leadingZeros] == 0 {
            leadingZeros += 1
        }
        
        return Bytes(repeating: .one, count: zerosCount)
        + Bytes(b58[leadingZeros...]).map(mapper)
    }
    
    public static func decode(
        _ bytes: Bytes,
        alphabet mapper: Optional<(Byte) -> Byte?> = .none
    ) throws -> Bytes {
        let mapper = mapper ?? _decode
        
        var onesCount = 0
        
        while bytes[onesCount] == .one {
            onesCount += 1
        }
        
        let bytesCount = bytes.count - onesCount
        let b58Count = ((bytesCount * 733) / 1000) + 1 - onesCount
        var b58 = Bytes(repeating: 0, count: b58Count)
        var count = 0
        
        var x = onesCount
        while x < bytesCount {
            guard let b58Index = mapper(bytes[x]) else {
                throw Base58DecodingError.invalidByte(bytes[x])
            }
            var carry = Int(b58Index), i = 0, j = b58Count - 1
            while j > -1 {
                if carry != 0 || i < count {
                    carry += 58 * Int(b58[j])
                    b58[j] = Byte(carry % 256)
                    carry /= 256
                    i += 1
                }
                j -= 1
            }
            count = i
            x += 1
        }
        
        // skip leading zeros
        var leadingZeros = 0
        while b58[leadingZeros] == 0 {
            leadingZeros += 1
        }
        
        return Bytes(repeating: 0, count: onesCount)
        + Bytes(b58[leadingZeros...])
    }

    public static func check(_ bytes: Bytes) -> Bytes {
        let digest = [UInt8](SHA256.hash(data: [UInt8](SHA256.hash(data: bytes))))
        return encode(bytes + digest[0..<4])
    }
    
    public static func uncheck(_ bytes: Bytes) throws -> Bytes {
        let payload = try decode(bytes)
        
        let result = Array(payload[0..<payload.count-4])
        let check = payload[payload.count-4..<payload.count]
        let digest = [UInt8](SHA256.hash(data: [UInt8](SHA256.hash(data: result))))
        
        guard check == digest[0..<4] else {
            throw Base58UncheckError.invalidPayload
        }
        
        return result
    }
}
