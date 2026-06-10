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

    # StepEntity regex pattern
    step_pattern = r'(StepEntity\(\s*id:\s*\'([^\'\s]+)\',.*?\n\s*\),?)'

    def replacer(match):
        step_text = match.group(0)

        # 1. Modify instruction
        def repl_instruction(m):
            text = m.group(1)
            # replace * with x
            text = text.replace('*', 'x')
            # replace / with ÷
            text = text.replace('/', '÷')
            # replace U+00D7 (×) with x
            text = text.replace('×', 'x')
            # replace : between numbers with ÷
            text = re.sub(r'(\d+)\s*:\s*(\d+)', r'\1 ÷ \2', text)
            return f"instruction: '{text}'"
        step_text = re.sub(r"instruction:\s*\'([^\']*)\'", repl_instruction, step_text)

        # 2. Modify options
        def repl_options(m):
            opts_raw = m.group(1)
            # We want to replace inside the single-quoted strings
            def repl_opt_str(ms):
                opt_str = ms.group(1)
                opt_str = opt_str.replace('*', 'x')
                opt_str = opt_str.replace('/', '÷')
                opt_str = opt_str.replace('×', 'x')
                opt_str = re.sub(r'(\d+)\s*:\s*(\d+)', r'\1 ÷ \2', opt_str)
                return f"'{opt_str}'"
            new_opts_raw = re.sub(r"\'([^\']*)\'", repl_opt_str, opts_raw)
            return f"options: [{new_opts_raw}]"
        step_text = re.sub(r"options:\s*\[([^\]]*)\]", repl_options, step_text)

        # 3. Modify correctAnswer
        def repl_correct_answer(m):
            text = m.group(1)
            text = text.replace('*', 'x')
            text = text.replace('/', '÷')
            text = text.replace('×', 'x')
            text = re.sub(r'(\d+)\s*:\s*(\d+)', r'\1 ÷ \2', text)
            return f"correctAnswer: '{text}'"
        step_text = re.sub(r"correctAnswer:\s*\'([^\']*)\'", repl_correct_answer, step_text)

        # 4. Modify feedbackError
        def repl_feedback_error(m):
            text = m.group(1)
            text = text.replace('*', 'x')
            text = text.replace('/', '÷')
            text = text.replace('×', 'x')
            text = re.sub(r'(\d+)\s*:\s*(\d+)', r'\1 ÷ \2', text)
            return f"feedbackError: '{text}'"
        step_text = re.sub(r"feedbackError:\s*\'([^\']*)\'", repl_feedback_error, step_text)

        return step_text

    # Run replacements on StepEntity blocks
    new_content = re.sub(r'StepEntity\(\s*id:\s*\'[^\']+\',.*?\n\s*\),?', replacer, content, flags=re.DOTALL)

    with open(repo_path, "w", encoding="utf-8") as f:
        f.write(new_content)

    print("Replacement of operators in exercise_repository.dart completed successfully!")

if __name__ == "__main__":
    main()
