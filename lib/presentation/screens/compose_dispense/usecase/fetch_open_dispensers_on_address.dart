import 'package:horizon/domain/entities/dispenser.dart';
import 'package:horizon/domain/repositories/dispenser_repository.dart';
import 'package:horizon/core/logging/logger.dart';

class FetchOpenDispensersOnAddressUseCase {
  final DispenserRepository dispenserRepository;
  final Logger? logger;

  FetchOpenDispensersOnAddressUseCase(
      {required this.dispenserRepository, this.logger});

  // for now we just abstract away task either here
  Future<List<Dispenser>> call(String address) async {
    final result =
        await dispenserRepository.getDispensersByAddress(address).run();
    return result.fold(
      (error) {
        throw FetchOpenDispensersOnAddressException(error);
      },
      (dispensers) => dispensers.isNotEmpty
          ? dispensers
          : throw FetchOpenDispensersOnAddressException(
              "No dispensers at this address"),
    );
  }
}

class FetchOpenDispensersOnAddressException implements Exception {
  final String message;
  FetchOpenDispensersOnAddressException(this.message);

  @override
  String toString() => 'FetchOpenDispensersOnAddressException: $message';
}
