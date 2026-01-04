import re
import os
import subprocess
import sys
import hashlib

def process_mermaid(content, output_dir, mmdc_path):
    """
    Finds mermaid blocks, converts them to PNGs, and replaces blocks with image links.
    """
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    def replace_mermaid(match):
        mermaid_code = match.group(1)
        
        # Create a hash of the code to use as filename (avoids regenerating same diagrams)
        code_hash = hashlib.md5(mermaid_code.encode('utf-8')).hexdigest()
        image_filename = f"mermaid_{code_hash}.png"
        image_path = os.path.join(output_dir, image_filename)
        
        # Only generate if it doesn't exist
        if not os.path.exists(image_path):
            temp_mmd = os.path.join(output_dir, f"temp_{code_hash}.mmd")
            with open(temp_mmd, "w") as f:
                f.write(mermaid_code)
            
            # Run mmdc
            # Using -b transparent for background
            cmd = [mmdc_path, "-i", temp_mmd, "-o", image_path, "-b", "transparent", "--scale", "2"]
            try:
                subprocess.run(cmd, check=True, capture_output=True)
            except subprocess.CalledProcessError as e:
                print(f"Error generating mermaid diagram: {e.stderr.decode()}", file=sys.stderr)
                return match.group(0) # Return original on error
            finally:
                if os.path.exists(temp_mmd):
                    os.remove(temp_mmd)
        
        # Return the markdown image link
        # We use a relative path suitable for the final HTML/PDF generation context
        # Assuming the HTML is generated in 07_Exports/ and images are in 04_Resources/images/generated/
        # The relative path from 07_Exports/ to 04_Resources/ is ../04_Resources/
        
        relative_path = f"../04_Resources/images/generated/{image_filename}"
        return f"![Mermaid Diagram]({relative_path})"

    # Regex to find mermaid blocks
    # Matches ```mermaid ... ```
    pattern = r"```mermaid\n(.*?)\n```"
    return re.sub(pattern, replace_mermaid, content, flags=re.DOTALL)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python process_mermaid.py <input_md_file>")
        sys.exit(1)

    input_file = sys.argv[1]
    
    # Path to mmdc executable
    # Assuming run from root or scripts dir, try to find node_modules
    project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    mmdc_path = os.path.join(project_root, "node_modules", ".bin", "mmdc")
    
    output_images_dir = os.path.join(project_root, "04_Resources", "images", "generated")

    with open(input_file, "r") as f:
        content = f.read()

    processed_content = process_mermaid(content, output_images_dir, mmdc_path)
    
    print(processed_content)
