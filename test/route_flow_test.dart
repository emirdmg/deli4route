import 'dart:io';
import 'package:deli4route/core/excel/excel_parser.dart';
import 'package:deli4route/features/routes/models/delivery_stop.dart';
import 'package:deli4route/features/routes/services/route_optimizer.dart';
import 'package:deli4route/features/routes/services/route_storage.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

DeliveryStop stop(int number, double longitude) => DeliveryStop(
  id: 'stop-$number',
  originalNumber: number,
  customerName: 'Müşteri $number',
  address: 'Adres $number',
  latitude: 0,
  longitude: longitude,
);

List<int> numbers(List<DeliveryStop> stops) =>
    stops.map((s) => s.originalNumber).toList();

List<int> workbookBytes(List<List<CellValue?>> rows) {
  final book = Excel.createExcel();
  for (final row in rows) {
    book['Sheet1'].appendRow(row);
  }
  return book.encode()!;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('invalid saved routes cannot be restored', () {
    final data = SavedRoute(
      stops: [stop(1, .01)],
      latitude: 0,
      longitude: 0,
    ).toJson();
    expect(
      () => SavedRoute.fromJson({...data, 'latitude': 91}),
      throwsFormatException,
    );
    expect(
      () => SavedRoute.fromJson({...data, 'version': 2}),
      throwsFormatException,
    );
    expect(
      () => SavedRoute.fromJson({...data, 'stops': []}),
      throwsFormatException,
    );
  });

  test(
    'nearest neighbour visits 2, 3, 1, 5, 4 without changing original numbers',
    () {
      final input = [
        stop(1, .03),
        stop(2, .01),
        stop(3, .02),
        stop(4, .05),
        stop(5, .04),
      ];
      final ordered = RouteOptimizer.nearestFirst(
        input,
        latitude: 0,
        longitude: 0,
      );
      expect(numbers(ordered), [2, 3, 1, 5, 4]);
      expect(numbers(input), [1, 2, 3, 4, 5]);
      expect(ordered.map((s) => s.id).toSet().length, 5);
    },
  );

  test('changing the starting position changes the first stop', () {
    final input = [
      stop(1, .03),
      stop(2, .01),
      stop(3, .02),
      stop(4, .05),
      stop(5, .04),
    ];
    expect(
      numbers(RouteOptimizer.nearestFirst(input, latitude: 0, longitude: .051)),
      [4, 5, 1, 3, 2],
    );
  });

  test('co-located deliveries are retained in stable order', () {
    final input = [stop(1, 0), stop(2, 0), stop(3, .01)];
    expect(
      numbers(RouteOptimizer.nearestFirst(input, latitude: 0, longitude: 0)),
      [1, 2, 3],
    );
  });

  test('missing coordinates cannot silently disappear from a route', () {
    expect(
      () => RouteOptimizer.nearestFirst(
        [
          const DeliveryStop(
            id: 'x',
            originalNumber: 1,
            customerName: 'X',
            address: 'X',
          ),
        ],
        latitude: 0,
        longitude: 0,
      ),
      throwsArgumentError,
    );
  });

  test('empty and single-stop routes are handled', () {
    expect(RouteOptimizer.nearestFirst([], latitude: 0, longitude: 0), isEmpty);
    expect(
      numbers(
        RouteOptimizer.nearestFirst([stop(1, 0)], latitude: 0, longitude: 0),
      ),
      [1],
    );
    expect(RouteOptimizer.distanceMeters(41, 29, 41, 29), 0);
  });

  test(
    'Turkish headers, comma decimal coordinates, blank rows and optional fields',
    () {
      final parsed = ExcelParser.parseBytes(
        workbookBytes([
          [
            TextCellValue('Müşteri Adı'),
            TextCellValue('Adres'),
            TextCellValue('Enlem'),
            TextCellValue('Boylam'),
          ],
          [
            TextCellValue('Ayşe'),
            TextCellValue('Adres A'),
            TextCellValue('41,01'),
            TextCellValue('29,02'),
          ],
          [],
          [
            TextCellValue('Ali'),
            TextCellValue('Adres B'),
            const DoubleCellValue(41.02),
            const DoubleCellValue(29.03),
          ],
        ]),
      );
      expect(parsed.length, 2);
      expect(parsed.first.customerName, 'Ayşe');
      expect(parsed.first.latitude, 41.01);
      expect(parsed.first.phone, isNull);
      expect(numbers(parsed), [1, 2]);
    },
  );

  test('address-only spreadsheets remain available for geocoding', () {
    final parsed = ExcelParser.parseBytes(
      workbookBytes([
        [TextCellValue('address')],
        [TextCellValue('Ankara, Türkiye')],
      ]),
    );
    expect(parsed.single.address, 'Ankara, Türkiye');
    expect(parsed.single.hasCoordinates, isFalse);
  });

  test('invalid coordinates report their spreadsheet row', () {
    expect(
      () => ExcelParser.parseBytes(
        workbookBytes([
          [
            TextCellValue('address'),
            TextCellValue('latitude'),
            TextCellValue('longitude'),
          ],
          [
            TextCellValue('A'),
            const DoubleCellValue(91),
            const DoubleCellValue(29),
          ],
        ]),
      ),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('2. satır'),
        ),
      ),
    );
  });

  test('missing headers and empty imports fail visibly', () {
    expect(
      () => ExcelParser.parseBytes(
        workbookBytes([
          [TextCellValue('name')],
        ]),
      ),
      throwsFormatException,
    );
    expect(
      () => ExcelParser.parseBytes(
        workbookBytes([
          [TextCellValue('address')],
        ]),
      ),
      throwsFormatException,
    );
  });

  test(
    'real sample Excel imports, sorts, saves, completes and restores on restart',
    () async {
      final parsed = ExcelParser.parseBytes(
        File('assets/templates/sample_deliveries.xlsx').readAsBytesSync(),
      );
      final ordered = RouteOptimizer.nearestFirst(
        parsed,
        latitude: 41,
        longitude: 29,
      );
      expect(numbers(ordered), [2, 3, 1, 5, 4]);
      final storage = RouteStorage();
      await storage.save(
        SavedRoute(stops: ordered, latitude: 41, longitude: 29, isDemo: true),
      );
      var restored = (await RouteStorage().load())!;
      expect(numbers(restored.stops), [2, 3, 1, 5, 4]);
      expect(restored.isDemo, isTrue);
      final completed = restored.stops.first.copyWith(completed: true);
      await storage.save(
        SavedRoute(
          stops: [completed, ...restored.stops.skip(1)],
          latitude: completed.latitude!,
          longitude: completed.longitude!,
          isDemo: true,
        ),
      );
      restored = (await RouteStorage().load())!;
      expect(restored.stops.first.completed, isTrue);
      expect(restored.stops.where((s) => !s.completed).first.originalNumber, 3);
      await storage.clear();
      expect(await storage.load(), isNull);
    },
  );
}
