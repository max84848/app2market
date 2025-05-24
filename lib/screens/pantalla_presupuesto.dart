import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class PantallaPresupuesto extends StatefulWidget {
  const PantallaPresupuesto({super.key});

  @override
  State<PantallaPresupuesto> createState() => _PantallaPresupuestoState();
}

class _PantallaPresupuestoState extends State<PantallaPresupuesto> {
  final TextEditingController _presupuestoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarPresupuesto();
  }

  Future<void> _cargarPresupuesto() async {
    final monto = await DatabaseHelper.instance.obtenerPresupuesto();
    _presupuestoController.text = monto.toStringAsFixed(2);
    setState(() {});
  }

  Future<void> _guardarPresupuesto() async {
    final nuevoMonto = double.tryParse(_presupuestoController.text) ?? 0.0;
    if (nuevoMonto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce un monto válido')),
      );
      return;
    }
    await DatabaseHelper.instance.actualizarPresupuesto(nuevoMonto);
    if (nuevoMonto < 70) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('⚠️ Presupuesto bajo'),
          content: Text('El presupuesto es bajo: \$${nuevoMonto.toStringAsFixed(2)}'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Presupuesto actualizado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Presupuesto')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _presupuestoController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Presupuesto',
                prefixText: '\$',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardarPresupuesto,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
