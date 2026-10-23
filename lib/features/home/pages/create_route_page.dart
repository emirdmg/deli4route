import 'package:deli4route/core/geocoding/geocoding_service.dart';
import 'package:deli4route/core/services/directory_file.dart';
import 'package:deli4route/features/routes/models/delivery_stop.dart';
import 'package:deli4route/features/routes/pages/location_picker_page.dart';
import 'package:flutter/material.dart';
import 'package:deli4route/core/theme/app_theme.dart';
import 'package:deli4route/core/widgets/route_ui.dart';
import 'package:latlong2/latlong.dart';

class CreateRoutePage extends StatefulWidget {
  final LatLng origin;
  final List<DeliveryStop>? initialStops;

  const CreateRoutePage({super.key, required this.origin, this.initialStops});

  @override
  State<CreateRoutePage> createState() => _CreateRoutePageState();
}

class _CreateRoutePageState extends State<CreateRoutePage> {
  List<DeliveryStop> _stops = [];
  final Map<String, String> _errors = {};
  bool _busy = false;
  bool _cancelRequested = false;
  bool _confirmed = false;
  int _processed = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialStops != null) {
      _stops = List.of(widget.initialStops!);
      _resolve();
    }
  }

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _import() async {
    setState(() => _busy = true);
    try {
      final stops = await pickExcelFile();
      if (!mounted) return;
      if (stops == null) {
        setState(() => _busy = false);
        return;
      }
      setState(() {
        _stops = stops;
        _confirmed = false;
        _errors.clear();
      });
      await _resolve();
    } catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      _message(
        error is FormatException
            ? error.message
            : 'Excel okunamadı. Geçerli bir .xlsx dosyası seçin.',
      );
    }
  }

  Future<void> _resolve() async {
    setState(() {
      _busy = true;
      _cancelRequested = false;
      _processed = 0;
    });
    for (var i = 0; i < _stops.length; i++) {
      if (!mounted || _cancelRequested) break;
      final stop = _stops[i];
      if (!stop.hasCoordinates) {
        try {
          final coordinates = await GeocodingService.getLatLngFromAddress(
            stop.address,
          );
          if (!mounted || _cancelRequested) break;
          _stops[i] = stop.copyWith(
            latitude: coordinates['lat'],
            longitude: coordinates['lng'],
          );
          _errors.remove(stop.id);
        } catch (error) {
          if (!mounted || _cancelRequested) break;
          _errors[stop.id] = error is FormatException
              ? error.message
              : 'Konum bulunamadı. Haritadan konum seçebilirsiniz.';
        }
      }
      if (mounted) setState(() => _processed = i + 1);
    }
    if (!mounted) return;
    setState(() => _busy = false);
  }

  Future<void> _editLocation(int index) async {
    final stop = _stops[index];
    final point = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerPage(
          title: 'Excel #${stop.originalNumber} · Konum düzelt',
          initialPoint: stop.hasCoordinates
              ? LatLng(stop.latitude!, stop.longitude!)
              : widget.origin,
        ),
      ),
    );
    if (!mounted || point == null) return;
    setState(() {
      _stops[index] = stop.copyWith(
        latitude: point.latitude,
        longitude: point.longitude,
      );
      _errors.remove(stop.id);
      _confirmed = false;
    });
  }

  Future<void> _template() async {
    try {
      final box = context.findRenderObject() as RenderBox?;
      await downloadExcelTemplate(
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      );
    } catch (_) {
      _message('Şablon paylaşılamadı. Lütfen tekrar deneyin.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final missing = _stops.where((stop) => !stop.hasCoordinates).length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Durakları ekle'),
        actions: [
          if (!_busy && _stops.isNotEmpty)
            TextButton(
              onPressed: _import,
              child: const Text('Dosyayı değiştir'),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  Row(
                    children: [
                      _step('1', 'Excel yükle', _stops.isEmpty),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: RouteColors.muted,
                        ),
                      ),
                      _step('2', 'Konumları kontrol et', _stops.isNotEmpty),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _stops.isEmpty
                        ? 'Durakların, tek dosyada.'
                        : 'Son bir konum kontrolü.',
                    style: const TextStyle(
                      fontSize: 27,
                      height: 1.15,
                      letterSpacing: -.8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _stops.isEmpty
                        ? 'Excel dosyanı yükle. Ziyaret sırasını birlikte oluşturalım.'
                        : 'Her durağın doğru yerde olduğundan emin ol. Düzeltmek için durağa dokun.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: RouteColors.muted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 22),
                  if (_busy) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _stops.isEmpty
                                  ? 'Dosya açılıyor…'
                                  : 'Konumlar hazırlanıyor: $_processed / ${_stops.length}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 14),
                            LinearProgressIndicator(
                              value: _stops.isEmpty
                                  ? null
                                  : _processed / _stops.length,
                              minHeight: 5,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _cancelRequested
                                    ? null
                                    : () => setState(
                                        () => _cancelRequested = true,
                                      ),
                                child: Text(
                                  _cancelRequested ? 'Durduruluyor…' : 'Durdur',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_stops.isEmpty) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const RouteIllustration(),
                            const SizedBox(height: 24),
                            const Text(
                              'Teslimat listen burada başlar',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Adreslerini içeren .xlsx dosyasını seç.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: RouteColors.muted,
                              ),
                            ),
                            const SizedBox(height: 22),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _busy ? null : _import,
                                icon: const Icon(
                                  Icons.upload_file_rounded,
                                  size: 20,
                                ),
                                label: const Text('Excel dosyası seç'),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: _busy ? null : _template,
                              icon: const Icon(
                                Icons.file_download_outlined,
                                size: 18,
                              ),
                              label: const Text('Excel şablonunu paylaş'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Card(
                      child: ExpansionTile(
                        shape: Border(),
                        collapsedShape: Border(),
                        leading: Icon(Icons.table_chart_outlined, size: 21),
                        title: Text(
                          'Dosya nasıl olmalı?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(18, 0, 18, 18),
                            child: Text(
                              'address / adres sütunu yeterli. İstersen customer_name, phone, note ve latitude / longitude ekle.\n\nExcel numaraları sıralama sonrasında korunur. CSV ve eski .xls dosyalarını önce .xlsx olarak kaydet.\n\nAdres çözümleme internet gerektirir ve cihaz servisinin sınırlarına tabidir.',
                              style: TextStyle(
                                fontSize: 13,
                                color: RouteColors.muted,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${_stops.length} teslimat durağı',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        RouteBadge(
                          missing == 0
                              ? 'Konumlar hazır'
                              : '$missing konum eksik',
                          icon: missing == 0
                              ? Icons.check_circle_outline
                              : Icons.location_off_outlined,
                          foreground: missing == 0
                              ? RouteColors.green
                              : RouteColors.orange,
                          background: missing == 0
                              ? RouteColors.greenSoft
                              : RouteColors.orangeSoft,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    for (var index = 0; index < _stops.length; index++) ...[
                      _reviewCard(index),
                      const SizedBox(height: 10),
                    ],
                  ],
                ],
              ),
            ),
            if (_stops.isNotEmpty)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: RouteColors.line)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_busy && missing > 0) ...[
                      Text(
                        '$missing durağın konumu eksik. Haritadan düzeltin veya tekrar deneyin.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: RouteColors.orange,
                        ),
                      ),
                      TextButton(
                        onPressed: _resolve,
                        child: const Text('Eksik adresleri tekrar çözümle'),
                      ),
                    ],
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _confirmed,
                      onChanged: !_busy && missing == 0
                          ? (value) =>
                                setState(() => _confirmed = value ?? false)
                          : null,
                      title: const Text(
                        'Durakların konumlarını kontrol ettim.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: !_busy && missing == 0 && _confirmed
                            ? () => Navigator.pop(
                                context,
                                List<DeliveryStop>.of(_stops),
                              )
                            : null,
                        icon: const Icon(Icons.route_rounded, size: 19),
                        label: Text('${_stops.length} durağı sırala'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _step(String number, String label, bool active) => Flexible(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? RouteColors.ink : RouteColors.line,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: TextStyle(
              color: active ? Colors.white : RouteColors.muted,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: active ? RouteColors.ink : RouteColors.muted,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _reviewCard(int index) {
    final stop = _stops[index];
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: _busy ? null : () => _editLocation(index),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 35,
                height: 35,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: RouteColors.background,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  '${stop.originalNumber}'.padLeft(2, '0'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stop.customerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      stop.address,
                      style: const TextStyle(
                        fontSize: 13,
                        color: RouteColors.muted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          stop.hasCoordinates
                              ? Icons.check_circle_outline_rounded
                              : Icons.error_outline_rounded,
                          size: 14,
                          color: stop.hasCoordinates
                              ? RouteColors.green
                              : RouteColors.orange,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            stop.hasCoordinates
                                ? '${stop.latitude!.toStringAsFixed(5)}, ${stop.longitude!.toStringAsFixed(5)}'
                                : _errors[stop.id] ?? 'Konum bekleniyor',
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.4,
                              color: stop.hasCoordinates
                                  ? RouteColors.green
                                  : RouteColors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Haritada kontrol et / düzelt',
                onPressed: _busy ? null : () => _editLocation(index),
                icon: const Icon(Icons.edit_location_alt_outlined, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: RouteColors.background,
                  foregroundColor: RouteColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
