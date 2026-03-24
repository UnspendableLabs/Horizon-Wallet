# BLS Private Key Export

## Requesting an export from a connected dApp (RPC)

When a user is connected to Horizon Wallet, any site can request the
encrypted BLS private key via the injected provider.

### JavaScript (dApp side)

```js
const response = await window.HorizonWalletProvider.request(
  'exportEncryptedBlsPrivateKey',
);

const hex = response.result.encryptedBlsPrivateKey;
```

The call opens the wallet popup where the user:

1. Enters their **wallet password** (if password-protected operations are
   enabled in wallet settings).
2. Chooses an **export password** used to encrypt the key blob.
3. Clicks **Export BLS Key**.

On success the promise resolves with `{ result: { encryptedBlsPrivateKey } }`
where `encryptedBlsPrivateKey` is the hex-encoded encrypted payload described
below. If the user closes the popup without exporting, the promise rejects
with an error.

### Example button

```html
<button id="get-bls-key">Get BLS Private Key</button>
<script>
  document.getElementById('get-bls-key').addEventListener('click', async () => {
    try {
      const { result } = await window.HorizonWalletProvider.request(
        'exportEncryptedBlsPrivateKey',
      );
      console.log('Encrypted BLS key:', result.encryptedBlsPrivateKey);
    } catch (err) {
      console.error('Export cancelled or failed', err);
    }
  });
</script>
```

---

## Decrypting an exported BLS private key blob (Rust / CLI)

Concise reference for implementing decryption outside the wallet. Sources: `lib/data/services/encryption_service/encryption_service_web.dart`, `web/encryption_worker.js`, `lib/domain/usecases/export_encrypted_bls_private_key.dart`, `tool/bls-entry.js`.

## Input

The wallet returns a **hex string** that encodes the **UTF-8 bytes** of the encrypted payload string (the same string the web encryption layer uses, starting with `A2::`). It is **not** raw ciphertext bytes—decode hex first, then interpret as UTF-8 text.

## Decryption steps

1. **Hex-decode** the export to get UTF-8 bytes, then decode as **UTF-8** to a `String`.
2. If the string does not start with **`A2::`**, reject or treat as wrong format.
3. **Strip** the `A2::` prefix and **`split` on `::`**. You must get **exactly four** segments (same as `decrypt` in `encryption_service_web.dart`).

### Segment layout (after removing `A2::`)

| Index | Content |
|-------|---------|
| 0 | Argon2 metadata fragment `v=19` (from the encoded hash; informational) |
| 1 | Parameter string `m=65536,t=6,p=4` (informational; use fixed params below when hashing) |
| 2 | **Salt**, standard base64 (decode to bytes—length 16 in current wallet code) |
| 3 | **IV + ciphertext**, concatenated as base64: **first 24 characters** = IV, **remainder** = AES ciphertext (both standard base64; IV decodes to **16 bytes**) |

The Dart code takes `iv = base64Decode(segment3[0..24])` and decrypts `decrypt64(segment3[24..])` with AES-256-CBC.

### Key derivation (Argon2id)

Match `hashPassword` in `web/encryption_worker.js`:

| Parameter | Value |
|-----------|--------|
| Algorithm | Argon2id |
| Memory (`m`) | **65536** KiB (64 MiB) |
| Iterations (`t`) | **6** |
| Parallelism (`p`) | **4** |
| Hash length | **32** bytes (AES-256 key) |
| Password | UTF-8 bytes of the user's export password |
| Salt | Bytes from segment 2 (decoded from base64) |

Use the **32-byte** digest as the AES key (not the full PHC `$argon2id$...` string). If you parse the PHC string instead, the **last `$`-separated field** is the raw hash in base64; pad base64 to a multiple of four before decoding (Dart uses `normalizeB64` for that).

### AES decryption

- **AES-256-CBC** with the Argon2-derived key and IV from segment 3 (first 24 base64 chars → 16-byte IV).
- Ciphertext: base64-decode the substring after those 24 characters.
- Padding: **PKCS#7**, as used by the Dart `encrypt` package.

### Plaintext

The decrypted UTF-8 string is a **hex encoding of the 32-byte BLS master private key** (64 hex characters, lowercase or as produced by the app). Validate length and hex if you want strict parsing.

## BLS key vs wallet seed (derivation)

The exported key is the **derived** BLS master secret key, not the raw mnemonic seed. Horizon/Kontor-style derivation from a seed is implemented in **`tool/bls-entry.js`** as `deriveMasterSK(seed)`:

- Salt starts as UTF-8 **`BLS-SIG-KEYGEN-SALT-`** (EIP-2333 style).
- Loop: `salt = SHA256(salt)`, then HKDF-SHA256 with `ikm = seed || 0x00`, `info = [0, L]` with `L = 48`, reduce modulo the BLS12-381 scalar order; repeat until non-zero; serialize as **32-byte** big-endian.

To verify a decryption against an expected seed, derive `deriveMasterSK(seed)` and compare to the hex you decrypted.
