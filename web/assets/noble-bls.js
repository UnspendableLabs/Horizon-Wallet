var __horizon_bls__ = (() => {
  var __defProp = Object.defineProperty;
  var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
  var __getOwnPropNames = Object.getOwnPropertyNames;
  var __hasOwnProp = Object.prototype.hasOwnProperty;
  var __esm = (fn, res) => function __init() {
    return fn && (res = (0, fn[__getOwnPropNames(fn)[0]])(fn = 0)), res;
  };
  var __commonJS = (cb, mod2) => function __require() {
    return mod2 || (0, cb[__getOwnPropNames(cb)[0]])((mod2 = { exports: {} }).exports, mod2), mod2.exports;
  };
  var __export = (target, all) => {
    for (var name in all)
      __defProp(target, name, { get: all[name], enumerable: true });
  };
  var __copyProps = (to, from, except, desc) => {
    if (from && typeof from === "object" || typeof from === "function") {
      for (let key of __getOwnPropNames(from))
        if (!__hasOwnProp.call(to, key) && key !== except)
          __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
    }
    return to;
  };
  var __toCommonJS = (mod2) => __copyProps(__defProp({}, "__esModule", { value: true }), mod2);

  // node_modules/@noble/hashes/utils.js
  var utils_exports = {};
  __export(utils_exports, {
    abytes: () => abytes,
    aexists: () => aexists,
    ahash: () => ahash,
    anumber: () => anumber,
    aoutput: () => aoutput,
    asyncLoop: () => asyncLoop,
    byteSwap: () => byteSwap,
    byteSwap32: () => byteSwap32,
    bytesToHex: () => bytesToHex,
    checkOpts: () => checkOpts,
    clean: () => clean,
    concatBytes: () => concatBytes,
    createHasher: () => createHasher,
    createView: () => createView,
    hexToBytes: () => hexToBytes,
    isBytes: () => isBytes,
    isLE: () => isLE,
    kdfInputToBytes: () => kdfInputToBytes,
    nextTick: () => nextTick,
    oidNist: () => oidNist,
    randomBytes: () => randomBytes,
    rotl: () => rotl,
    rotr: () => rotr,
    swap32IfBE: () => swap32IfBE,
    swap8IfBE: () => swap8IfBE,
    u32: () => u32,
    u8: () => u8,
    utf8ToBytes: () => utf8ToBytes
  });
  function isBytes(a) {
    return a instanceof Uint8Array || ArrayBuffer.isView(a) && a.constructor.name === "Uint8Array";
  }
  function anumber(n, title = "") {
    if (!Number.isSafeInteger(n) || n < 0) {
      const prefix = title && `"${title}" `;
      throw new Error(`${prefix}expected integer >= 0, got ${n}`);
    }
  }
  function abytes(value, length, title = "") {
    const bytes = isBytes(value);
    const len = value?.length;
    const needsLen = length !== void 0;
    if (!bytes || needsLen && len !== length) {
      const prefix = title && `"${title}" `;
      const ofLen = needsLen ? ` of length ${length}` : "";
      const got = bytes ? `length=${len}` : `type=${typeof value}`;
      throw new Error(prefix + "expected Uint8Array" + ofLen + ", got " + got);
    }
    return value;
  }
  function ahash(h) {
    if (typeof h !== "function" || typeof h.create !== "function")
      throw new Error("Hash must wrapped by utils.createHasher");
    anumber(h.outputLen);
    anumber(h.blockLen);
  }
  function aexists(instance, checkFinished = true) {
    if (instance.destroyed)
      throw new Error("Hash instance has been destroyed");
    if (checkFinished && instance.finished)
      throw new Error("Hash#digest() has already been called");
  }
  function aoutput(out, instance) {
    abytes(out, void 0, "digestInto() output");
    const min = instance.outputLen;
    if (out.length < min) {
      throw new Error('"digestInto() output" expected to be of length >=' + min);
    }
  }
  function u8(arr) {
    return new Uint8Array(arr.buffer, arr.byteOffset, arr.byteLength);
  }
  function u32(arr) {
    return new Uint32Array(arr.buffer, arr.byteOffset, Math.floor(arr.byteLength / 4));
  }
  function clean(...arrays) {
    for (let i = 0; i < arrays.length; i++) {
      arrays[i].fill(0);
    }
  }
  function createView(arr) {
    return new DataView(arr.buffer, arr.byteOffset, arr.byteLength);
  }
  function rotr(word, shift) {
    return word << 32 - shift | word >>> shift;
  }
  function rotl(word, shift) {
    return word << shift | word >>> 32 - shift >>> 0;
  }
  function byteSwap(word) {
    return word << 24 & 4278190080 | word << 8 & 16711680 | word >>> 8 & 65280 | word >>> 24 & 255;
  }
  function byteSwap32(arr) {
    for (let i = 0; i < arr.length; i++) {
      arr[i] = byteSwap(arr[i]);
    }
    return arr;
  }
  function bytesToHex(bytes) {
    abytes(bytes);
    if (hasHexBuiltin)
      return bytes.toHex();
    let hex = "";
    for (let i = 0; i < bytes.length; i++) {
      hex += hexes[bytes[i]];
    }
    return hex;
  }
  function asciiToBase16(ch) {
    if (ch >= asciis._0 && ch <= asciis._9)
      return ch - asciis._0;
    if (ch >= asciis.A && ch <= asciis.F)
      return ch - (asciis.A - 10);
    if (ch >= asciis.a && ch <= asciis.f)
      return ch - (asciis.a - 10);
    return;
  }
  function hexToBytes(hex) {
    if (typeof hex !== "string")
      throw new Error("hex string expected, got " + typeof hex);
    if (hasHexBuiltin)
      return Uint8Array.fromHex(hex);
    const hl = hex.length;
    const al = hl / 2;
    if (hl % 2)
      throw new Error("hex string expected, got unpadded hex of length " + hl);
    const array = new Uint8Array(al);
    for (let ai = 0, hi = 0; ai < al; ai++, hi += 2) {
      const n1 = asciiToBase16(hex.charCodeAt(hi));
      const n2 = asciiToBase16(hex.charCodeAt(hi + 1));
      if (n1 === void 0 || n2 === void 0) {
        const char = hex[hi] + hex[hi + 1];
        throw new Error('hex string expected, got non-hex character "' + char + '" at index ' + hi);
      }
      array[ai] = n1 * 16 + n2;
    }
    return array;
  }
  async function asyncLoop(iters, tick, cb) {
    let ts = Date.now();
    for (let i = 0; i < iters; i++) {
      cb(i);
      const diff = Date.now() - ts;
      if (diff >= 0 && diff < tick)
        continue;
      await nextTick();
      ts += diff;
    }
  }
  function utf8ToBytes(str) {
    if (typeof str !== "string")
      throw new Error("string expected");
    return new Uint8Array(new TextEncoder().encode(str));
  }
  function kdfInputToBytes(data, errorTitle = "") {
    if (typeof data === "string")
      return utf8ToBytes(data);
    return abytes(data, void 0, errorTitle);
  }
  function concatBytes(...arrays) {
    let sum = 0;
    for (let i = 0; i < arrays.length; i++) {
      const a = arrays[i];
      abytes(a);
      sum += a.length;
    }
    const res = new Uint8Array(sum);
    for (let i = 0, pad = 0; i < arrays.length; i++) {
      const a = arrays[i];
      res.set(a, pad);
      pad += a.length;
    }
    return res;
  }
  function checkOpts(defaults, opts) {
    if (opts !== void 0 && {}.toString.call(opts) !== "[object Object]")
      throw new Error("options must be object or undefined");
    const merged = Object.assign(defaults, opts);
    return merged;
  }
  function createHasher(hashCons, info = {}) {
    const hashC = (msg, opts) => hashCons(opts).update(msg).digest();
    const tmp = hashCons(void 0);
    hashC.outputLen = tmp.outputLen;
    hashC.blockLen = tmp.blockLen;
    hashC.create = (opts) => hashCons(opts);
    Object.assign(hashC, info);
    return Object.freeze(hashC);
  }
  function randomBytes(bytesLength = 32) {
    const cr = typeof globalThis === "object" ? globalThis.crypto : null;
    if (typeof cr?.getRandomValues !== "function")
      throw new Error("crypto.getRandomValues must be defined");
    return cr.getRandomValues(new Uint8Array(bytesLength));
  }
  var isLE, swap8IfBE, swap32IfBE, hasHexBuiltin, hexes, asciis, nextTick, oidNist;
  var init_utils = __esm({
    "node_modules/@noble/hashes/utils.js"() {
      isLE = /* @__PURE__ */ (() => new Uint8Array(new Uint32Array([287454020]).buffer)[0] === 68)();
      swap8IfBE = isLE ? (n) => n : (n) => byteSwap(n);
      swap32IfBE = isLE ? (u) => u : byteSwap32;
      hasHexBuiltin = /* @__PURE__ */ (() => (
        // @ts-ignore
        typeof Uint8Array.from([]).toHex === "function" && typeof Uint8Array.fromHex === "function"
      ))();
      hexes = /* @__PURE__ */ Array.from({ length: 256 }, (_, i) => i.toString(16).padStart(2, "0"));
      asciis = { _0: 48, _9: 57, A: 65, F: 70, a: 97, f: 102 };
      nextTick = async () => {
      };
      oidNist = (suffix) => ({
        oid: Uint8Array.from([6, 9, 96, 134, 72, 1, 101, 3, 4, 2, suffix])
      });
    }
  });

  // node_modules/@noble/hashes/_md.js
  function Chi(a, b, c) {
    return a & b ^ ~a & c;
  }
  function Maj(a, b, c) {
    return a & b ^ a & c ^ b & c;
  }
  var HashMD, SHA256_IV, SHA224_IV, SHA384_IV, SHA512_IV;
  var init_md = __esm({
    "node_modules/@noble/hashes/_md.js"() {
      init_utils();
      HashMD = class {
        blockLen;
        outputLen;
        padOffset;
        isLE;
        // For partial updates less than block size
        buffer;
        view;
        finished = false;
        length = 0;
        pos = 0;
        destroyed = false;
        constructor(blockLen, outputLen, padOffset, isLE2) {
          this.blockLen = blockLen;
          this.outputLen = outputLen;
          this.padOffset = padOffset;
          this.isLE = isLE2;
          this.buffer = new Uint8Array(blockLen);
          this.view = createView(this.buffer);
        }
        update(data) {
          aexists(this);
          abytes(data);
          const { view, buffer, blockLen } = this;
          const len = data.length;
          for (let pos = 0; pos < len; ) {
            const take = Math.min(blockLen - this.pos, len - pos);
            if (take === blockLen) {
              const dataView = createView(data);
              for (; blockLen <= len - pos; pos += blockLen)
                this.process(dataView, pos);
              continue;
            }
            buffer.set(data.subarray(pos, pos + take), this.pos);
            this.pos += take;
            pos += take;
            if (this.pos === blockLen) {
              this.process(view, 0);
              this.pos = 0;
            }
          }
          this.length += data.length;
          this.roundClean();
          return this;
        }
        digestInto(out) {
          aexists(this);
          aoutput(out, this);
          this.finished = true;
          const { buffer, view, blockLen, isLE: isLE2 } = this;
          let { pos } = this;
          buffer[pos++] = 128;
          clean(this.buffer.subarray(pos));
          if (this.padOffset > blockLen - pos) {
            this.process(view, 0);
            pos = 0;
          }
          for (let i = pos; i < blockLen; i++)
            buffer[i] = 0;
          view.setBigUint64(blockLen - 8, BigInt(this.length * 8), isLE2);
          this.process(view, 0);
          const oview = createView(out);
          const len = this.outputLen;
          if (len % 4)
            throw new Error("_sha2: outputLen must be aligned to 32bit");
          const outLen = len / 4;
          const state = this.get();
          if (outLen > state.length)
            throw new Error("_sha2: outputLen bigger than state");
          for (let i = 0; i < outLen; i++)
            oview.setUint32(4 * i, state[i], isLE2);
        }
        digest() {
          const { buffer, outputLen } = this;
          this.digestInto(buffer);
          const res = buffer.slice(0, outputLen);
          this.destroy();
          return res;
        }
        _cloneInto(to) {
          to ||= new this.constructor();
          to.set(...this.get());
          const { blockLen, buffer, length, finished, destroyed, pos } = this;
          to.destroyed = destroyed;
          to.finished = finished;
          to.length = length;
          to.pos = pos;
          if (length % blockLen)
            to.buffer.set(buffer);
          return to;
        }
        clone() {
          return this._cloneInto();
        }
      };
      SHA256_IV = /* @__PURE__ */ Uint32Array.from([
        1779033703,
        3144134277,
        1013904242,
        2773480762,
        1359893119,
        2600822924,
        528734635,
        1541459225
      ]);
      SHA224_IV = /* @__PURE__ */ Uint32Array.from([
        3238371032,
        914150663,
        812702999,
        4144912697,
        4290775857,
        1750603025,
        1694076839,
        3204075428
      ]);
      SHA384_IV = /* @__PURE__ */ Uint32Array.from([
        3418070365,
        3238371032,
        1654270250,
        914150663,
        2438529370,
        812702999,
        355462360,
        4144912697,
        1731405415,
        4290775857,
        2394180231,
        1750603025,
        3675008525,
        1694076839,
        1203062813,
        3204075428
      ]);
      SHA512_IV = /* @__PURE__ */ Uint32Array.from([
        1779033703,
        4089235720,
        3144134277,
        2227873595,
        1013904242,
        4271175723,
        2773480762,
        1595750129,
        1359893119,
        2917565137,
        2600822924,
        725511199,
        528734635,
        4215389547,
        1541459225,
        327033209
      ]);
    }
  });

  // node_modules/@noble/hashes/_u64.js
  function fromBig(n, le = false) {
    if (le)
      return { h: Number(n & U32_MASK64), l: Number(n >> _32n & U32_MASK64) };
    return { h: Number(n >> _32n & U32_MASK64) | 0, l: Number(n & U32_MASK64) | 0 };
  }
  function split(lst, le = false) {
    const len = lst.length;
    let Ah = new Uint32Array(len);
    let Al = new Uint32Array(len);
    for (let i = 0; i < len; i++) {
      const { h, l } = fromBig(lst[i], le);
      [Ah[i], Al[i]] = [h, l];
    }
    return [Ah, Al];
  }
  function add(Ah, Al, Bh, Bl) {
    const l = (Al >>> 0) + (Bl >>> 0);
    return { h: Ah + Bh + (l / 2 ** 32 | 0) | 0, l: l | 0 };
  }
  var U32_MASK64, _32n, shrSH, shrSL, rotrSH, rotrSL, rotrBH, rotrBL, add3L, add3H, add4L, add4H, add5L, add5H;
  var init_u64 = __esm({
    "node_modules/@noble/hashes/_u64.js"() {
      U32_MASK64 = /* @__PURE__ */ BigInt(2 ** 32 - 1);
      _32n = /* @__PURE__ */ BigInt(32);
      shrSH = (h, _l, s) => h >>> s;
      shrSL = (h, l, s) => h << 32 - s | l >>> s;
      rotrSH = (h, l, s) => h >>> s | l << 32 - s;
      rotrSL = (h, l, s) => h << 32 - s | l >>> s;
      rotrBH = (h, l, s) => h << 64 - s | l >>> s - 32;
      rotrBL = (h, l, s) => h >>> s - 32 | l << 64 - s;
      add3L = (Al, Bl, Cl) => (Al >>> 0) + (Bl >>> 0) + (Cl >>> 0);
      add3H = (low, Ah, Bh, Ch) => Ah + Bh + Ch + (low / 2 ** 32 | 0) | 0;
      add4L = (Al, Bl, Cl, Dl) => (Al >>> 0) + (Bl >>> 0) + (Cl >>> 0) + (Dl >>> 0);
      add4H = (low, Ah, Bh, Ch, Dh) => Ah + Bh + Ch + Dh + (low / 2 ** 32 | 0) | 0;
      add5L = (Al, Bl, Cl, Dl, El) => (Al >>> 0) + (Bl >>> 0) + (Cl >>> 0) + (Dl >>> 0) + (El >>> 0);
      add5H = (low, Ah, Bh, Ch, Dh, Eh) => Ah + Bh + Ch + Dh + Eh + (low / 2 ** 32 | 0) | 0;
    }
  });

  // node_modules/@noble/hashes/sha2.js
  var sha2_exports = {};
  __export(sha2_exports, {
    _SHA224: () => _SHA224,
    _SHA256: () => _SHA256,
    _SHA384: () => _SHA384,
    _SHA512: () => _SHA512,
    _SHA512_224: () => _SHA512_224,
    _SHA512_256: () => _SHA512_256,
    sha224: () => sha224,
    sha256: () => sha256,
    sha384: () => sha384,
    sha512: () => sha512,
    sha512_224: () => sha512_224,
    sha512_256: () => sha512_256
  });
  var SHA256_K, SHA256_W, SHA2_32B, _SHA256, _SHA224, K512, SHA512_Kh, SHA512_Kl, SHA512_W_H, SHA512_W_L, SHA2_64B, _SHA512, _SHA384, T224_IV, T256_IV, _SHA512_224, _SHA512_256, sha256, sha224, sha512, sha384, sha512_256, sha512_224;
  var init_sha2 = __esm({
    "node_modules/@noble/hashes/sha2.js"() {
      init_md();
      init_u64();
      init_utils();
      SHA256_K = /* @__PURE__ */ Uint32Array.from([
        1116352408,
        1899447441,
        3049323471,
        3921009573,
        961987163,
        1508970993,
        2453635748,
        2870763221,
        3624381080,
        310598401,
        607225278,
        1426881987,
        1925078388,
        2162078206,
        2614888103,
        3248222580,
        3835390401,
        4022224774,
        264347078,
        604807628,
        770255983,
        1249150122,
        1555081692,
        1996064986,
        2554220882,
        2821834349,
        2952996808,
        3210313671,
        3336571891,
        3584528711,
        113926993,
        338241895,
        666307205,
        773529912,
        1294757372,
        1396182291,
        1695183700,
        1986661051,
        2177026350,
        2456956037,
        2730485921,
        2820302411,
        3259730800,
        3345764771,
        3516065817,
        3600352804,
        4094571909,
        275423344,
        430227734,
        506948616,
        659060556,
        883997877,
        958139571,
        1322822218,
        1537002063,
        1747873779,
        1955562222,
        2024104815,
        2227730452,
        2361852424,
        2428436474,
        2756734187,
        3204031479,
        3329325298
      ]);
      SHA256_W = /* @__PURE__ */ new Uint32Array(64);
      SHA2_32B = class extends HashMD {
        constructor(outputLen) {
          super(64, outputLen, 8, false);
        }
        get() {
          const { A, B, C, D, E, F, G, H } = this;
          return [A, B, C, D, E, F, G, H];
        }
        // prettier-ignore
        set(A, B, C, D, E, F, G, H) {
          this.A = A | 0;
          this.B = B | 0;
          this.C = C | 0;
          this.D = D | 0;
          this.E = E | 0;
          this.F = F | 0;
          this.G = G | 0;
          this.H = H | 0;
        }
        process(view, offset) {
          for (let i = 0; i < 16; i++, offset += 4)
            SHA256_W[i] = view.getUint32(offset, false);
          for (let i = 16; i < 64; i++) {
            const W15 = SHA256_W[i - 15];
            const W2 = SHA256_W[i - 2];
            const s0 = rotr(W15, 7) ^ rotr(W15, 18) ^ W15 >>> 3;
            const s1 = rotr(W2, 17) ^ rotr(W2, 19) ^ W2 >>> 10;
            SHA256_W[i] = s1 + SHA256_W[i - 7] + s0 + SHA256_W[i - 16] | 0;
          }
          let { A, B, C, D, E, F, G, H } = this;
          for (let i = 0; i < 64; i++) {
            const sigma1 = rotr(E, 6) ^ rotr(E, 11) ^ rotr(E, 25);
            const T1 = H + sigma1 + Chi(E, F, G) + SHA256_K[i] + SHA256_W[i] | 0;
            const sigma0 = rotr(A, 2) ^ rotr(A, 13) ^ rotr(A, 22);
            const T2 = sigma0 + Maj(A, B, C) | 0;
            H = G;
            G = F;
            F = E;
            E = D + T1 | 0;
            D = C;
            C = B;
            B = A;
            A = T1 + T2 | 0;
          }
          A = A + this.A | 0;
          B = B + this.B | 0;
          C = C + this.C | 0;
          D = D + this.D | 0;
          E = E + this.E | 0;
          F = F + this.F | 0;
          G = G + this.G | 0;
          H = H + this.H | 0;
          this.set(A, B, C, D, E, F, G, H);
        }
        roundClean() {
          clean(SHA256_W);
        }
        destroy() {
          this.set(0, 0, 0, 0, 0, 0, 0, 0);
          clean(this.buffer);
        }
      };
      _SHA256 = class extends SHA2_32B {
        // We cannot use array here since array allows indexing by variable
        // which means optimizer/compiler cannot use registers.
        A = SHA256_IV[0] | 0;
        B = SHA256_IV[1] | 0;
        C = SHA256_IV[2] | 0;
        D = SHA256_IV[3] | 0;
        E = SHA256_IV[4] | 0;
        F = SHA256_IV[5] | 0;
        G = SHA256_IV[6] | 0;
        H = SHA256_IV[7] | 0;
        constructor() {
          super(32);
        }
      };
      _SHA224 = class extends SHA2_32B {
        A = SHA224_IV[0] | 0;
        B = SHA224_IV[1] | 0;
        C = SHA224_IV[2] | 0;
        D = SHA224_IV[3] | 0;
        E = SHA224_IV[4] | 0;
        F = SHA224_IV[5] | 0;
        G = SHA224_IV[6] | 0;
        H = SHA224_IV[7] | 0;
        constructor() {
          super(28);
        }
      };
      K512 = /* @__PURE__ */ (() => split([
        "0x428a2f98d728ae22",
        "0x7137449123ef65cd",
        "0xb5c0fbcfec4d3b2f",
        "0xe9b5dba58189dbbc",
        "0x3956c25bf348b538",
        "0x59f111f1b605d019",
        "0x923f82a4af194f9b",
        "0xab1c5ed5da6d8118",
        "0xd807aa98a3030242",
        "0x12835b0145706fbe",
        "0x243185be4ee4b28c",
        "0x550c7dc3d5ffb4e2",
        "0x72be5d74f27b896f",
        "0x80deb1fe3b1696b1",
        "0x9bdc06a725c71235",
        "0xc19bf174cf692694",
        "0xe49b69c19ef14ad2",
        "0xefbe4786384f25e3",
        "0x0fc19dc68b8cd5b5",
        "0x240ca1cc77ac9c65",
        "0x2de92c6f592b0275",
        "0x4a7484aa6ea6e483",
        "0x5cb0a9dcbd41fbd4",
        "0x76f988da831153b5",
        "0x983e5152ee66dfab",
        "0xa831c66d2db43210",
        "0xb00327c898fb213f",
        "0xbf597fc7beef0ee4",
        "0xc6e00bf33da88fc2",
        "0xd5a79147930aa725",
        "0x06ca6351e003826f",
        "0x142929670a0e6e70",
        "0x27b70a8546d22ffc",
        "0x2e1b21385c26c926",
        "0x4d2c6dfc5ac42aed",
        "0x53380d139d95b3df",
        "0x650a73548baf63de",
        "0x766a0abb3c77b2a8",
        "0x81c2c92e47edaee6",
        "0x92722c851482353b",
        "0xa2bfe8a14cf10364",
        "0xa81a664bbc423001",
        "0xc24b8b70d0f89791",
        "0xc76c51a30654be30",
        "0xd192e819d6ef5218",
        "0xd69906245565a910",
        "0xf40e35855771202a",
        "0x106aa07032bbd1b8",
        "0x19a4c116b8d2d0c8",
        "0x1e376c085141ab53",
        "0x2748774cdf8eeb99",
        "0x34b0bcb5e19b48a8",
        "0x391c0cb3c5c95a63",
        "0x4ed8aa4ae3418acb",
        "0x5b9cca4f7763e373",
        "0x682e6ff3d6b2b8a3",
        "0x748f82ee5defb2fc",
        "0x78a5636f43172f60",
        "0x84c87814a1f0ab72",
        "0x8cc702081a6439ec",
        "0x90befffa23631e28",
        "0xa4506cebde82bde9",
        "0xbef9a3f7b2c67915",
        "0xc67178f2e372532b",
        "0xca273eceea26619c",
        "0xd186b8c721c0c207",
        "0xeada7dd6cde0eb1e",
        "0xf57d4f7fee6ed178",
        "0x06f067aa72176fba",
        "0x0a637dc5a2c898a6",
        "0x113f9804bef90dae",
        "0x1b710b35131c471b",
        "0x28db77f523047d84",
        "0x32caab7b40c72493",
        "0x3c9ebe0a15c9bebc",
        "0x431d67c49c100d4c",
        "0x4cc5d4becb3e42b6",
        "0x597f299cfc657e2a",
        "0x5fcb6fab3ad6faec",
        "0x6c44198c4a475817"
      ].map((n) => BigInt(n))))();
      SHA512_Kh = /* @__PURE__ */ (() => K512[0])();
      SHA512_Kl = /* @__PURE__ */ (() => K512[1])();
      SHA512_W_H = /* @__PURE__ */ new Uint32Array(80);
      SHA512_W_L = /* @__PURE__ */ new Uint32Array(80);
      SHA2_64B = class extends HashMD {
        constructor(outputLen) {
          super(128, outputLen, 16, false);
        }
        // prettier-ignore
        get() {
          const { Ah, Al, Bh, Bl, Ch, Cl, Dh, Dl, Eh, El, Fh, Fl, Gh, Gl, Hh, Hl } = this;
          return [Ah, Al, Bh, Bl, Ch, Cl, Dh, Dl, Eh, El, Fh, Fl, Gh, Gl, Hh, Hl];
        }
        // prettier-ignore
        set(Ah, Al, Bh, Bl, Ch, Cl, Dh, Dl, Eh, El, Fh, Fl, Gh, Gl, Hh, Hl) {
          this.Ah = Ah | 0;
          this.Al = Al | 0;
          this.Bh = Bh | 0;
          this.Bl = Bl | 0;
          this.Ch = Ch | 0;
          this.Cl = Cl | 0;
          this.Dh = Dh | 0;
          this.Dl = Dl | 0;
          this.Eh = Eh | 0;
          this.El = El | 0;
          this.Fh = Fh | 0;
          this.Fl = Fl | 0;
          this.Gh = Gh | 0;
          this.Gl = Gl | 0;
          this.Hh = Hh | 0;
          this.Hl = Hl | 0;
        }
        process(view, offset) {
          for (let i = 0; i < 16; i++, offset += 4) {
            SHA512_W_H[i] = view.getUint32(offset);
            SHA512_W_L[i] = view.getUint32(offset += 4);
          }
          for (let i = 16; i < 80; i++) {
            const W15h = SHA512_W_H[i - 15] | 0;
            const W15l = SHA512_W_L[i - 15] | 0;
            const s0h = rotrSH(W15h, W15l, 1) ^ rotrSH(W15h, W15l, 8) ^ shrSH(W15h, W15l, 7);
            const s0l = rotrSL(W15h, W15l, 1) ^ rotrSL(W15h, W15l, 8) ^ shrSL(W15h, W15l, 7);
            const W2h = SHA512_W_H[i - 2] | 0;
            const W2l = SHA512_W_L[i - 2] | 0;
            const s1h = rotrSH(W2h, W2l, 19) ^ rotrBH(W2h, W2l, 61) ^ shrSH(W2h, W2l, 6);
            const s1l = rotrSL(W2h, W2l, 19) ^ rotrBL(W2h, W2l, 61) ^ shrSL(W2h, W2l, 6);
            const SUMl = add4L(s0l, s1l, SHA512_W_L[i - 7], SHA512_W_L[i - 16]);
            const SUMh = add4H(SUMl, s0h, s1h, SHA512_W_H[i - 7], SHA512_W_H[i - 16]);
            SHA512_W_H[i] = SUMh | 0;
            SHA512_W_L[i] = SUMl | 0;
          }
          let { Ah, Al, Bh, Bl, Ch, Cl, Dh, Dl, Eh, El, Fh, Fl, Gh, Gl, Hh, Hl } = this;
          for (let i = 0; i < 80; i++) {
            const sigma1h = rotrSH(Eh, El, 14) ^ rotrSH(Eh, El, 18) ^ rotrBH(Eh, El, 41);
            const sigma1l = rotrSL(Eh, El, 14) ^ rotrSL(Eh, El, 18) ^ rotrBL(Eh, El, 41);
            const CHIh = Eh & Fh ^ ~Eh & Gh;
            const CHIl = El & Fl ^ ~El & Gl;
            const T1ll = add5L(Hl, sigma1l, CHIl, SHA512_Kl[i], SHA512_W_L[i]);
            const T1h = add5H(T1ll, Hh, sigma1h, CHIh, SHA512_Kh[i], SHA512_W_H[i]);
            const T1l = T1ll | 0;
            const sigma0h = rotrSH(Ah, Al, 28) ^ rotrBH(Ah, Al, 34) ^ rotrBH(Ah, Al, 39);
            const sigma0l = rotrSL(Ah, Al, 28) ^ rotrBL(Ah, Al, 34) ^ rotrBL(Ah, Al, 39);
            const MAJh = Ah & Bh ^ Ah & Ch ^ Bh & Ch;
            const MAJl = Al & Bl ^ Al & Cl ^ Bl & Cl;
            Hh = Gh | 0;
            Hl = Gl | 0;
            Gh = Fh | 0;
            Gl = Fl | 0;
            Fh = Eh | 0;
            Fl = El | 0;
            ({ h: Eh, l: El } = add(Dh | 0, Dl | 0, T1h | 0, T1l | 0));
            Dh = Ch | 0;
            Dl = Cl | 0;
            Ch = Bh | 0;
            Cl = Bl | 0;
            Bh = Ah | 0;
            Bl = Al | 0;
            const All = add3L(T1l, sigma0l, MAJl);
            Ah = add3H(All, T1h, sigma0h, MAJh);
            Al = All | 0;
          }
          ({ h: Ah, l: Al } = add(this.Ah | 0, this.Al | 0, Ah | 0, Al | 0));
          ({ h: Bh, l: Bl } = add(this.Bh | 0, this.Bl | 0, Bh | 0, Bl | 0));
          ({ h: Ch, l: Cl } = add(this.Ch | 0, this.Cl | 0, Ch | 0, Cl | 0));
          ({ h: Dh, l: Dl } = add(this.Dh | 0, this.Dl | 0, Dh | 0, Dl | 0));
          ({ h: Eh, l: El } = add(this.Eh | 0, this.El | 0, Eh | 0, El | 0));
          ({ h: Fh, l: Fl } = add(this.Fh | 0, this.Fl | 0, Fh | 0, Fl | 0));
          ({ h: Gh, l: Gl } = add(this.Gh | 0, this.Gl | 0, Gh | 0, Gl | 0));
          ({ h: Hh, l: Hl } = add(this.Hh | 0, this.Hl | 0, Hh | 0, Hl | 0));
          this.set(Ah, Al, Bh, Bl, Ch, Cl, Dh, Dl, Eh, El, Fh, Fl, Gh, Gl, Hh, Hl);
        }
        roundClean() {
          clean(SHA512_W_H, SHA512_W_L);
        }
        destroy() {
          clean(this.buffer);
          this.set(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        }
      };
      _SHA512 = class extends SHA2_64B {
        Ah = SHA512_IV[0] | 0;
        Al = SHA512_IV[1] | 0;
        Bh = SHA512_IV[2] | 0;
        Bl = SHA512_IV[3] | 0;
        Ch = SHA512_IV[4] | 0;
        Cl = SHA512_IV[5] | 0;
        Dh = SHA512_IV[6] | 0;
        Dl = SHA512_IV[7] | 0;
        Eh = SHA512_IV[8] | 0;
        El = SHA512_IV[9] | 0;
        Fh = SHA512_IV[10] | 0;
        Fl = SHA512_IV[11] | 0;
        Gh = SHA512_IV[12] | 0;
        Gl = SHA512_IV[13] | 0;
        Hh = SHA512_IV[14] | 0;
        Hl = SHA512_IV[15] | 0;
        constructor() {
          super(64);
        }
      };
      _SHA384 = class extends SHA2_64B {
        Ah = SHA384_IV[0] | 0;
        Al = SHA384_IV[1] | 0;
        Bh = SHA384_IV[2] | 0;
        Bl = SHA384_IV[3] | 0;
        Ch = SHA384_IV[4] | 0;
        Cl = SHA384_IV[5] | 0;
        Dh = SHA384_IV[6] | 0;
        Dl = SHA384_IV[7] | 0;
        Eh = SHA384_IV[8] | 0;
        El = SHA384_IV[9] | 0;
        Fh = SHA384_IV[10] | 0;
        Fl = SHA384_IV[11] | 0;
        Gh = SHA384_IV[12] | 0;
        Gl = SHA384_IV[13] | 0;
        Hh = SHA384_IV[14] | 0;
        Hl = SHA384_IV[15] | 0;
        constructor() {
          super(48);
        }
      };
      T224_IV = /* @__PURE__ */ Uint32Array.from([
        2352822216,
        424955298,
        1944164710,
        2312950998,
        502970286,
        855612546,
        1738396948,
        1479516111,
        258812777,
        2077511080,
        2011393907,
        79989058,
        1067287976,
        1780299464,
        286451373,
        2446758561
      ]);
      T256_IV = /* @__PURE__ */ Uint32Array.from([
        573645204,
        4230739756,
        2673172387,
        3360449730,
        596883563,
        1867755857,
        2520282905,
        1497426621,
        2519219938,
        2827943907,
        3193839141,
        1401305490,
        721525244,
        746961066,
        246885852,
        2177182882
      ]);
      _SHA512_224 = class extends SHA2_64B {
        Ah = T224_IV[0] | 0;
        Al = T224_IV[1] | 0;
        Bh = T224_IV[2] | 0;
        Bl = T224_IV[3] | 0;
        Ch = T224_IV[4] | 0;
        Cl = T224_IV[5] | 0;
        Dh = T224_IV[6] | 0;
        Dl = T224_IV[7] | 0;
        Eh = T224_IV[8] | 0;
        El = T224_IV[9] | 0;
        Fh = T224_IV[10] | 0;
        Fl = T224_IV[11] | 0;
        Gh = T224_IV[12] | 0;
        Gl = T224_IV[13] | 0;
        Hh = T224_IV[14] | 0;
        Hl = T224_IV[15] | 0;
        constructor() {
          super(28);
        }
      };
      _SHA512_256 = class extends SHA2_64B {
        Ah = T256_IV[0] | 0;
        Al = T256_IV[1] | 0;
        Bh = T256_IV[2] | 0;
        Bl = T256_IV[3] | 0;
        Ch = T256_IV[4] | 0;
        Cl = T256_IV[5] | 0;
        Dh = T256_IV[6] | 0;
        Dl = T256_IV[7] | 0;
        Eh = T256_IV[8] | 0;
        El = T256_IV[9] | 0;
        Fh = T256_IV[10] | 0;
        Fl = T256_IV[11] | 0;
        Gh = T256_IV[12] | 0;
        Gl = T256_IV[13] | 0;
        Hh = T256_IV[14] | 0;
        Hl = T256_IV[15] | 0;
        constructor() {
          super(32);
        }
      };
      sha256 = /* @__PURE__ */ createHasher(
        () => new _SHA256(),
        /* @__PURE__ */ oidNist(1)
      );
      sha224 = /* @__PURE__ */ createHasher(
        () => new _SHA224(),
        /* @__PURE__ */ oidNist(4)
      );
      sha512 = /* @__PURE__ */ createHasher(
        () => new _SHA512(),
        /* @__PURE__ */ oidNist(3)
      );
      sha384 = /* @__PURE__ */ createHasher(
        () => new _SHA384(),
        /* @__PURE__ */ oidNist(2)
      );
      sha512_256 = /* @__PURE__ */ createHasher(
        () => new _SHA512_256(),
        /* @__PURE__ */ oidNist(6)
      );
      sha512_224 = /* @__PURE__ */ createHasher(
        () => new _SHA512_224(),
        /* @__PURE__ */ oidNist(5)
      );
    }
  });

  // node_modules/@noble/curves/utils.js
  function abool(value, title = "") {
    if (typeof value !== "boolean") {
      const prefix = title && `"${title}" `;
      throw new Error(prefix + "expected boolean, got type=" + typeof value);
    }
    return value;
  }
  function abignumber(n) {
    if (typeof n === "bigint") {
      if (!isPosBig(n))
        throw new Error("positive bigint expected, got " + n);
    } else
      anumber(n);
    return n;
  }
  function asafenumber(value, title = "") {
    if (!Number.isSafeInteger(value)) {
      const prefix = title && `"${title}" `;
      throw new Error(prefix + "expected safe integer, got type=" + typeof value);
    }
  }
  function hexToNumber(hex) {
    if (typeof hex !== "string")
      throw new Error("hex string expected, got " + typeof hex);
    return hex === "" ? _0n : BigInt("0x" + hex);
  }
  function bytesToNumberBE(bytes) {
    return hexToNumber(bytesToHex(bytes));
  }
  function bytesToNumberLE(bytes) {
    return hexToNumber(bytesToHex(copyBytes(abytes(bytes)).reverse()));
  }
  function numberToBytesBE(n, len) {
    anumber(len);
    n = abignumber(n);
    const res = hexToBytes(n.toString(16).padStart(len * 2, "0"));
    if (res.length !== len)
      throw new Error("number too large");
    return res;
  }
  function numberToBytesLE(n, len) {
    return numberToBytesBE(n, len).reverse();
  }
  function copyBytes(bytes) {
    return Uint8Array.from(bytes);
  }
  function asciiToBytes(ascii) {
    return Uint8Array.from(ascii, (c, i) => {
      const charCode = c.charCodeAt(0);
      if (c.length !== 1 || charCode > 127) {
        throw new Error(`string contains non-ASCII character "${ascii[i]}" with code ${charCode} at position ${i}`);
      }
      return charCode;
    });
  }
  function bitLen(n) {
    let len;
    for (len = 0; n > _0n; n >>= _1n, len += 1)
      ;
    return len;
  }
  function bitGet(n, pos) {
    return n >> BigInt(pos) & _1n;
  }
  function validateObject(object, fields2 = {}, optFields = {}) {
    if (!object || typeof object !== "object")
      throw new Error("expected valid options object");
    function checkField(fieldName, expectedType, isOpt) {
      const val = object[fieldName];
      if (isOpt && val === void 0)
        return;
      const current = typeof val;
      if (current !== expectedType || val === null)
        throw new Error(`param "${fieldName}" is invalid: expected ${expectedType}, got ${current}`);
    }
    const iter = (f, isOpt) => Object.entries(f).forEach(([k, v]) => checkField(k, v, isOpt));
    iter(fields2, false);
    iter(optFields, true);
  }
  function memoized(fn) {
    const map = /* @__PURE__ */ new WeakMap();
    return (arg, ...args) => {
      const val = map.get(arg);
      if (val !== void 0)
        return val;
      const computed = fn(arg, ...args);
      map.set(arg, computed);
      return computed;
    };
  }
  var _0n, _1n, isPosBig, bitMask, notImplemented;
  var init_utils2 = __esm({
    "node_modules/@noble/curves/utils.js"() {
      init_utils();
      init_utils();
      _0n = /* @__PURE__ */ BigInt(0);
      _1n = /* @__PURE__ */ BigInt(1);
      isPosBig = (n) => typeof n === "bigint" && _0n <= n;
      bitMask = (n) => (_1n << BigInt(n)) - _1n;
      notImplemented = () => {
        throw new Error("not implemented");
      };
    }
  });

  // node_modules/@noble/curves/abstract/modular.js
  function mod(a, b) {
    const result = a % b;
    return result >= _0n2 ? result : b + result;
  }
  function invert(number, modulo) {
    if (number === _0n2)
      throw new Error("invert: expected non-zero number");
    if (modulo <= _0n2)
      throw new Error("invert: expected positive modulus, got " + modulo);
    let a = mod(number, modulo);
    let b = modulo;
    let x = _0n2, y = _1n2, u = _1n2, v = _0n2;
    while (a !== _0n2) {
      const q = b / a;
      const r = b % a;
      const m = x - u * q;
      const n = y - v * q;
      b = a, a = r, x = u, y = v, u = m, v = n;
    }
    const gcd = b;
    if (gcd !== _1n2)
      throw new Error("invert: does not exist");
    return mod(x, modulo);
  }
  function assertIsSquare(Fp3, root, n) {
    if (!Fp3.eql(Fp3.sqr(root), n))
      throw new Error("Cannot find square root");
  }
  function sqrt3mod4(Fp3, n) {
    const p1div4 = (Fp3.ORDER + _1n2) / _4n;
    const root = Fp3.pow(n, p1div4);
    assertIsSquare(Fp3, root, n);
    return root;
  }
  function sqrt5mod8(Fp3, n) {
    const p5div8 = (Fp3.ORDER - _5n) / _8n;
    const n2 = Fp3.mul(n, _2n);
    const v = Fp3.pow(n2, p5div8);
    const nv = Fp3.mul(n, v);
    const i = Fp3.mul(Fp3.mul(nv, _2n), v);
    const root = Fp3.mul(nv, Fp3.sub(i, Fp3.ONE));
    assertIsSquare(Fp3, root, n);
    return root;
  }
  function sqrt9mod16(P) {
    const Fp_ = Field(P);
    const tn = tonelliShanks(P);
    const c1 = tn(Fp_, Fp_.neg(Fp_.ONE));
    const c2 = tn(Fp_, c1);
    const c3 = tn(Fp_, Fp_.neg(c1));
    const c4 = (P + _7n) / _16n;
    return (Fp3, n) => {
      let tv1 = Fp3.pow(n, c4);
      let tv2 = Fp3.mul(tv1, c1);
      const tv3 = Fp3.mul(tv1, c2);
      const tv4 = Fp3.mul(tv1, c3);
      const e1 = Fp3.eql(Fp3.sqr(tv2), n);
      const e2 = Fp3.eql(Fp3.sqr(tv3), n);
      tv1 = Fp3.cmov(tv1, tv2, e1);
      tv2 = Fp3.cmov(tv4, tv3, e2);
      const e3 = Fp3.eql(Fp3.sqr(tv2), n);
      const root = Fp3.cmov(tv1, tv2, e3);
      assertIsSquare(Fp3, root, n);
      return root;
    };
  }
  function tonelliShanks(P) {
    if (P < _3n)
      throw new Error("sqrt is not defined for small field");
    let Q = P - _1n2;
    let S = 0;
    while (Q % _2n === _0n2) {
      Q /= _2n;
      S++;
    }
    let Z = _2n;
    const _Fp = Field(P);
    while (FpLegendre(_Fp, Z) === 1) {
      if (Z++ > 1e3)
        throw new Error("Cannot find square root: probably non-prime P");
    }
    if (S === 1)
      return sqrt3mod4;
    let cc = _Fp.pow(Z, Q);
    const Q1div2 = (Q + _1n2) / _2n;
    return function tonelliSlow(Fp3, n) {
      if (Fp3.is0(n))
        return n;
      if (FpLegendre(Fp3, n) !== 1)
        throw new Error("Cannot find square root");
      let M = S;
      let c = Fp3.mul(Fp3.ONE, cc);
      let t = Fp3.pow(n, Q);
      let R = Fp3.pow(n, Q1div2);
      while (!Fp3.eql(t, Fp3.ONE)) {
        if (Fp3.is0(t))
          return Fp3.ZERO;
        let i = 1;
        let t_tmp = Fp3.sqr(t);
        while (!Fp3.eql(t_tmp, Fp3.ONE)) {
          i++;
          t_tmp = Fp3.sqr(t_tmp);
          if (i === M)
            throw new Error("Cannot find square root");
        }
        const exponent = _1n2 << BigInt(M - i - 1);
        const b = Fp3.pow(c, exponent);
        M = i;
        c = Fp3.sqr(b);
        t = Fp3.mul(t, c);
        R = Fp3.mul(R, b);
      }
      return R;
    };
  }
  function FpSqrt(P) {
    if (P % _4n === _3n)
      return sqrt3mod4;
    if (P % _8n === _5n)
      return sqrt5mod8;
    if (P % _16n === _9n)
      return sqrt9mod16(P);
    return tonelliShanks(P);
  }
  function validateField(field) {
    const initial = {
      ORDER: "bigint",
      BYTES: "number",
      BITS: "number"
    };
    const opts = FIELD_FIELDS.reduce((map, val) => {
      map[val] = "function";
      return map;
    }, initial);
    validateObject(field, opts);
    return field;
  }
  function FpPow(Fp3, num, power) {
    if (power < _0n2)
      throw new Error("invalid exponent, negatives unsupported");
    if (power === _0n2)
      return Fp3.ONE;
    if (power === _1n2)
      return num;
    let p = Fp3.ONE;
    let d = num;
    while (power > _0n2) {
      if (power & _1n2)
        p = Fp3.mul(p, d);
      d = Fp3.sqr(d);
      power >>= _1n2;
    }
    return p;
  }
  function FpInvertBatch(Fp3, nums, passZero = false) {
    const inverted = new Array(nums.length).fill(passZero ? Fp3.ZERO : void 0);
    const multipliedAcc = nums.reduce((acc, num, i) => {
      if (Fp3.is0(num))
        return acc;
      inverted[i] = acc;
      return Fp3.mul(acc, num);
    }, Fp3.ONE);
    const invertedAcc = Fp3.inv(multipliedAcc);
    nums.reduceRight((acc, num, i) => {
      if (Fp3.is0(num))
        return acc;
      inverted[i] = Fp3.mul(acc, inverted[i]);
      return Fp3.mul(acc, num);
    }, invertedAcc);
    return inverted;
  }
  function FpLegendre(Fp3, n) {
    const p1mod2 = (Fp3.ORDER - _1n2) / _2n;
    const powered = Fp3.pow(n, p1mod2);
    const yes = Fp3.eql(powered, Fp3.ONE);
    const zero = Fp3.eql(powered, Fp3.ZERO);
    const no = Fp3.eql(powered, Fp3.neg(Fp3.ONE));
    if (!yes && !zero && !no)
      throw new Error("invalid Legendre symbol result");
    return yes ? 1 : zero ? 0 : -1;
  }
  function nLength(n, nBitLength) {
    if (nBitLength !== void 0)
      anumber(nBitLength);
    const _nBitLength = nBitLength !== void 0 ? nBitLength : n.toString(2).length;
    const nByteLength = Math.ceil(_nBitLength / 8);
    return { nBitLength: _nBitLength, nByteLength };
  }
  function Field(ORDER, opts = {}) {
    return new _Field(ORDER, opts);
  }
  function getFieldBytesLength(fieldOrder) {
    if (typeof fieldOrder !== "bigint")
      throw new Error("field order must be bigint");
    const bitLength = fieldOrder.toString(2).length;
    return Math.ceil(bitLength / 8);
  }
  function getMinHashLength(fieldOrder) {
    const length = getFieldBytesLength(fieldOrder);
    return length + Math.ceil(length / 2);
  }
  function mapHashToField(key, fieldOrder, isLE2 = false) {
    abytes(key);
    const len = key.length;
    const fieldLen = getFieldBytesLength(fieldOrder);
    const minLen = getMinHashLength(fieldOrder);
    if (len < 16 || len < minLen || len > 1024)
      throw new Error("expected " + minLen + "-1024 bytes of input, got " + len);
    const num = isLE2 ? bytesToNumberLE(key) : bytesToNumberBE(key);
    const reduced = mod(num, fieldOrder - _1n2) + _1n2;
    return isLE2 ? numberToBytesLE(reduced, fieldLen) : numberToBytesBE(reduced, fieldLen);
  }
  var _0n2, _1n2, _2n, _3n, _4n, _5n, _7n, _8n, _9n, _16n, FIELD_FIELDS, _Field;
  var init_modular = __esm({
    "node_modules/@noble/curves/abstract/modular.js"() {
      init_utils2();
      _0n2 = /* @__PURE__ */ BigInt(0);
      _1n2 = /* @__PURE__ */ BigInt(1);
      _2n = /* @__PURE__ */ BigInt(2);
      _3n = /* @__PURE__ */ BigInt(3);
      _4n = /* @__PURE__ */ BigInt(4);
      _5n = /* @__PURE__ */ BigInt(5);
      _7n = /* @__PURE__ */ BigInt(7);
      _8n = /* @__PURE__ */ BigInt(8);
      _9n = /* @__PURE__ */ BigInt(9);
      _16n = /* @__PURE__ */ BigInt(16);
      FIELD_FIELDS = [
        "create",
        "isValid",
        "is0",
        "neg",
        "inv",
        "sqrt",
        "sqr",
        "eql",
        "add",
        "sub",
        "mul",
        "pow",
        "div",
        "addN",
        "subN",
        "mulN",
        "sqrN"
      ];
      _Field = class {
        ORDER;
        BITS;
        BYTES;
        isLE;
        ZERO = _0n2;
        ONE = _1n2;
        _lengths;
        _sqrt;
        // cached sqrt
        _mod;
        constructor(ORDER, opts = {}) {
          if (ORDER <= _0n2)
            throw new Error("invalid field: expected ORDER > 0, got " + ORDER);
          let _nbitLength = void 0;
          this.isLE = false;
          if (opts != null && typeof opts === "object") {
            if (typeof opts.BITS === "number")
              _nbitLength = opts.BITS;
            if (typeof opts.sqrt === "function")
              this.sqrt = opts.sqrt;
            if (typeof opts.isLE === "boolean")
              this.isLE = opts.isLE;
            if (opts.allowedLengths)
              this._lengths = opts.allowedLengths?.slice();
            if (typeof opts.modFromBytes === "boolean")
              this._mod = opts.modFromBytes;
          }
          const { nBitLength, nByteLength } = nLength(ORDER, _nbitLength);
          if (nByteLength > 2048)
            throw new Error("invalid field: expected ORDER of <= 2048 bytes");
          this.ORDER = ORDER;
          this.BITS = nBitLength;
          this.BYTES = nByteLength;
          this._sqrt = void 0;
          Object.preventExtensions(this);
        }
        create(num) {
          return mod(num, this.ORDER);
        }
        isValid(num) {
          if (typeof num !== "bigint")
            throw new Error("invalid field element: expected bigint, got " + typeof num);
          return _0n2 <= num && num < this.ORDER;
        }
        is0(num) {
          return num === _0n2;
        }
        // is valid and invertible
        isValidNot0(num) {
          return !this.is0(num) && this.isValid(num);
        }
        isOdd(num) {
          return (num & _1n2) === _1n2;
        }
        neg(num) {
          return mod(-num, this.ORDER);
        }
        eql(lhs, rhs) {
          return lhs === rhs;
        }
        sqr(num) {
          return mod(num * num, this.ORDER);
        }
        add(lhs, rhs) {
          return mod(lhs + rhs, this.ORDER);
        }
        sub(lhs, rhs) {
          return mod(lhs - rhs, this.ORDER);
        }
        mul(lhs, rhs) {
          return mod(lhs * rhs, this.ORDER);
        }
        pow(num, power) {
          return FpPow(this, num, power);
        }
        div(lhs, rhs) {
          return mod(lhs * invert(rhs, this.ORDER), this.ORDER);
        }
        // Same as above, but doesn't normalize
        sqrN(num) {
          return num * num;
        }
        addN(lhs, rhs) {
          return lhs + rhs;
        }
        subN(lhs, rhs) {
          return lhs - rhs;
        }
        mulN(lhs, rhs) {
          return lhs * rhs;
        }
        inv(num) {
          return invert(num, this.ORDER);
        }
        sqrt(num) {
          if (!this._sqrt)
            this._sqrt = FpSqrt(this.ORDER);
          return this._sqrt(this, num);
        }
        toBytes(num) {
          return this.isLE ? numberToBytesLE(num, this.BYTES) : numberToBytesBE(num, this.BYTES);
        }
        fromBytes(bytes, skipValidation = false) {
          abytes(bytes);
          const { _lengths: allowedLengths, BYTES, isLE: isLE2, ORDER, _mod: modFromBytes } = this;
          if (allowedLengths) {
            if (!allowedLengths.includes(bytes.length) || bytes.length > BYTES) {
              throw new Error("Field.fromBytes: expected " + allowedLengths + " bytes, got " + bytes.length);
            }
            const padded = new Uint8Array(BYTES);
            padded.set(bytes, isLE2 ? 0 : padded.length - bytes.length);
            bytes = padded;
          }
          if (bytes.length !== BYTES)
            throw new Error("Field.fromBytes: expected " + BYTES + " bytes, got " + bytes.length);
          let scalar = isLE2 ? bytesToNumberLE(bytes) : bytesToNumberBE(bytes);
          if (modFromBytes)
            scalar = mod(scalar, ORDER);
          if (!skipValidation) {
            if (!this.isValid(scalar))
              throw new Error("invalid field element: outside of range 0..ORDER");
          }
          return scalar;
        }
        // TODO: we don't need it here, move out to separate fn
        invertBatch(lst) {
          return FpInvertBatch(this, lst);
        }
        // We can't move this out because Fp6, Fp12 implement it
        // and it's unclear what to return in there.
        cmov(a, b, condition) {
          return condition ? b : a;
        }
      };
    }
  });

  // node_modules/@noble/curves/abstract/curve.js
  function negateCt(condition, item) {
    const neg = item.negate();
    return condition ? neg : item;
  }
  function normalizeZ(c, points) {
    const invertedZs = FpInvertBatch(c.Fp, points.map((p) => p.Z));
    return points.map((p, i) => c.fromAffine(p.toAffine(invertedZs[i])));
  }
  function validateW(W, bits) {
    if (!Number.isSafeInteger(W) || W <= 0 || W > bits)
      throw new Error("invalid window size, expected [1.." + bits + "], got W=" + W);
  }
  function calcWOpts(W, scalarBits) {
    validateW(W, scalarBits);
    const windows = Math.ceil(scalarBits / W) + 1;
    const windowSize = 2 ** (W - 1);
    const maxNumber = 2 ** W;
    const mask = bitMask(W);
    const shiftBy = BigInt(W);
    return { windows, windowSize, mask, maxNumber, shiftBy };
  }
  function calcOffsets(n, window, wOpts) {
    const { windowSize, mask, maxNumber, shiftBy } = wOpts;
    let wbits = Number(n & mask);
    let nextN = n >> shiftBy;
    if (wbits > windowSize) {
      wbits -= maxNumber;
      nextN += _1n3;
    }
    const offsetStart = window * windowSize;
    const offset = offsetStart + Math.abs(wbits) - 1;
    const isZero = wbits === 0;
    const isNeg = wbits < 0;
    const isNegF = window % 2 !== 0;
    const offsetF = offsetStart;
    return { nextN, offset, isZero, isNeg, isNegF, offsetF };
  }
  function getW(P) {
    return pointWindowSizes.get(P) || 1;
  }
  function assert0(n) {
    if (n !== _0n3)
      throw new Error("invalid wNAF");
  }
  function mulEndoUnsafe(Point, point, k1, k2) {
    let acc = point;
    let p1 = Point.ZERO;
    let p2 = Point.ZERO;
    while (k1 > _0n3 || k2 > _0n3) {
      if (k1 & _1n3)
        p1 = p1.add(acc);
      if (k2 & _1n3)
        p2 = p2.add(acc);
      acc = acc.double();
      k1 >>= _1n3;
      k2 >>= _1n3;
    }
    return { p1, p2 };
  }
  function createField(order, field, isLE2) {
    if (field) {
      if (field.ORDER !== order)
        throw new Error("Field.ORDER must match order: Fp == p, Fn == n");
      validateField(field);
      return field;
    } else {
      return Field(order, { isLE: isLE2 });
    }
  }
  function createCurveFields(type, CURVE, curveOpts = {}, FpFnLE) {
    if (FpFnLE === void 0)
      FpFnLE = type === "edwards";
    if (!CURVE || typeof CURVE !== "object")
      throw new Error(`expected valid ${type} CURVE object`);
    for (const p of ["p", "n", "h"]) {
      const val = CURVE[p];
      if (!(typeof val === "bigint" && val > _0n3))
        throw new Error(`CURVE.${p} must be positive bigint`);
    }
    const Fp3 = createField(CURVE.p, curveOpts.Fp, FpFnLE);
    const Fn = createField(CURVE.n, curveOpts.Fn, FpFnLE);
    const _b = type === "weierstrass" ? "b" : "d";
    const params = ["Gx", "Gy", "a", _b];
    for (const p of params) {
      if (!Fp3.isValid(CURVE[p]))
        throw new Error(`CURVE.${p} must be valid field element of CURVE.Fp`);
    }
    CURVE = Object.freeze(Object.assign({}, CURVE));
    return { CURVE, Fp: Fp3, Fn };
  }
  var _0n3, _1n3, pointPrecomputes, pointWindowSizes, wNAF;
  var init_curve = __esm({
    "node_modules/@noble/curves/abstract/curve.js"() {
      init_utils2();
      init_modular();
      _0n3 = /* @__PURE__ */ BigInt(0);
      _1n3 = /* @__PURE__ */ BigInt(1);
      pointPrecomputes = /* @__PURE__ */ new WeakMap();
      pointWindowSizes = /* @__PURE__ */ new WeakMap();
      wNAF = class {
        BASE;
        ZERO;
        Fn;
        bits;
        // Parametrized with a given Point class (not individual point)
        constructor(Point, bits) {
          this.BASE = Point.BASE;
          this.ZERO = Point.ZERO;
          this.Fn = Point.Fn;
          this.bits = bits;
        }
        // non-const time multiplication ladder
        _unsafeLadder(elm, n, p = this.ZERO) {
          let d = elm;
          while (n > _0n3) {
            if (n & _1n3)
              p = p.add(d);
            d = d.double();
            n >>= _1n3;
          }
          return p;
        }
        /**
         * Creates a wNAF precomputation window. Used for caching.
         * Default window size is set by `utils.precompute()` and is equal to 8.
         * Number of precomputed points depends on the curve size:
         * 2^(𝑊−1) * (Math.ceil(𝑛 / 𝑊) + 1), where:
         * - 𝑊 is the window size
         * - 𝑛 is the bitlength of the curve order.
         * For a 256-bit curve and window size 8, the number of precomputed points is 128 * 33 = 4224.
         * @param point Point instance
         * @param W window size
         * @returns precomputed point tables flattened to a single array
         */
        precomputeWindow(point, W) {
          const { windows, windowSize } = calcWOpts(W, this.bits);
          const points = [];
          let p = point;
          let base = p;
          for (let window = 0; window < windows; window++) {
            base = p;
            points.push(base);
            for (let i = 1; i < windowSize; i++) {
              base = base.add(p);
              points.push(base);
            }
            p = base.double();
          }
          return points;
        }
        /**
         * Implements ec multiplication using precomputed tables and w-ary non-adjacent form.
         * More compact implementation:
         * https://github.com/paulmillr/noble-secp256k1/blob/47cb1669b6e506ad66b35fe7d76132ae97465da2/index.ts#L502-L541
         * @returns real and fake (for const-time) points
         */
        wNAF(W, precomputes, n) {
          if (!this.Fn.isValid(n))
            throw new Error("invalid scalar");
          let p = this.ZERO;
          let f = this.BASE;
          const wo = calcWOpts(W, this.bits);
          for (let window = 0; window < wo.windows; window++) {
            const { nextN, offset, isZero, isNeg, isNegF, offsetF } = calcOffsets(n, window, wo);
            n = nextN;
            if (isZero) {
              f = f.add(negateCt(isNegF, precomputes[offsetF]));
            } else {
              p = p.add(negateCt(isNeg, precomputes[offset]));
            }
          }
          assert0(n);
          return { p, f };
        }
        /**
         * Implements ec unsafe (non const-time) multiplication using precomputed tables and w-ary non-adjacent form.
         * @param acc accumulator point to add result of multiplication
         * @returns point
         */
        wNAFUnsafe(W, precomputes, n, acc = this.ZERO) {
          const wo = calcWOpts(W, this.bits);
          for (let window = 0; window < wo.windows; window++) {
            if (n === _0n3)
              break;
            const { nextN, offset, isZero, isNeg } = calcOffsets(n, window, wo);
            n = nextN;
            if (isZero) {
              continue;
            } else {
              const item = precomputes[offset];
              acc = acc.add(isNeg ? item.negate() : item);
            }
          }
          assert0(n);
          return acc;
        }
        getPrecomputes(W, point, transform) {
          let comp = pointPrecomputes.get(point);
          if (!comp) {
            comp = this.precomputeWindow(point, W);
            if (W !== 1) {
              if (typeof transform === "function")
                comp = transform(comp);
              pointPrecomputes.set(point, comp);
            }
          }
          return comp;
        }
        cached(point, scalar, transform) {
          const W = getW(point);
          return this.wNAF(W, this.getPrecomputes(W, point, transform), scalar);
        }
        unsafe(point, scalar, transform, prev) {
          const W = getW(point);
          if (W === 1)
            return this._unsafeLadder(point, scalar, prev);
          return this.wNAFUnsafe(W, this.getPrecomputes(W, point, transform), scalar, prev);
        }
        // We calculate precomputes for elliptic curve point multiplication
        // using windowed method. This specifies window size and
        // stores precomputed values. Usually only base point would be precomputed.
        createCache(P, W) {
          validateW(W, this.bits);
          pointWindowSizes.set(P, W);
          pointPrecomputes.delete(P);
        }
        hasCache(elm) {
          return getW(elm) !== 1;
        }
      };
    }
  });

  // node_modules/@noble/curves/abstract/hash-to-curve.js
  function i2osp(value, length) {
    asafenumber(value);
    asafenumber(length);
    if (value < 0 || value >= 1 << 8 * length)
      throw new Error("invalid I2OSP input: " + value);
    const res = Array.from({ length }).fill(0);
    for (let i = length - 1; i >= 0; i--) {
      res[i] = value & 255;
      value >>>= 8;
    }
    return new Uint8Array(res);
  }
  function strxor(a, b) {
    const arr = new Uint8Array(a.length);
    for (let i = 0; i < a.length; i++) {
      arr[i] = a[i] ^ b[i];
    }
    return arr;
  }
  function normDST(DST) {
    if (!isBytes(DST) && typeof DST !== "string")
      throw new Error("DST must be Uint8Array or ascii string");
    return typeof DST === "string" ? asciiToBytes(DST) : DST;
  }
  function expand_message_xmd(msg, DST, lenInBytes, H) {
    abytes(msg);
    asafenumber(lenInBytes);
    DST = normDST(DST);
    if (DST.length > 255)
      DST = H(concatBytes(asciiToBytes("H2C-OVERSIZE-DST-"), DST));
    const { outputLen: b_in_bytes, blockLen: r_in_bytes } = H;
    const ell = Math.ceil(lenInBytes / b_in_bytes);
    if (lenInBytes > 65535 || ell > 255)
      throw new Error("expand_message_xmd: invalid lenInBytes");
    const DST_prime = concatBytes(DST, i2osp(DST.length, 1));
    const Z_pad = i2osp(0, r_in_bytes);
    const l_i_b_str = i2osp(lenInBytes, 2);
    const b = new Array(ell);
    const b_0 = H(concatBytes(Z_pad, msg, l_i_b_str, i2osp(0, 1), DST_prime));
    b[0] = H(concatBytes(b_0, i2osp(1, 1), DST_prime));
    for (let i = 1; i <= ell; i++) {
      const args = [strxor(b_0, b[i - 1]), i2osp(i + 1, 1), DST_prime];
      b[i] = H(concatBytes(...args));
    }
    const pseudo_random_bytes = concatBytes(...b);
    return pseudo_random_bytes.slice(0, lenInBytes);
  }
  function expand_message_xof(msg, DST, lenInBytes, k, H) {
    abytes(msg);
    asafenumber(lenInBytes);
    DST = normDST(DST);
    if (DST.length > 255) {
      const dkLen = Math.ceil(2 * k / 8);
      DST = H.create({ dkLen }).update(asciiToBytes("H2C-OVERSIZE-DST-")).update(DST).digest();
    }
    if (lenInBytes > 65535 || DST.length > 255)
      throw new Error("expand_message_xof: invalid lenInBytes");
    return H.create({ dkLen: lenInBytes }).update(msg).update(i2osp(lenInBytes, 2)).update(DST).update(i2osp(DST.length, 1)).digest();
  }
  function hash_to_field(msg, count, options) {
    validateObject(options, {
      p: "bigint",
      m: "number",
      k: "number",
      hash: "function"
    });
    const { p, k, m, hash, expand: expand2, DST } = options;
    asafenumber(hash.outputLen, "valid hash");
    abytes(msg);
    asafenumber(count);
    const log2p = p.toString(2).length;
    const L = Math.ceil((log2p + k) / 8);
    const len_in_bytes = count * m * L;
    let prb;
    if (expand2 === "xmd") {
      prb = expand_message_xmd(msg, DST, len_in_bytes, hash);
    } else if (expand2 === "xof") {
      prb = expand_message_xof(msg, DST, len_in_bytes, k, hash);
    } else if (expand2 === "_internal_pass") {
      prb = msg;
    } else {
      throw new Error('expand must be "xmd" or "xof"');
    }
    const u = new Array(count);
    for (let i = 0; i < count; i++) {
      const e = new Array(m);
      for (let j = 0; j < m; j++) {
        const elm_offset = L * (j + i * m);
        const tv = prb.subarray(elm_offset, elm_offset + L);
        e[j] = mod(os2ip(tv), p);
      }
      u[i] = e;
    }
    return u;
  }
  function isogenyMap(field, map) {
    const coeff = map.map((i) => Array.from(i).reverse());
    return (x, y) => {
      const [xn, xd, yn, yd] = coeff.map((val) => val.reduce((acc, i) => field.add(field.mul(acc, x), i)));
      const [xd_inv, yd_inv] = FpInvertBatch(field, [xd, yd], true);
      x = field.mul(xn, xd_inv);
      y = field.mul(y, field.mul(yn, yd_inv));
      return { x, y };
    };
  }
  function createHasher2(Point, mapToCurve, defaults) {
    if (typeof mapToCurve !== "function")
      throw new Error("mapToCurve() must be defined");
    function map(num) {
      return Point.fromAffine(mapToCurve(num));
    }
    function clear(initial) {
      const P = initial.clearCofactor();
      if (P.equals(Point.ZERO))
        return Point.ZERO;
      P.assertValidity();
      return P;
    }
    return {
      defaults: Object.freeze(defaults),
      Point,
      hashToCurve(msg, options) {
        const opts = Object.assign({}, defaults, options);
        const u = hash_to_field(msg, 2, opts);
        const u0 = map(u[0]);
        const u1 = map(u[1]);
        return clear(u0.add(u1));
      },
      encodeToCurve(msg, options) {
        const optsDst = defaults.encodeDST ? { DST: defaults.encodeDST } : {};
        const opts = Object.assign({}, defaults, optsDst, options);
        const u = hash_to_field(msg, 1, opts);
        const u0 = map(u[0]);
        return clear(u0);
      },
      /** See {@link H2CHasher} */
      mapToCurve(scalars) {
        if (defaults.m === 1) {
          if (typeof scalars !== "bigint")
            throw new Error("expected bigint (m=1)");
          return clear(map([scalars]));
        }
        if (!Array.isArray(scalars))
          throw new Error("expected array of bigints");
        for (const i of scalars)
          if (typeof i !== "bigint")
            throw new Error("expected array of bigints");
        return clear(map(scalars));
      },
      // hash_to_scalar can produce 0: https://www.rfc-editor.org/errata/eid8393
      // RFC 9380, draft-irtf-cfrg-bbs-signatures-08
      hashToScalar(msg, options) {
        const N = Point.Fn.ORDER;
        const opts = Object.assign({}, defaults, { p: N, m: 1, DST: _DST_scalar }, options);
        return hash_to_field(msg, 1, opts)[0][0];
      }
    };
  }
  var os2ip, _DST_scalar;
  var init_hash_to_curve = __esm({
    "node_modules/@noble/curves/abstract/hash-to-curve.js"() {
      init_utils2();
      init_modular();
      os2ip = bytesToNumberBE;
      _DST_scalar = asciiToBytes("HashToScalar-");
    }
  });

  // node_modules/@noble/hashes/hmac.js
  var _HMAC, hmac;
  var init_hmac = __esm({
    "node_modules/@noble/hashes/hmac.js"() {
      init_utils();
      _HMAC = class {
        oHash;
        iHash;
        blockLen;
        outputLen;
        finished = false;
        destroyed = false;
        constructor(hash, key) {
          ahash(hash);
          abytes(key, void 0, "key");
          this.iHash = hash.create();
          if (typeof this.iHash.update !== "function")
            throw new Error("Expected instance of class which extends utils.Hash");
          this.blockLen = this.iHash.blockLen;
          this.outputLen = this.iHash.outputLen;
          const blockLen = this.blockLen;
          const pad = new Uint8Array(blockLen);
          pad.set(key.length > blockLen ? hash.create().update(key).digest() : key);
          for (let i = 0; i < pad.length; i++)
            pad[i] ^= 54;
          this.iHash.update(pad);
          this.oHash = hash.create();
          for (let i = 0; i < pad.length; i++)
            pad[i] ^= 54 ^ 92;
          this.oHash.update(pad);
          clean(pad);
        }
        update(buf) {
          aexists(this);
          this.iHash.update(buf);
          return this;
        }
        digestInto(out) {
          aexists(this);
          abytes(out, this.outputLen, "output");
          this.finished = true;
          this.iHash.digestInto(out);
          this.oHash.update(out);
          this.oHash.digestInto(out);
          this.destroy();
        }
        digest() {
          const out = new Uint8Array(this.oHash.outputLen);
          this.digestInto(out);
          return out;
        }
        _cloneInto(to) {
          to ||= Object.create(Object.getPrototypeOf(this), {});
          const { oHash, iHash, finished, destroyed, blockLen, outputLen } = this;
          to = to;
          to.finished = finished;
          to.destroyed = destroyed;
          to.blockLen = blockLen;
          to.outputLen = outputLen;
          to.oHash = oHash._cloneInto(to.oHash);
          to.iHash = iHash._cloneInto(to.iHash);
          return to;
        }
        clone() {
          return this._cloneInto();
        }
        destroy() {
          this.destroyed = true;
          this.oHash.destroy();
          this.iHash.destroy();
        }
      };
      hmac = (hash, key, message) => new _HMAC(hash, key).update(message).digest();
      hmac.create = (hash, key) => new _HMAC(hash, key);
    }
  });

  // node_modules/@noble/curves/abstract/weierstrass.js
  function _splitEndoScalar(k, basis, n) {
    const [[a1, b1], [a2, b2]] = basis;
    const c1 = divNearest(b2 * k, n);
    const c2 = divNearest(-b1 * k, n);
    let k1 = k - c1 * a1 - c2 * a2;
    let k2 = -c1 * b1 - c2 * b2;
    const k1neg = k1 < _0n4;
    const k2neg = k2 < _0n4;
    if (k1neg)
      k1 = -k1;
    if (k2neg)
      k2 = -k2;
    const MAX_NUM = bitMask(Math.ceil(bitLen(n) / 2)) + _1n4;
    if (k1 < _0n4 || k1 >= MAX_NUM || k2 < _0n4 || k2 >= MAX_NUM) {
      throw new Error("splitScalar (endomorphism): failed, k=" + k);
    }
    return { k1neg, k1, k2neg, k2 };
  }
  function weierstrass(params, extraOpts = {}) {
    const validated = createCurveFields("weierstrass", params, extraOpts);
    const { Fp: Fp3, Fn } = validated;
    let CURVE = validated.CURVE;
    const { h: cofactor, n: CURVE_ORDER } = CURVE;
    validateObject(extraOpts, {}, {
      allowInfinityPoint: "boolean",
      clearCofactor: "function",
      isTorsionFree: "function",
      fromBytes: "function",
      toBytes: "function",
      endo: "object"
    });
    const { endo } = extraOpts;
    if (endo) {
      if (!Fp3.is0(CURVE.a) || typeof endo.beta !== "bigint" || !Array.isArray(endo.basises)) {
        throw new Error('invalid endo: expected "beta": bigint and "basises": array');
      }
    }
    const lengths = getWLengths(Fp3, Fn);
    function assertCompressionIsSupported() {
      if (!Fp3.isOdd)
        throw new Error("compression is not supported: Field does not have .isOdd()");
    }
    function pointToBytes(_c, point, isCompressed) {
      const { x, y } = point.toAffine();
      const bx = Fp3.toBytes(x);
      abool(isCompressed, "isCompressed");
      if (isCompressed) {
        assertCompressionIsSupported();
        const hasEvenY = !Fp3.isOdd(y);
        return concatBytes(pprefix(hasEvenY), bx);
      } else {
        return concatBytes(Uint8Array.of(4), bx, Fp3.toBytes(y));
      }
    }
    function pointFromBytes(bytes) {
      abytes(bytes, void 0, "Point");
      const { publicKey: comp, publicKeyUncompressed: uncomp } = lengths;
      const length = bytes.length;
      const head = bytes[0];
      const tail = bytes.subarray(1);
      if (length === comp && (head === 2 || head === 3)) {
        const x = Fp3.fromBytes(tail);
        if (!Fp3.isValid(x))
          throw new Error("bad point: is not on curve, wrong x");
        const y2 = weierstrassEquation(x);
        let y;
        try {
          y = Fp3.sqrt(y2);
        } catch (sqrtError) {
          const err = sqrtError instanceof Error ? ": " + sqrtError.message : "";
          throw new Error("bad point: is not on curve, sqrt error" + err);
        }
        assertCompressionIsSupported();
        const evenY = Fp3.isOdd(y);
        const evenH = (head & 1) === 1;
        if (evenH !== evenY)
          y = Fp3.neg(y);
        return { x, y };
      } else if (length === uncomp && head === 4) {
        const L = Fp3.BYTES;
        const x = Fp3.fromBytes(tail.subarray(0, L));
        const y = Fp3.fromBytes(tail.subarray(L, L * 2));
        if (!isValidXY(x, y))
          throw new Error("bad point: is not on curve");
        return { x, y };
      } else {
        throw new Error(`bad point: got length ${length}, expected compressed=${comp} or uncompressed=${uncomp}`);
      }
    }
    const encodePoint = extraOpts.toBytes || pointToBytes;
    const decodePoint = extraOpts.fromBytes || pointFromBytes;
    function weierstrassEquation(x) {
      const x2 = Fp3.sqr(x);
      const x3 = Fp3.mul(x2, x);
      return Fp3.add(Fp3.add(x3, Fp3.mul(x, CURVE.a)), CURVE.b);
    }
    function isValidXY(x, y) {
      const left = Fp3.sqr(y);
      const right = weierstrassEquation(x);
      return Fp3.eql(left, right);
    }
    if (!isValidXY(CURVE.Gx, CURVE.Gy))
      throw new Error("bad curve params: generator point");
    const _4a3 = Fp3.mul(Fp3.pow(CURVE.a, _3n2), _4n2);
    const _27b2 = Fp3.mul(Fp3.sqr(CURVE.b), BigInt(27));
    if (Fp3.is0(Fp3.add(_4a3, _27b2)))
      throw new Error("bad curve params: a or b");
    function acoord(title, n, banZero = false) {
      if (!Fp3.isValid(n) || banZero && Fp3.is0(n))
        throw new Error(`bad point coordinate ${title}`);
      return n;
    }
    function aprjpoint(other) {
      if (!(other instanceof Point))
        throw new Error("Weierstrass Point expected");
    }
    function splitEndoScalarN(k) {
      if (!endo || !endo.basises)
        throw new Error("no endo");
      return _splitEndoScalar(k, endo.basises, Fn.ORDER);
    }
    const toAffineMemo = memoized((p, iz) => {
      const { X, Y, Z } = p;
      if (Fp3.eql(Z, Fp3.ONE))
        return { x: X, y: Y };
      const is0 = p.is0();
      if (iz == null)
        iz = is0 ? Fp3.ONE : Fp3.inv(Z);
      const x = Fp3.mul(X, iz);
      const y = Fp3.mul(Y, iz);
      const zz = Fp3.mul(Z, iz);
      if (is0)
        return { x: Fp3.ZERO, y: Fp3.ZERO };
      if (!Fp3.eql(zz, Fp3.ONE))
        throw new Error("invZ was invalid");
      return { x, y };
    });
    const assertValidMemo = memoized((p) => {
      if (p.is0()) {
        if (extraOpts.allowInfinityPoint && !Fp3.is0(p.Y))
          return;
        throw new Error("bad point: ZERO");
      }
      const { x, y } = p.toAffine();
      if (!Fp3.isValid(x) || !Fp3.isValid(y))
        throw new Error("bad point: x or y not field elements");
      if (!isValidXY(x, y))
        throw new Error("bad point: equation left != right");
      if (!p.isTorsionFree())
        throw new Error("bad point: not in prime-order subgroup");
      return true;
    });
    function finishEndo(endoBeta, k1p, k2p, k1neg, k2neg) {
      k2p = new Point(Fp3.mul(k2p.X, endoBeta), k2p.Y, k2p.Z);
      k1p = negateCt(k1neg, k1p);
      k2p = negateCt(k2neg, k2p);
      return k1p.add(k2p);
    }
    class Point {
      // base / generator point
      static BASE = new Point(CURVE.Gx, CURVE.Gy, Fp3.ONE);
      // zero / infinity / identity point
      static ZERO = new Point(Fp3.ZERO, Fp3.ONE, Fp3.ZERO);
      // 0, 1, 0
      // math field
      static Fp = Fp3;
      // scalar field
      static Fn = Fn;
      X;
      Y;
      Z;
      /** Does NOT validate if the point is valid. Use `.assertValidity()`. */
      constructor(X, Y, Z) {
        this.X = acoord("x", X);
        this.Y = acoord("y", Y, true);
        this.Z = acoord("z", Z);
        Object.freeze(this);
      }
      static CURVE() {
        return CURVE;
      }
      /** Does NOT validate if the point is valid. Use `.assertValidity()`. */
      static fromAffine(p) {
        const { x, y } = p || {};
        if (!p || !Fp3.isValid(x) || !Fp3.isValid(y))
          throw new Error("invalid affine point");
        if (p instanceof Point)
          throw new Error("projective point not allowed");
        if (Fp3.is0(x) && Fp3.is0(y))
          return Point.ZERO;
        return new Point(x, y, Fp3.ONE);
      }
      static fromBytes(bytes) {
        const P = Point.fromAffine(decodePoint(abytes(bytes, void 0, "point")));
        P.assertValidity();
        return P;
      }
      static fromHex(hex) {
        return Point.fromBytes(hexToBytes(hex));
      }
      get x() {
        return this.toAffine().x;
      }
      get y() {
        return this.toAffine().y;
      }
      /**
       *
       * @param windowSize
       * @param isLazy true will defer table computation until the first multiplication
       * @returns
       */
      precompute(windowSize = 8, isLazy = true) {
        wnaf.createCache(this, windowSize);
        if (!isLazy)
          this.multiply(_3n2);
        return this;
      }
      // TODO: return `this`
      /** A point on curve is valid if it conforms to equation. */
      assertValidity() {
        assertValidMemo(this);
      }
      hasEvenY() {
        const { y } = this.toAffine();
        if (!Fp3.isOdd)
          throw new Error("Field doesn't support isOdd");
        return !Fp3.isOdd(y);
      }
      /** Compare one point to another. */
      equals(other) {
        aprjpoint(other);
        const { X: X1, Y: Y1, Z: Z1 } = this;
        const { X: X2, Y: Y2, Z: Z2 } = other;
        const U1 = Fp3.eql(Fp3.mul(X1, Z2), Fp3.mul(X2, Z1));
        const U2 = Fp3.eql(Fp3.mul(Y1, Z2), Fp3.mul(Y2, Z1));
        return U1 && U2;
      }
      /** Flips point to one corresponding to (x, -y) in Affine coordinates. */
      negate() {
        return new Point(this.X, Fp3.neg(this.Y), this.Z);
      }
      // Renes-Costello-Batina exception-free doubling formula.
      // There is 30% faster Jacobian formula, but it is not complete.
      // https://eprint.iacr.org/2015/1060, algorithm 3
      // Cost: 8M + 3S + 3*a + 2*b3 + 15add.
      double() {
        const { a, b } = CURVE;
        const b3 = Fp3.mul(b, _3n2);
        const { X: X1, Y: Y1, Z: Z1 } = this;
        let X3 = Fp3.ZERO, Y3 = Fp3.ZERO, Z3 = Fp3.ZERO;
        let t0 = Fp3.mul(X1, X1);
        let t1 = Fp3.mul(Y1, Y1);
        let t2 = Fp3.mul(Z1, Z1);
        let t3 = Fp3.mul(X1, Y1);
        t3 = Fp3.add(t3, t3);
        Z3 = Fp3.mul(X1, Z1);
        Z3 = Fp3.add(Z3, Z3);
        X3 = Fp3.mul(a, Z3);
        Y3 = Fp3.mul(b3, t2);
        Y3 = Fp3.add(X3, Y3);
        X3 = Fp3.sub(t1, Y3);
        Y3 = Fp3.add(t1, Y3);
        Y3 = Fp3.mul(X3, Y3);
        X3 = Fp3.mul(t3, X3);
        Z3 = Fp3.mul(b3, Z3);
        t2 = Fp3.mul(a, t2);
        t3 = Fp3.sub(t0, t2);
        t3 = Fp3.mul(a, t3);
        t3 = Fp3.add(t3, Z3);
        Z3 = Fp3.add(t0, t0);
        t0 = Fp3.add(Z3, t0);
        t0 = Fp3.add(t0, t2);
        t0 = Fp3.mul(t0, t3);
        Y3 = Fp3.add(Y3, t0);
        t2 = Fp3.mul(Y1, Z1);
        t2 = Fp3.add(t2, t2);
        t0 = Fp3.mul(t2, t3);
        X3 = Fp3.sub(X3, t0);
        Z3 = Fp3.mul(t2, t1);
        Z3 = Fp3.add(Z3, Z3);
        Z3 = Fp3.add(Z3, Z3);
        return new Point(X3, Y3, Z3);
      }
      // Renes-Costello-Batina exception-free addition formula.
      // There is 30% faster Jacobian formula, but it is not complete.
      // https://eprint.iacr.org/2015/1060, algorithm 1
      // Cost: 12M + 0S + 3*a + 3*b3 + 23add.
      add(other) {
        aprjpoint(other);
        const { X: X1, Y: Y1, Z: Z1 } = this;
        const { X: X2, Y: Y2, Z: Z2 } = other;
        let X3 = Fp3.ZERO, Y3 = Fp3.ZERO, Z3 = Fp3.ZERO;
        const a = CURVE.a;
        const b3 = Fp3.mul(CURVE.b, _3n2);
        let t0 = Fp3.mul(X1, X2);
        let t1 = Fp3.mul(Y1, Y2);
        let t2 = Fp3.mul(Z1, Z2);
        let t3 = Fp3.add(X1, Y1);
        let t4 = Fp3.add(X2, Y2);
        t3 = Fp3.mul(t3, t4);
        t4 = Fp3.add(t0, t1);
        t3 = Fp3.sub(t3, t4);
        t4 = Fp3.add(X1, Z1);
        let t5 = Fp3.add(X2, Z2);
        t4 = Fp3.mul(t4, t5);
        t5 = Fp3.add(t0, t2);
        t4 = Fp3.sub(t4, t5);
        t5 = Fp3.add(Y1, Z1);
        X3 = Fp3.add(Y2, Z2);
        t5 = Fp3.mul(t5, X3);
        X3 = Fp3.add(t1, t2);
        t5 = Fp3.sub(t5, X3);
        Z3 = Fp3.mul(a, t4);
        X3 = Fp3.mul(b3, t2);
        Z3 = Fp3.add(X3, Z3);
        X3 = Fp3.sub(t1, Z3);
        Z3 = Fp3.add(t1, Z3);
        Y3 = Fp3.mul(X3, Z3);
        t1 = Fp3.add(t0, t0);
        t1 = Fp3.add(t1, t0);
        t2 = Fp3.mul(a, t2);
        t4 = Fp3.mul(b3, t4);
        t1 = Fp3.add(t1, t2);
        t2 = Fp3.sub(t0, t2);
        t2 = Fp3.mul(a, t2);
        t4 = Fp3.add(t4, t2);
        t0 = Fp3.mul(t1, t4);
        Y3 = Fp3.add(Y3, t0);
        t0 = Fp3.mul(t5, t4);
        X3 = Fp3.mul(t3, X3);
        X3 = Fp3.sub(X3, t0);
        t0 = Fp3.mul(t3, t1);
        Z3 = Fp3.mul(t5, Z3);
        Z3 = Fp3.add(Z3, t0);
        return new Point(X3, Y3, Z3);
      }
      subtract(other) {
        return this.add(other.negate());
      }
      is0() {
        return this.equals(Point.ZERO);
      }
      /**
       * Constant time multiplication.
       * Uses wNAF method. Windowed method may be 10% faster,
       * but takes 2x longer to generate and consumes 2x memory.
       * Uses precomputes when available.
       * Uses endomorphism for Koblitz curves.
       * @param scalar by which the point would be multiplied
       * @returns New point
       */
      multiply(scalar) {
        const { endo: endo2 } = extraOpts;
        if (!Fn.isValidNot0(scalar))
          throw new Error("invalid scalar: out of range");
        let point, fake;
        const mul = (n) => wnaf.cached(this, n, (p) => normalizeZ(Point, p));
        if (endo2) {
          const { k1neg, k1, k2neg, k2 } = splitEndoScalarN(scalar);
          const { p: k1p, f: k1f } = mul(k1);
          const { p: k2p, f: k2f } = mul(k2);
          fake = k1f.add(k2f);
          point = finishEndo(endo2.beta, k1p, k2p, k1neg, k2neg);
        } else {
          const { p, f } = mul(scalar);
          point = p;
          fake = f;
        }
        return normalizeZ(Point, [point, fake])[0];
      }
      /**
       * Non-constant-time multiplication. Uses double-and-add algorithm.
       * It's faster, but should only be used when you don't care about
       * an exposed secret key e.g. sig verification, which works over *public* keys.
       */
      multiplyUnsafe(sc) {
        const { endo: endo2 } = extraOpts;
        const p = this;
        if (!Fn.isValid(sc))
          throw new Error("invalid scalar: out of range");
        if (sc === _0n4 || p.is0())
          return Point.ZERO;
        if (sc === _1n4)
          return p;
        if (wnaf.hasCache(this))
          return this.multiply(sc);
        if (endo2) {
          const { k1neg, k1, k2neg, k2 } = splitEndoScalarN(sc);
          const { p1, p2 } = mulEndoUnsafe(Point, p, k1, k2);
          return finishEndo(endo2.beta, p1, p2, k1neg, k2neg);
        } else {
          return wnaf.unsafe(p, sc);
        }
      }
      /**
       * Converts Projective point to affine (x, y) coordinates.
       * @param invertedZ Z^-1 (inverted zero) - optional, precomputation is useful for invertBatch
       */
      toAffine(invertedZ) {
        return toAffineMemo(this, invertedZ);
      }
      /**
       * Checks whether Point is free of torsion elements (is in prime subgroup).
       * Always torsion-free for cofactor=1 curves.
       */
      isTorsionFree() {
        const { isTorsionFree } = extraOpts;
        if (cofactor === _1n4)
          return true;
        if (isTorsionFree)
          return isTorsionFree(Point, this);
        return wnaf.unsafe(this, CURVE_ORDER).is0();
      }
      clearCofactor() {
        const { clearCofactor } = extraOpts;
        if (cofactor === _1n4)
          return this;
        if (clearCofactor)
          return clearCofactor(Point, this);
        return this.multiplyUnsafe(cofactor);
      }
      isSmallOrder() {
        return this.multiplyUnsafe(cofactor).is0();
      }
      toBytes(isCompressed = true) {
        abool(isCompressed, "isCompressed");
        this.assertValidity();
        return encodePoint(Point, this, isCompressed);
      }
      toHex(isCompressed = true) {
        return bytesToHex(this.toBytes(isCompressed));
      }
      toString() {
        return `<Point ${this.is0() ? "ZERO" : this.toHex()}>`;
      }
    }
    const bits = Fn.BITS;
    const wnaf = new wNAF(Point, extraOpts.endo ? Math.ceil(bits / 2) : bits);
    Point.BASE.precompute(8);
    return Point;
  }
  function pprefix(hasEvenY) {
    return Uint8Array.of(hasEvenY ? 2 : 3);
  }
  function SWUFpSqrtRatio(Fp3, Z) {
    const q = Fp3.ORDER;
    let l = _0n4;
    for (let o = q - _1n4; o % _2n2 === _0n4; o /= _2n2)
      l += _1n4;
    const c1 = l;
    const _2n_pow_c1_1 = _2n2 << c1 - _1n4 - _1n4;
    const _2n_pow_c1 = _2n_pow_c1_1 * _2n2;
    const c2 = (q - _1n4) / _2n_pow_c1;
    const c3 = (c2 - _1n4) / _2n2;
    const c4 = _2n_pow_c1 - _1n4;
    const c5 = _2n_pow_c1_1;
    const c6 = Fp3.pow(Z, c2);
    const c7 = Fp3.pow(Z, (c2 + _1n4) / _2n2);
    let sqrtRatio = (u, v) => {
      let tv1 = c6;
      let tv2 = Fp3.pow(v, c4);
      let tv3 = Fp3.sqr(tv2);
      tv3 = Fp3.mul(tv3, v);
      let tv5 = Fp3.mul(u, tv3);
      tv5 = Fp3.pow(tv5, c3);
      tv5 = Fp3.mul(tv5, tv2);
      tv2 = Fp3.mul(tv5, v);
      tv3 = Fp3.mul(tv5, u);
      let tv4 = Fp3.mul(tv3, tv2);
      tv5 = Fp3.pow(tv4, c5);
      let isQR = Fp3.eql(tv5, Fp3.ONE);
      tv2 = Fp3.mul(tv3, c7);
      tv5 = Fp3.mul(tv4, tv1);
      tv3 = Fp3.cmov(tv2, tv3, isQR);
      tv4 = Fp3.cmov(tv5, tv4, isQR);
      for (let i = c1; i > _1n4; i--) {
        let tv52 = i - _2n2;
        tv52 = _2n2 << tv52 - _1n4;
        let tvv5 = Fp3.pow(tv4, tv52);
        const e1 = Fp3.eql(tvv5, Fp3.ONE);
        tv2 = Fp3.mul(tv3, tv1);
        tv1 = Fp3.mul(tv1, tv1);
        tvv5 = Fp3.mul(tv4, tv1);
        tv3 = Fp3.cmov(tv2, tv3, e1);
        tv4 = Fp3.cmov(tvv5, tv4, e1);
      }
      return { isValid: isQR, value: tv3 };
    };
    if (Fp3.ORDER % _4n2 === _3n2) {
      const c12 = (Fp3.ORDER - _3n2) / _4n2;
      const c22 = Fp3.sqrt(Fp3.neg(Z));
      sqrtRatio = (u, v) => {
        let tv1 = Fp3.sqr(v);
        const tv2 = Fp3.mul(u, v);
        tv1 = Fp3.mul(tv1, tv2);
        let y1 = Fp3.pow(tv1, c12);
        y1 = Fp3.mul(y1, tv2);
        const y2 = Fp3.mul(y1, c22);
        const tv3 = Fp3.mul(Fp3.sqr(y1), v);
        const isQR = Fp3.eql(tv3, u);
        let y = Fp3.cmov(y2, y1, isQR);
        return { isValid: isQR, value: y };
      };
    }
    return sqrtRatio;
  }
  function mapToCurveSimpleSWU(Fp3, opts) {
    validateField(Fp3);
    const { A, B, Z } = opts;
    if (!Fp3.isValid(A) || !Fp3.isValid(B) || !Fp3.isValid(Z))
      throw new Error("mapToCurveSimpleSWU: invalid opts");
    const sqrtRatio = SWUFpSqrtRatio(Fp3, Z);
    if (!Fp3.isOdd)
      throw new Error("Field does not have .isOdd()");
    return (u) => {
      let tv1, tv2, tv3, tv4, tv5, tv6, x, y;
      tv1 = Fp3.sqr(u);
      tv1 = Fp3.mul(tv1, Z);
      tv2 = Fp3.sqr(tv1);
      tv2 = Fp3.add(tv2, tv1);
      tv3 = Fp3.add(tv2, Fp3.ONE);
      tv3 = Fp3.mul(tv3, B);
      tv4 = Fp3.cmov(Z, Fp3.neg(tv2), !Fp3.eql(tv2, Fp3.ZERO));
      tv4 = Fp3.mul(tv4, A);
      tv2 = Fp3.sqr(tv3);
      tv6 = Fp3.sqr(tv4);
      tv5 = Fp3.mul(tv6, A);
      tv2 = Fp3.add(tv2, tv5);
      tv2 = Fp3.mul(tv2, tv3);
      tv6 = Fp3.mul(tv6, tv4);
      tv5 = Fp3.mul(tv6, B);
      tv2 = Fp3.add(tv2, tv5);
      x = Fp3.mul(tv1, tv3);
      const { isValid, value } = sqrtRatio(tv2, tv6);
      y = Fp3.mul(tv1, u);
      y = Fp3.mul(y, value);
      x = Fp3.cmov(x, tv3, isValid);
      y = Fp3.cmov(y, value, isValid);
      const e1 = Fp3.isOdd(u) === Fp3.isOdd(y);
      y = Fp3.cmov(Fp3.neg(y), y, e1);
      const tv4_inv = FpInvertBatch(Fp3, [tv4], true)[0];
      x = Fp3.mul(x, tv4_inv);
      return { x, y };
    };
  }
  function getWLengths(Fp3, Fn) {
    return {
      secretKey: Fn.BYTES,
      publicKey: 1 + Fp3.BYTES,
      publicKeyUncompressed: 1 + 2 * Fp3.BYTES,
      publicKeyHasPrefix: true,
      signature: 2 * Fn.BYTES
    };
  }
  var divNearest, _0n4, _1n4, _2n2, _3n2, _4n2;
  var init_weierstrass = __esm({
    "node_modules/@noble/curves/abstract/weierstrass.js"() {
      init_utils2();
      init_curve();
      init_modular();
      divNearest = (num, den) => (num + (num >= 0 ? den : -den) / _2n2) / den;
      _0n4 = BigInt(0);
      _1n4 = BigInt(1);
      _2n2 = BigInt(2);
      _3n2 = BigInt(3);
      _4n2 = BigInt(4);
    }
  });

  // node_modules/@noble/curves/abstract/bls.js
  function NAfDecomposition(a) {
    const res = [];
    for (; a > _1n5; a >>= _1n5) {
      if ((a & _1n5) === _0n5)
        res.unshift(0);
      else if ((a & _3n3) === _3n3) {
        res.unshift(-1);
        a += _1n5;
      } else
        res.unshift(1);
    }
    return res;
  }
  function aNonEmpty(arr) {
    if (!Array.isArray(arr) || arr.length === 0)
      throw new Error("expected non-empty array");
  }
  function createBlsPairing(fields2, G1, G2, params) {
    const { Fr, Fp2: Fp22, Fp12: Fp122 } = fields2;
    const { twistType, ateLoopSize, xNegative, postPrecompute } = params;
    let lineFunction;
    if (twistType === "multiplicative") {
      lineFunction = (c0, c1, c2, f, Px, Py) => Fp122.mul014(f, c0, Fp22.mul(c1, Px), Fp22.mul(c2, Py));
    } else if (twistType === "divisive") {
      lineFunction = (c0, c1, c2, f, Px, Py) => Fp122.mul034(f, Fp22.mul(c2, Py), Fp22.mul(c1, Px), c0);
    } else
      throw new Error("bls: unknown twist type");
    const Fp2div2 = Fp22.div(Fp22.ONE, Fp22.mul(Fp22.ONE, _2n3));
    function pointDouble(ell, Rx, Ry, Rz) {
      const t0 = Fp22.sqr(Ry);
      const t1 = Fp22.sqr(Rz);
      const t2 = Fp22.mulByB(Fp22.mul(t1, _3n3));
      const t3 = Fp22.mul(t2, _3n3);
      const t4 = Fp22.sub(Fp22.sub(Fp22.sqr(Fp22.add(Ry, Rz)), t1), t0);
      const c0 = Fp22.sub(t2, t0);
      const c1 = Fp22.mul(Fp22.sqr(Rx), _3n3);
      const c2 = Fp22.neg(t4);
      ell.push([c0, c1, c2]);
      Rx = Fp22.mul(Fp22.mul(Fp22.mul(Fp22.sub(t0, t3), Rx), Ry), Fp2div2);
      Ry = Fp22.sub(Fp22.sqr(Fp22.mul(Fp22.add(t0, t3), Fp2div2)), Fp22.mul(Fp22.sqr(t2), _3n3));
      Rz = Fp22.mul(t0, t4);
      return { Rx, Ry, Rz };
    }
    function pointAdd(ell, Rx, Ry, Rz, Qx, Qy) {
      const t0 = Fp22.sub(Ry, Fp22.mul(Qy, Rz));
      const t1 = Fp22.sub(Rx, Fp22.mul(Qx, Rz));
      const c0 = Fp22.sub(Fp22.mul(t0, Qx), Fp22.mul(t1, Qy));
      const c1 = Fp22.neg(t0);
      const c2 = t1;
      ell.push([c0, c1, c2]);
      const t2 = Fp22.sqr(t1);
      const t3 = Fp22.mul(t2, t1);
      const t4 = Fp22.mul(t2, Rx);
      const t5 = Fp22.add(Fp22.sub(t3, Fp22.mul(t4, _2n3)), Fp22.mul(Fp22.sqr(t0), Rz));
      Rx = Fp22.mul(t1, t5);
      Ry = Fp22.sub(Fp22.mul(Fp22.sub(t4, t5), t0), Fp22.mul(t3, Ry));
      Rz = Fp22.mul(Rz, t3);
      return { Rx, Ry, Rz };
    }
    const ATE_NAF = NAfDecomposition(ateLoopSize);
    const calcPairingPrecomputes = memoized((point) => {
      const p = point;
      const { x, y } = p.toAffine();
      const Qx = x, Qy = y, negQy = Fp22.neg(y);
      let Rx = Qx, Ry = Qy, Rz = Fp22.ONE;
      const ell = [];
      for (const bit of ATE_NAF) {
        const cur = [];
        ({ Rx, Ry, Rz } = pointDouble(cur, Rx, Ry, Rz));
        if (bit)
          ({ Rx, Ry, Rz } = pointAdd(cur, Rx, Ry, Rz, Qx, bit === -1 ? negQy : Qy));
        ell.push(cur);
      }
      if (postPrecompute) {
        const last = ell[ell.length - 1];
        postPrecompute(Rx, Ry, Rz, Qx, Qy, pointAdd.bind(null, last));
      }
      return ell;
    });
    function millerLoopBatch(pairs, withFinalExponent = false) {
      let f12 = Fp122.ONE;
      if (pairs.length) {
        const ellLen = pairs[0][0].length;
        for (let i = 0; i < ellLen; i++) {
          f12 = Fp122.sqr(f12);
          for (const [ell, Px, Py] of pairs) {
            for (const [c0, c1, c2] of ell[i])
              f12 = lineFunction(c0, c1, c2, f12, Px, Py);
          }
        }
      }
      if (xNegative)
        f12 = Fp122.conjugate(f12);
      return withFinalExponent ? Fp122.finalExponentiate(f12) : f12;
    }
    function pairingBatch(pairs, withFinalExponent = true) {
      const res = [];
      normalizeZ(G1, pairs.map(({ g1 }) => g1));
      normalizeZ(G2, pairs.map(({ g2 }) => g2));
      for (const { g1, g2 } of pairs) {
        if (g1.is0() || g2.is0())
          throw new Error("pairing is not available for ZERO point");
        g1.assertValidity();
        g2.assertValidity();
        const Qa = g1.toAffine();
        res.push([calcPairingPrecomputes(g2), Qa.x, Qa.y]);
      }
      return millerLoopBatch(res, withFinalExponent);
    }
    function pairing(Q, P, withFinalExponent = true) {
      return pairingBatch([{ g1: Q, g2: P }], withFinalExponent);
    }
    const lengths = {
      seed: getMinHashLength(Fr.ORDER)
    };
    const rand = params.randomBytes || randomBytes;
    const randomSecretKey = (seed = rand(lengths.seed)) => {
      abytes(seed, lengths.seed, "seed");
      return mapHashToField(seed, Fr.ORDER);
    };
    return {
      lengths,
      Fr,
      Fp12: Fp122,
      // NOTE: we re-export Fp12 here because pairing results are Fp12!
      millerLoopBatch,
      pairing,
      pairingBatch,
      calcPairingPrecomputes,
      randomSecretKey
    };
  }
  function createBlsSig(blsPairing, PubPoint, SigPoint, isSigG1, hashToSigCurve, SignatureCoder) {
    const { Fr, Fp12: Fp122, pairingBatch, randomSecretKey, lengths } = blsPairing;
    if (!SignatureCoder) {
      SignatureCoder = {
        fromBytes: notImplemented,
        fromHex: notImplemented,
        toBytes: notImplemented,
        toHex: notImplemented
      };
    }
    function normPub(point) {
      return point instanceof PubPoint ? point : PubPoint.fromBytes(point);
    }
    function normSig(point) {
      return point instanceof SigPoint ? point : SigPoint.fromBytes(point);
    }
    function amsg(m) {
      if (!(m instanceof SigPoint))
        throw new Error(`expected valid message hashed to ${!isSigG1 ? "G2" : "G1"} curve`);
      return m;
    }
    const pair = !isSigG1 ? (a, b) => ({ g1: a, g2: b }) : (a, b) => ({ g1: b, g2: a });
    return Object.freeze({
      lengths: { ...lengths, secretKey: Fr.BYTES },
      keygen(seed) {
        const secretKey = randomSecretKey(seed);
        const publicKey = this.getPublicKey(secretKey);
        return { secretKey, publicKey };
      },
      // P = pk x G
      getPublicKey(secretKey) {
        let sec;
        try {
          sec = PubPoint.Fn.fromBytes(secretKey);
        } catch (error) {
          throw new Error("invalid private key: " + typeof secretKey, { cause: error });
        }
        return PubPoint.BASE.multiply(sec);
      },
      // S = pk x H(m)
      sign(message, secretKey, unusedArg) {
        if (unusedArg != null)
          throw new Error("sign() expects 2 arguments");
        const sec = PubPoint.Fn.fromBytes(secretKey);
        amsg(message).assertValidity();
        return message.multiply(sec);
      },
      // Checks if pairing of public key & hash is equal to pairing of generator & signature.
      // e(P, H(m)) == e(G, S)
      // e(S, G) == e(H(m), P)
      verify(signature, message, publicKey, unusedArg) {
        if (unusedArg != null)
          throw new Error("verify() expects 3 arguments");
        signature = normSig(signature);
        publicKey = normPub(publicKey);
        const P = publicKey.negate();
        const G = PubPoint.BASE;
        const Hm = amsg(message);
        const S = signature;
        try {
          const exp = pairingBatch([pair(P, Hm), pair(G, S)]);
          return Fp122.eql(exp, Fp122.ONE);
        } catch {
          return false;
        }
      },
      // https://ethresear.ch/t/fast-verification-of-multiple-bls-signatures/5407
      // e(G, S) = e(G, SUM(n)(Si)) = MUL(n)(e(G, Si))
      // TODO: maybe `{message: G2Hex, publicKey: G1Hex}[]` instead?
      verifyBatch(signature, items) {
        aNonEmpty(items);
        const sig = normSig(signature);
        const nMessages = items.map((i) => i.message);
        const nPublicKeys = items.map((i) => normPub(i.publicKey));
        const messagePubKeyMap = /* @__PURE__ */ new Map();
        for (let i = 0; i < nPublicKeys.length; i++) {
          const pub = nPublicKeys[i];
          const msg = nMessages[i];
          let keys = messagePubKeyMap.get(msg);
          if (keys === void 0) {
            keys = [];
            messagePubKeyMap.set(msg, keys);
          }
          keys.push(pub);
        }
        const paired = [];
        const G = PubPoint.BASE;
        try {
          for (const [msg, keys] of messagePubKeyMap) {
            const groupPublicKey = keys.reduce((acc, msg2) => acc.add(msg2));
            paired.push(pair(groupPublicKey, msg));
          }
          paired.push(pair(G.negate(), sig));
          return Fp122.eql(pairingBatch(paired), Fp122.ONE);
        } catch {
          return false;
        }
      },
      // Adds a bunch of public key points together.
      // pk1 + pk2 + pk3 = pkA
      aggregatePublicKeys(publicKeys) {
        aNonEmpty(publicKeys);
        publicKeys = publicKeys.map((pub) => normPub(pub));
        const agg = publicKeys.reduce((sum, p) => sum.add(p), PubPoint.ZERO);
        agg.assertValidity();
        return agg;
      },
      // Adds a bunch of signature points together.
      // pk1 + pk2 + pk3 = pkA
      aggregateSignatures(signatures) {
        aNonEmpty(signatures);
        signatures = signatures.map((sig) => normSig(sig));
        const agg = signatures.reduce((sum, s) => sum.add(s), SigPoint.ZERO);
        agg.assertValidity();
        return agg;
      },
      hash(messageBytes, DST) {
        abytes(messageBytes);
        const opts = DST ? { DST } : void 0;
        return hashToSigCurve(messageBytes, opts);
      },
      Signature: SignatureCoder
    });
  }
  function blsBasic(fields2, G1_Point2, G2_Point2, params) {
    const { Fp: Fp3, Fr, Fp2: Fp22, Fp6: Fp62, Fp12: Fp122 } = fields2;
    const G1 = { Point: G1_Point2 };
    const G2 = { Point: G2_Point2 };
    const pairingRes = createBlsPairing(fields2, G1_Point2, G2_Point2, params);
    const { millerLoopBatch, pairing, pairingBatch, calcPairingPrecomputes, randomSecretKey, lengths } = pairingRes;
    G1.Point.BASE.precompute(4);
    return Object.freeze({
      lengths,
      millerLoopBatch,
      pairing,
      pairingBatch,
      G1,
      G2,
      fields: { Fr, Fp: Fp3, Fp2: Fp22, Fp6: Fp62, Fp12: Fp122 },
      params: {
        ateLoopSize: params.ateLoopSize,
        twistType: params.twistType
      },
      utils: {
        randomSecretKey,
        calcPairingPrecomputes
      }
    });
  }
  function blsHashers(fields2, G1_Point2, G2_Point2, params, hasherParams) {
    const base = blsBasic(fields2, G1_Point2, G2_Point2, params);
    const G1Hasher = createHasher2(G1_Point2, hasherParams.mapToG1 || notImplemented, {
      ...hasherParams.hasherOpts,
      ...hasherParams.hasherOptsG1
    });
    const G2Hasher = createHasher2(G2_Point2, hasherParams.mapToG2 || notImplemented, {
      ...hasherParams.hasherOpts,
      ...hasherParams.hasherOptsG2
    });
    return Object.freeze({ ...base, G1: G1Hasher, G2: G2Hasher });
  }
  function bls(fields2, G1_Point2, G2_Point2, params, hasherParams, signatureCoders2) {
    const base = blsHashers(fields2, G1_Point2, G2_Point2, params, hasherParams);
    const pairingRes = {
      ...base,
      Fr: base.fields.Fr,
      Fp12: base.fields.Fp12,
      calcPairingPrecomputes: base.utils.calcPairingPrecomputes,
      randomSecretKey: base.utils.randomSecretKey
    };
    const longSignatures = createBlsSig(pairingRes, G1_Point2, G2_Point2, false, base.G2.hashToCurve, signatureCoders2?.LongSignature);
    const shortSignatures = createBlsSig(pairingRes, G2_Point2, G1_Point2, true, base.G1.hashToCurve, signatureCoders2?.ShortSignature);
    return Object.freeze({ ...base, longSignatures, shortSignatures });
  }
  var _0n5, _1n5, _2n3, _3n3;
  var init_bls = __esm({
    "node_modules/@noble/curves/abstract/bls.js"() {
      init_utils2();
      init_curve();
      init_hash_to_curve();
      init_modular();
      _0n5 = BigInt(0);
      _1n5 = BigInt(1);
      _2n3 = BigInt(2);
      _3n3 = BigInt(3);
    }
  });

  // node_modules/@noble/curves/abstract/tower.js
  function calcFrobeniusCoefficients(Fp3, nonResidue, modulus, degree, num = 1, divisor) {
    const _divisor = BigInt(divisor === void 0 ? degree : divisor);
    const towerModulus = modulus ** BigInt(degree);
    const res = [];
    for (let i = 0; i < num; i++) {
      const a = BigInt(i + 1);
      const powers = [];
      for (let j = 0, qPower = _1n6; j < degree; j++) {
        const power = (a * qPower - a) / _divisor % towerModulus;
        powers.push(Fp3.pow(nonResidue, power));
        qPower *= modulus;
      }
      res.push(powers);
    }
    return res;
  }
  function psiFrobenius(Fp3, Fp22, base) {
    const PSI_X = Fp22.pow(base, (Fp3.ORDER - _1n6) / _3n4);
    const PSI_Y = Fp22.pow(base, (Fp3.ORDER - _1n6) / _2n4);
    function psi(x, y) {
      const x2 = Fp22.mul(Fp22.frobeniusMap(x, 1), PSI_X);
      const y2 = Fp22.mul(Fp22.frobeniusMap(y, 1), PSI_Y);
      return [x2, y2];
    }
    const PSI2_X = Fp22.pow(base, (Fp3.ORDER ** _2n4 - _1n6) / _3n4);
    const PSI2_Y = Fp22.pow(base, (Fp3.ORDER ** _2n4 - _1n6) / _2n4);
    if (!Fp22.eql(PSI2_Y, Fp22.neg(Fp22.ONE)))
      throw new Error("psiFrobenius: PSI2_Y!==-1");
    function psi2(x, y) {
      return [Fp22.mul(x, PSI2_X), Fp22.neg(y)];
    }
    const mapAffine = (fn) => (c, P) => {
      const affine = P.toAffine();
      const p = fn(affine.x, affine.y);
      return c.fromAffine({ x: p[0], y: p[1] });
    };
    const G2psi3 = mapAffine(psi);
    const G2psi22 = mapAffine(psi2);
    return { psi, psi2, G2psi: G2psi3, G2psi2: G2psi22, PSI_X, PSI_Y, PSI2_X, PSI2_Y };
  }
  function tower12(opts) {
    const Fp3 = Field(opts.ORDER);
    const Fp22 = new _Field2(Fp3, opts);
    const Fp62 = new _Field6(Fp22);
    const Fp122 = new _Field12(Fp62, opts);
    return { Fp: Fp3, Fp2: Fp22, Fp6: Fp62, Fp12: Fp122 };
  }
  var _0n6, _1n6, _2n4, _3n4, Fp2fromBigTuple, _Field2, _Field6, _Field12;
  var init_tower = __esm({
    "node_modules/@noble/curves/abstract/tower.js"() {
      init_utils2();
      init_modular();
      _0n6 = BigInt(0);
      _1n6 = BigInt(1);
      _2n4 = BigInt(2);
      _3n4 = BigInt(3);
      Fp2fromBigTuple = (Fp3, tuple) => {
        if (tuple.length !== 2)
          throw new Error("invalid tuple");
        const fps = tuple.map((n) => Fp3.create(n));
        return { c0: fps[0], c1: fps[1] };
      };
      _Field2 = class {
        ORDER;
        BITS;
        BYTES;
        isLE;
        ZERO;
        ONE;
        Fp;
        NONRESIDUE;
        mulByB;
        Fp_NONRESIDUE;
        Fp_div2;
        FROBENIUS_COEFFICIENTS;
        constructor(Fp3, opts = {}) {
          const ORDER = Fp3.ORDER;
          const FP2_ORDER = ORDER * ORDER;
          this.Fp = Fp3;
          this.ORDER = FP2_ORDER;
          this.BITS = bitLen(FP2_ORDER);
          this.BYTES = Math.ceil(bitLen(FP2_ORDER) / 8);
          this.isLE = Fp3.isLE;
          this.ZERO = { c0: Fp3.ZERO, c1: Fp3.ZERO };
          this.ONE = { c0: Fp3.ONE, c1: Fp3.ZERO };
          this.Fp_NONRESIDUE = Fp3.create(opts.NONRESIDUE || BigInt(-1));
          this.Fp_div2 = Fp3.div(Fp3.ONE, _2n4);
          this.NONRESIDUE = Fp2fromBigTuple(Fp3, opts.FP2_NONRESIDUE);
          this.FROBENIUS_COEFFICIENTS = calcFrobeniusCoefficients(Fp3, this.Fp_NONRESIDUE, Fp3.ORDER, 2)[0];
          this.mulByB = opts.Fp2mulByB;
          Object.seal(this);
        }
        fromBigTuple(tuple) {
          return Fp2fromBigTuple(this.Fp, tuple);
        }
        create(num) {
          return num;
        }
        isValid({ c0, c1 }) {
          function isValidC(num, ORDER) {
            return typeof num === "bigint" && _0n6 <= num && num < ORDER;
          }
          return isValidC(c0, this.ORDER) && isValidC(c1, this.ORDER);
        }
        is0({ c0, c1 }) {
          return this.Fp.is0(c0) && this.Fp.is0(c1);
        }
        isValidNot0(num) {
          return !this.is0(num) && this.isValid(num);
        }
        eql({ c0, c1 }, { c0: r0, c1: r1 }) {
          return this.Fp.eql(c0, r0) && this.Fp.eql(c1, r1);
        }
        neg({ c0, c1 }) {
          return { c0: this.Fp.neg(c0), c1: this.Fp.neg(c1) };
        }
        pow(num, power) {
          return FpPow(this, num, power);
        }
        invertBatch(nums) {
          return FpInvertBatch(this, nums);
        }
        // Normalized
        add(f1, f2) {
          const { c0, c1 } = f1;
          const { c0: r0, c1: r1 } = f2;
          return {
            c0: this.Fp.add(c0, r0),
            c1: this.Fp.add(c1, r1)
          };
        }
        sub({ c0, c1 }, { c0: r0, c1: r1 }) {
          return {
            c0: this.Fp.sub(c0, r0),
            c1: this.Fp.sub(c1, r1)
          };
        }
        mul({ c0, c1 }, rhs) {
          const { Fp: Fp3 } = this;
          if (typeof rhs === "bigint")
            return { c0: Fp3.mul(c0, rhs), c1: Fp3.mul(c1, rhs) };
          const { c0: r0, c1: r1 } = rhs;
          let t1 = Fp3.mul(c0, r0);
          let t2 = Fp3.mul(c1, r1);
          const o0 = Fp3.sub(t1, t2);
          const o1 = Fp3.sub(Fp3.mul(Fp3.add(c0, c1), Fp3.add(r0, r1)), Fp3.add(t1, t2));
          return { c0: o0, c1: o1 };
        }
        sqr({ c0, c1 }) {
          const { Fp: Fp3 } = this;
          const a = Fp3.add(c0, c1);
          const b = Fp3.sub(c0, c1);
          const c = Fp3.add(c0, c0);
          return { c0: Fp3.mul(a, b), c1: Fp3.mul(c, c1) };
        }
        // NonNormalized stuff
        addN(a, b) {
          return this.add(a, b);
        }
        subN(a, b) {
          return this.sub(a, b);
        }
        mulN(a, b) {
          return this.mul(a, b);
        }
        sqrN(a) {
          return this.sqr(a);
        }
        // Why inversion for bigint inside Fp instead of Fp2? it is even used in that context?
        div(lhs, rhs) {
          const { Fp: Fp3 } = this;
          return this.mul(lhs, typeof rhs === "bigint" ? Fp3.inv(Fp3.create(rhs)) : this.inv(rhs));
        }
        inv({ c0: a, c1: b }) {
          const { Fp: Fp3 } = this;
          const factor = Fp3.inv(Fp3.create(a * a + b * b));
          return { c0: Fp3.mul(factor, Fp3.create(a)), c1: Fp3.mul(factor, Fp3.create(-b)) };
        }
        sqrt(num) {
          const { Fp: Fp3 } = this;
          const Fp22 = this;
          const { c0, c1 } = num;
          if (Fp3.is0(c1)) {
            if (FpLegendre(Fp3, c0) === 1)
              return Fp22.create({ c0: Fp3.sqrt(c0), c1: Fp3.ZERO });
            else
              return Fp22.create({ c0: Fp3.ZERO, c1: Fp3.sqrt(Fp3.div(c0, this.Fp_NONRESIDUE)) });
          }
          const a = Fp3.sqrt(Fp3.sub(Fp3.sqr(c0), Fp3.mul(Fp3.sqr(c1), this.Fp_NONRESIDUE)));
          let d = Fp3.mul(Fp3.add(a, c0), this.Fp_div2);
          const legendre = FpLegendre(Fp3, d);
          if (legendre === -1)
            d = Fp3.sub(d, a);
          const a0 = Fp3.sqrt(d);
          const candidateSqrt = Fp22.create({ c0: a0, c1: Fp3.div(Fp3.mul(c1, this.Fp_div2), a0) });
          if (!Fp22.eql(Fp22.sqr(candidateSqrt), num))
            throw new Error("Cannot find square root");
          const x1 = candidateSqrt;
          const x2 = Fp22.neg(x1);
          const { re: re1, im: im1 } = Fp22.reim(x1);
          const { re: re2, im: im2 } = Fp22.reim(x2);
          if (im1 > im2 || im1 === im2 && re1 > re2)
            return x1;
          return x2;
        }
        // Same as sgn0_m_eq_2 in RFC 9380
        isOdd(x) {
          const { re: x0, im: x1 } = this.reim(x);
          const sign_0 = x0 % _2n4;
          const zero_0 = x0 === _0n6;
          const sign_1 = x1 % _2n4;
          return BigInt(sign_0 || zero_0 && sign_1) == _1n6;
        }
        // Bytes util
        fromBytes(b) {
          const { Fp: Fp3 } = this;
          if (b.length !== this.BYTES)
            throw new Error("fromBytes invalid length=" + b.length);
          return { c0: Fp3.fromBytes(b.subarray(0, Fp3.BYTES)), c1: Fp3.fromBytes(b.subarray(Fp3.BYTES)) };
        }
        toBytes({ c0, c1 }) {
          return concatBytes(this.Fp.toBytes(c0), this.Fp.toBytes(c1));
        }
        cmov({ c0, c1 }, { c0: r0, c1: r1 }, c) {
          return {
            c0: this.Fp.cmov(c0, r0, c),
            c1: this.Fp.cmov(c1, r1, c)
          };
        }
        reim({ c0, c1 }) {
          return { re: c0, im: c1 };
        }
        Fp4Square(a, b) {
          const Fp22 = this;
          const a2 = Fp22.sqr(a);
          const b2 = Fp22.sqr(b);
          return {
            first: Fp22.add(Fp22.mulByNonresidue(b2), a2),
            // b² * Nonresidue + a²
            second: Fp22.sub(Fp22.sub(Fp22.sqr(Fp22.add(a, b)), a2), b2)
            // (a + b)² - a² - b²
          };
        }
        // multiply by u + 1
        mulByNonresidue({ c0, c1 }) {
          return this.mul({ c0, c1 }, this.NONRESIDUE);
        }
        frobeniusMap({ c0, c1 }, power) {
          return {
            c0,
            c1: this.Fp.mul(c1, this.FROBENIUS_COEFFICIENTS[power % 2])
          };
        }
      };
      _Field6 = class {
        ORDER;
        BITS;
        BYTES;
        isLE;
        ZERO;
        ONE;
        Fp2;
        FROBENIUS_COEFFICIENTS_1;
        FROBENIUS_COEFFICIENTS_2;
        constructor(Fp22) {
          this.Fp2 = Fp22;
          this.ORDER = Fp22.ORDER;
          this.BITS = 3 * Fp22.BITS;
          this.BYTES = 3 * Fp22.BYTES;
          this.isLE = Fp22.isLE;
          this.ZERO = { c0: Fp22.ZERO, c1: Fp22.ZERO, c2: Fp22.ZERO };
          this.ONE = { c0: Fp22.ONE, c1: Fp22.ZERO, c2: Fp22.ZERO };
          const { Fp: Fp3 } = Fp22;
          const frob = calcFrobeniusCoefficients(Fp22, Fp22.NONRESIDUE, Fp3.ORDER, 6, 2, 3);
          this.FROBENIUS_COEFFICIENTS_1 = frob[0];
          this.FROBENIUS_COEFFICIENTS_2 = frob[1];
          Object.seal(this);
        }
        add({ c0, c1, c2 }, { c0: r0, c1: r1, c2: r2 }) {
          const { Fp2: Fp22 } = this;
          return {
            c0: Fp22.add(c0, r0),
            c1: Fp22.add(c1, r1),
            c2: Fp22.add(c2, r2)
          };
        }
        sub({ c0, c1, c2 }, { c0: r0, c1: r1, c2: r2 }) {
          const { Fp2: Fp22 } = this;
          return {
            c0: Fp22.sub(c0, r0),
            c1: Fp22.sub(c1, r1),
            c2: Fp22.sub(c2, r2)
          };
        }
        mul({ c0, c1, c2 }, rhs) {
          const { Fp2: Fp22 } = this;
          if (typeof rhs === "bigint") {
            return {
              c0: Fp22.mul(c0, rhs),
              c1: Fp22.mul(c1, rhs),
              c2: Fp22.mul(c2, rhs)
            };
          }
          const { c0: r0, c1: r1, c2: r2 } = rhs;
          const t0 = Fp22.mul(c0, r0);
          const t1 = Fp22.mul(c1, r1);
          const t2 = Fp22.mul(c2, r2);
          return {
            // t0 + (c1 + c2) * (r1 * r2) - (T1 + T2) * (u + 1)
            c0: Fp22.add(t0, Fp22.mulByNonresidue(Fp22.sub(Fp22.mul(Fp22.add(c1, c2), Fp22.add(r1, r2)), Fp22.add(t1, t2)))),
            // (c0 + c1) * (r0 + r1) - (T0 + T1) + T2 * (u + 1)
            c1: Fp22.add(Fp22.sub(Fp22.mul(Fp22.add(c0, c1), Fp22.add(r0, r1)), Fp22.add(t0, t1)), Fp22.mulByNonresidue(t2)),
            // T1 + (c0 + c2) * (r0 + r2) - T0 + T2
            c2: Fp22.sub(Fp22.add(t1, Fp22.mul(Fp22.add(c0, c2), Fp22.add(r0, r2))), Fp22.add(t0, t2))
          };
        }
        sqr({ c0, c1, c2 }) {
          const { Fp2: Fp22 } = this;
          let t0 = Fp22.sqr(c0);
          let t1 = Fp22.mul(Fp22.mul(c0, c1), _2n4);
          let t3 = Fp22.mul(Fp22.mul(c1, c2), _2n4);
          let t4 = Fp22.sqr(c2);
          return {
            c0: Fp22.add(Fp22.mulByNonresidue(t3), t0),
            // T3 * (u + 1) + T0
            c1: Fp22.add(Fp22.mulByNonresidue(t4), t1),
            // T4 * (u + 1) + T1
            // T1 + (c0 - c1 + c2)² + T3 - T0 - T4
            c2: Fp22.sub(Fp22.sub(Fp22.add(Fp22.add(t1, Fp22.sqr(Fp22.add(Fp22.sub(c0, c1), c2))), t3), t0), t4)
          };
        }
        addN(a, b) {
          return this.add(a, b);
        }
        subN(a, b) {
          return this.sub(a, b);
        }
        mulN(a, b) {
          return this.mul(a, b);
        }
        sqrN(a) {
          return this.sqr(a);
        }
        create(num) {
          return num;
        }
        isValid({ c0, c1, c2 }) {
          const { Fp2: Fp22 } = this;
          return Fp22.isValid(c0) && Fp22.isValid(c1) && Fp22.isValid(c2);
        }
        is0({ c0, c1, c2 }) {
          const { Fp2: Fp22 } = this;
          return Fp22.is0(c0) && Fp22.is0(c1) && Fp22.is0(c2);
        }
        isValidNot0(num) {
          return !this.is0(num) && this.isValid(num);
        }
        neg({ c0, c1, c2 }) {
          const { Fp2: Fp22 } = this;
          return { c0: Fp22.neg(c0), c1: Fp22.neg(c1), c2: Fp22.neg(c2) };
        }
        eql({ c0, c1, c2 }, { c0: r0, c1: r1, c2: r2 }) {
          const { Fp2: Fp22 } = this;
          return Fp22.eql(c0, r0) && Fp22.eql(c1, r1) && Fp22.eql(c2, r2);
        }
        sqrt(_) {
          return notImplemented();
        }
        // Do we need division by bigint at all? Should be done via order:
        div(lhs, rhs) {
          const { Fp2: Fp22 } = this;
          const { Fp: Fp3 } = Fp22;
          return this.mul(lhs, typeof rhs === "bigint" ? Fp3.inv(Fp3.create(rhs)) : this.inv(rhs));
        }
        pow(num, power) {
          return FpPow(this, num, power);
        }
        invertBatch(nums) {
          return FpInvertBatch(this, nums);
        }
        inv({ c0, c1, c2 }) {
          const { Fp2: Fp22 } = this;
          let t0 = Fp22.sub(Fp22.sqr(c0), Fp22.mulByNonresidue(Fp22.mul(c2, c1)));
          let t1 = Fp22.sub(Fp22.mulByNonresidue(Fp22.sqr(c2)), Fp22.mul(c0, c1));
          let t2 = Fp22.sub(Fp22.sqr(c1), Fp22.mul(c0, c2));
          let t4 = Fp22.inv(Fp22.add(Fp22.mulByNonresidue(Fp22.add(Fp22.mul(c2, t1), Fp22.mul(c1, t2))), Fp22.mul(c0, t0)));
          return { c0: Fp22.mul(t4, t0), c1: Fp22.mul(t4, t1), c2: Fp22.mul(t4, t2) };
        }
        // Bytes utils
        fromBytes(b) {
          const { Fp2: Fp22 } = this;
          if (b.length !== this.BYTES)
            throw new Error("fromBytes invalid length=" + b.length);
          const B2 = Fp22.BYTES;
          return {
            c0: Fp22.fromBytes(b.subarray(0, B2)),
            c1: Fp22.fromBytes(b.subarray(B2, B2 * 2)),
            c2: Fp22.fromBytes(b.subarray(2 * B2))
          };
        }
        toBytes({ c0, c1, c2 }) {
          const { Fp2: Fp22 } = this;
          return concatBytes(Fp22.toBytes(c0), Fp22.toBytes(c1), Fp22.toBytes(c2));
        }
        cmov({ c0, c1, c2 }, { c0: r0, c1: r1, c2: r2 }, c) {
          const { Fp2: Fp22 } = this;
          return {
            c0: Fp22.cmov(c0, r0, c),
            c1: Fp22.cmov(c1, r1, c),
            c2: Fp22.cmov(c2, r2, c)
          };
        }
        fromBigSix(t) {
          const { Fp2: Fp22 } = this;
          if (!Array.isArray(t) || t.length !== 6)
            throw new Error("invalid Fp6 usage");
          return {
            c0: Fp22.fromBigTuple(t.slice(0, 2)),
            c1: Fp22.fromBigTuple(t.slice(2, 4)),
            c2: Fp22.fromBigTuple(t.slice(4, 6))
          };
        }
        frobeniusMap({ c0, c1, c2 }, power) {
          const { Fp2: Fp22 } = this;
          return {
            c0: Fp22.frobeniusMap(c0, power),
            c1: Fp22.mul(Fp22.frobeniusMap(c1, power), this.FROBENIUS_COEFFICIENTS_1[power % 6]),
            c2: Fp22.mul(Fp22.frobeniusMap(c2, power), this.FROBENIUS_COEFFICIENTS_2[power % 6])
          };
        }
        mulByFp2({ c0, c1, c2 }, rhs) {
          const { Fp2: Fp22 } = this;
          return {
            c0: Fp22.mul(c0, rhs),
            c1: Fp22.mul(c1, rhs),
            c2: Fp22.mul(c2, rhs)
          };
        }
        mulByNonresidue({ c0, c1, c2 }) {
          const { Fp2: Fp22 } = this;
          return { c0: Fp22.mulByNonresidue(c2), c1: c0, c2: c1 };
        }
        // Sparse multiplication
        mul1({ c0, c1, c2 }, b1) {
          const { Fp2: Fp22 } = this;
          return {
            c0: Fp22.mulByNonresidue(Fp22.mul(c2, b1)),
            c1: Fp22.mul(c0, b1),
            c2: Fp22.mul(c1, b1)
          };
        }
        // Sparse multiplication
        mul01({ c0, c1, c2 }, b0, b1) {
          const { Fp2: Fp22 } = this;
          let t0 = Fp22.mul(c0, b0);
          let t1 = Fp22.mul(c1, b1);
          return {
            // ((c1 + c2) * b1 - T1) * (u + 1) + T0
            c0: Fp22.add(Fp22.mulByNonresidue(Fp22.sub(Fp22.mul(Fp22.add(c1, c2), b1), t1)), t0),
            // (b0 + b1) * (c0 + c1) - T0 - T1
            c1: Fp22.sub(Fp22.sub(Fp22.mul(Fp22.add(b0, b1), Fp22.add(c0, c1)), t0), t1),
            // (c0 + c2) * b0 - T0 + T1
            c2: Fp22.add(Fp22.sub(Fp22.mul(Fp22.add(c0, c2), b0), t0), t1)
          };
        }
      };
      _Field12 = class {
        ORDER;
        BITS;
        BYTES;
        isLE;
        ZERO;
        ONE;
        Fp6;
        FROBENIUS_COEFFICIENTS;
        X_LEN;
        finalExponentiate;
        constructor(Fp62, opts) {
          const { Fp2: Fp22 } = Fp62;
          const { Fp: Fp3 } = Fp22;
          this.Fp6 = Fp62;
          this.ORDER = Fp22.ORDER;
          this.BITS = 2 * Fp62.BITS;
          this.BYTES = 2 * Fp62.BYTES;
          this.isLE = Fp62.isLE;
          this.ZERO = { c0: Fp62.ZERO, c1: Fp62.ZERO };
          this.ONE = { c0: Fp62.ONE, c1: Fp62.ZERO };
          this.FROBENIUS_COEFFICIENTS = calcFrobeniusCoefficients(Fp22, Fp22.NONRESIDUE, Fp3.ORDER, 12, 1, 6)[0];
          this.X_LEN = opts.X_LEN;
          this.finalExponentiate = opts.Fp12finalExponentiate;
        }
        create(num) {
          return num;
        }
        isValid({ c0, c1 }) {
          const { Fp6: Fp62 } = this;
          return Fp62.isValid(c0) && Fp62.isValid(c1);
        }
        is0({ c0, c1 }) {
          const { Fp6: Fp62 } = this;
          return Fp62.is0(c0) && Fp62.is0(c1);
        }
        isValidNot0(num) {
          return !this.is0(num) && this.isValid(num);
        }
        neg({ c0, c1 }) {
          const { Fp6: Fp62 } = this;
          return { c0: Fp62.neg(c0), c1: Fp62.neg(c1) };
        }
        eql({ c0, c1 }, { c0: r0, c1: r1 }) {
          const { Fp6: Fp62 } = this;
          return Fp62.eql(c0, r0) && Fp62.eql(c1, r1);
        }
        sqrt(_) {
          notImplemented();
        }
        inv({ c0, c1 }) {
          const { Fp6: Fp62 } = this;
          let t = Fp62.inv(Fp62.sub(Fp62.sqr(c0), Fp62.mulByNonresidue(Fp62.sqr(c1))));
          return { c0: Fp62.mul(c0, t), c1: Fp62.neg(Fp62.mul(c1, t)) };
        }
        div(lhs, rhs) {
          const { Fp6: Fp62 } = this;
          const { Fp2: Fp22 } = Fp62;
          const { Fp: Fp3 } = Fp22;
          return this.mul(lhs, typeof rhs === "bigint" ? Fp3.inv(Fp3.create(rhs)) : this.inv(rhs));
        }
        pow(num, power) {
          return FpPow(this, num, power);
        }
        invertBatch(nums) {
          return FpInvertBatch(this, nums);
        }
        // Normalized
        add({ c0, c1 }, { c0: r0, c1: r1 }) {
          const { Fp6: Fp62 } = this;
          return {
            c0: Fp62.add(c0, r0),
            c1: Fp62.add(c1, r1)
          };
        }
        sub({ c0, c1 }, { c0: r0, c1: r1 }) {
          const { Fp6: Fp62 } = this;
          return {
            c0: Fp62.sub(c0, r0),
            c1: Fp62.sub(c1, r1)
          };
        }
        mul({ c0, c1 }, rhs) {
          const { Fp6: Fp62 } = this;
          if (typeof rhs === "bigint")
            return { c0: Fp62.mul(c0, rhs), c1: Fp62.mul(c1, rhs) };
          let { c0: r0, c1: r1 } = rhs;
          let t1 = Fp62.mul(c0, r0);
          let t2 = Fp62.mul(c1, r1);
          return {
            c0: Fp62.add(t1, Fp62.mulByNonresidue(t2)),
            // T1 + T2 * v
            // (c0 + c1) * (r0 + r1) - (T1 + T2)
            c1: Fp62.sub(Fp62.mul(Fp62.add(c0, c1), Fp62.add(r0, r1)), Fp62.add(t1, t2))
          };
        }
        sqr({ c0, c1 }) {
          const { Fp6: Fp62 } = this;
          let ab = Fp62.mul(c0, c1);
          return {
            // (c1 * v + c0) * (c0 + c1) - AB - AB * v
            c0: Fp62.sub(Fp62.sub(Fp62.mul(Fp62.add(Fp62.mulByNonresidue(c1), c0), Fp62.add(c0, c1)), ab), Fp62.mulByNonresidue(ab)),
            c1: Fp62.add(ab, ab)
          };
        }
        // NonNormalized stuff
        addN(a, b) {
          return this.add(a, b);
        }
        subN(a, b) {
          return this.sub(a, b);
        }
        mulN(a, b) {
          return this.mul(a, b);
        }
        sqrN(a) {
          return this.sqr(a);
        }
        // Bytes utils
        fromBytes(b) {
          const { Fp6: Fp62 } = this;
          if (b.length !== this.BYTES)
            throw new Error("fromBytes invalid length=" + b.length);
          return {
            c0: Fp62.fromBytes(b.subarray(0, Fp62.BYTES)),
            c1: Fp62.fromBytes(b.subarray(Fp62.BYTES))
          };
        }
        toBytes({ c0, c1 }) {
          const { Fp6: Fp62 } = this;
          return concatBytes(Fp62.toBytes(c0), Fp62.toBytes(c1));
        }
        cmov({ c0, c1 }, { c0: r0, c1: r1 }, c) {
          const { Fp6: Fp62 } = this;
          return {
            c0: Fp62.cmov(c0, r0, c),
            c1: Fp62.cmov(c1, r1, c)
          };
        }
        // Utils
        // toString() {
        //   return '' + 'Fp12(' + this.c0 + this.c1 + '* w');
        // },
        // fromTuple(c: [Fp6, Fp6]) {
        //   return new Fp12(...c);
        // }
        fromBigTwelve(t) {
          const { Fp6: Fp62 } = this;
          return {
            c0: Fp62.fromBigSix(t.slice(0, 6)),
            c1: Fp62.fromBigSix(t.slice(6, 12))
          };
        }
        // Raises to q**i -th power
        frobeniusMap(lhs, power) {
          const { Fp6: Fp62 } = this;
          const { Fp2: Fp22 } = Fp62;
          const { c0, c1, c2 } = Fp62.frobeniusMap(lhs.c1, power);
          const coeff = this.FROBENIUS_COEFFICIENTS[power % 12];
          return {
            c0: Fp62.frobeniusMap(lhs.c0, power),
            c1: Fp62.create({
              c0: Fp22.mul(c0, coeff),
              c1: Fp22.mul(c1, coeff),
              c2: Fp22.mul(c2, coeff)
            })
          };
        }
        mulByFp2({ c0, c1 }, rhs) {
          const { Fp6: Fp62 } = this;
          return {
            c0: Fp62.mulByFp2(c0, rhs),
            c1: Fp62.mulByFp2(c1, rhs)
          };
        }
        conjugate({ c0, c1 }) {
          return { c0, c1: this.Fp6.neg(c1) };
        }
        // Sparse multiplication
        mul014({ c0, c1 }, o0, o1, o4) {
          const { Fp6: Fp62 } = this;
          const { Fp2: Fp22 } = Fp62;
          let t0 = Fp62.mul01(c0, o0, o1);
          let t1 = Fp62.mul1(c1, o4);
          return {
            c0: Fp62.add(Fp62.mulByNonresidue(t1), t0),
            // T1 * v + T0
            // (c1 + c0) * [o0, o1+o4] - T0 - T1
            c1: Fp62.sub(Fp62.sub(Fp62.mul01(Fp62.add(c1, c0), o0, Fp22.add(o1, o4)), t0), t1)
          };
        }
        mul034({ c0, c1 }, o0, o3, o4) {
          const { Fp6: Fp62 } = this;
          const { Fp2: Fp22 } = Fp62;
          const a = Fp62.create({
            c0: Fp22.mul(c0.c0, o0),
            c1: Fp22.mul(c0.c1, o0),
            c2: Fp22.mul(c0.c2, o0)
          });
          const b = Fp62.mul01(c1, o3, o4);
          const e = Fp62.mul01(Fp62.add(c0, c1), Fp22.add(o0, o3), o4);
          return {
            c0: Fp62.add(Fp62.mulByNonresidue(b), a),
            c1: Fp62.sub(e, Fp62.add(a, b))
          };
        }
        // A cyclotomic group is a subgroup of Fp^n defined by
        //   GΦₙ(p) = {α ∈ Fpⁿ : α^Φₙ(p) = 1}
        // The result of any pairing is in a cyclotomic subgroup
        // https://eprint.iacr.org/2009/565.pdf
        // https://eprint.iacr.org/2010/354.pdf
        _cyclotomicSquare({ c0, c1 }) {
          const { Fp6: Fp62 } = this;
          const { Fp2: Fp22 } = Fp62;
          const { c0: c0c0, c1: c0c1, c2: c0c2 } = c0;
          const { c0: c1c0, c1: c1c1, c2: c1c2 } = c1;
          const { first: t3, second: t4 } = Fp22.Fp4Square(c0c0, c1c1);
          const { first: t5, second: t6 } = Fp22.Fp4Square(c1c0, c0c2);
          const { first: t7, second: t8 } = Fp22.Fp4Square(c0c1, c1c2);
          const t9 = Fp22.mulByNonresidue(t8);
          return {
            c0: Fp62.create({
              c0: Fp22.add(Fp22.mul(Fp22.sub(t3, c0c0), _2n4), t3),
              // 2 * (T3 - c0c0)  + T3
              c1: Fp22.add(Fp22.mul(Fp22.sub(t5, c0c1), _2n4), t5),
              // 2 * (T5 - c0c1)  + T5
              c2: Fp22.add(Fp22.mul(Fp22.sub(t7, c0c2), _2n4), t7)
            }),
            // 2 * (T7 - c0c2)  + T7
            c1: Fp62.create({
              c0: Fp22.add(Fp22.mul(Fp22.add(t9, c1c0), _2n4), t9),
              // 2 * (T9 + c1c0) + T9
              c1: Fp22.add(Fp22.mul(Fp22.add(t4, c1c1), _2n4), t4),
              // 2 * (T4 + c1c1) + T4
              c2: Fp22.add(Fp22.mul(Fp22.add(t6, c1c2), _2n4), t6)
            })
          };
        }
        // https://eprint.iacr.org/2009/565.pdf
        _cyclotomicExp(num, n) {
          let z = this.ONE;
          for (let i = this.X_LEN - 1; i >= 0; i--) {
            z = this._cyclotomicSquare(z);
            if (bitGet(n, i))
              z = this.mul(z, num);
          }
          return z;
        }
      };
    }
  });

  // node_modules/@noble/curves/bls12-381.js
  var bls12_381_exports = {};
  __export(bls12_381_exports, {
    bls12_381: () => bls12_381,
    bls12_381_Fr: () => bls12_381_Fr
  });
  function parseMask(bytes) {
    bytes = copyBytes(bytes);
    const mask = bytes[0] & 224;
    const compressed = !!(mask >> 7 & 1);
    const infinity = !!(mask >> 6 & 1);
    const sort = !!(mask >> 5 & 1);
    bytes[0] &= 31;
    return { compressed, infinity, sort, value: bytes };
  }
  function setMask(bytes, mask) {
    if (bytes[0] & 224)
      throw new Error("setMask: non-empty mask");
    if (mask.compressed)
      bytes[0] |= 128;
    if (mask.infinity)
      bytes[0] |= 64;
    if (mask.sort)
      bytes[0] |= 32;
    return bytes;
  }
  function pointG1ToBytes(_c, point, isComp) {
    const { BYTES: L, ORDER: P } = Fp;
    const is0 = point.is0();
    const { x, y } = point.toAffine();
    if (isComp) {
      if (is0)
        return COMPZERO.slice();
      const sort = Boolean(y * _2n5 / P);
      return setMask(numberToBytesBE(x, L), { compressed: true, sort });
    } else {
      if (is0) {
        return concatBytes(Uint8Array.of(64), new Uint8Array(2 * L - 1));
      } else {
        return concatBytes(numberToBytesBE(x, L), numberToBytesBE(y, L));
      }
    }
  }
  function signatureG1ToBytes(point) {
    point.assertValidity();
    const { BYTES: L, ORDER: P } = Fp;
    const { x, y } = point.toAffine();
    if (point.is0())
      return COMPZERO.slice();
    const sort = Boolean(y * _2n5 / P);
    return setMask(numberToBytesBE(x, L), { compressed: true, sort });
  }
  function pointG1FromBytes(bytes) {
    const { compressed, infinity, sort, value } = parseMask(bytes);
    const { BYTES: L, ORDER: P } = Fp;
    if (value.length === 48 && compressed) {
      const compressedValue = bytesToNumberBE(value);
      const x = Fp.create(compressedValue & bitMask(Fp.BITS));
      if (infinity) {
        if (x !== _0n7)
          throw new Error("invalid G1 point: non-empty, at infinity, with compression");
        return { x: _0n7, y: _0n7 };
      }
      const right = Fp.add(Fp.pow(x, _3n5), Fp.create(bls12_381_CURVE_G1.b));
      let y = Fp.sqrt(right);
      if (!y)
        throw new Error("invalid G1 point: compressed point");
      if (y * _2n5 / P !== BigInt(sort))
        y = Fp.neg(y);
      return { x: Fp.create(x), y: Fp.create(y) };
    } else if (value.length === 96 && !compressed) {
      const x = bytesToNumberBE(value.subarray(0, L));
      const y = bytesToNumberBE(value.subarray(L));
      if (infinity) {
        if (x !== _0n7 || y !== _0n7)
          throw new Error("G1: non-empty point at infinity");
        return bls12_381.G1.Point.ZERO.toAffine();
      }
      return { x: Fp.create(x), y: Fp.create(y) };
    } else {
      throw new Error("invalid G1 point: expected 48/96 bytes");
    }
  }
  function signatureG1FromBytes(bytes) {
    const { infinity, sort, value } = parseMask(abytes(bytes, 48, "signature"));
    const P = Fp.ORDER;
    const Point = bls12_381.G1.Point;
    const compressedValue = bytesToNumberBE(value);
    if (infinity)
      return Point.ZERO;
    const x = Fp.create(compressedValue & bitMask(Fp.BITS));
    const right = Fp.add(Fp.pow(x, _3n5), Fp.create(bls12_381_CURVE_G1.b));
    let y = Fp.sqrt(right);
    if (!y)
      throw new Error("invalid G1 point: compressed");
    const aflag = BigInt(sort);
    if (y * _2n5 / P !== aflag)
      y = Fp.neg(y);
    const point = Point.fromAffine({ x, y });
    point.assertValidity();
    return point;
  }
  function pointG2ToBytes(_c, point, isComp) {
    const { BYTES: L, ORDER: P } = Fp;
    const is0 = point.is0();
    const { x, y } = point.toAffine();
    if (isComp) {
      if (is0)
        return concatBytes(COMPZERO, numberToBytesBE(_0n7, L));
      const flag = Boolean(y.c1 === _0n7 ? y.c0 * _2n5 / P : y.c1 * _2n5 / P);
      return concatBytes(setMask(numberToBytesBE(x.c1, L), { compressed: true, sort: flag }), numberToBytesBE(x.c0, L));
    } else {
      if (is0)
        return concatBytes(Uint8Array.of(64), new Uint8Array(4 * L - 1));
      const { re: x0, im: x1 } = Fp2.reim(x);
      const { re: y0, im: y1 } = Fp2.reim(y);
      return concatBytes(numberToBytesBE(x1, L), numberToBytesBE(x0, L), numberToBytesBE(y1, L), numberToBytesBE(y0, L));
    }
  }
  function signatureG2ToBytes(point) {
    point.assertValidity();
    const { BYTES: L } = Fp;
    if (point.is0())
      return concatBytes(COMPZERO, numberToBytesBE(_0n7, L));
    const { x, y } = point.toAffine();
    const { re: x0, im: x1 } = Fp2.reim(x);
    const { re: y0, im: y1 } = Fp2.reim(y);
    const tmp = y1 > _0n7 ? y1 * _2n5 : y0 * _2n5;
    const sort = Boolean(tmp / Fp.ORDER & _1n7);
    const z2 = x0;
    return concatBytes(setMask(numberToBytesBE(x1, L), { sort, compressed: true }), numberToBytesBE(z2, L));
  }
  function pointG2FromBytes(bytes) {
    const { BYTES: L, ORDER: P } = Fp;
    const { compressed, infinity, sort, value } = parseMask(bytes);
    if (!compressed && !infinity && sort || // 00100000
    !compressed && infinity && sort || // 01100000
    sort && infinity && compressed) {
      throw new Error("invalid encoding flag: " + (bytes[0] & 224));
    }
    const slc = (b, from, to) => bytesToNumberBE(b.slice(from, to));
    if (value.length === 96 && compressed) {
      if (infinity) {
        if (value.reduce((p, c) => p !== 0 ? c + 1 : c, 0) > 0) {
          throw new Error("invalid G2 point: compressed");
        }
        return { x: Fp2.ZERO, y: Fp2.ZERO };
      }
      const x_1 = slc(value, 0, L);
      const x_0 = slc(value, L, 2 * L);
      const x = Fp2.create({ c0: Fp.create(x_0), c1: Fp.create(x_1) });
      const right = Fp2.add(Fp2.pow(x, _3n5), bls12_381_CURVE_G2.b);
      let y = Fp2.sqrt(right);
      const Y_bit = y.c1 === _0n7 ? y.c0 * _2n5 / P : y.c1 * _2n5 / P ? _1n7 : _0n7;
      y = sort && Y_bit > 0 ? y : Fp2.neg(y);
      return { x, y };
    } else if (value.length === 192 && !compressed) {
      if (infinity) {
        if (value.reduce((p, c) => p !== 0 ? c + 1 : c, 0) > 0) {
          throw new Error("invalid G2 point: uncompressed");
        }
        return { x: Fp2.ZERO, y: Fp2.ZERO };
      }
      const x1 = slc(value, 0 * L, 1 * L);
      const x0 = slc(value, 1 * L, 2 * L);
      const y1 = slc(value, 2 * L, 3 * L);
      const y0 = slc(value, 3 * L, 4 * L);
      return { x: Fp2.fromBigTuple([x0, x1]), y: Fp2.fromBigTuple([y0, y1]) };
    } else {
      throw new Error("invalid G2 point: expected 96/192 bytes");
    }
  }
  function signatureG2FromBytes(bytes) {
    const { ORDER: P } = Fp;
    const { infinity, sort, value } = parseMask(abytes(bytes));
    const Point = bls12_381.G2.Point;
    const half = value.length / 2;
    if (half !== 48 && half !== 96)
      throw new Error("invalid compressed signature length, expected 96/192 bytes");
    const z1 = bytesToNumberBE(value.slice(0, half));
    const z2 = bytesToNumberBE(value.slice(half));
    if (infinity)
      return Point.ZERO;
    const x1 = Fp.create(z1 & bitMask(Fp.BITS));
    const x2 = Fp.create(z2);
    const x = Fp2.create({ c0: x2, c1: x1 });
    const y2 = Fp2.add(Fp2.pow(x, _3n5), bls12_381_CURVE_G2.b);
    let y = Fp2.sqrt(y2);
    if (!y)
      throw new Error("Failed to find a square root");
    const { re: y0, im: y1 } = Fp2.reim(y);
    const aflag1 = BigInt(sort);
    const isGreater = y1 > _0n7 && y1 * _2n5 / P !== aflag1;
    const is0 = y1 === _0n7 && y0 * _2n5 / P !== aflag1;
    if (isGreater || is0)
      y = Fp2.neg(y);
    const point = Point.fromAffine({ x, y });
    point.assertValidity();
    return point;
  }
  function mapToG1(scalars) {
    const { x, y } = G1_SWU(Fp.create(scalars[0]));
    return isogenyMapG1(x, y);
  }
  function mapToG2(scalars) {
    const { x, y } = G2_SWU(Fp2.fromBigTuple(scalars));
    return isogenyMapG2(x, y);
  }
  var _0n7, _1n7, _2n5, _3n5, _4n3, BLS_X, BLS_X_LEN, bls12_381_CURVE_G1, bls12_381_Fr, Fp, Fp2, Fp6, Fp12, G2psi, G2psi2, hasher_opts, bls12_381_CURVE_G2, COMPZERO, signatureCoders, fields, G1_Point, G2_Point, bls12_hasher_opts, bls12_params, bls12_381, isogenyMapG2, isogenyMapG1, G1_SWU, G2_SWU;
  var init_bls12_381 = __esm({
    "node_modules/@noble/curves/bls12-381.js"() {
      init_sha2();
      init_bls();
      init_modular();
      init_utils2();
      init_hash_to_curve();
      init_tower();
      init_weierstrass();
      _0n7 = BigInt(0);
      _1n7 = BigInt(1);
      _2n5 = BigInt(2);
      _3n5 = BigInt(3);
      _4n3 = BigInt(4);
      BLS_X = BigInt("0xd201000000010000");
      BLS_X_LEN = bitLen(BLS_X);
      bls12_381_CURVE_G1 = {
        p: BigInt("0x1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaab"),
        n: BigInt("0x73eda753299d7d483339d80809a1d80553bda402fffe5bfeffffffff00000001"),
        h: BigInt("0x396c8c005555e1568c00aaab0000aaab"),
        a: _0n7,
        b: _4n3,
        Gx: BigInt("0x17f1d3a73197d7942695638c4fa9ac0fc3688c4f9774b905a14e3a3f171bac586c55e83ff97a1aeffb3af00adb22c6bb"),
        Gy: BigInt("0x08b3f481e3aaa0f1a09e30ed741d8ae4fcf5e095d5d00af600db18cb2c04b3edd03cc744a2888ae40caa232946c5e7e1")
      };
      bls12_381_Fr = Field(bls12_381_CURVE_G1.n, {
        modFromBytes: true
      });
      ({ Fp, Fp2, Fp6, Fp12 } = tower12({
        ORDER: bls12_381_CURVE_G1.p,
        X_LEN: BLS_X_LEN,
        // Finite extension field over irreducible polynominal.
        // Fp(u) / (u² - β) where β = -1
        FP2_NONRESIDUE: [_1n7, _1n7],
        Fp2mulByB: ({ c0, c1 }) => {
          const t0 = Fp.mul(c0, _4n3);
          const t1 = Fp.mul(c1, _4n3);
          return { c0: Fp.sub(t0, t1), c1: Fp.add(t0, t1) };
        },
        Fp12finalExponentiate: (num) => {
          const x = BLS_X;
          const t0 = Fp12.div(Fp12.frobeniusMap(num, 6), num);
          const t1 = Fp12.mul(Fp12.frobeniusMap(t0, 2), t0);
          const t2 = Fp12.conjugate(Fp12._cyclotomicExp(t1, x));
          const t3 = Fp12.mul(Fp12.conjugate(Fp12._cyclotomicSquare(t1)), t2);
          const t4 = Fp12.conjugate(Fp12._cyclotomicExp(t3, x));
          const t5 = Fp12.conjugate(Fp12._cyclotomicExp(t4, x));
          const t6 = Fp12.mul(Fp12.conjugate(Fp12._cyclotomicExp(t5, x)), Fp12._cyclotomicSquare(t2));
          const t7 = Fp12.conjugate(Fp12._cyclotomicExp(t6, x));
          const t2_t5_pow_q2 = Fp12.frobeniusMap(Fp12.mul(t2, t5), 2);
          const t4_t1_pow_q3 = Fp12.frobeniusMap(Fp12.mul(t4, t1), 3);
          const t6_t1c_pow_q1 = Fp12.frobeniusMap(Fp12.mul(t6, Fp12.conjugate(t1)), 1);
          const t7_t3c_t1 = Fp12.mul(Fp12.mul(t7, Fp12.conjugate(t3)), t1);
          return Fp12.mul(Fp12.mul(Fp12.mul(t2_t5_pow_q2, t4_t1_pow_q3), t6_t1c_pow_q1), t7_t3c_t1);
        }
      }));
      ({ G2psi, G2psi2 } = psiFrobenius(Fp, Fp2, Fp2.div(Fp2.ONE, Fp2.NONRESIDUE)));
      hasher_opts = Object.freeze({
        DST: "BLS_SIG_BLS12381G2_XMD:SHA-256_SSWU_RO_NUL_",
        encodeDST: "BLS_SIG_BLS12381G2_XMD:SHA-256_SSWU_RO_NUL_",
        p: Fp.ORDER,
        m: 2,
        k: 128,
        expand: "xmd",
        hash: sha256
      });
      bls12_381_CURVE_G2 = {
        p: Fp2.ORDER,
        n: bls12_381_CURVE_G1.n,
        h: BigInt("0x5d543a95414e7f1091d50792876a202cd91de4547085abaa68a205b2e5a7ddfa628f1cb4d9e82ef21537e293a6691ae1616ec6e786f0c70cf1c38e31c7238e5"),
        a: Fp2.ZERO,
        b: Fp2.fromBigTuple([_4n3, _4n3]),
        Gx: Fp2.fromBigTuple([
          BigInt("0x024aa2b2f08f0a91260805272dc51051c6e47ad4fa403b02b4510b647ae3d1770bac0326a805bbefd48056c8c121bdb8"),
          BigInt("0x13e02b6052719f607dacd3a088274f65596bd0d09920b61ab5da61bbdc7f5049334cf11213945d57e5ac7d055d042b7e")
        ]),
        Gy: Fp2.fromBigTuple([
          BigInt("0x0ce5d527727d6e118cc9cdc6da2e351aadfd9baa8cbdd3a76d429a695160d12c923ac9cc3baca289e193548608b82801"),
          BigInt("0x0606c4a02ea734cc32acd2b02bc28b99cb3e287e85a763af267492ab572e99ab3f370d275cec1da1aaa9075ff05f79be")
        ])
      };
      COMPZERO = setMask(Fp.toBytes(_0n7), { infinity: true, compressed: true });
      signatureCoders = {
        ShortSignature: {
          fromBytes(bytes) {
            return signatureG1FromBytes(abytes(bytes));
          },
          fromHex(hex) {
            return signatureG1FromBytes(hexToBytes(hex));
          },
          toBytes(point) {
            return signatureG1ToBytes(point);
          },
          toRawBytes(point) {
            return signatureG1ToBytes(point);
          },
          toHex(point) {
            return bytesToHex(signatureG1ToBytes(point));
          }
        },
        LongSignature: {
          fromBytes(bytes) {
            return signatureG2FromBytes(abytes(bytes));
          },
          fromHex(hex) {
            return signatureG2FromBytes(hexToBytes(hex));
          },
          toBytes(point) {
            return signatureG2ToBytes(point);
          },
          toRawBytes(point) {
            return signatureG2ToBytes(point);
          },
          toHex(point) {
            return bytesToHex(signatureG2ToBytes(point));
          }
        }
      };
      fields = {
        Fp,
        Fp2,
        Fp6,
        Fp12,
        Fr: bls12_381_Fr
      };
      G1_Point = weierstrass(bls12_381_CURVE_G1, {
        allowInfinityPoint: true,
        Fn: bls12_381_Fr,
        fromBytes: pointG1FromBytes,
        toBytes: pointG1ToBytes,
        // Checks is the point resides in prime-order subgroup.
        // point.isTorsionFree() should return true for valid points
        // It returns false for shitty points.
        // https://eprint.iacr.org/2021/1130.pdf
        isTorsionFree: (c, point) => {
          const beta = BigInt("0x5f19672fdf76ce51ba69c6076a0f77eaddb3a93be6f89688de17d813620a00022e01fffffffefffe");
          const phi = new c(Fp.mul(point.X, beta), point.Y, point.Z);
          const xP = point.multiplyUnsafe(BLS_X).negate();
          const u2P = xP.multiplyUnsafe(BLS_X);
          return u2P.equals(phi);
        },
        // Clear cofactor of G1
        // https://eprint.iacr.org/2019/403
        clearCofactor: (_c, point) => {
          return point.multiplyUnsafe(BLS_X).add(point);
        }
      });
      G2_Point = weierstrass(bls12_381_CURVE_G2, {
        Fp: Fp2,
        allowInfinityPoint: true,
        Fn: bls12_381_Fr,
        fromBytes: pointG2FromBytes,
        toBytes: pointG2ToBytes,
        // https://eprint.iacr.org/2021/1130.pdf
        // Older version: https://eprint.iacr.org/2019/814.pdf
        isTorsionFree: (c, P) => {
          return P.multiplyUnsafe(BLS_X).negate().equals(G2psi(c, P));
        },
        // clear_cofactor_bls12381_g2 from RFC 9380.
        // https://eprint.iacr.org/2017/419.pdf
        // prettier-ignore
        clearCofactor: (c, P) => {
          const x = BLS_X;
          let t1 = P.multiplyUnsafe(x).negate();
          let t2 = G2psi(c, P);
          let t3 = P.double();
          t3 = G2psi2(c, t3);
          t3 = t3.subtract(t2);
          t2 = t1.add(t2);
          t2 = t2.multiplyUnsafe(x).negate();
          t3 = t3.add(t2);
          t3 = t3.subtract(t1);
          const Q = t3.subtract(P);
          return Q;
        }
      });
      bls12_hasher_opts = {
        mapToG1,
        mapToG2,
        hasherOpts: hasher_opts,
        hasherOptsG1: { ...hasher_opts, m: 1, DST: "BLS_SIG_BLS12381G1_XMD:SHA-256_SSWU_RO_NUL_" },
        hasherOptsG2: { ...hasher_opts }
      };
      bls12_params = {
        ateLoopSize: BLS_X,
        // The BLS parameter x for BLS12-381
        xNegative: true,
        twistType: "multiplicative",
        randomBytes
      };
      bls12_381 = bls(fields, G1_Point, G2_Point, bls12_params, bls12_hasher_opts, signatureCoders);
      isogenyMapG2 = isogenyMap(Fp2, [
        // xNum
        [
          [
            "0x5c759507e8e333ebb5b7a9a47d7ed8532c52d39fd3a042a88b58423c50ae15d5c2638e343d9c71c6238aaaaaaaa97d6",
            "0x5c759507e8e333ebb5b7a9a47d7ed8532c52d39fd3a042a88b58423c50ae15d5c2638e343d9c71c6238aaaaaaaa97d6"
          ],
          [
            "0x0",
            "0x11560bf17baa99bc32126fced787c88f984f87adf7ae0c7f9a208c6b4f20a4181472aaa9cb8d555526a9ffffffffc71a"
          ],
          [
            "0x11560bf17baa99bc32126fced787c88f984f87adf7ae0c7f9a208c6b4f20a4181472aaa9cb8d555526a9ffffffffc71e",
            "0x8ab05f8bdd54cde190937e76bc3e447cc27c3d6fbd7063fcd104635a790520c0a395554e5c6aaaa9354ffffffffe38d"
          ],
          [
            "0x171d6541fa38ccfaed6dea691f5fb614cb14b4e7f4e810aa22d6108f142b85757098e38d0f671c7188e2aaaaaaaa5ed1",
            "0x0"
          ]
        ],
        // xDen
        [
          [
            "0x0",
            "0x1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaa63"
          ],
          [
            "0xc",
            "0x1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaa9f"
          ],
          ["0x1", "0x0"]
          // LAST 1
        ],
        // yNum
        [
          [
            "0x1530477c7ab4113b59a4c18b076d11930f7da5d4a07f649bf54439d87d27e500fc8c25ebf8c92f6812cfc71c71c6d706",
            "0x1530477c7ab4113b59a4c18b076d11930f7da5d4a07f649bf54439d87d27e500fc8c25ebf8c92f6812cfc71c71c6d706"
          ],
          [
            "0x0",
            "0x5c759507e8e333ebb5b7a9a47d7ed8532c52d39fd3a042a88b58423c50ae15d5c2638e343d9c71c6238aaaaaaaa97be"
          ],
          [
            "0x11560bf17baa99bc32126fced787c88f984f87adf7ae0c7f9a208c6b4f20a4181472aaa9cb8d555526a9ffffffffc71c",
            "0x8ab05f8bdd54cde190937e76bc3e447cc27c3d6fbd7063fcd104635a790520c0a395554e5c6aaaa9354ffffffffe38f"
          ],
          [
            "0x124c9ad43b6cf79bfbf7043de3811ad0761b0f37a1e26286b0e977c69aa274524e79097a56dc4bd9e1b371c71c718b10",
            "0x0"
          ]
        ],
        // yDen
        [
          [
            "0x1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffa8fb",
            "0x1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffa8fb"
          ],
          [
            "0x0",
            "0x1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffa9d3"
          ],
          [
            "0x12",
            "0x1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaa99"
          ],
          ["0x1", "0x0"]
          // LAST 1
        ]
      ].map((i) => i.map((pair) => Fp2.fromBigTuple(pair.map(BigInt)))));
      isogenyMapG1 = isogenyMap(Fp, [
        // xNum
        [
          "0x11a05f2b1e833340b809101dd99815856b303e88a2d7005ff2627b56cdb4e2c85610c2d5f2e62d6eaeac1662734649b7",
          "0x17294ed3e943ab2f0588bab22147a81c7c17e75b2f6a8417f565e33c70d1e86b4838f2a6f318c356e834eef1b3cb83bb",
          "0xd54005db97678ec1d1048c5d10a9a1bce032473295983e56878e501ec68e25c958c3e3d2a09729fe0179f9dac9edcb0",
          "0x1778e7166fcc6db74e0609d307e55412d7f5e4656a8dbf25f1b33289f1b330835336e25ce3107193c5b388641d9b6861",
          "0xe99726a3199f4436642b4b3e4118e5499db995a1257fb3f086eeb65982fac18985a286f301e77c451154ce9ac8895d9",
          "0x1630c3250d7313ff01d1201bf7a74ab5db3cb17dd952799b9ed3ab9097e68f90a0870d2dcae73d19cd13c1c66f652983",
          "0xd6ed6553fe44d296a3726c38ae652bfb11586264f0f8ce19008e218f9c86b2a8da25128c1052ecaddd7f225a139ed84",
          "0x17b81e7701abdbe2e8743884d1117e53356de5ab275b4db1a682c62ef0f2753339b7c8f8c8f475af9ccb5618e3f0c88e",
          "0x80d3cf1f9a78fc47b90b33563be990dc43b756ce79f5574a2c596c928c5d1de4fa295f296b74e956d71986a8497e317",
          "0x169b1f8e1bcfa7c42e0c37515d138f22dd2ecb803a0c5c99676314baf4bb1b7fa3190b2edc0327797f241067be390c9e",
          "0x10321da079ce07e272d8ec09d2565b0dfa7dccdde6787f96d50af36003b14866f69b771f8c285decca67df3f1605fb7b",
          "0x6e08c248e260e70bd1e962381edee3d31d79d7e22c837bc23c0bf1bc24c6b68c24b1b80b64d391fa9c8ba2e8ba2d229"
        ],
        // xDen
        [
          "0x8ca8d548cff19ae18b2e62f4bd3fa6f01d5ef4ba35b48ba9c9588617fc8ac62b558d681be343df8993cf9fa40d21b1c",
          "0x12561a5deb559c4348b4711298e536367041e8ca0cf0800c0126c2588c48bf5713daa8846cb026e9e5c8276ec82b3bff",
          "0xb2962fe57a3225e8137e629bff2991f6f89416f5a718cd1fca64e00b11aceacd6a3d0967c94fedcfcc239ba5cb83e19",
          "0x3425581a58ae2fec83aafef7c40eb545b08243f16b1655154cca8abc28d6fd04976d5243eecf5c4130de8938dc62cd8",
          "0x13a8e162022914a80a6f1d5f43e7a07dffdfc759a12062bb8d6b44e833b306da9bd29ba81f35781d539d395b3532a21e",
          "0xe7355f8e4e667b955390f7f0506c6e9395735e9ce9cad4d0a43bcef24b8982f7400d24bc4228f11c02df9a29f6304a5",
          "0x772caacf16936190f3e0c63e0596721570f5799af53a1894e2e073062aede9cea73b3538f0de06cec2574496ee84a3a",
          "0x14a7ac2a9d64a8b230b3f5b074cf01996e7f63c21bca68a81996e1cdf9822c580fa5b9489d11e2d311f7d99bbdcc5a5e",
          "0xa10ecf6ada54f825e920b3dafc7a3cce07f8d1d7161366b74100da67f39883503826692abba43704776ec3a79a1d641",
          "0x95fc13ab9e92ad4476d6e3eb3a56680f682b4ee96f7d03776df533978f31c1593174e4b4b7865002d6384d168ecdd0a",
          "0x000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001"
          // LAST 1
        ],
        // yNum
        [
          "0x90d97c81ba24ee0259d1f094980dcfa11ad138e48a869522b52af6c956543d3cd0c7aee9b3ba3c2be9845719707bb33",
          "0x134996a104ee5811d51036d776fb46831223e96c254f383d0f906343eb67ad34d6c56711962fa8bfe097e75a2e41c696",
          "0xcc786baa966e66f4a384c86a3b49942552e2d658a31ce2c344be4b91400da7d26d521628b00523b8dfe240c72de1f6",
          "0x1f86376e8981c217898751ad8746757d42aa7b90eeb791c09e4a3ec03251cf9de405aba9ec61deca6355c77b0e5f4cb",
          "0x8cc03fdefe0ff135caf4fe2a21529c4195536fbe3ce50b879833fd221351adc2ee7f8dc099040a841b6daecf2e8fedb",
          "0x16603fca40634b6a2211e11db8f0a6a074a7d0d4afadb7bd76505c3d3ad5544e203f6326c95a807299b23ab13633a5f0",
          "0x4ab0b9bcfac1bbcb2c977d027796b3ce75bb8ca2be184cb5231413c4d634f3747a87ac2460f415ec961f8855fe9d6f2",
          "0x987c8d5333ab86fde9926bd2ca6c674170a05bfe3bdd81ffd038da6c26c842642f64550fedfe935a15e4ca31870fb29",
          "0x9fc4018bd96684be88c9e221e4da1bb8f3abd16679dc26c1e8b6e6a1f20cabe69d65201c78607a360370e577bdba587",
          "0xe1bba7a1186bdb5223abde7ada14a23c42a0ca7915af6fe06985e7ed1e4d43b9b3f7055dd4eba6f2bafaaebca731c30",
          "0x19713e47937cd1be0dfd0b8f1d43fb93cd2fcbcb6caf493fd1183e416389e61031bf3a5cce3fbafce813711ad011c132",
          "0x18b46a908f36f6deb918c143fed2edcc523559b8aaf0c2462e6bfe7f911f643249d9cdf41b44d606ce07c8a4d0074d8e",
          "0xb182cac101b9399d155096004f53f447aa7b12a3426b08ec02710e807b4633f06c851c1919211f20d4c04f00b971ef8",
          "0x245a394ad1eca9b72fc00ae7be315dc757b3b080d4c158013e6632d3c40659cc6cf90ad1c232a6442d9d3f5db980133",
          "0x5c129645e44cf1102a159f748c4a3fc5e673d81d7e86568d9ab0f5d396a7ce46ba1049b6579afb7866b1e715475224b",
          "0x15e6be4e990f03ce4ea50b3b42df2eb5cb181d8f84965a3957add4fa95af01b2b665027efec01c7704b456be69c8b604"
        ],
        // yDen
        [
          "0x16112c4c3a9c98b252181140fad0eae9601a6de578980be6eec3232b5be72e7a07f3688ef60c206d01479253b03663c1",
          "0x1962d75c2381201e1a0cbd6c43c348b885c84ff731c4d59ca4a10356f453e01f78a4260763529e3532f6102c2e49a03d",
          "0x58df3306640da276faaae7d6e8eb15778c4855551ae7f310c35a5dd279cd2eca6757cd636f96f891e2538b53dbf67f2",
          "0x16b7d288798e5395f20d23bf89edb4d1d115c5dbddbcd30e123da489e726af41727364f2c28297ada8d26d98445f5416",
          "0xbe0e079545f43e4b00cc912f8228ddcc6d19c9f0f69bbb0542eda0fc9dec916a20b15dc0fd2ededda39142311a5001d",
          "0x8d9e5297186db2d9fb266eaac783182b70152c65550d881c5ecd87b6f0f5a6449f38db9dfa9cce202c6477faaf9b7ac",
          "0x166007c08a99db2fc3ba8734ace9824b5eecfdfa8d0cf8ef5dd365bc400a0051d5fa9c01a58b1fb93d1a1399126a775c",
          "0x16a3ef08be3ea7ea03bcddfabba6ff6ee5a4375efa1f4fd7feb34fd206357132b920f5b00801dee460ee415a15812ed9",
          "0x1866c8ed336c61231a1be54fd1d74cc4f9fb0ce4c6af5920abc5750c4bf39b4852cfe2f7bb9248836b233d9d55535d4a",
          "0x167a55cda70a6e1cea820597d94a84903216f763e13d87bb5308592e7ea7d4fbc7385ea3d529b35e346ef48bb8913f55",
          "0x4d2f259eea405bd48f010a01ad2911d9c6dd039bb61a6290e591b36e636a5c871a5c29f4f83060400f8b49cba8f6aa8",
          "0xaccbb67481d033ff5852c1e48c50c477f94ff8aefce42d28c0f9a88cea7913516f968986f7ebbea9684b529e2561092",
          "0xad6b9514c767fe3c3613144b45f1496543346d98adf02267d5ceef9a00d9b8693000763e3b90ac11e99b138573345cc",
          "0x2660400eb2e4f3b628bdd0d53cd76f2bf565b94e72927c1cb748df27942480e420517bd8714cc80d1fadc1326ed06f7",
          "0xe0fa1d816ddc03e6b24255e0d7819c171c40f65e273b853324efcd6356caa205ca2f570f13497804415473a1d634b8f",
          "0x000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001"
          // LAST 1
        ]
      ].map((i) => i.map((j) => BigInt(j))));
      G1_SWU = mapToCurveSimpleSWU(Fp, {
        A: Fp.create(BigInt("0x144698a3b8e9433d693a02c96d4982b0ea985383ee66a8d8e8981aefd881ac98936f8da0e0f97f5cf428082d584c1d")),
        B: Fp.create(BigInt("0x12e2908d11688030018b12e8753eee3b2016c1f0f24f4070a0b9c14fcef35ef55a23215a316ceaa5d1cc48e98e172be0")),
        Z: Fp.create(BigInt(11))
      });
      G2_SWU = mapToCurveSimpleSWU(Fp2, {
        A: Fp2.create({ c0: Fp.create(_0n7), c1: Fp.create(BigInt(240)) }),
        // A' = 240 * I
        B: Fp2.create({ c0: Fp.create(BigInt(1012)), c1: Fp.create(BigInt(1012)) }),
        // B' = 1012 * (1 + I)
        Z: Fp2.create({ c0: Fp.create(BigInt(-2)), c1: Fp.create(BigInt(-1)) })
        // Z: -(2 + I)
      });
    }
  });

  // node_modules/@noble/hashes/hkdf.js
  var hkdf_exports = {};
  __export(hkdf_exports, {
    expand: () => expand,
    extract: () => extract,
    hkdf: () => hkdf
  });
  function extract(hash, ikm, salt) {
    ahash(hash);
    if (salt === void 0)
      salt = new Uint8Array(hash.outputLen);
    return hmac(hash, salt, ikm);
  }
  function expand(hash, prk, info, length = 32) {
    ahash(hash);
    anumber(length, "length");
    const olen = hash.outputLen;
    if (length > 255 * olen)
      throw new Error("Length must be <= 255*HashLen");
    const blocks = Math.ceil(length / olen);
    if (info === void 0)
      info = EMPTY_BUFFER;
    else
      abytes(info, void 0, "info");
    const okm = new Uint8Array(blocks * olen);
    const HMAC = hmac.create(hash, prk);
    const HMACTmp = HMAC._cloneInto();
    const T = new Uint8Array(HMAC.outputLen);
    for (let counter = 0; counter < blocks; counter++) {
      HKDF_COUNTER[0] = counter + 1;
      HMACTmp.update(counter === 0 ? EMPTY_BUFFER : T).update(info).update(HKDF_COUNTER).digestInto(T);
      okm.set(T, olen * counter);
      HMAC._cloneInto(HMACTmp);
    }
    HMAC.destroy();
    HMACTmp.destroy();
    clean(T, HKDF_COUNTER);
    return okm.slice(0, length);
  }
  var HKDF_COUNTER, EMPTY_BUFFER, hkdf;
  var init_hkdf = __esm({
    "node_modules/@noble/hashes/hkdf.js"() {
      init_hmac();
      init_utils();
      HKDF_COUNTER = /* @__PURE__ */ Uint8Array.of(0);
      EMPTY_BUFFER = /* @__PURE__ */ Uint8Array.of();
      hkdf = (hash, ikm, salt, info, length) => expand(hash, extract(hash, ikm, salt), info, length);
    }
  });

  // bls-entry.js
  var require_bls_entry = __commonJS({
    "bls-entry.js"(exports, module) {
      var { bls12_381: bls12_3812 } = (init_bls12_381(), __toCommonJS(bls12_381_exports));
      var { hexToBytes: hexToBytes2 } = (init_utils(), __toCommonJS(utils_exports));
      var { hkdf: hkdf2 } = (init_hkdf(), __toCommonJS(hkdf_exports));
      var { sha256: sha2562 } = (init_sha2(), __toCommonJS(sha2_exports));
      var BLS_ORDER = BigInt(
        "0x73eda753299d7d483339d80809a1d80553bda402fffe5bfeffffffff00000001"
      );
      function deriveMasterSK(seed) {
        let salt = new TextEncoder().encode("BLS-SIG-KEYGEN-SALT-");
        const ikm = new Uint8Array(seed.length + 1);
        ikm.set(seed);
        ikm[seed.length] = 0;
        const L = 48;
        while (true) {
          salt = sha2562(salt);
          const okm = hkdf2(sha2562, ikm, salt, new Uint8Array([0, L]), L);
          let sk = BigInt(0);
          for (let i = 0; i < okm.length; i++) {
            sk = (sk << BigInt(8)) + BigInt(okm[i]);
          }
          sk = sk % BLS_ORDER;
          if (sk !== BigInt(0)) {
            const skBytes = new Uint8Array(32);
            for (let i = 31; i >= 0; i--) {
              skBytes[i] = Number(sk & BigInt(255));
              sk >>= BigInt(8);
            }
            return skBytes;
          }
        }
      }
      var KONTOR_BLS_DST = "BLS_SIG_BLS12381G1_XMD:SHA-256_SSWU_RO_NUL_";
      function sign(messageHex, privateKey, dst) {
        const msgBytes = hexToBytes2(messageHex);
        const effectiveDst = dst || KONTOR_BLS_DST;
        const hashedMsg = bls12_3812.shortSignatures.hash(msgBytes, effectiveDst);
        const sigPoint = bls12_3812.shortSignatures.sign(hashedMsg, privateKey);
        return bls12_3812.shortSignatures.Signature.toHex(sigPoint);
      }
      function getPublicKey(privateKey) {
        const pubPoint = bls12_3812.shortSignatures.getPublicKey(privateKey);
        return pubPoint.toHex();
      }
      var SCHNORR_BINDING_PREFIX = new TextEncoder().encode("KONTOR_XONLY_TO_BLS_V1");
      var BLS_BINDING_PREFIX = new TextEncoder().encode("KONTOR_BLS_TO_XONLY_V1");
      function signBlsBinding(blsPrivateKey, xOnlyPubkeyHex) {
        const xOnlyBytes = hexToBytes2(xOnlyPubkeyHex);
        const msg = new Uint8Array(BLS_BINDING_PREFIX.length + xOnlyBytes.length);
        msg.set(BLS_BINDING_PREFIX);
        msg.set(xOnlyBytes, BLS_BINDING_PREFIX.length);
        const hashedMsg = bls12_3812.shortSignatures.hash(msg, KONTOR_BLS_DST);
        const sigPoint = bls12_3812.shortSignatures.sign(hashedMsg, blsPrivateKey);
        return bls12_3812.shortSignatures.Signature.toHex(sigPoint);
      }
      function schnorrBindingHash(blsPubkeyHex) {
        const blsPubkeyBytes = hexToBytes2(blsPubkeyHex);
        const preimage = new Uint8Array(SCHNORR_BINDING_PREFIX.length + blsPubkeyBytes.length);
        preimage.set(SCHNORR_BINDING_PREFIX);
        preimage.set(blsPubkeyBytes, SCHNORR_BINDING_PREFIX.length);
        return sha2562(preimage);
      }
      module.exports = {
        sign,
        getPublicKey,
        deriveMasterSK,
        signBlsBinding,
        schnorrBindingHash
      };
    }
  });
  return require_bls_entry();
})();
/*! Bundled license information:

@noble/hashes/utils.js:
  (*! noble-hashes - MIT License (c) 2022 Paul Miller (paulmillr.com) *)

@noble/curves/utils.js:
@noble/curves/abstract/modular.js:
@noble/curves/abstract/curve.js:
@noble/curves/abstract/weierstrass.js:
@noble/curves/abstract/bls.js:
@noble/curves/abstract/tower.js:
@noble/curves/bls12-381.js:
  (*! noble-curves - MIT License (c) 2022 Paul Miller (paulmillr.com) *)
*/
