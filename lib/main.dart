import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/product.dart';
import 'database/db_helper.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora Super',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(useMaterial3: true),
      theme: ThemeData.light(useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    _refreshProducts();
  }

  Future _refreshProducts() async {
    final data = await DBHelper.getProducts();
    setState(() {
      products = data;
    });
  }

  double get total {
    return products.fold(0, (sum, item) => sum + item.price);
  }

  void _addOrUpdateProduct({Product? product}) {
    if (product != null) {
      _nameController.text = product.name;
      _priceController.text = product.price.toString();
    } else {
      _nameController.clear();
      _priceController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product == null ? 'Agregar producto' : 'Modificar producto'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese nombre' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese precio';
                  if (double.tryParse(value) == null) return 'Precio inválido';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final name = _nameController.text.trim();
                final price = double.parse(_priceController.text.trim());
                if (product == null) {
                  await DBHelper.insertProduct(Product(name: name, price: price));
                } else {
                  await DBHelper.updateProduct(Product(id: product.id, name: name, price: price));
                }
                Navigator.pop(context);
                _refreshProducts();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(int id) async {
    await DBHelper.deleteProduct(id);
    _refreshProducts();
  }

  Future<void> _deleteAll() async {
    await DBHelper.deleteAll();
    _refreshProducts();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'es_MX');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora Super'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Borrar todo',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmar'),
                  content: const Text('¿Seguro que quieres borrar todo?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _deleteAll();
                        Navigator.pop(context);
                      },
                      child: const Text('Borrar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrUpdateProduct(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.centerLeft,
            child: Text(
              'Total: ${currencyFormat.format(total)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: products.isEmpty
                ? const Center(child: Text('No hay productos'))
                : ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final prod = products[index];
                      return Slidable(
                        key: ValueKey(prod.id),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) => _addOrUpdateProduct(product: prod),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: 'Modificar',
                            ),
                            SlidableAction(
                              onPressed: (context) => _deleteProduct(prod.id!),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Borrar',
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(prod.name),
                          trailing: Text(currencyFormat.format(prod.price)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
