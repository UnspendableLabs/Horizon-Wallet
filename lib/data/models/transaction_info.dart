import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/data/sources/network/api/v2_api.dart' as api;
import 'package:horizon/data/models/transaction_unpacked.dart';

class InfoVerboseMapper {
  static TransactionInfo toDomain(api.InfoVerbose info) {
    return switch (info) {
      api.EnhancedSendInfoVerbose(unpackedData: var u) =>
        TransactionInfoEnhancedSend(
          btcAmountNormalized: info.btcAmountNormalized ?? "",
          hash: "",
          source: info.source,
          destination: info.destination,
          btcAmount: info.btcAmount,
          fee: info.fee,
          data: info.data,
          domain: TransactionInfoDomainLocal(
              raw: "", submittedAt: DateTime.now()), // TODO: this is wrong
          unpackedData: EnhancedSendUnpackedVerboseMapper.toDomain(u),
        ),
      api.IssuanceInfoVerbose(unpackedData: var u) => TransactionInfoIssuance(
          btcAmountNormalized: info.btcAmountNormalized ?? "",
          hash: "",
          source: info.source,
          destination: info.destination,
          btcAmount: info.btcAmount,
          fee: info.fee,
          data: info.data,
          domain: TransactionInfoDomainLocal(
              raw: "", submittedAt: DateTime.now()), // TODO: this is wrong
          unpackedData: IssuanceUnpackedVerboseMapper.toDomain(u),
        ),
      api.DispenserInfoVerbose(unpackedData: var u) => TransactionInfoDispenser(
          btcAmountNormalized: info.btcAmountNormalized ?? "",
          hash: "",
          source: info.source,
          destination: info.destination,
          btcAmount: info.btcAmount,
          fee: info.fee,
          data: info.data,
          domain: TransactionInfoDomainLocal(
              raw: "", submittedAt: DateTime.now()), // TODO: this is wrong
          unpackedData: DispenserUnpackedVerboseMapper.toDomain(u),
        ),
      api.DispenseInfoVerbose(unpackedData: var u) => TransactionInfoDispense(
          btcAmountNormalized: info.btcAmountNormalized ?? "",
          hash: "",
          source: info.source,
          destination: info.destination,
          btcAmount: info.btcAmount,
          fee: info.fee,
          data: info.data,
          domain: TransactionInfoDomainLocal(
              raw: "", submittedAt: DateTime.now()), // TODO: this is wrong
          unpackedData: DispenseUnpackedVerboseMapper.toDomain(u),
        ),
      api.FairmintInfoVerbose(unpackedData: var u) => TransactionInfoFairmint(
          btcAmountNormalized: info.btcAmountNormalized ?? "",
          hash: "",
          source: info.source,
          destination: info.destination,
          btcAmount: info.btcAmount,
          fee: info.fee,
          data: info.data,
          domain: TransactionInfoDomainLocal(
              raw: "", submittedAt: DateTime.now()), // TODO: this is wrong
          unpackedData: FairmintUnpackedVerboseMapper.toDomain(u),
        ),
      api.FairminterInfoVerbose(unpackedData: var u) =>
        TransactionInfoFairminter(
          btcAmountNormalized: info.btcAmountNormalized ?? "",
          hash: "",
          source: info.source,
          destination: info.destination,
          btcAmount: info.btcAmount,
          fee: info.fee,
          data: info.data,
          domain: TransactionInfoDomainLocal(
              raw: "", submittedAt: DateTime.now()), // TODO: this is wrong
          unpackedData: FairminterUnpackedVerboseMapper.toDomain(u),
        ),
      api.OrderInfoVerbose(unpackedData: var u) => TransactionInfoOrder(
          btcAmountNormalized: info.btcAmountNormalized ?? "",
          hash: "",
          source: info.source,
          destination: info.destination,
          btcAmount: info.btcAmount,
          fee: info.fee,
          data: info.data,
          domain: TransactionInfoDomainLocal(
              raw: "", submittedAt: DateTime.now()), // TODO: this is wrong
          unpackedData: OrderUnpackedVerboseMapper.toDomain(u),
        ),
      api.CancelInfoVerbose(unpackedData: var u) => TransactionInfoCancel(
          btcAmountNormalized: info.btcAmountNormalized ?? "",
          hash: "",
          source: info.source,
          destination: info.destination,
          btcAmount: info.btcAmount,
          fee: info.fee,
          data: info.data,
          domain: TransactionInfoDomainLocal(
              raw: "", submittedAt: DateTime.now()), // TODO: this is wrong
          unpackedData: CancelUnpackedVerboseMapper.toDomain(u),
        ),
      api.AttachInfoVerbose(unpackedData: var u) => TransactionInfoAttach(
          btcAmountNormalized: info.btcAmountNormalized ?? "",
          hash: "",
          source: info.source,
          destination: info.destination,
          btcAmount: info.btcAmount,
          fee: info.fee,
          data: info.data,
          domain: TransactionInfoDomainLocal(
              raw: "", submittedAt: DateTime.now()), // TODO: this is wrong
          unpackedData: AttachUnpackedVerboseMapper.toDomain(u),
        ),
      api.DetachInfoVerbose(unpackedData: var u) => TransactionInfoDetach(
          btcAmountNormalized: info.btcAmountNormalized ?? "",
          hash: "",
          source: info.source,
          destination: info.destination,
          btcAmount: info.btcAmount,
          fee: info.fee,
          data: info.data,
          domain: TransactionInfoDomainLocal(
              raw: "", submittedAt: DateTime.now()), // TODO: this is wrong
          unpackedData: DetachUnpackedVerboseMapper.toDomain(u),
        ),
      api.MpmaSendInfoVerbose(unpackedData: var u) => TransactionInfoMpmaSend(
          btcAmountNormalized: info.btcAmountNormalized ?? "",
          hash: "",
          source: info.source,
          destination: info.destination,
          btcAmount: info.btcAmount,
          fee: info.fee,
          data: info.data,
          domain: TransactionInfoDomainLocal(
              raw: "", submittedAt: DateTime.now()), // TODO: this is wrong
          unpackedData: MpmaSendUnpackedVerboseMapper.toDomain(u),
        ),
      api.MoveToUtxoInfoVerbose() => TransactionInfoMoveToUtxo(
          btcAmountNormalized: info.btcAmountNormalized ?? "",
          hash: "",
          source: info.source,
          destination: info.destination,
          btcAmount: info.btcAmount,
          fee: info.fee,
          data: info.data,
          domain: TransactionInfoDomainLocal(
              raw: "", submittedAt: DateTime.now()), // TODO: this is wrong
        ),
      api.AssetDestructionInfoVerbose(unpackedData: var u) =>
        TransactionInfoAssetDestruction(
          btcAmountNormalized: info.btcAmountNormalized ?? "",
          hash: "",
          source: info.source,
          destination: info.destination,
          btcAmount: info.btcAmount,
          fee: info.fee,
          data: info.data,
          domain: TransactionInfoDomainLocal(
              raw: "", submittedAt: DateTime.now()), // TODO: this is wrong
          unpackedData: AssetDestructionUnpackedVerboseMapper.toDomain(u),
        ),
      api.SweepInfoVerbose(unpackedData: var u) => TransactionInfoSweep(
          btcAmountNormalized: info.btcAmountNormalized ?? "",
          hash: "",
          source: info.source,
          destination: info.destination,
          btcAmount: info.btcAmount,
          fee: info.fee,
          data: info.data,
          domain: TransactionInfoDomainLocal(
              raw: "", submittedAt: DateTime.now()), // TODO: this is wrong
          unpackedData: SweepUnpackedVerboseMapper.toDomain(u),
        ),
      _ => TransactionInfo(
          btcAmountNormalized: info.btcAmountNormalized ?? "",
          hash: "",
          domain: TransactionInfoDomainLocal(
              raw: "", submittedAt: DateTime.now()), // TODO: this is wrong
          source: info.source,
          destination: info.destination,
          btcAmount: info.btcAmount,
          fee: info.fee,
          data: info.data,
        )
    };
  }
}
