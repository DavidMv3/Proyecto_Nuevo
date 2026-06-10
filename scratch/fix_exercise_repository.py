import re
import sys

def main():
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass
    repo_path = r"lib/data/repositories/exercise_repository.dart"
    with open(repo_path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Direct fixes for specific step IDs
    # We will look for StepEntity definitions and replace them.

    # medium_2_s3
    content = content.replace(
        """          id: 'medium_2_s3',
          instruction: 'En el primer bloque, ¿qué operación se debe resolver primero?',
          options: ['La resta 22 - 20', 'La multiplicación 23 * 22', 'La propiedad del producto de potencias de igual base', 'La suma 23 + 22'],
          correctIds: [],""",
        """          id: 'medium_2_s3',
          instruction: 'En el primer bloque, ¿qué operación se debe resolver primero?',
          options: ['La resta 22 - 20', 'La multiplicación 23 * 22', 'La propiedad del producto de potencias de igual base', 'La suma 23 + 22'],
          correctAnswer: 'La propiedad del producto de potencias de igual base',
          correctIds: [],"""
    )

    # medium_2_s11
    content = content.replace(
        """          id: 'medium_2_s11',
          instruction: 'El resultado de la última operación es/',
          expressionOverride: '27',
          options: ['25'],
          correctIds: [],
          algorithmHint: 'Resuelve la operación indicada con cuidado.',
          feedbackError: 'El resultado correcto de esta operación es .',""",
        """          id: 'medium_2_s11',
          instruction: 'El resultado de la última operación es/',
          expressionOverride: '27',
          options: ['25', '26', '27', '28'],
          correctAnswer: '27',
          correctIds: [],
          algorithmHint: 'Resuelve la operación indicada con cuidado.',
          feedbackError: 'El resultado de la suma 12 + 15 es 27.',"""
    )

    # medium_3_s3
    content = content.replace(
        """          id: 'medium_3_s3',
          instruction: 'En el primer bloque, ¿qué operación se debe resolver primero?',
          options: ['La suma 32 + 7', 'La división 34 / 3 2', 'La propiedad de división de potencias de igual base', 'La resta entre bloques'],
          correctIds: [],""",
        """          id: 'medium_3_s3',
          instruction: 'En el primer bloque, ¿qué operación se debe resolver primero?',
          options: ['La suma 32 + 7', 'La división 34 / 3 2', 'La propiedad de división de potencias de igual base', 'La resta entre bloques'],
          correctAnswer: 'La propiedad de división de potencias de igual base',
          correctIds: [],"""
    )

    # medium_3_s11
    content = content.replace(
        """          id: 'medium_3_s11',
          instruction: 'El resultado de la última operación es/',
          expressionOverride: '1',
          correctIds: [],
          algorithmHint: 'Resuelve la operación indicada con cuidado.',
          feedbackError: 'El resultado correcto de esta operación es .',""",
        """          id: 'medium_3_s11',
          instruction: 'El resultado de la última operación es/',
          expressionOverride: '1',
          options: ['0', '1', '2', '31'],
          correctAnswer: '1',
          correctIds: [],
          algorithmHint: 'Resuelve la operación indicada con cuidado.',
          feedbackError: 'El resultado de la resta 16 - 15 es 1.',"""
    )

    # medium_4_s11
    content = content.replace(
        """          id: 'medium_4_s11',
          instruction: 'El resultado de la última operación es/',
          expressionOverride: '22',
          correctIds: [],
          algorithmHint: 'Resuelve la operación indicada con cuidado.',
          feedbackError: 'El resultado correcto de esta operación es .',""",
        """          id: 'medium_4_s11',
          instruction: 'El resultado de la última operación es/',
          expressionOverride: '22',
          options: ['20', '21', '22', '23'],
          correctAnswer: '22',
          correctIds: [],
          algorithmHint: 'Resuelve la operación indicada con cuidado.',
          feedbackError: 'El resultado de la suma 6 + 16 es 22.',"""
    )

    # medium_5_s11
    content = content.replace(
        """          id: 'medium_5_s11',
          instruction: 'El resultado de la última operación es/',
          expressionOverride: '25',
          options: ['23'],
          correctIds: [],
          algorithmHint: 'Resuelve la operación indicada con cuidado.',
          feedbackError: 'El resultado correcto de esta operación es .',""",
        """          id: 'medium_5_s11',
          instruction: 'El resultado de la última operación es/',
          expressionOverride: '25',
          options: ['23', '24', '25', '26'],
          correctAnswer: '25',
          correctIds: [],
          algorithmHint: 'Resuelve la operación indicada con cuidado.',
          feedbackError: 'El resultado de la suma 4 + 21 es 25.',"""
    )

    # medium_8_s3
    content = content.replace(
        """          id: 'medium_8_s3',
          instruction: 'En el primer bloque, ¿qué se debe resolver primero?',
          options: ['La división √ 144 / √ 16', 'La propiedad de división de raíces con el mismo índice', 'La suma con20', 'La resta entre bloques'],
          correctIds: [],""",
        """          id: 'medium_8_s3',
          instruction: 'En el primer bloque, ¿qué se debe resolver primero?',
          options: ['La división √ 144 / √ 16', 'La propiedad de división de raíces con el mismo índice', 'La suma con20', 'La resta entre bloques'],
          correctAnswer: 'La propiedad de división de raíces con el mismo índice',
          correctIds: [],"""
    )

    # medium_8_s10
    content = content.replace(
        """          id: 'medium_8_s10',
          instruction: 'En el primer bloque, ¿qué se debe resolver ahora?',
          options: ['La suma √ 9 + 20', 'La raíz cuadrada √ 9', 'La resta entre bloques', 'La división 144 / 16'],
          correctIds: [],""",
        """          id: 'medium_8_s10',
          instruction: 'En el primer bloque, ¿qué se debe resolver ahora?',
          options: ['La suma √ 9 + 20', 'La raíz cuadrada √ 9', 'La resta entre bloques', 'La división 144 / 16'],
          correctAnswer: 'La raíz cuadrada √ 9',
          correctIds: [],"""
    )

    # medium_8_s13
    content = content.replace(
        """          id: 'medium_8_s13',
          instruction: 'El resultado de la última operación es/',
          expressionOverride: '8',
          options: ['6', '7', '8', '9'],
          correctIds: [],
          algorithmHint: 'Resuelve la operación indicada con cuidado.',
          feedbackError: 'El resultado correcto de esta operación es .',""",
        """          id: 'medium_8_s13',
          instruction: 'El resultado de la última operación es/',
          expressionOverride: '8',
          options: ['6', '7', '8', '9'],
          correctAnswer: '8',
          correctIds: [],
          algorithmHint: 'Resuelve la operación indicada con cuidado.',
          feedbackError: 'El resultado de la resta 23 - 15 es 8.',"""
    )

    # medium_9_s4
    content = content.replace(
        """          id: 'medium_9_s4',
          instruction: 'Al aplicar la propiedad raíz de raíz en p√ 81, el resultado queda/',
          expressionOverride: '[ root4( 81 ) + 4 ^ 2 ] - [ 30 / 5 - 3 ]',
          options: ['4√ 81', '√ 81', '3√ 81', '812'],
          correctIds: [],""",
        """          id: 'medium_9_s4',
          instruction: 'Al aplicar la propiedad raíz de raíz en p√ 81, el resultado queda/',
          expressionOverride: '[ root4( 81 ) + 4 ^ 2 ] - [ 30 / 5 - 3 ]',
          options: ['4√ 81', '√ 81', '3√ 81', '812'],
          correctAnswer: '4√ 81',
          correctIds: [],"""
    )

    # medium_9_s9
    content = content.replace(
        """          id: 'medium_9_s9',
          instruction: 'En el primer bloque, ¿qué se debe resolver ahora?',
          options: ['La raíz cuarta 4√ 81', 'La suma 4√ 81 + 16', 'La resta del segundo bloque', 'La suma entre bloques'],
          correctIds: [],""",
        """          id: 'medium_9_s9',
          instruction: 'En el primer bloque, ¿qué se debe resolver ahora?',
          options: ['La raíz cuarta 4√ 81', 'La suma 4√ 81 + 16', 'La resta del segundo bloque', 'La suma entre bloques'],
          correctAnswer: 'La raíz cuarta 4√ 81',
          correctIds: [],"""
    )

    # medium_10_s11
    content = content.replace(
        """          id: 'medium_10_s11',
          instruction: 'En el segundo bloque, ¿qué se debe resolver ahora?',
          options: ['La resta 36 - 3', 'La raíz cuadrada √ 36', 'La suma 36 + 16', 'La resta entre bloques'],
          correctIds: [],""",
        """          id: 'medium_10_s11',
          instruction: 'En el segundo bloque, ¿qué se debe resolver ahora?',
          options: ['La resta 36 - 3', 'La raíz cuadrada √ 36', 'La suma 36 + 16', 'La resta entre bloques'],
          correctAnswer: 'La raíz cuadrada √ 36',
          correctIds: [],"""
    )

    # hard_5_s1
    content = content.replace(
        """          id: 'hard_5_s1',
          instruction: 'En la expresión aritmética, ¿qué elemento se debe conservar inicialmente?',
          options: ['El número 3 que está fuera del corchete', 'La resta', 'La división', 'La suma'],
          correctIds: [],""",
        """          id: 'hard_5_s1',
          instruction: 'En la expresión aritmética, ¿qué elemento se debe conservar inicialmente?',
          options: ['El número 3 que está fuera del corchete', 'La resta', 'La división', 'La suma'],
          correctAnswer: 'El número 3 que está fuera del corchete',
          correctIds: [],"""
    )

    # hard_6_s5
    content = content.replace(
        """          id: 'hard_6_s5',
          instruction: 'En el tercer bloque, ¿qué se debe resolver primero?',
          options: ['La raíz cuadrada exterior', 'La propiedad de la raíz cúbica de una potencia', 'La suma final', 'La resta'],
          correctIds: [],""",
        """          id: 'hard_6_s5',
          instruction: 'En el tercer bloque, ¿qué se debe resolver primero?',
          options: ['La raíz cuadrada exterior', 'La propiedad de la raíz cúbica de una potencia', 'La suma final', 'La resta'],
          correctAnswer: 'La propiedad de la raíz cúbica de una potencia',
          correctIds: [],"""
    )

    # hard_6_s8
    content = content.replace(
        """          id: 'hard_6_s8',
          instruction: 'Entre las operaciones que quedaron ¿cuál tiene mayor jerarquía?',
          options: ['La propiedad de la raíz cuadrada de una potencia', 'La suma 20 + 2', 'La resta', 'La suma final'],
          correctIds: [],""",
        """          id: 'hard_6_s8',
          instruction: 'Entre las operaciones que quedaron ¿cuál tiene mayor jerarquía?',
          options: ['La propiedad de la raíz cuadrada de una potencia', 'La suma 20 + 2', 'La resta', 'La suma final'],
          correctAnswer: 'La propiedad de la raíz cuadrada de una potencia',
          correctIds: [],"""
    )

    # hard_9_s22
    content = content.replace(
        """          id: 'hard_9_s22',
          instruction: 'El resultado de las operaciones finales es/',
          expressionOverride: '180',
          options: ['170', '180'],
          correctIds: [],
          algorithmHint: 'Resuelve la operación indicada con cuidado.',
          feedbackError: 'El resultado correcto de esta operación es .',""",
        """          id: 'hard_9_s22',
          instruction: 'El resultado de las operaciones finales es/',
          expressionOverride: '180',
          options: ['170', '180'],
          correctAnswer: '180',
          correctIds: [],
          algorithmHint: 'Resuelve la operación indicada con cuidado.',
          feedbackError: 'El resultado de las operaciones 249 - 5 - 64 es 180.',"""
    )

    # 2. Automated normalization for symbol mismatches
    # Let's find each StepEntity and fix symbol mismatches.
    def normalize(s):
        return s.replace(' ', '').replace('×', '*').replace('÷', '/').replace(':', '/').replace('−', '-').lower()

    pattern = r'(StepEntity\(\s+id:\s*\'[^\']+\',.*?\n\s+\),?)'
    
    def replacer(match):
        step_text = match.group(1)
        # Find options
        options_match = re.search(r'options:\s*\[([^\]]*)\]', step_text)
        if not options_match:
            return step_text
        opts_raw = options_match.group(1)
        options = [opt.strip().strip("'").strip('"') for opt in opts_raw.split(',') if opt.strip()]
        if not options:
            return step_text
            
        correct_answer_match = re.search(r'correctAnswer:\s*\'([^\']*)\'', step_text)
        if not correct_answer_match:
            return step_text
        correct_answer = correct_answer_match.group(1)
        if not correct_answer or correct_answer in options:
            return step_text
            
        # We have a mismatch! Let's find the matching normalized option
        norm_ans = normalize(correct_answer)
        for opt in options:
            if normalize(opt) == norm_ans:
                # Replace correctAnswer in step_text
                print(f"Fixing mismatch: '{correct_answer}' -> '{opt}'")
                step_text = step_text.replace(f"correctAnswer: '{correct_answer}'", f"correctAnswer: '{opt}'")
                break
        return step_text

    # Use re.sub with replacer function. We must do it on the whole file but be careful with multi-line matches.
    # re.DOTALL is important so . matches newline.
    fixed_content = re.sub(r'(StepEntity\(\s*id:\s*\'[^\']+\',.*?\n\s*\),?)', replacer, content, flags=re.DOTALL)

    with open(repo_path, "w", encoding="utf-8") as f:
        f.write(fixed_content)

    print("Fix script completed successfully!")

if __name__ == "__main__":
    main()
