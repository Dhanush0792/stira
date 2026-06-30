import zipfile
import xml.etree.ElementTree as ET
import sys
import os

def extract_text_from_xml(xml_content):
    try:
        root = ET.fromstring(xml_content)
        ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
        output = []
        for p in root.findall('.//w:p', ns):
            p_text = ""
            for t in p.findall('.//w:t', ns):
                if t.text:
                    p_text += t.text
            if p_text:
                output.append(p_text)
        return '\n'.join(output)
    except Exception as e:
        return f"Error: {e}"

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python read_docx_raw.py <path_to_docx>")
    else:
        file_path = sys.argv[1]
        try:
            with zipfile.ZipFile(file_path) as z:
                all_text = []
                for name in z.namelist():
                    if name.startswith('word/') and name.endswith('.xml'):
                        xml_content = z.read(name)
                        text = extract_text_from_xml(xml_content)
                        if text:
                            all_text.append(f"--- FILE: {name} ---")
                            all_text.append(text)
                print('\n\n'.join(all_text))
        except Exception as e:
            print(f"Error: {e}")
