import zipfile
import xml.etree.ElementTree as ET
import sys
import io

# Force stdout to use utf-8
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

def extract_text(xml_content, tag_name='w:t'):
    try:
        root = ET.fromstring(xml_content)
        ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
        output = []
        for t in root.findall(f'.//{tag_name}', ns):
            if t.text:
                output.append(t.text)
        return '\n'.join(output)
    except Exception as e:
        return f"Error: {e}"

if __name__ == "__main__":
    file_path = "c:\\Users\\Desktop\\Projects\\stira\\stira_notification_layer.docx"
    with zipfile.ZipFile(file_path) as z:
        for target in ['word/document.xml', 'word/comments.xml', 'word/footer1.xml']:
            if target in z.namelist():
                print(f"--- {target} ---")
                print(extract_text(z.read(target)))
                print("\n")
