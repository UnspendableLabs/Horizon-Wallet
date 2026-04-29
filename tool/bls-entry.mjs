// esbuild entry for the BLS bundle consumed by the Flutter web app.
//
// Re-exports the BLS primitives from `@unspendablelabs/kontor-portal-client`
// (the canonical implementation of the Kontor PoP / BLS signature primitives)
// under the `__horizon_bls__` IIFE global produced by `tool/build_extension.dart`
// and consumed by `lib/js/bls.dart`. Adding a name here makes it available
// to Dart via `@JS('__horizon_bls__')`.

export {
  sign,
  getPublicKey,
  deriveMasterSK,
  deriveBlsKey,
  signBlsBinding,
  schnorrBindingHash,
  KONTOR_BLS_DST,
} from "@unspendablelabs/kontor-portal-client/bls";
