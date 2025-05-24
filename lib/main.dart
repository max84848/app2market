import 'package:flutter/material.dart';
import 'screens/pantalla_principal.dart';
import 'screens/pantalla_grafica.dart';
import 'screens/pantalla_presupuesto.dart';
import 'screens/pantalla_historial.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = true;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App2Market',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      debugShowCheckedModeBanner: false,
      home: HomeScreen(
        isDarkMode: _isDarkMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Creamos el GlobalKey para PantallaHistorial
  final GlobalKey<PantallaHistorialState> historialKey = GlobalKey<PantallaHistorialState>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      
  PantallaPrincipal(
    onCompraGuardada: () {
      historialKey.currentState?.refrescarHistorial();
    },
  ),
  const PantallaGrafica(),
  PantallaPresupuesto(onPresupuestoActualizado: () {}),
  PantallaHistorial(key: historialKey),
];
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Si selecciona la pestaña historial, refrescamos la lista automáticamente
    if (index == 3) {
      historialKey.currentState?.refrescarHistorial();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App2Market'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Cambiar tema',
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cosas'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Gráfica'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Presupuesto'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
        ],
      ),
    );
  }
}
