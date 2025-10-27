// import 'package:flutter_bloc/flutter_bloc.dart';

// part 'preferences_state.dart';

// class PreferencesCubit extends Cubit<PreferencesState> {
//   PreferencesCubit()
//     : super(
//         PreferencesState(
//           hapticFeedback: true,
//           wakeUpAlarm: true,
//           ledFeedback: true,
//           activeTab: 'Home',
//         ),
//       );

//   void toggleHapticFeedback(bool value) =>
//       emit(state.copyWith(hapticFeedback: value));

//   void toggleWakeUpAlarm(bool value) =>
//       emit(state.copyWith(wakeUpAlarm: value));

//   void toggleLedFeedback(bool value) =>
//       emit(state.copyWith(ledFeedback: value));

//   void updateActiveTab(String label) => emit(state.copyWith(activeTab: label));
// }

//============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';

part 'preferences_state.dart';

class PreferencesCubit extends Cubit<PreferencesState> {
  PreferencesCubit()
      : super(
          PreferencesState(
            hapticFeedback: true,
            wakeUpAlarm: true,
            ledFeedback: true,
            activeTab: 'Home',
          ),
        );

  void toggleHapticFeedback(bool value) =>
      emit(state.copyWith(hapticFeedback: value));

  void toggleWakeUpAlarm(bool value) =>
      emit(state.copyWith(wakeUpAlarm: value));

  void toggleLedFeedback(bool value) =>
      emit(state.copyWith(ledFeedback: value));

  void updateActiveTab(String label) => emit(state.copyWith(activeTab: label));
}
