import re
import urllib.parse
import sys

def process_math(content):
    # Regex to find $...$ (inline math)
    # We use a non-greedy match and avoid matching things that aren't actually math
    # but for most purposes in this book, $...$ will be math.
    
    def replace_math(match):
        # Determine which group matched (Standard Block $$, User Block $\n...\n$, or Inline $...$)
        latex = match.group(1) or match.group(2) or match.group(3)
        latex = latex.strip()
        
        # Simplify the styled latex to avoid 400 errors
        # Use \large for better base resolution
        styled_latex = f"\\large {latex}"
        
        safe_latex = urllib.parse.quote(styled_latex)
        img_url = f"https://latex.codecogs.com/svg.latex?{safe_latex}"
        
        return f'<img class="math-formula" src="{img_url}" alt="{latex}">'

    # Matches:
    # 1. $$...$$ (Standard Block Math)
    # 2. $\n...\n$ (User's newline style Block Math)
    # 3. $...$ (Inline Math, no newlines)
    pattern = r'(?<!\\)\$\$([\s\S]+?)\$\$|(?<!\\)\$\n([\s\S]+?)\n\$|(?<!\\)\$([^\$\n]+)\$'
    result = re.sub(pattern, replace_math, content)
    
    # After math processing, unescape \$ to plain $ for normal currency text
    result = result.replace('\\$', '$')
    return result

if __name__ == "__main__":
    if len(sys.argv) < 2:
        content = sys.stdin.read()
    else:
        with open(sys.argv[1], "r") as f:
            content = f.read()

    print(process_math(content))
