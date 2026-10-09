"""Vectors for the wallet's mirror of the Counterparty parser.

The wallet shows the message a reveal publishes before signing it, so it must
rebuild that message exactly like the parser: the envelope extraction and the
serde_cbor round trip of ordinals metadata (lib/common/tapscript.dart,
lib/common/cbor.dart), and the reading of the outputs that carry data or the
reveal marker (classifyCounterpartyOutput). Every vector here is a reveal
transaction parsed by `counterparty_rs` itself, so the expected values are the
parser's, not the wallet's.

Usage, with the `counterparty_rs` module of counterparty-core v11.5.0:

    python -I test/fixtures/generate_counterparty_parser_vectors.py \
        test/fixtures/counterparty_parser_vectors.json <scratch dir>
"""

import json
import struct
import sys

from counterparty_rs import indexer

# a valid x-only key (counterparty_reveal_messages.json `envelope_key`)
KEY = bytes.fromhex("c2e75ffa83a8dd813c5dbd9adb4d546d7bbe561dbd5c52d16e25c8465d287837")
# the commit txid the reveal spends, display byte order: the ARC4 key
COMMIT_TXID = bytes.fromhex("caf899297fdde9e60c6c50656e3fb7e91e5c5a59070a09d32a2c70f8d68fc60c")
PREFIX = b"CNTRPRTY"
P2WPKH_A = bytes.fromhex("0014381b5e3cf3f9d5d387f8fac1dde50cf5353160f3")
P2WPKH_B = bytes.fromhex("0014d54e68ffeb057db5f29803843334e703c94acd8e")


def push(data):
    n = len(data)
    if n == 0:
        return b"\x00"
    if n < 0x4C:
        return bytes([n]) + data
    if n < 0x100:
        return b"\x4c" + bytes([n]) + data
    return b"\x4d" + struct.pack("<H", n) + data


def envelope(items):
    """`OP_FALSE OP_IF <items> OP_ENDIF <KEY> OP_CHECKSIG`; an int item is a
    raw opcode, bytes are pushed."""
    body = b"".join(bytes([i]) if isinstance(i, int) else push(i) for i in items)
    return b"\x00\x63" + body + b"\x68" + push(KEY) + b"\xac"


def ord_envelope(metadata_chunks, mime=b"text/plain", content=None, head=None):
    items = head if head is not None else [b"ord", b"\x07", b"xcp", b"\x01", mime]
    for chunk in metadata_chunks:
        items = items + [b"\x05", chunk]
    if content is not None:
        items = items + [b""] + content
    return envelope(items)


def rc4(key, data):
    s = list(range(256))
    j = 0
    for i in range(256):
        j = (j + s[i] + key[i % len(key)]) % 256
        s[i], s[j] = s[j], s[i]
    i = j = 0
    out = bytearray()
    for b in data:
        i = (i + 1) % 256
        j = (j + s[i]) % 256
        s[i], s[j] = s[j], s[i]
        out.append(b ^ s[(s[i] + s[j]) % 256])
    return bytes(out)


def varint(n):
    if n < 0xFD:
        return bytes([n])
    if n <= 0xFFFF:
        return b"\xfd" + struct.pack("<H", n)
    return b"\xfe" + struct.pack("<I", n)


def reveal_tx(envelope_script, outputs):
    """A one-input segwit transaction spending COMMIT_TXID:0 with the witness
    <signature> <envelope> <control block>; outputs are scriptPubKeys."""
    tx = struct.pack("<i", 2) + b"\x00\x01" + varint(1)
    tx += COMMIT_TXID[::-1] + struct.pack("<I", 0) + b"\x00" + b"\xff\xff\xff\xff"
    tx += varint(len(outputs))
    for script in outputs:
        tx += struct.pack("<q", 546 if script[0] != 0x6A else 0) + varint(len(script)) + script
    witness = [b"\x11" * 64, envelope_script, b"\xc0" + KEY]
    tx += varint(len(witness)) + b"".join(varint(len(w)) + w for w in witness)
    tx += struct.pack("<I", 0)
    return tx.hex()


def marker_op_return():
    return b"\x6a" + push(PREFIX)


def arc4_op_return(clear):
    return b"\x6a" + push(rc4(COMMIT_TXID, clear))


def p2pkh_carrying(data):
    """A P2PKH-shaped output whose hash deobfuscates to `<len> CNTRPRTY data`."""
    clear = bytes([len(PREFIX) + len(data)]) + PREFIX + data
    clear = clear + b"\x00" * (20 - len(clear))
    assert len(clear) == 20
    return b"\x76\xa9\x14" + rc4(COMMIT_TXID, clear) + b"\x88\xac"


def multisig_carrying(data):
    """A 1-of-2 bare multisig output whose first key carries `<len> CNTRPRTY data`."""
    clear = bytes([len(PREFIX) + len(data)]) + PREFIX + data
    clear = clear + b"\x00" * (31 - len(clear))
    pk1 = b"\x02" + rc4(COMMIT_TXID, clear) + b"\x00"
    pk2 = b"\x03" + KEY
    return b"\x51" + push(pk1) + push(pk2) + b"\x52\xae"


def cbor_head(major, n):
    if n < 24:
        return bytes([(major << 5) | n])
    if n < 0x100:
        return bytes([(major << 5) | 24, n])
    if n < 0x10000:
        return bytes([(major << 5) | 25]) + struct.pack(">H", n)
    if n < 0x100000000:
        return bytes([(major << 5) | 26]) + struct.pack(">I", n)
    return bytes([(major << 5) | 27]) + struct.pack(">Q", n)


def arr(*items):
    return cbor_head(4, len(items)) + b"".join(items)


def uint(n):
    return cbor_head(0, n)


def nint(n):
    return cbor_head(1, -1 - n)


def text(s):
    b = s.encode() if isinstance(s, str) else s
    return cbor_head(3, len(b)) + b


def bstr(b):
    return cbor_head(2, len(b)) + b


def cmap(*pairs):
    return cbor_head(5, len(pairs)) + b"".join(k + v for k, v in pairs)


def tag(t, v):
    return cbor_head(6, t) + v


TRUE, FALSE, NULL, UNDEFINED = b"\xf5", b"\xf4", b"\xf6", b"\xf7"


def f16(x):
    return b"\xf9" + struct.pack(">e", x)


def f32(x):
    return b"\xfa" + struct.pack(">f", x)


def f64(x):
    return b"\xfb" + struct.pack(">d", x)


ISSUANCE = [uint(1000), TRUE, FALSE, NULL, text("desc")]


def nested(depth):
    v = uint(0)
    for _ in range(depth):
        v = arr(v)
    return v


ENVELOPES = [
    ("generic_concatenates_pushes", envelope([PREFIX + b"\x04", b"abc", 0x51, b"def", 0x60])),
    ("ord_array", ord_envelope([arr(uint(22), *ISSUANCE)])),
    ("ord_metadata_in_chunks", ord_envelope([arr(uint(22), *ISSUANCE)[:3], arr(uint(22), *ISSUANCE)[3:]])),
    ("ord_with_content", ord_envelope([arr(uint(22), uint(5))], content=[b"hello ", b"world"])),
    ("ord_map_xcp", ord_envelope([cmap((text("name"), text("x")), (text("xcp"), arr(uint(22), uint(7))))])),
    ("ord_map_duplicate_xcp_last_wins", ord_envelope([cmap((text("xcp"), arr(uint(2), uint(1))), (text("xcp"), arr(uint(4), text("bcrt1qphlpxevt78x4g8t5s9aj0dpr9lfsjt9vlss6ej"), uint(1))))])),
    ("ord_integers", ord_envelope([arr(uint(22), uint(0), uint(23), uint(24), uint(255), uint(256), uint(65535), uint(65536), uint(2**32 - 1), uint(2**32), uint(2**53 + 1), uint(2**64 - 1), nint(-1), nint(-25), nint(-(2**64)))])),
    ("ord_non_minimal_integers", ord_envelope([b"\x98\x03" + b"\x18\x16" + b"\x19\x00\x05" + b"\x3a\x00\x00\x00\x00"])),
    ("ord_floats", ord_envelope([arr(uint(30), f64(1.5), f64(100000.0), f64(0.1), f32(3.25), f16(-0.0), f64(float("inf")), f64(float("-inf")), f32(float("nan")), f64(65504.0), f64(5.960464477539063e-08), f64(2.0 ** -20), f64(1e300))])),
    ("ord_tags_dropped", ord_envelope([tag(55799, arr(uint(22), tag(1, uint(1700000000)), tag(2, bstr(b"\x01\x00")), tag(32, text("http://x"))))])),
    ("ord_undefined_reads_null", ord_envelope([arr(uint(22), UNDEFINED, NULL)])),
    ("ord_indefinite_lengths", ord_envelope([b"\x9f" + uint(22) + b"\x5f" + bstr(b"ab") + bstr(b"cd") + b"\xff" + b"\x7f" + text("he") + text("llo") + b"\xff" + b"\xbf" + text("k") + uint(1) + b"\xff" + b"\xff"])),
    ("ord_nested_map_sorted_deduplicated", ord_envelope([arr(uint(22), cmap((text("bb"), uint(1)), (text("a"), uint(2)), (uint(10), uint(3)), (nint(-1), uint(4)), (uint(1), uint(5)), (bstr(b"z"), uint(6)), (text("a"), uint(7)), (arr(uint(1)), uint(8)), (TRUE, uint(9)), (NULL, uint(10)), (f64(1.5), uint(11))))])),
    # arrays and maps of one length sort by their encodings, compared byte by
    # byte: [1000] (81 19 03 e8) before [true] (81 f5)
    ("ord_map_keys_of_one_length_by_encoding", ord_envelope([arr(uint(22), cmap((arr(TRUE), uint(1)), (arr(uint(1000)), uint(2)), (cmap((uint(0), TRUE)), uint(3)), (cmap((uint(0), uint(1000))), uint(4))))])),
    # str::from_utf8 keeps a byte order mark
    ("ord_text_keeps_bom", ord_envelope([arr(uint(22), text("\ufeffA"), text("\ufeff\ufeffB"), cmap((text("\ufeffk"), uint(1)), (text("k"), uint(2))))])),
    ("ord_type_id_truncated_to_u8", ord_envelope([arr(uint(260), uint(1))])),
    ("ord_negative_type_id_truncated_to_u8", ord_envelope([arr(nint(-252), uint(1))])),
    ("ord_big_type_id_truncated_to_u8", ord_envelope([arr(uint(2**64 - 252), uint(1))])),
    ("ord_invalid_utf8_mime_is_empty", ord_envelope([arr(uint(22), uint(1))], mime=b"\xff\xfe")),
    ("ord_mime_keeps_bom", ord_envelope([arr(uint(22), uint(1))], mime=b"\xef\xbb\xbftext/plain")),
    ("ord_mime_not_a_push", ord_envelope([arr(uint(22), uint(1))], head=[b"ord", b"\x07", b"xcp", b"\x01", 0x51])),
    # serde_cbor refuses the 128th nested array or map
    ("ord_depth_127_ok", ord_envelope([arr(uint(22), nested(126))])),
    ("ord_depth_128_rejected", ord_envelope([arr(uint(22), nested(127))])),
    ("ord_short_body_rejected", envelope([b"ord", b"\x07", b"xcp"])),
    ("ord_no_metadata_rejected", ord_envelope([], content=[b"x"])),
    ("ord_trailing_bytes_rejected", ord_envelope([arr(uint(22), uint(1)) + b"\x00"])),
    ("ord_invalid_utf8_text_rejected", ord_envelope([arr(uint(22), text(b"\xc3\x28"))])),
    ("ord_utf8_surrogate_rejected", ord_envelope([arr(uint(22), text(b"\xed\xa0\x80"))])),
    ("ord_float_type_id_rejected", ord_envelope([arr(f64(22.0), uint(1))])),
    ("ord_empty_array_rejected", ord_envelope([arr()])),
    ("ord_map_without_xcp_rejected", ord_envelope([cmap((text("name"), text("x")))])),
    ("ord_reserved_simple_value_rejected", ord_envelope([arr(uint(22), b"\xf8\x20")])),
    ("ord_unassigned_info_rejected", ord_envelope([arr(uint(22), b"\x1c")])),
]

GENERIC = envelope([PREFIX + b"\x04payload"])

OUTPUTS = [
    ("marker_in_clear", [marker_op_return(), P2WPKH_A]),
    ("marker_arc4", [arc4_op_return(PREFIX + PREFIX), P2WPKH_A]),
    ("marker_with_destination", [P2WPKH_B, marker_op_return(), P2WPKH_A]),
    ("marker_in_p2pkh_output", [p2pkh_carrying(PREFIX), P2WPKH_A]),
    ("marker_in_multisig_output", [multisig_carrying(PREFIX), P2WPKH_A]),
    ("p2pkh_data_before_marker", [p2pkh_carrying(b"\x04"), marker_op_return(), P2WPKH_A]),
    ("arc4_data_after_marker", [marker_op_return(), arc4_op_return(PREFIX + b"tail")]),
    ("two_markers", [marker_op_return(), arc4_op_return(PREFIX + PREFIX)]),
    ("plain_p2pkh_destination", [b"\x76\xa9\x14" + b"\x22" * 20 + b"\x88\xac", marker_op_return(), P2WPKH_A]),
    ("prefixed_plaintext_is_not_a_marker", [b"\x6a" + push(PREFIX + b"xyz"), P2WPKH_A]),
    ("no_marker", [P2WPKH_A]),
]


def parsed_vouts(deserializer, tx_hex):
    tx = deserializer.parse_transaction(tx_hex, 1000, True)
    pv = tx["parsed_vouts"]
    if not isinstance(pv, (list, tuple)):
        return None
    destinations, _btc, _fee, data, _dispensers, is_reveal = pv
    return {"destinations": list(destinations), "data": bytes(data).hex(), "is_reveal": bool(is_reveal)}


def main():
    out_path, scratch = sys.argv[1], sys.argv[2]
    d = indexer.Deserializer({
        "rpc_address": "http://127.0.0.1:1", "rpc_user": "x", "rpc_password": "x",
        "rpc_api_key": "", "db_dir": scratch + "/db", "log_file": scratch + "/log.txt",
        "json_format": False, "only_write_in_reorg_window": True,
        "network": "regtest", "prefix": PREFIX, "enable_all_protocol_changes": True,
    })

    envelopes = []
    for name, script in ENVELOPES:
        pv = parsed_vouts(d, reveal_tx(script, [marker_op_return(), P2WPKH_A]))
        message = pv["data"] if pv is not None and pv["is_reveal"] else None
        envelopes.append({"name": name, "envelope_script": script.hex(), "message": message})

    outputs = []
    for name, scripts in OUTPUTS:
        pv = parsed_vouts(d, reveal_tx(GENERIC, scripts))
        outputs.append({
            "name": name,
            "output_scripts": [s.hex() for s in scripts],
            "is_reveal": pv is not None and pv["is_reveal"],
            "destination_count": len(pv["destinations"]) if pv else 0,
            "data": pv["data"] if pv else None,
        })

    with open(out_path, "w") as f:
        json.dump({
            "source": "counterparty_rs indexer.Deserializer.parse_transaction (counterparty-core v11.5.0), regtest, height 1000, all protocol changes",
            "first_input_txid": COMMIT_TXID.hex(),
            "envelope_key": KEY.hex(),
            "generic_envelope": GENERIC.hex(),
            "envelopes": envelopes,
            "outputs": outputs,
        }, f, indent=1)
        f.write("\n")


if __name__ == "__main__":
    main()
