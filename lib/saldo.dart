// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, sort_child_properties_last

import 'package:cien_conductor/common.dart';
import 'package:flutter/material.dart';

class SaldoScreen extends StatefulWidget {
  @override
  _SaldoScreenState createState() => _SaldoScreenState();
}

class _SaldoScreenState extends State<SaldoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Saldo',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.account_balance_wallet), // ejemplo de ícono
            onPressed: () {
              // acción al presionar el ícono
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      Container(
                        margin: EdgeInsets.all(20),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 60),
                              '\$${Common.saldo}'),
                        ),
                      ),
                      SizedBox(
                        height: 100,
                      )
                    ],
                  ),
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: Container(
                  color: const Color.fromARGB(255, 236, 236, 236),
                ),
              ),
            ],
          ),
          Positioned(
            top: 220,
            left: 16,
            right: 16,
            child: Container(
              height: 900,
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          Common.name,
                          style: TextStyle(fontSize: 22, color: Colors.black),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          Common.phone,
                          style: TextStyle(fontSize: 22, color: Colors.black),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "¿Necesitas recargar tu saldo? ¡Es muy sencillo! Solo sigue estos pasos:\n\n"
                          "1. **Realiza un depósito**:\n"
                          "   Transfiere el monto deseado al siguiente número de tarjeta:\n"
                          "   **4152 3141 1847 2201** de **BBVA**.\n\n"
                          "   Asegúrate de que el nombre del titular de la cuenta sea **Neftali Rangel García**.\n\n"
                          "2. **Envía whatsapp al 4151512750 indicando el depósito con foto del ticket**:\n"
                          "   Una vez realizado el depósito, tu saldo se actualizará en aproximadamente 24 horas.\n\n"
                          "**Atentamente:** "
                          "**100% FDE**",
                          style: TextStyle(fontSize: 12, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
