import 'package:deli4route/core/excel/excel_parser.dart';
import 'package:deli4route/features/home/pages/create_route_page.dart';
import 'package:deli4route/features/routes/models/delivery_stop.dart';
import 'package:deli4route/features/routes/pages/location_picker_page.dart';
import 'package:deli4route/features/routes/services/location_service.dart';
import 'package:deli4route/features/routes/services/navigation_service.dart';
import 'package:deli4route/features/routes/services/route_optimizer.dart';
import 'package:deli4route/features/routes/services/route_storage.dart';
import 'package:deli4route/features/routes/widgets/route_map.dart';
import 'package:flutter/material.dart';
import 'package:deli4route/core/theme/app_theme.dart';
import 'package:deli4route/core/widgets/route_ui.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class RoutePage extends StatefulWidget {
  final LocationService? locationService;
  const RoutePage({super.key, this.locationService});

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  static const _demoOrigin = LatLng(41.0, 29.0);
  final _storage = RouteStorage();
  final _navigation = NavigationService();
  SavedRoute? _route;
  LatLng? _origin;
  String? _locationError;
  bool _loading = true;
  bool _locating = false;
  bool _saving = false;
  bool _manualOrigin = false;

  List<DeliveryStop> get _pending =>
      _route?.stops.where((stop) => !stop.completed).toList() ?? [];

  @override
  void initState() {
    super.initState();
    _restore();
  }

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _restore() async {
    try {
      final saved = await _storage.load();
      if (!mounted) return;
      setState(() {
        _route = saved;
        if (saved != null) _origin = LatLng(saved.latitude, saved.longitude);
      });
    } catch (_) {
      _message('Kayıtlı rota okunamadı. Yeni bir Excel yükleyebilirsiniz.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
    if (mounted && _route == null) await _locate();
  }

  Future<LatLng?> _locate({bool reorder = false}) async {
    if (_locating) return _origin;
    setState(() => _locating = true);
    try {
      final position = await (widget.locationService ?? LocationService())
          .current();
      if (!mounted) return null;
      final point = LatLng(position.latitude, position.longitude);
      setState(() {
        _origin = point;
        _locationError = null;
        _manualOrigin = false;
      });
      if (reorder && _route != null) await _reorder(point);
      return point;
    } catch (error) {
      if (mounted) {
        setState(
          () => _locationError = error is FormatException
              ? error.message
              : 'Güncel konum alınamadı. Tekrar deneyin veya başlangıcı haritadan seçin.',
        );
      }
      return null;
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<LatLng?> _chooseOrigin({bool reorder = true}) async {
    final point = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerPage(
          initialPoint: _origin ?? _demoOrigin,
          title: 'Rota başlangıcını seç',
        ),
      ),
    );
    if (!mounted || point == null) return null;
    setState(() {
      _origin = point;
      _locationError = null;
      _manualOrigin = true;
    });
    if (reorder && _route != null) await _reorder(point);
    return point;
  }

  Future<void> _save(SavedRoute next) async {
    await _storage.save(next);
    if (!mounted) return;
    setState(() {
      _route = next;
      _origin = LatLng(next.latitude, next.longitude);
    });
  }

  Future<void> _reorder(LatLng point) async {
    final route = _route;
    if (route == null || _saving) return;
    setState(() => _saving = true);
    try {
      final completed = route.stops.where((stop) => stop.completed).toList();
      final ordered = RouteOptimizer.nearestFirst(
        route.stops.where((stop) => !stop.completed).toList(),
        latitude: point.latitude,
        longitude: point.longitude,
      );
      await _save(
        SavedRoute(
          stops: [...completed, ...ordered],
          latitude: point.latitude,
          longitude: point.longitude,
          isDemo: route.isDemo,
        ),
      );
    } catch (_) {
      _message('Yeni sıra kaydedilemedi. Lütfen tekrar deneyin.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _import({bool demo = false}) async {
    if (_route != null) {
      final replace = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Yeni rota oluşturulsun mu?'),
          content: const Text(
            'Yeni rota kaydedilince mevcut rota ve teslimat işaretleri değişecek.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Devam et'),
            ),
          ],
        ),
      );
      if (!mounted || replace != true) return;
    }
    LatLng? point = demo
        ? _demoOrigin
        : _manualOrigin
        ? _origin
        : await _locate();
    if (!mounted) return;
    if (point == null) {
      point = await _chooseOrigin(reorder: false);
      if (!mounted || point == null) return;
    }
    final routeOrigin = point;
    List<DeliveryStop>? sample;
    if (demo) {
      try {
        final data = await rootBundle.load(
          'assets/templates/sample_deliveries.xlsx',
        );
        sample = ExcelParser.parseBytes(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        );
      } catch (_) {
        _message('Örnek dosya açılamadı.');
        return;
      }
    }
    if (!mounted) return;
    final stops = await Navigator.push<List<DeliveryStop>>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CreateRoutePage(origin: routeOrigin, initialStops: sample),
      ),
    );
    if (!mounted || stops == null || stops.isEmpty) return;
    setState(() => _saving = true);
    try {
      final ordered = RouteOptimizer.nearestFirst(
        stops,
        latitude: routeOrigin.latitude,
        longitude: routeOrigin.longitude,
      );
      await _save(
        SavedRoute(
          stops: ordered,
          latitude: routeOrigin.latitude,
          longitude: routeOrigin.longitude,
          isDemo: demo,
        ),
      );
      if (demo) _manualOrigin = false;
    } catch (_) {
      _message(
        'Rota oluşturulamadı veya kaydedilemedi. Mevcut rota korunuyor.',
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _complete(DeliveryStop stop, {bool completed = true}) async {
    final route = _route;
    if (route == null || _saving) return;
    setState(() => _saving = true);
    try {
      final changed = route.stops
          .map(
            (item) =>
                item.id == stop.id ? item.copyWith(completed: completed) : item,
          )
          .toList();
      final point = completed
          ? LatLng(stop.latitude!, stop.longitude!)
          : _origin ?? LatLng(route.latitude, route.longitude);
      final ordered = RouteOptimizer.nearestFirst(
        changed.where((item) => !item.completed).toList(),
        latitude: point.latitude,
        longitude: point.longitude,
      );
      await _save(
        SavedRoute(
          stops: [...changed.where((item) => item.completed), ...ordered],
          latitude: point.latitude,
          longitude: point.longitude,
          isDemo: route.isDemo,
        ),
      );
      if (completed && mounted) {
        _manualOrigin = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel #${stop.originalNumber} tamamlandı.'),
            action: SnackBarAction(
              label: 'Geri al',
              onPressed: () => _complete(stop, completed: false),
            ),
          ),
        );
      }
    } catch (_) {
      _message('Teslimat durumu kaydedilemedi. Tekrar deneyin.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _navigate(DeliveryStop stop) async {
    try {
      await _navigation.open(stop);
    } catch (error) {
      _message(
        error is FormatException ? error.message : 'Navigasyon açılamadı.',
      );
    }
  }

  Future<void> _clear() async {
    final clear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Kaydedilen rota silinsin mi?'),
        content: const Text(
          'Duraklar ve bu cihazdaki adres önbelleği silinecek.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (!mounted || clear != true) return;
    setState(() => _saving = true);
    try {
      await _storage.clear();
      if (mounted) setState(() => _route = null);
    } catch (_) {
      _message('Rota silinemedi. Lütfen tekrar deneyin.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _about() => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Deli4Route nasıl çalışır?'),
      content: const SingleChildScrollView(
        child: Text(
          '1. Başlangıcı cihaz konumundan veya haritadan seç.\n\n'
          '2. Excel adreslerini yükle ve konumları kontrol et.\n\n'
          '3. Başlangıçtan en yakın durak seçilir; ardından o duraktan kalan en yakın durağa geçilir.\n\n'
          'Mesafeler kuş uçuşudur. Bu yöntem trafik, tek yön ve köprüleri hesaplamaz; '
          'toplamda en kısa yol garantisi vermez. Haritadaki noktalı çizgiler yalnızca ziyaret sırasını gösterir. '
          'Gerçek yol tarifi için Navigasyon düğmesini kullan.\n\n'
          'Rota ve teslimat durumları yalnızca bu cihazda saklanır. '
          'Harita ve cihazın adres çözümleme servisi internet gerektirebilir. '
          'Hesap veya API anahtarı gerekmez.',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tamam'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final route = _route;
    final pending = _pending;
    final completed =
        route?.stops.where((stop) => stop.completed).toList() ??
        <DeliveryStop>[];
    final blocked = _saving || _loading || _locating;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: RouteColors.ink,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.route_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 9),
            const Flexible(
              child: Text(
                'Deli4Route',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _about,
            tooltip: 'Nasıl çalışır?',
            icon: const Icon(Icons.info_outline_rounded, size: 22),
          ),
          if (route != null)
            IconButton(
              onPressed: blocked ? null : _clear,
              tooltip: 'Rotayı sil',
              icon: const Icon(Icons.delete_outline_rounded, size: 22),
            ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            if (blocked) const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  const Text(
                    'DAĞITIM PLANLAYICI',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w700,
                      color: RouteColors.muted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    route == null
                        ? 'Bir dosya.\nDüzenli bir rota.'
                        : 'Dağıtım rotan',
                    style: const TextStyle(
                      fontSize: 30,
                      height: 1.15,
                      letterSpacing: -1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    route == null
                        ? 'Duraklarını ekle, sıranı oluştur, yola çık.'
                        : pending.isEmpty
                        ? 'Bugünkü durakların tamamlandı.'
                        : 'Sıradaki teslimatına hazırsın.',
                    style: const TextStyle(
                      color: RouteColors.muted,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (route != null) ...[
                    _progressCard(route, completed.length, pending.length),
                    const SizedBox(height: 16),
                    if (route.isDemo) ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: RouteBadge(
                          'Örnek rota · İstanbul test noktaları',
                          icon: Icons.science_outlined,
                          foreground: RouteColors.orange,
                          background: RouteColors.orangeSoft,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: SizedBox(
                        height: 215,
                        child: RouteMap(
                          key: ValueKey(
                            '${_origin?.latitude},${_origin?.longitude}:${pending.map((s) => s.id).join(',')}',
                          ),
                          origin:
                              _origin ??
                              LatLng(route.latitude, route.longitude),
                          stops: route.stops,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.route_outlined,
                            size: 14,
                            color: RouteColors.muted,
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Çizgi ziyaret sırasını gösterir. Yol tarifi navigasyonda açılır.',
                              style: TextStyle(
                                fontSize: 11,
                                color: RouteColors.muted,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  _originCard(blocked),
                  if (_locationError != null) ...[
                    const SizedBox(height: 12),
                    Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _locationError!,
                              style: const TextStyle(fontSize: 13),
                            ),
                            TextButton(
                              onPressed: () => Geolocator.openAppSettings(),
                              child: const Text('Uygulama ayarlarını aç'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  if (route == null)
                    _empty(blocked)
                  else ...[
                    if (pending.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(28),
                          child: Column(
                            children: [
                              Icon(
                                Icons.task_alt_rounded,
                                color: RouteColors.green,
                                size: 44,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Eline sağlık!',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Rotadaki tüm duraklar tamamlandı.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: RouteColors.muted),
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Ziyaret sırası',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          RouteBadge('${pending.length} durak kaldı'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      for (var i = 0; i < pending.length; i++) ...[
                        _stopCard(pending[i], i, blocked),
                        const SizedBox(height: 12),
                      ],
                    ],
                    if (completed.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Card(
                        child: ExpansionTile(
                          shape: const Border(),
                          collapsedShape: const Border(),
                          leading: const Icon(
                            Icons.check_circle_outline,
                            color: RouteColors.green,
                          ),
                          title: Text(
                            'Tamamlananlar (${completed.length})',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          children: completed
                              .map(
                                (stop) => ListTile(
                                  title: Text(
                                    stop.customerName,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  subtitle: Text(
                                    'Excel #${stop.originalNumber} · ${stop.address}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  trailing: TextButton(
                                    onPressed: blocked
                                        ? null
                                        : () =>
                                              _complete(stop, completed: false),
                                    child: const Text('Geri al'),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            if (route != null)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                decoration: const BoxDecoration(
                  color: RouteColors.background,
                  border: Border(top: BorderSide(color: RouteColors.line)),
                ),
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: blocked ? null : _import,
                  icon: const Icon(Icons.add_rounded, size: 19),
                  label: const Text('Yeni Excel ile rota oluştur'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _progressCard(SavedRoute route, int completed, int remaining) =>
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: RouteColors.ink,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ROTA DURUMU',
                        style: TextStyle(
                          color: Color(0xFFAFC4C4),
                          fontSize: 10,
                          letterSpacing: 1.3,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '$completed / ${route.stops.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'teslimat tamamlandı',
                        style: TextStyle(
                          color: Color(0xFFC0D0D0),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                RouteBadge(
                  remaining == 0 ? 'Tamamlandı' : '$remaining durak kaldı',
                  icon: remaining == 0
                      ? Icons.check
                      : Icons.local_shipping_outlined,
                  foreground: Colors.white,
                  background: const Color(0xFF324A50),
                ),
              ],
            ),
            const SizedBox(height: 18),
            LinearProgressIndicator(
              value: completed / route.stops.length,
              minHeight: 5,
              color: const Color(0xFFFFA37B),
              backgroundColor: const Color(0xFF385057),
            ),
          ],
        ),
      );

  Widget _originCard(bool blocked) => Card(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: RouteColors.greenSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.my_location_rounded,
                  size: 18,
                  color: RouteColors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Başlangıç noktası',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _origin == null
                          ? 'Konumunu kullan veya haritadan seç'
                          : '${_origin!.latitude.toStringAsFixed(4)}, ${_origin!.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(
                        color: RouteColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            children: [
              TextButton.icon(
                onPressed: blocked ? null : () => _locate(reorder: true),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(
                  _route == null
                      ? 'Konumumu kullan'
                      : 'Konumumdan yeniden sırala',
                ),
              ),
              TextButton.icon(
                onPressed: blocked ? null : _chooseOrigin,
                icon: const Icon(Icons.edit_location_alt_outlined, size: 16),
                label: const Text('Başlangıç seç'),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _empty(bool blocked) => Card(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          const RouteIllustration(),
          const SizedBox(height: 20),
          const Text(
            'Excel’den rotaya',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Adreslerini tek dosyada yükle. Konumları kontrol et, en yakın duraktan başla.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: RouteColors.muted,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: blocked ? null : _import,
              icon: const Icon(Icons.upload_file_rounded, size: 20),
              label: const Text('Excel’den rota oluştur'),
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: blocked ? null : () => _import(demo: true),
            child: const Text('Örnek 5 durakla dene'),
          ),
          const SizedBox(height: 14),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.phone_android_rounded,
                size: 14,
                color: RouteColors.muted,
              ),
              SizedBox(width: 5),
              Flexible(
                child: Text(
                  'Hesapsız. Rotan cihazında saklanır.',
                  style: TextStyle(fontSize: 11, color: RouteColors.muted),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _stopCard(DeliveryStop stop, int index, bool blocked) {
    final first = index == 0;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: first ? const Color(0xFFE7B79F) : RouteColors.line,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: first ? RouteColors.orange : RouteColors.background,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Text(
                    '${index + 1}'.padLeft(2, '0'),
                    style: TextStyle(
                      color: first ? Colors.white : RouteColors.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        first ? 'SIRADAKİ DURAK' : '${index + 1}. ZİYARET',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: .8,
                          color: first ? RouteColors.orange : RouteColors.muted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stop.customerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                RouteBadge('Excel #${stop.originalNumber}'),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              stop.address,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            if (stop.note?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.notes_rounded,
                      size: 16,
                      color: RouteColors.muted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        stop.note!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: RouteColors.muted,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (stop.phone?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  stop.phone!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: RouteColors.muted,
                  ),
                ),
              ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final buttons = [
                  FilledButton.icon(
                    onPressed: blocked ? null : () => _navigate(stop),
                    style: first
                        ? null
                        : FilledButton.styleFrom(
                            backgroundColor: RouteColors.ink,
                          ),
                    icon: const Icon(Icons.near_me_outlined, size: 17),
                    label: const Text('Navigasyon'),
                  ),
                  OutlinedButton.icon(
                    onPressed: blocked ? null : () => _complete(stop),
                    icon: const Icon(Icons.check_rounded, size: 17),
                    label: const Text('Tamamlandı'),
                  ),
                ];
                if (constraints.maxWidth < 315 ||
                    MediaQuery.textScalerOf(context).scale(14) > 18) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buttons[0],
                      const SizedBox(height: 8),
                      buttons[1],
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: buttons[0]),
                    const SizedBox(width: 8),
                    Expanded(child: buttons[1]),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
