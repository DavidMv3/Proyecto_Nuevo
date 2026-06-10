import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mateandina/main.dart';
import 'package:mateandina/presentation/providers/player_profile_provider.dart';
import 'package:mateandina/data/datasources/player_profile_local_datasource.dart';
import 'package:mateandina/domain/entities/player_profile_entity.dart';

class FakePlayerProfileLocalDatasource extends PlayerProfileLocalDatasource {
  @override
  Future<void> init() async {}

  @override
  PlayerProfileEntity load() {
    return const PlayerProfileEntity(
      availableCoins: 100,
      highestUnlockedLevel: 1,
      lastPlayedLevel: 0,
      lastPlayedStepIndex: 0,
      lastPlayedExerciseId: '',
      completedExerciseIds: [],
      unlockedAccessoryIds: [],
      ownedPartIds: [],
      equippedPartIds: [],
    );
  }

  @override
  Future<void> save(PlayerProfileEntity profile) async {}
}

void main() {
  testWidgets('App smoke test - title is visible', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playerProfileDatasourceProvider.overrideWithValue(FakePlayerProfileLocalDatasource()),
        ],
        child: const MateAndinaApp(),
      ),
    );

    // Verify that the title 'MateAndina' is visible on the home screen
    expect(find.text('MateAndina'), findsOneWidget);
  });
}
