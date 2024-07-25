import 'package:equatable/equatable.dart';


class DisplayTransaction  extends Equatable  {

  final String hash;
  const DisplayTransaction({required this.hash});

  @override
  List<Object> get props => [hash];
  

}
