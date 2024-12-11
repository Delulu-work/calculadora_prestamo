import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Generador de préstamos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const FormularioPrestamo(),
    );
  }
}
class FormularioPrestamo extends StatefulWidget {
  const FormularioPrestamo({super.key});

  @override
  State<FormularioPrestamo> createState() => _FormularioPrestamoState();
}

class _FormularioPrestamoState extends State<FormularioPrestamo> {
  
  TextEditingController montoPrestamoController = TextEditingController();
  TextEditingController tasaInteresController = TextEditingController();
  TextEditingController plazoController = TextEditingController();

 
  String cuotaMensual = '';
  String montoPrestamo = '';
  String tasaInteres = '';
  bool mostrarResultado = false;
  bool mostrarTabla = false;

  List<Map<String, String>> tablaAmortizacion = [];

  // Calcular el préstamo
  void _calcularPrestamo() {
    double montoPrestamoValor = double.parse(montoPrestamoController.text);
    double tasaInteresValor = double.parse(tasaInteresController.text);
    int plazoValor = int.parse(plazoController.text);

    // Calcular la tasa de interés mensual
    double tasaInteresMensual = tasaInteresValor / 100 / 12;

    // Calcular el pago mensual (cuota fija)
    double pagoMensual = (montoPrestamoValor * tasaInteresMensual) / 
        (1 - (1 / (1 + tasaInteresMensual * plazoValor)));

    // tabla de amortización
    List<Map<String, String>> tabla = [];
    double saldoRestante = montoPrestamoValor;

    for (int i = 1; i <= plazoValor; i++) {
     
      double interes = saldoRestante * tasaInteresMensual;

      
      double capital = pagoMensual - interes;

      
      saldoRestante -= capital;

     
      tabla.add({
        'No': i.toString(),
        'Cuota': pagoMensual.toStringAsFixed(2),
        'Capital': capital.toStringAsFixed(2),
        'Interés': interes.toStringAsFixed(2),
        'Balance': saldoRestante.toStringAsFixed(2),
      });
    }

    
    setState(() {
      cuotaMensual = pagoMensual.toStringAsFixed(2);
      montoPrestamo = montoPrestamoController.text;
      tasaInteres = tasaInteresController.text;
      mostrarResultado = true;
      mostrarTabla = true;
      tablaAmortizacion = tabla;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el tamaño de la pantalla
    double anchoPantalla = MediaQuery.of(context).size.width;
    double altoPantalla = MediaQuery.of(context).size.height;

    // Definir el tamaño de la fuente en función del ancho de la pantalla
    double tamanoFuente = anchoPantalla > 600 ? 18 : 14;  // Si es más grande que 600px, usar tamaño de fuente más grande

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generador de Préstamo'),
        backgroundColor: Color.fromARGB(255, 1, 76, 91),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(anchoPantalla * 0.05),  // Usamos un padding basado en el tamaño de la pantalla
        child: Column(
          children: [
            // Monto del préstamo
            TextField(
              controller: montoPrestamoController,
              decoration: const InputDecoration(
                labelText: 'Monto del Préstamo',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Tasa de interés anual
            TextField(
              controller: tasaInteresController,
              decoration: const InputDecoration(
                labelText: 'Tasa de Interés Anual (%)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Plazo del préstamo en meses
            TextField(
              controller: plazoController,
              decoration: const InputDecoration(
                labelText: 'Plazo en Meses',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            
            ElevatedButton(
              onPressed: _calcularPrestamo,
              child: const Text('Calcular Préstamo'),
            ),
            const SizedBox(height: 20),

            
            if (mostrarResultado)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'La cuota mensual es de \$ $cuotaMensual para un monto de \$ $montoPrestamo a una tasa de interés del $tasaInteres%.',
                    style: TextStyle(fontSize: tamanoFuente, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                ],
              ),

           
            if (mostrarTabla)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tabla de Amortización',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('No')),
                        DataColumn(label: Text('Cuota')),
                        DataColumn(label: Text('Capital')),
                        DataColumn(label: Text('Interés')),
                        DataColumn(label: Text('Balance')),
                      ],
                      rows: tablaAmortizacion
                          .map(
                            (fila) => DataRow(
                              cells: [
                                DataCell(Text(fila['No']!)),
                                DataCell(Text(fila['Cuota']!)),
                                DataCell(Text(fila['Capital']!)),
                                DataCell(Text(fila['Interés']!)),
                                DataCell(Text(fila['Balance']!)),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}