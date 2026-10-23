import 'package:deli4route/features/home/pages/create_route_page.dart';
import 'package:deli4route/core/theme/app_theme.dart';
import 'package:deli4route/features/navigation/pages/route_page.dart';
import 'package:deli4route/features/routes/models/delivery_stop.dart';
import 'package:deli4route/features/routes/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeniedLocation extends LocationService {
  @override
  Future<Position> current() async => throw const FormatException(
    'Konum izni verilmedi. Başlangıç seçebilirsiniz.',
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('denied GPS leaves a usable importer and manual starting point', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: RoutePage(locationService: DeniedLocation()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Excel’den rota oluştur'), findsOneWidget);
    expect(find.text('Başlangıç seç'), findsOneWidget);
    expect(find.textContaining('Konum izni verilmedi'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('small screens keep the importer reachable with larger text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: RoutePage(locationService: DeniedLocation()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Excel’den rota oluştur'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Excel’den rota oluştur').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'coordinate imports require review before returning the stop list',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      List<DeliveryStop>? result;
      const stops = [
        DeliveryStop(
          id: 'row-2',
          originalNumber: 1,
          customerName: 'Örnek',
          address: 'Test noktası',
          latitude: 41,
          longitude: 29,
        ),
      ];
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await Navigator.push<List<DeliveryStop>>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateRoutePage(
                        origin: LatLng(41, 29),
                        initialStops: stops,
                      ),
                    ),
                  );
                },
                child: const Text('İçe aktar'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('İçe aktar'));
      await tester.pumpAndSettle();
      final submit = find.widgetWithText(FilledButton, '1 durağı sırala');
      expect(tester.widget<FilledButton>(submit).onPressed, isNull);
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(tester.widget<FilledButton>(submit).onPressed, isNotNull);
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(result?.single.id, 'row-2');
      expect(tester.takeException(), isNull);
    },
  );
}
