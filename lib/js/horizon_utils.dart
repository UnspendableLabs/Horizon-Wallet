@JS('horizon_utils')
library;

import 'dart:js_interop';
import 'package:horizon/js/bitcoin.dart';

@JS("countSigOps")
external int countSigOps(Transaction transaction);
