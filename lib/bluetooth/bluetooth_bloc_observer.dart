import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

class BluetoothBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    if (kDebugMode) {
      debugPrint('onEvent -- bloc: ${bloc.runtimeType}, event: $event');
    }
    super.onEvent(bloc, event);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    if (kDebugMode) {
      debugPrint('onChange -- bloc: ${bloc.runtimeType}, change: $change');
    }
    super.onChange(bloc, change);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    if (kDebugMode) {
      debugPrint(
        'onTransition -- bloc: ${bloc.runtimeType}, transition: $transition',
      );
    }
    super.onTransition(bloc, transition);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('onError -- bloc: ${bloc.runtimeType}, error: $error');
    }
    super.onError(bloc, error, stackTrace);
  }
}
