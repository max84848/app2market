import 'package:flutter/material.dart';
import 'database/db_helper.dart';
import 'models/compra.dart';
import '../screens/pantalla_historial.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App2Market',
      theme: ThemeData.dark(), // 🌙 Modo oscuro
      home: const PantallaPrincipal(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});
  
  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  final List<Map<String, dynamic>> productos = [];

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();

  void agregarProducto() {
    final nombre = _nombreController.text.trim();
    final precio = double.tryParse(_precioController.text) ?? 0.0;
    if (nombre.isNotEmpty && precio > 0) {
      setState(() {
        productos.add({'nombre': nombre, 'precio': precio});
      });
      _nombreController.clear();
      _precioController.clear();
    }
  }

  void eliminarProducto(int index) {
    setState(() {
      productos.removeAt(index);
    });
  }

  void modificarProducto(int index) {
    final producto = productos[index];
    _nombreController.text = producto['nombre'];
    _precioController.text = producto['precio'].toString();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Modificar producto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nombreController, decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(controller: _precioController, decoration: const InputDecoration(labelText: 'Precio')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final nombre = _nombreController.text.trim();
              final precio = double.tryParse(_precioController.text) ?? 0.0;
              if (nombre.isNotEmpty && precio > 0) {
                setState(() {
                  productos[index] = {'nombre': nombre, 'precio': precio};
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  double calcularTotal() {
    return productos.fold(0.0, (sum, item) => sum + (item['precio'] as double));
  }

  List<String> obtenerProductosSeleccionados() {
    return productos.map((p) => p['nombre'] as String).toList();
  }

  void guardarCompra() async {
    if (productos.isEmpty) return;
    final compra = Compra(
      fecha: DateTime.now(),
      total: calcularTotal(),
      productos: obtenerProductosSeleccionados(),
    );
    await DatabaseHelper.instance.insertarCompra(compra);
    setState(() {
      productos.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compra guardada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App2Market'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PantallaHistorial()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Producto'),
            ),
            TextField(
              controller: _precioController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Precio'),
            ),
            ElevatedButton(
              onPressed: agregarProducto,
              child: const Text('Agregar producto'),
            ),
            const SizedBox(height: 12),
            const Text('Lista de productos:', style: TextStyle(fontSize: 16)),
            Expanded(
              child: ListView.builder(
                itemCount: productos.length,
                itemBuilder: (context, index) {
                  final producto = productos[index];
                  return ListTile(
                    title: Text('${producto['nombre']} - \$${producto['precio'].toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit), onPressed: () => modificarProducto(index)),
                        IconButton(icon: const Icon(Icons.delete), onPressed: () => eliminarProducto(index)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text('Total: \$${calcularTotal().toStringAsFixed(2)}'),
            ElevatedButton(
              onPressed: guardarCompra,
              child: const Text('Guardar compra'),
            ),
          ],
        ),
      ),
    );
  }
}
