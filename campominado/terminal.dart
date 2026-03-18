import 'dart:io';
import 'dart:math';

class Ponto {
  final int x;
  final int y;

  Ponto(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ponto &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

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
    (x) => List.generate(tamanho, (y) {
      if (minasPos.contains(Ponto(x, y))) return '*';
      int qtd = contarMinasAdjacentes(x, y, minasPos, tamanho);
      return qtd > 0 ? qtd.toString() : '.';
    }),
  );
}

class CampoMinado {
  int tamanho;
  int numeroMinas;
  late Set<Ponto> minasPos;
  late List<List<String>> tabuleiro;
  late List<List<bool>> revelado;

  int status = 0;

  CampoMinado(this.tamanho, this.numeroMinas) {
    iniciarJogo();
  }

  void iniciarJogo() {
    status = 0;
    minasPos = gerarMinas(tamanho, numeroMinas);
    tabuleiro = criarTabuleiro(tamanho, minasPos);
    revelado = List.generate(
      tamanho,
      (_) => List.generate(tamanho, (_) => false),
    );
  }

  void clicarCelula(int x, int y) {
    if (x < 0 || x >= tamanho || y < 0 || y >= tamanho || revelado[x][y])
      return;

    revelado[x][y] = true;

    if (minasPos.contains(Ponto(x, y))) {
      status = -1;
      return;
    }

    if (tabuleiro[x][y] == '.') {
      for (int dx = -1; dx <= 1; dx++) {
        for (int dy = -1; dy <= 1; dy++) {
          clicarCelula(x + dx, y + dy);
        }
      }
    }

    int fechadas = 0;
    for (var linha in revelado) {
      fechadas += linha.where((aberta) => !aberta).length;
    }

    if (fechadas == numeroMinas) status = 1;
  }
}

void printTabuleiro(CampoMinado jogo) {
  stdout.write('   ');
  for (int i = 0; i < jogo.tamanho; i++) {
    stdout.write(i.toString().padRight(3));
  }
  print('\n' + '---' * (jogo.tamanho + 1));

  for (int i = 0; i < jogo.tamanho; i++) {
    stdout.write(i.toString().padRight(3));

    for (int j = 0; j < jogo.tamanho; j++) {
      String char = jogo.revelado[i][j] ? jogo.tabuleiro[i][j] : '#';
      stdout.write(char.padRight(3));
    }
    print('');
  }
}

void main() {
  final jogo = CampoMinado(12, 20);

  while (jogo.status == 0) {
    printTabuleiro(jogo);
    stdout.write('\nDigite linha e coluna (ex: 2 3): ');
    String? input = stdin.readLineSync();

    if (input == null || input.trim().toLowerCase() == 'sair') {
      break;
    }

    List<String> partes = input.trim().split(RegExp(r'\s+'));
    if (partes.length == 2) {
      int? x = int.tryParse(partes[0]);
      int? y = int.tryParse(partes[1]);

      if (x != null && y != null) {
        jogo.clicarCelula(x, y);

        if (jogo.status == -1) {
          printTabuleiro(jogo);
          print('\n💥 CABUM! Você pisou em uma mina. Fim de jogo.');
          break;
        } else if (jogo.status == 1) {
          printTabuleiro(jogo);
          print('\n🏆 PARABÉNS! Você limpou o campo com sucesso!');
          break;
        }
      }
    }
  }
}
