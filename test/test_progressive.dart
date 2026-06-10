// ignore_for_file: unused_element
import 'dart:core';

class _TokenSegment {
  final List<String> base;
  final List<String> current;
  final List<int> baseIndices;

  bool get isModified {
    if (base.length != current.length) return true;
    for (int k = 0; k < base.length; k++) {
      if (base[k] != current[k]) return true;
    }
    return false;
  }

  _TokenSegment(this.base, this.current, this.baseIndices);
}

String getProgressiveExpression(
  String baseExpr, 
  String currentExpr, {
  required bool isCompleted,
  int? stepIndex,
  List<Map<String, dynamic>>? steps,
  String? baseExpression,
  int? activeStepIndex,
  bool? activeStepCompleted,
}) {
  final baseTokens = baseExpr.trim().split(RegExp(r'\s+'));
  final currentTokens = currentExpr.trim().split(RegExp(r'\s+'));

  if (currentTokens.length <= 1) {
    return isCompleted ? currentExpr : '';
  }

  // Calcular profundidades de paréntesis y corchetes en baseTokens
  final depths = <int>[];
  int currentDepth = 0;
  for (final token in baseTokens) {
    if (token == '(' || token == '[' || token == '{' || token.contains('(') || token.contains('[') || token.contains('{')) {
      currentDepth++;
    }
    depths.add(currentDepth);
    if (token == ')' || token == ']' || token == '}' || token.contains(')') || token.contains(']') || token.contains('}')) {
      currentDepth--;
    }
  }

  bool isOperatorAt(int idx) {
    if (idx < 0 || idx >= baseTokens.length) return false;
    final val = baseTokens[idx];
    if (val == '(' || val == ')' || val == '[' || val == ']' || val == '{' || val == '}') {
      return false;
    }
    if (['*', '/', '^', 'x', '×', '÷'].contains(val) || val.contains('sqrt') || val.contains('root')) {
      return true;
    }
    return false;
  }

  bool isOperationToken(int idx) {
    if (idx < 0 || idx >= baseTokens.length) return false;
    final val = baseTokens[idx];
    if (val == '(' || val == ')' || val == '[' || val == ']' || val == '{' || val == '}') {
      return false;
    }
    if (isOperatorAt(idx)) return true;
    if (idx > 0 && isOperatorAt(idx - 1)) return true;
    if (idx < baseTokens.length - 1 && isOperatorAt(idx + 1)) return true;
    return false;
  }

  // Helper para identificar el bloque (separados por + o - a profundidad 0) de cada token
  int getBlockIndex(int tokenIdx) {
    int block = 0;
    for (int k = 0; k <= tokenIdx; k++) {
      final val = baseTokens[k];
      final depth = depths[k];
      if (depth == 0 && (val == '+' || val == '-')) {
        block++;
      }
    }
    return block;
  }

  // Alineación LCS
  final n = baseTokens.length;
  final m = currentTokens.length;
  final dp = List.generate(n + 1, (_) => List.filled(m + 1, 0));

  for (int i = 1; i <= n; i++) {
    for (int j = 1; j <= m; j++) {
      if (baseTokens[i - 1] == currentTokens[j - 1]) {
        dp[i][j] = dp[i - 1][j - 1] + 1;
      } else {
        dp[i][j] = dp[i - 1][j] > dp[i][j - 1] ? dp[i - 1][j] : dp[i][j - 1];
      }
    }
  }

  final baseMatched = List.filled(n, false);
  final currentMatched = List.filled(m, false);
  int i = n;
  int j = m;
  while (i > 0 && j > 0) {
    if (baseTokens[i - 1] == currentTokens[j - 1]) {
      baseMatched[i - 1] = true;
      currentMatched[j - 1] = true;
      i--;
      j--;
    } else if (dp[i - 1][j] >= dp[i][j - 1]) {
      i--;
    } else {
      j--;
    }
  }

  final segments = <_TokenSegment>[];
  int basePtr = 0;
  int currentPtr = 0;

  while (basePtr < n || currentPtr < m) {
    if (basePtr < n && currentPtr < m && baseMatched[basePtr] && currentMatched[currentPtr] && baseTokens[basePtr] == currentTokens[currentPtr]) {
      segments.add(_TokenSegment([baseTokens[basePtr]], [currentTokens[currentPtr]], [basePtr]));
      basePtr++;
      currentPtr++;
    } else {
      int nextBaseMatch = basePtr;
      while (nextBaseMatch < n && !baseMatched[nextBaseMatch]) {
        nextBaseMatch++;
      }
      int nextCurrentMatch = currentPtr;
      while (nextCurrentMatch < m && !currentMatched[nextCurrentMatch]) {
        nextCurrentMatch++;
      }

      final baseSeg = baseTokens.sublist(basePtr, nextBaseMatch);
      final currentSeg = currentTokens.sublist(currentPtr, nextCurrentMatch);
      final baseIndices = List.generate(nextBaseMatch - basePtr, (k) => basePtr + k);
      segments.add(_TokenSegment(baseSeg, currentSeg, baseIndices));

      basePtr = nextBaseMatch;
      currentPtr = nextCurrentMatch;
    }
  }

  int lastModifiedIdx = -1;
  if (isCompleted) {
    for (int k = 0; k < segments.length; k++) {
      if (segments[k].isModified) {
        lastModifiedIdx = k;
      }
    }
  } else {
    for (int k = 0; k < segments.length; k++) {
      if (segments[k].isModified) {
        lastModifiedIdx = k;
        break;
      }
    }
  }

  // Identificar cuál es el bloque de la modificación activa
  int modifiedBlockIdx = 0;
  if (lastModifiedIdx != -1) {
    for (final idx in segments[lastModifiedIdx].baseIndices) {
      final b = getBlockIndex(idx);
      if (b > modifiedBlockIdx) {
        modifiedBlockIdx = b;
      }
    }
  }

  int getSegmentBlock(int segIdx) {
    final seg = segments[segIdx];
    if (seg.baseIndices.isNotEmpty) {
      return getBlockIndex(seg.baseIndices.first);
    }
    for (int k = segIdx - 1; k >= 0; k--) {
      if (segments[k].baseIndices.isNotEmpty) {
        return getBlockIndex(segments[k].baseIndices.last);
      }
    }
    for (int k = segIdx + 1; k < segments.length; k++) {
      if (segments[k].baseIndices.isNotEmpty) {
        return getBlockIndex(segments[k].baseIndices.first);
      }
    }
    return 0;
  }

  bool blockHasOperations(int bIdx) {
    for (int k = 0; k < segments.length; k++) {
      if (getSegmentBlock(k) == bIdx) {
        for (final token in segments[k].current) {
          if (['*', '/', '^', 'x', '×', '÷'].contains(token) || token.contains('sqrt') || token.contains('root')) {
            return true;
          }
        }
      }
    }
    return false;
  }

  int getModifiedBlockIdx(String bExpr, String cExpr) {
    final bTokens = bExpr.trim().split(RegExp(r'\s+'));
    final cTokens = cExpr.trim().split(RegExp(r'\s+'));

    if (cTokens.length <= 1) return 0;

    final dps = <int>[];
    int cDepth = 0;
    for (final token in bTokens) {
      if (token == '(' || token == '[' || token == '{' || token.contains('(') || token.contains('[') || token.contains('{')) {
        cDepth++;
      }
      dps.add(cDepth);
      if (token == ')' || token == ']' || token == '}' || token.contains(')') || token.contains(']') || token.contains('}')) {
        cDepth--;
      }
    }

    int getBIndex(int tokenIdx) {
      int block = 0;
      for (int k = 0; k <= tokenIdx; k++) {
        final val = bTokens[k];
        final depth = dps[k];
        if (depth == 0 && (val == '+' || val == '-')) {
          block++;
        }
      }
      return block;
    }

    final nL = bTokens.length;
    final mL = cTokens.length;
    final dpTable = List.generate(nL + 1, (_) => List.filled(mL + 1, 0));

    for (int x = 1; x <= nL; x++) {
      for (int y = 1; y <= mL; y++) {
        if (bTokens[x - 1] == cTokens[y - 1]) {
          dpTable[x][y] = dpTable[x - 1][y - 1] + 1;
        } else {
          dpTable[x][y] = dpTable[x - 1][y] > dpTable[x][y - 1] ? dpTable[x - 1][y] : dpTable[x][y - 1];
        }
      }
    }

    final bMatched = List.filled(nL, false);
    final cMatched = List.filled(mL, false);
    int x = nL;
    int y = mL;
    while (x > 0 && y > 0) {
      if (bTokens[x - 1] == cTokens[y - 1]) {
        bMatched[x - 1] = true;
        cMatched[y - 1] = true;
        x--;
        y--;
      } else if (dpTable[x - 1][y] >= dpTable[x][y - 1]) {
        x--;
      } else {
        y--;
      }
    }

    final segs = <_TokenSegment>[];
    int bPtr = 0;
    int cPtr = 0;

    while (bPtr < nL || cPtr < mL) {
      if (bPtr < nL && cPtr < mL && bMatched[bPtr] && cMatched[cPtr] && bTokens[bPtr] == cTokens[cPtr]) {
        segs.add(_TokenSegment([bTokens[bPtr]], [cTokens[cPtr]], [bPtr]));
        bPtr++;
        cPtr++;
      } else {
        int nextBaseMatch = bPtr;
        while (nextBaseMatch < nL && !bMatched[nextBaseMatch]) {
          nextBaseMatch++;
        }
        int nextCurrentMatch = cPtr;
        while (nextCurrentMatch < mL && !cMatched[nextCurrentMatch]) {
          nextCurrentMatch++;
        }

        final baseSeg = bTokens.sublist(bPtr, nextBaseMatch);
        final currentSeg = cTokens.sublist(cPtr, nextCurrentMatch);
        final baseIndices = List.generate(nextBaseMatch - bPtr, (k) => bPtr + k);
        segs.add(_TokenSegment(baseSeg, currentSeg, baseIndices));

        bPtr = nextBaseMatch;
        cPtr = nextCurrentMatch;
      }
    }

    int lastModIdx = -1;
    for (int k = 0; k < segs.length; k++) {
      if (segs[k].isModified) {
        lastModIdx = k;
      }
    }

    int modBlockIdx = 0;
    if (lastModIdx != -1) {
      for (final idx in segs[lastModIdx].baseIndices) {
        final b = getBIndex(idx);
        if (b > modBlockIdx) {
          modBlockIdx = b;
        }
      }
    }
    return modBlockIdx;
  }

  int getStepBlockIdxRelative(int j, String expr) {
    if (steps == null) return -1;
    for (int idx = j; idx < steps.length; idx++) {
      final override = steps[idx]['override'] as String?;
      if (override != null) {
        return getModifiedBlockIdx(expr, override);
      }
    }
    return -1;
  }

  bool isBlockModifiedByPastSteps(int blockIdx) {
    if (stepIndex == null || steps == null) return false;
    for (int j = 0; j <= stepIndex; j++) {
      if (getStepBlockIdxRelative(j, baseExpr) == blockIdx) {
        return true;
      }
    }
    return false;
  }

  bool isBlockIdxHidden(int blockIdx) {
    return false;
  }

  bool isGroupingSymbol(String token) {
    return token == '(' || token == '[' || token == '{';
  }

  bool isOperandToken(String token) {
    final clean = token.replaceAll(RegExp(r'[\(\)\[\]\{\}\+\-\*\/x×÷\^]'), '').trim();
    return clean.isNotEmpty;
  }

  final output = <String>[];

  void addSegmentTokens(List<String> tokens, List<int> baseIndices, int blockIdx) {
    if (isBlockIdxHidden(blockIdx)) {
      for (int j = 0; j < tokens.length; j++) {
        final t = tokens[j];
        final baseIdx = (j < baseIndices.length) ? baseIndices[j] : -1;
        
        bool show = false;
        if (isGroupingSymbol(t)) {
          show = true;
        } else if (baseIdx != -1) {
          final depth = depths[baseIdx];
          if (depth == 0 && (t == '+' || t == '-')) {
            show = true;
          }
        }
        
        if (show) {
          output.add(t);
        }
      }
    } else {
      output.addAll(tokens);
    }
  }

  for (int k = 0; k < segments.length; k++) {
    final seg = segments[k];
    final blockIdx = getSegmentBlock(k);

    if (k < lastModifiedIdx) {
      addSegmentTokens(seg.current, seg.baseIndices, blockIdx);
    } else if (k == lastModifiedIdx) {
      if (isCompleted) {
        addSegmentTokens(seg.current, seg.baseIndices, blockIdx);
      } else {
        // Para el segmento activo modificado (no completado), no mostramos el resultado,
        // pero mostramos cualquier paréntesis o corchete inicial.
        for (final token in seg.base) {
          if (token == '(' || token == '[' || token == '{' || token.startsWith('sqrt(') || token.startsWith('root') || token.endsWith('(')) {
            output.add(token);
          } else {
            break;
          }
        }
        break; // Truncamos aquí
      }
    } else {
      addSegmentTokens(seg.current, seg.baseIndices, blockIdx);
    }
  }

  // Eliminar carets inválidos si quedaron huérfanos al final (ej: '3 ^')
  while (output.isNotEmpty && output.last == '^') {
    output.removeLast();
  }

  return output.join(' ');
}

void simulateExercise(String baseExpression, List<Map<String, dynamic>> stepOverrides) {
  print("--- Simulating exercise: $baseExpression ---");
  List<String> equationHistory = [baseExpression];
  String? workingLine = baseExpression;

  for (int stepIdx = 0; stepIdx < stepOverrides.length; stepIdx++) {
    final step = stepOverrides[stepIdx];
    final String instruction = step['instruction'];
    final String? override = step['override'];

    print("\n[Step ${stepIdx + 1}] $instruction");

    // Before answering the step (completed = false)
    List<WidgetLine> linesBefore = buildHistoryLines(baseExpression, equationHistory, override, workingLine, false, stepOverrides, stepIdx);
    print("  Before answering:");
    for (var line in linesBefore) {
      print("    = ${line.expr}");
    }

    // After answering (completed = true)
    final workingLineAfter = override ?? workingLine;
    List<WidgetLine> linesAfter = buildHistoryLines(baseExpression, equationHistory, override, workingLineAfter, true, stepOverrides, stepIdx);
    print("  After answering:");
    for (var line in linesAfter) {
      print("    = ${line.expr}");
    }

    // Advance to next step (update history and workingLine)
    if (workingLineAfter != null) {
      final cleanWorking = workingLineAfter.replaceAll(' ', '');
      final isSameAsLast = equationHistory.isNotEmpty && equationHistory.last.replaceAll(' ', '') == cleanWorking;
      if (!isSameAsLast) {
        equationHistory.add(workingLineAfter);
      }
    }
    workingLine = workingLineAfter;
  }
}

class WidgetLine {
  final String expr;
  WidgetLine(this.expr);
}

class _Candidate {
  final String expression;
  final bool isCompleted;
  final int? stepIndex;
  _Candidate(this.expression, this.isCompleted, {this.stepIndex});
}

List<String> getTopLevelOperators(String expr) {
  final tokens = expr.trim().split(RegExp(r'\s+'));
  final operators = <String>[];
  int depth = 0;
  for (final t in tokens) {
    if (t == '(' || t == '[' || t == '{' || t.contains('(') || t.contains('[') || t.contains('{')) {
      depth++;
    }
    if (depth == 0 && (t == '+' || t == '-')) {
      operators.add(t);
    }
    if (t == ')' || t == ']' || t == '}' || t.contains(')') || t.contains(']') || t.contains('}')) {
      depth--;
    }
  }
  return operators;
}

List<WidgetLine> buildHistoryLines(
    String baseExpression,
    List<String> history,
    String? activeOverride,
    String? workingLine,
    bool stepCompleted,
    List<Map<String, dynamic>> steps,
    int currentStepIndex,
) {
  final List<_Candidate> candidateExprs = [];

  String getExpressionAfterStep(int stepIdx) {
    for (int i = stepIdx; i >= 0; i--) {
      final override = steps[i]['override'] as String?;
      if (override != null) return override;
    }
    return baseExpression;
  }

  for (int i = 0; i <= currentStepIndex; i++) {
    final step = steps[i];
    final isCurrent = (i == currentStepIndex);
    if (isCurrent && !stepCompleted) {
      continue;
    }

    final override = step['override'] as String?;
    final instructionText = step['instruction'] as String? ?? '';
    final correctAnsText = step['correctAnswer'] as String? ?? '';
    final isConserve = '$instructionText $correctAnsText'.toLowerCase().contains('conser');

    if (override != null || isConserve) {
      final expr = getExpressionAfterStep(i);
      candidateExprs.add(_Candidate(expr, true, stepIndex: i));
    }
  }

  final List<String> rawProgressiveLines = [];
  for (int i = 0; i < candidateExprs.length; i++) {
    final candidate = candidateExprs[i];
    final prevExpr = (i == 0) ? baseExpression : candidateExprs[i - 1].expression;

    final prog = getProgressiveExpression(
      prevExpr, 
      candidate.expression, 
      isCompleted: candidate.isCompleted,
      stepIndex: candidate.stepIndex,
      steps: steps,
      baseExpression: baseExpression,
      activeStepIndex: currentStepIndex,
      activeStepCompleted: stepCompleted,
    );
    rawProgressiveLines.add(prog);
  }

  final List<String> filteredLines = [];
  final cleanLines = rawProgressiveLines.map((s) => s.replaceAll(' ', '')).toList();

  for (int i = 0; i < rawProgressiveLines.length; i++) {
    final raw = rawProgressiveLines[i].trim();
    if (raw.isEmpty) continue;

    final clean = cleanLines[i];
    bool shouldFilter = false;
    final opsI = getTopLevelOperators(raw);

    for (int j = i + 1; j < rawProgressiveLines.length; j++) {
      final nextRaw = rawProgressiveLines[j].trim();
      final nextClean = cleanLines[j];
      
      // Rule 1: prefix matching
      if (nextClean.startsWith(clean)) {
        shouldFilter = true;
        break;
      }
      
      // Rule 2: same block structure (operators at depth 0)
      final opsJ = getTopLevelOperators(nextRaw);
      if (opsI.length == opsJ.length) {
        bool matches = true;
        for (int k = 0; k < opsI.length; k++) {
          if (opsI[k] != opsJ[k]) {
            matches = false;
            break;
          }
        }
        if (matches) {
          shouldFilter = true;
          break;
        }
      }
    }
    if (!shouldFilter) {
      filteredLines.add(raw);
    }
  }

  return filteredLines.map((e) => WidgetLine(e)).toList();
}

void main() {
  print("=== EASY 1 SIMULATION ===");
  simulateExercise(
    '18 + 3 * 5',
    [
      {'instruction': 'Signos separadores', 'override': null},
      {'instruction': 'Cuantos bloques', 'override': null},
      {'instruction': 'Es correcto afirmar que se resuelve primero', 'override': null},
      {'instruction': 'Cuando en un bloque no hay operaciones se debe', 'correctAnswer': 'conservar', 'override': '18 +'},
      {'instruction': 'El resultado de la operación del segundo bloque es', 'override': '18 + 15'},
      {'instruction': 'El resultado de la última operación es', 'override': '33'},
    ],
  );

  print("\n=== EASY 2 SIMULATION ===");
  simulateExercise(
    '8 - 3 * 2 + 1',
    [
      {'instruction': 'Signos separadores', 'override': null},
      {'instruction': 'Cuantos bloques', 'override': null},
      {'instruction': 'Los bloques en los que se deben conservar', 'correctAnswer': 'conservar', 'override': '8 -'},
      {'instruction': 'El resultado de la operación del segundo bloque', 'override': '8 - 6 + 1'},
      {'instruction': 'El resultado de la última operación', 'override': '3'},
    ],
  );

  print("\n=== EASY 5 SIMULATION ===");
  simulateExercise(
    '1 + 12 / 4 - 1 + 2 ^ 3',
    [
      {'instruction': 'Signos separadores', 'override': null},
      {'instruction': 'Cuantos bloques', 'override': null},
      {'instruction': 'Los bloques en los que se deben conservar', 'correctAnswer': 'conservar', 'override': '1 +'},
      {'instruction': 'Se pueden resolver la división y la potenciación', 'override': null},
      {'instruction': 'El resultado de la división del segundo bloque', 'override': '1 + 3'},
      {'instruction': 'El resultado de la potencia del cuarto bloque', 'override': '1 + 3 - 1 + 8'},
      {'instruction': 'El resultado de las últimas operaciones', 'override': '11'},
    ],
  );

  print("\n=== EASY 7 SIMULATION ===");
  simulateExercise(
    'sqrt( 4 + 12 ) - 15 / 5',
    [
      {'instruction': 'Signos separadores', 'override': null},
      {'instruction': 'Cuantos bloques', 'override': null},
      {'instruction': 'Que se hace primero en bloque 1', 'override': null},
      {'instruction': 'Suma primer bloque', 'override': 'sqrt( 16 ) - 15 / 5'},
      {'instruction': 'Se pueden resolver a la vez', 'override': null},
      {'instruction': 'Resultado division segundo bloque', 'override': 'sqrt( 16 ) - 3'},
      {'instruction': 'Que se debe resolver primero', 'override': null},
      {'instruction': 'Resultado raiz cuadrada primer bloque', 'override': '4'},
      {'instruction': '¿Qué acción hacemos con el 3?', 'correctAnswer': 'conservar', 'override': '4 - 3'},
      {'instruction': 'Resultado de la ultima operacion', 'override': '1'},
    ],
  );

  print("\n=== EASY 10 SIMULATION ===");
  simulateExercise(
    '( 2 + 10 / 5 ) * 2 ^ 2 - 3',
    [
      {'instruction': 'Signos separadores', 'override': null},
      {'instruction': 'Cuantos bloques', 'override': null},
      {'instruction': 'Que se resuelve primero', 'override': null},
      {'instruction': 'El resultado de la división 10 ÷ 5 es', 'override': '( 2 + 2 ) * 2 ^ 2 - 3'},
      {'instruction': 'Que se resuelve ahora', 'override': null},
      {'instruction': 'El resultado de la suma 2 + 2 es', 'override': '4 * 2 ^ 2 - 3'},
      {'instruction': 'Que operacion se resuelve primero', 'override': null},
      {'instruction': 'El resultado de la potencia 2^2 es', 'override': '4 * 4 - 3'},
      {'instruction': 'Que se resuelve ahora', 'override': null},
      {'instruction': 'El resultado de la multiplicacion 4 x 4 es', 'override': '16 - 3'},
      {'instruction': 'Resultado de la ultima operacion', 'override': '13'},
    ],
  );

  print("\n=== MEDIUM 1 SIMULATION ===");
  simulateExercise(
    '3 ^ 6 / 3 ^ 4 - 2 * ( 5 - 2 )',
    [
      {'instruction': 'Signos separadores', 'override': null},
      {'instruction': 'Cuantos bloques', 'override': null},
      {'instruction': 'En el primer bloque se debe:', 'override': null},
      {'instruction': 'Al aplicar la propiedad de división de potencias de igual base en el primer bloque, el resultado es:', 'override': '3 ^ 2 - 2 * ( 5 - 2 )'},
      {'instruction': '¿Cuánto es 3^2?', 'override': '9 - 2 * ( 5 - 2 )'},
      {'instruction': 'En el segundo bloque, ¿qué operación se debe resolver primero?', 'override': null},
      {'instruction': 'El resultado de la resta 5 - 2 es:', 'override': '9 - 2 * 3'},
      {'instruction': 'En el segundo bloque, ¿qué operación se debe resolver ahora?', 'override': null},
      {'instruction': 'El resultado de la multiplicación 2 x 3 es:', 'override': '9 - 6'},
      {'instruction': 'El resultado final es:', 'override': '3'},
    ],
  );
}

