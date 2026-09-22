import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Juego de Memoria - Tríos',
      theme: ThemeData(primarySwatch: Colors.pink, useMaterial3: true),
      home: const PantallaMemoria(),
    );
  }
}

class PantallaMemoria extends StatefulWidget {
  const PantallaMemoria({super.key});

  @override
  State<PantallaMemoria> createState() => _PantallaMemoriaState();
}

class _PantallaMemoriaState extends State<PantallaMemoria> {
  // Cambiamos emojis por letras/palabras sencillas
  final List<String> _simbolos = ['X', 'Y', 'Z', 'K', 'M', 'E'];

  late List<String> _cartas;
  late List<bool> _volteadas;
  late List<bool> _emparejadas;

  // Guardamos los índices de hasta 3 cartas seleccionadas
  List<int> _seleccionadas = [];
  int _intentos = 0;
  bool _bloqueado = false;

  @override
  void initState() {
    super.initState();
    _iniciarJuego();
  }

  void _iniciarJuego() {
    // 3 cartas de cada símbolo (en total 18 cartas)
    _cartas = [..._simbolos, ..._simbolos, ..._simbolos];
    _cartas.shuffle(Random());

    _volteadas = List.filled(_cartas.length, false);
    _emparejadas = List.filled(_cartas.length, false);
    _seleccionadas = [];
    _intentos = 0;
    _bloqueado = false;
  }

  void _voltearCarta(int indice) {
    if (_bloqueado || _volteadas[indice] || _emparejadas[indice]) return;

    setState(() {
      _volteadas[indice] = true;
      _seleccionadas.add(indice);
    });

    // Si ya elegimos 3 cartas, validamos
    if (_seleccionadas.length == 3) {
      _intentos++;
      final i1 = _seleccionadas[0];
      final i2 = _seleccionadas[1];
      final i3 = _seleccionadas[2];

      // Validación: comprobar si las 3 tienen la misma letra/palabra
      if (_cartas[i1] == _cartas[i2] && _cartas[i2] == _cartas[i3]) {
        setState(() {
          _emparejadas[i1] = true;
          _emparejadas[i2] = true;
          _emparejadas[i3] = true;
          _seleccionadas.clear();
        });
        _revisarVictoria();
      } else {
        // No coinciden: se ocultan tras un breve tiempo
        _bloqueado = true;
        Future.delayed(const Duration(milliseconds: 800), () {
          setState(() {
            _volteadas[i1] = false;
            _volteadas[i2] = false;
            _volteadas[i3] = false;
            _seleccionadas.clear();
            _bloqueado = false;
          });
        });
      }
    }
  }

  void _revisarVictoria() {
    if (_emparejadas.every((e) => e)) {
      Future.delayed(const Duration(milliseconds: 300), () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('¡Ganaste! 🎉'),
            content: Text('Lo lograste en $_intentos intentos.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(_iniciarJuego);
                },
                child: const Text('Jugar de nuevo'),
              ),
            ],
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EEFF),
      appBar: AppBar(
        title: const Text('Juego de Tríos'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('Intentos: $_intentos')),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: _cartas.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 columnas x 6 filas = 18 cartas perfectamente ordenadas
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, indice) {
            final mostrar = _volteadas[indice] || _emparejadas[indice];
            return GestureDetector(
              onTap: () => _voltearCarta(indice),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: mostrar
                      ? (_emparejadas[indice] ? Colors.green[200] : Colors.white)
                      : Colors.pink[300], // Fondo rosado
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  mostrar ? _cartas[indice] : '?',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: mostrar ? Colors.black : Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(_iniciarJuego),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}