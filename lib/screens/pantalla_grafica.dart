import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database/db_helper.dart';
import '../models/compra.dart';

class PantallaGrafica extends StatefulWidget {
  const PantallaGrafica({super.key});

  @override
  State<PantallaGrafica> createState() => _PantallaGraficaState();
}

class _PantallaGraficaState extends State<PantallaGrafica> {
  List<Compra> compras = [];

  @override
  void initState() {
    super.initState();
    cargarCompras();
  }

  Future<void> cargarCompras() async {
    final data = await DatabaseHelper.instance.obtenerHistorial();
    setState(() {
      compras = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (compras.isEmpty) {
      return const Center(child: Text('No hay datos para graficar'));
    }

    // Agrupar totales por fecha (sin hora)
    final Map<String, double> totalesPorFecha = {};
    for (var compra in compras) {
      final fecha = compra.fecha.toLocal().toString().split(' ')[0];
      totalesPorFecha[fecha] = (totalesPorFecha[fecha] ?? 0) + compra.total;
    }

    final fechas = totalesPorFecha.keys.toList();
    final totales = totalesPorFecha.values.toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (totales.reduce((a, b) => a > b ? a : b) * 1.2),
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= fechas.length) return const SizedBox.shrink();
                  final fecha = fechas[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(fecha, style: const TextStyle(fontSize: 10)),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(totales.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: totales[index],
                  color: Colors.purple,
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
