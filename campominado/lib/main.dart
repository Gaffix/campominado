import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

// logica
class Ponto {
  final int x;
  final int y;

  Ponto(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ponto && runtimeType == other.runtimeType && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  String toString() => 'Ponto($x, $y)';
}

Set<Ponto> gerarMinas(int tamanho, int minas) {
  final rand = Random();
  final Set<Ponto> minasPos = {};

  while (minasPos.length < minas) {
    final p = Ponto(rand.nextInt(tamanho), rand.nextInt(tamanho));
    minasPos.add(p);
  }

  return minasPos;
}

int contarMinasAdjacentes(int x, int y, Set<Ponto> minasPos, int tamanho) {
  int cont = 0;
  for (int dx = -1; dx <= 1; dx++) {
    for (int dy = -1; dy <= 1; dy++) {
      if (dx == 0 && dy == 0) continue;
      int nx = x + dx;
      int ny = y + dy;
      if (nx >= 0 && nx < tamanho && ny >= 0 && ny < tamanho) {
        if (minasPos.contains(Ponto(nx, ny))) cont++;
      }
    }
  }
  return cont;
}

List<List<String>> criarTabuleiro(int tamanho, Set<Ponto> minasPos) {
  return List.generate(
    tamanho,
    (x) => List.generate(
      tamanho,
      (y) {
        if (minasPos.contains(Ponto(x, y))) return '*';
        int qtd = contarMinasAdjacentes(x, y, minasPos, tamanho);
        return qtd > 0 ? qtd.toString() : '.';
      },
    ),
  );
}

void main() {
  runApp(const BoomBoomApp());
}

class BoomBoomApp extends StatelessWidget {
  const BoomBoomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Boom! Boom!',
      theme: ThemeData.dark(),
      home: const TelaInicio(), 
    );
  }
}

// TELA DE INÍCIO
class TelaInicio extends StatelessWidget {
  const TelaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Boom! Boom!',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Cuidado onde pisa...',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 60),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TelaJogo()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Jogar'),
                ),
                
                const SizedBox(height: 20),

                OutlinedButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.grey),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  child: const Text('Sair'),
                ),
              ],
            ),
          ),
          
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 48.0), // pra sair de tras dos botao de baixo
              child: Text(
                'Desenvolvido por Bruno Gelain e João Pramio',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// TELA DO JOGO
class TelaJogo extends StatefulWidget {
  const TelaJogo({super.key});

  @override
  State<TelaJogo> createState() => _TelaJogoState();
}

class _TelaJogoState extends State<TelaJogo> {
  static const int campoSize = 12;
  static const int numeroMinas = 20;

  late Set<Ponto> minasPos;
  late List<List<String>> tabuleiro;
  late List<List<bool>> revelado;
  late List<List<bool>> marcado; 
  
  bool fimDeJogo = false;
  bool isModoCavar = true;

  @override
  void initState() {
    super.initState();
    _iniciarJogo();
  }

  void _iniciarJogo() {
    setState(() {
      minasPos = gerarMinas(campoSize, numeroMinas);
      tabuleiro = criarTabuleiro(campoSize, minasPos);
      revelado = List.generate(campoSize, (_) => List.generate(campoSize, (_) => false));
      marcado = List.generate(campoSize, (_) => List.generate(campoSize, (_) => false));
      fimDeJogo = false;
      isModoCavar = true; 
    });
  }

  void _aoClicarCelula(int x, int y) {
    if (fimDeJogo) return;

    if (isModoCavar) {
      if (marcado[x][y] || revelado[x][y]) return;
      
      setState(() {
        _revelarRecursivo(x, y);
        _verificarFimDeJogo(x, y);
      });
    } else {
      if (revelado[x][y]) return;

      setState(() {
        marcado[x][y] = !marcado[x][y];
      });
    }
  }

  void _revelarRecursivo(int x, int y) {
    if (x < 0 || x >= campoSize || y < 0 || y >= campoSize) return;
    if (revelado[x][y] || marcado[x][y]) return;

    revelado[x][y] = true;

    if (tabuleiro[x][y] == '*') return;

    if (tabuleiro[x][y] == '.') {
      for (int dx = -1; dx <= 1; dx++) {
        for (int dy = -1; dy <= 1; dy++) {
          if (dx != 0 || dy != 0) {
            _revelarRecursivo(x + dx, y + dy);
          }
        }
      }
    }
  }

  void _verificarFimDeJogo(int ultimoX, int ultimoY) {
    if (tabuleiro[ultimoX][ultimoY] == '*') {
      fimDeJogo = true;
      _revelarTudo();
      _mostrarDialogo(vitoria: false);
      return;
    }

    int celulasReveladas = 0;
    for (int i = 0; i < campoSize; i++) {
      for (int j = 0; j < campoSize; j++) {
        if (revelado[i][j]) celulasReveladas++;
      }
    }

    int celulasSeguras = (campoSize * campoSize) - numeroMinas;
    if (celulasReveladas == celulasSeguras) {
      fimDeJogo = true;
      _marcarTodasMinas(); 
      _mostrarDialogo(vitoria: true);
    }
  }

  void _revelarTudo() {
    for (int i = 0; i < campoSize; i++) {
      for (int j = 0; j < campoSize; j++) {
        revelado[i][j] = true;
      }
    }
  }

  void _marcarTodasMinas() {
    for (var p in minasPos) {
      marcado[p.x][p.y] = true;
    }
  }

  void _mostrarDialogo({required bool vitoria}) {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            vitoria ? 'Vitória! 🎉' : 'BOOM! 💥',
            style: TextStyle(color: vitoria ? Colors.greenAccent : Colors.redAccent),
          ),
          content: Text(
            vitoria 
              ? 'Parabéns, você ganhou' 
              : 'Its over, você explodiu.',
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Menu Principal', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
                _iniciarJogo(); 
              },
              child: const Text('Jogar Novamente', style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boom! Boom!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _iniciarJogo,
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: campoSize,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: campoSize * campoSize,
                itemBuilder: (context, index) {
                  int x = index ~/ campoSize;
                  int y = index % campoSize;
                  
                  bool isRevelado = revelado[x][y];
                  bool isMarcado = marcado[x][y];
                  String valor = tabuleiro[x][y];

                  Widget conteudo;
                  if (isRevelado) {
                    if (valor == '*') {
                      conteudo = const Icon(Icons.emergency, color: Colors.redAccent, size: 20);
                    } else if (valor == '.') {
                      conteudo = const SizedBox.shrink();
                    } else {
                      conteudo = Text(valor, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white));
                    }
                  } else if (isMarcado) {
                    conteudo = const Icon(Icons.flag, color: Colors.redAccent, size: 20);
                  } else {
                    conteudo = const SizedBox.shrink();
                  }

                  return GestureDetector(
                    onTap: () => _aoClicarCelula(x, y),
                    onLongPress: () {
                      if (!revelado[x][y] && !fimDeJogo) {
                        setState(() { marcado[x][y] = !marcado[x][y]; });
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isRevelado ? Colors.grey[800] : Colors.grey[400],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.black26),
                      ),
                      child: Center(child: conteudo),
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => setState(() => isModoCavar = true),
                icon: const Icon(Icons.touch_app),
                label: const Text('Cavar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isModoCavar ? Colors.blueAccent : Colors.grey[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => setState(() => isModoCavar = false),
                icon: const Icon(Icons.flag),
                label: const Text('Marcar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: !isModoCavar ? Colors.redAccent : Colors.grey[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}