import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/route_map.dart';

class LocationPickerPage extends StatefulWidget {
  final LatLng initialPoint;
  final String title;

  const LocationPickerPage({
    super.key,
    required this.initialPoint,
    required this.title,
  });

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _latitude;
  late final TextEditingController _longitude;
  late LatLng _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialPoint;
    _latitude = TextEditingController(
      text: _selected.latitude.toStringAsFixed(6),
    );
    _longitude = TextEditingController(
      text: _selected.longitude.toStringAsFixed(6),
    );
  }

  @override
  void dispose() {
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  String? _validate(String? text, double limit) {
    final value = double.tryParse((text ?? '').replaceAll(',', '.'));
    if (value == null || !value.isFinite || value.abs() > limit) {
      return 'Geçersiz koordinat';
    }
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      LatLng(
        double.parse(_latitude.text.replaceAll(',', '.')),
        double.parse(_longitude.text.replaceAll(',', '.')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title)),
    body: Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Text(
            'Haritada doğru noktaya dokunun veya enlem/boylamı yazın.',
          ),
        ),
        Expanded(
          child: RouteMap(
            origin: widget.initialPoint,
            selectedPoint: _selected,
            onTap: (point) => setState(() {
              _selected = point;
              _latitude.text = point.latitude.toStringAsFixed(6);
              _longitude.text = point.longitude.toStringAsFixed(6);
            }),
          ),
        ),
        SafeArea(
          top: false,
          minimum: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latitude,
                        decoration: const InputDecoration(labelText: 'Enlem'),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        validator: (value) => _validate(value, 90),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _longitude,
                        decoration: const InputDecoration(labelText: 'Boylam'),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        validator: (value) => _validate(value, 180),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check),
                    label: const Text('Bu konumu kullan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
