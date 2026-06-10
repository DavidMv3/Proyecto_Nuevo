/// Tipo de cada pieza/token de la ecuación.
enum TokenType {
  number,       // Ej: 18, 4, 2, 5
  operator,     // Ej: +, -, *
  parenthesis,  // Ej: (, )
}

/// Representa un elemento atómico clickeable dentro de una ecuación.
class EquationToken {
  /// Identificador único basado en posición (ej. "t0", "t1"...)
  final String id;

  /// El texto visible del token (ej. "18", "+", "(")
  final String value;

  /// Categoría del token para el motor de validación
  final TokenType type;

  const EquationToken({
    required this.id,
    required this.value,
    required this.type,
  });

  /// Convierte una expresión en cadena a una lista de [EquationToken].
  /// Se asume que cada elemento está separado por un espacio.
  ///
  /// Ejemplo: "18 + ( 4 * 2 ) - 5"
  static List<EquationToken> fromExpression(String expression) {
    final parts = expression.trim().split(' ');
    return List.generate(parts.length, (i) {
      final val = parts[i];
      TokenType type;
      if (val == '(' || val == ')' || val == '[' || val == ']') {
        type = TokenType.parenthesis;
      } else if (['+', '-', '*', '/', 'x', '÷', '×'].contains(val)) {
        type = TokenType.operator;
      } else {
        type = TokenType.number;
      }
      return EquationToken(id: 't$i', value: val, type: type);
    });
  }
}
