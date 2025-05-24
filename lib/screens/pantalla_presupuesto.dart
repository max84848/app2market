import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class PantallaPresupuesto extends StatefulWidget {
  final VoidCallback onPresupuestoActualizado;
  const PantallaPresupuesto({super.key, required this.onPresupuestoActualizado});

  @override
  State<PantallaPresupuesto> createState() => _PantallaPresupuestoState();
}

class _PantallaPresupuestoState extends State<PantallaPresupuesto> {
  double _presupuesto = 0;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarPresupuesto();
  }

  Future<void> _cargarPresupuesto() async {
    final p = await DatabaseHelper.instance.obtenerPresupuesto();
    setState(() {
      _presupuesto = p;
      _controller.text = _presupuesto.toStringAsFixed(2);
    });
  }

  Future<void> _guardarPresupuesto() async {
    final nuevo = double.tryParse(_controller.text) ?? _presupuesto;
    await DatabaseHelper.instance.actualizarPresupuesto(nuevo);
    setState(() {
      _presupuesto = nuevo;
    });
    widget.onPresupuestoActualizado();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Presupuesto actualizado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Presupuesto Actual',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Nuevo presupuesto',
              border: OutlineInputBorder(),
              prefixText: '\$ ',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _guardarPresupuesto,
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
