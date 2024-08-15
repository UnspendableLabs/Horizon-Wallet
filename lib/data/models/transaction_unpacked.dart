import "package:horizon/data/sources/network/api/v2_api.dart" as api;
import "package:horizon/domain/entities/transaction_unpacked.dart";

// extension TransactionUnpackedMapper on api.TransactionUnpacked {
//   TransactionUnpacked toDomain() {
//     switch (messageType) {
//       case "enhanced_send":
//         return EnhancedSendUnpackedMapper.toDomain(this as api.EnhancedSendUnpacked);
//       default:
//         return TransactionUnpacked(
//           messageType: messageType,
//         );
//     }
//   }
// }
//
//

extension ToApi on TransactionUnpacked {
  api.TransactionUnpacked toApi() {
    switch (runtimeType) {
      case EnhancedSendUnpacked:
        return (this as EnhancedSendUnpacked).toApi();
      default:
        throw UnimplementedError();
    }
  }
}
