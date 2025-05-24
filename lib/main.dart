import 'package:flutter/material.dart';
import 'database/db_helper.dart';
import 'models/compra.dart';
import 'screens/pantalla_historial.dart';
import 'screens/pantalla_presupuesto.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App2Market',
      theme: ThemeData.dark(),
      home: const PantallaConBNB(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Nueva clase principal con BNB
class PantallaConBNB extends StatefulWidget {
  const PantallaConBNB({super.key});

  @override
  State<PantallaConBNB> createState() => _PantallaConBNBState();
}

class _PantallaConBNBState extends State<PantallaConBNB> {
  int _paginaActual = 0;

  final List<Widget> _pantallas = [
    const PantallaProductos(),
    const PantallaGrafica(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pantallas[_paginaActual],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaActual,
        onTap: (index) => setState(() => _paginaActual = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Productos'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Gráfica'),
        ],
      ),
    );
  }
}

// Pantalla principal con productos y presupuesto
class PantallaProductos extends StatefulWidget {
  const PantallaProductos({super.key});

  @override
  State<PantallaProductos> createState() => _PantallaProductosState();
}

class _PantallaProductosState extends State<PantallaProductos> {
  final List<Map<String, dynamic>> productos = [];
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  double presupuestoRestante = 0;

  @override
  void initState() {
    super.initState();
    cargarPresupuesto();
  }

  Future<void> cargarPresupuesto() async {
    final restante = await DatabaseHelper.instance.obtenerPresupuesto();
    setState(() {
      presupuestoRestante = restante;
    });
  }

  void agregarProductoDialog() {
    _nombreController.clear();
    _precioController.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Agregar producto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nombreController, decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(controller: _precioController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Precio')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final nombre = _nombreController.text.trim();
              final precio = double.tryParse(_precioController.text) ?? 0.0;
              if (nombre.isNotEmpty && precio > 0) {
                setState(() {
                  productos.add({'nombre': nombre, 'precio': precio});
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Agregar'),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ],
      ),
    );
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
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
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

  Color obtenerColorPresupuesto(double restante) {
    return restante >= 0 ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final restanteActual = presupuestoRestante - calcularTotal();
    return Scaffold(
      appBar: AppBar(
        title: const Text('App2Market'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Historial de compras',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PantallaHistorial()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            tooltip: 'Presupuesto',
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const PantallaPresupuesto()));
              cargarPresupuesto();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
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
            Text('Total: \$${calcularTotal().toStringAsFixed(2)}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              restanteActual < 0
                  ? 'Presupuesto: -\$${restanteActual.abs().toStringAsFixed(2)}'
                  : 'Presupuesto: \$${restanteActual.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: obtenerColorPresupuesto(restanteActual)),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: 'agregar',
                  backgroundColor: Colors.purple,
                  onPressed: agregarProductoDialog,
                  child: const Icon(Icons.add),
                ),
                FloatingActionButton(
                  heroTag: 'guardar',
                  backgroundColor: Colors.green,
                  onPressed: () async {
                    if (productos.isEmpty) return;

                    final compra = Compra(
                      fecha: DateTime.now(),
                      total: calcularTotal(),
                      productos: obtenerProductosSeleccionados(),
                    );

                    await DatabaseHelper.instance.insertarCompra(compra);
                    await DatabaseHelper.instance.descontarDelPresupuesto(compra.total);
                    final restante = await DatabaseHelper.instance.obtenerPresupuesto();

                    if (!context.mounted) return;
                    if (restante < 70) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('⚠️ Presupuesto bajo'),
                          content: Text('Solo te quedan \$${restante.toStringAsFixed(2)}'),
                          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Compra guardada')));
                    }

                    setState(() {
                      productos.clear();
                    });

                    cargarPresupuesto();
                  },
                  child: const Icon(Icons.check),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Pantalla de gráfica (por ahora solo texto)
class PantallaGrafica extends StatelessWidget {
  const PantallaGrafica({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('aca ira la gráfica', style: TextStyle(fontSize: 24)),
    );
  }
}
