import xml.etree.ElementTree as ET
import copy

def split_svg():
    original_path = 'assets/avatar/jerseys/basic.svg'
    ET.register_namespace('', "http://www.w3.org/2000/svg")
    ET.register_namespace('inkscape', "http://www.inkscape.org/namespaces/inkscape")
    ET.register_namespace('sodipodi', "http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd")
    
    tree = ET.parse(original_path)
    root = tree.getroot()
    ns = {'svg': 'http://www.w3.org/2000/svg'}

    # Strategy:
    # 1. Base (Body): path18851
    # 2. Layer 2: path24639 (The big complex path in g24721)
    # 3. Layer 3: Everything else in g24721

    # Find the main group g18855
    g_main = None
    for g in root.findall('.//svg:g', ns):
        if g.get('id') == 'g18855':
            g_main = g
            break
            
    if g_main is None:
        print("Error: g18855 not found")
        return

    # Find inner group g24721
    g_inner = None
    for g in g_main.findall('.//svg:g', ns):
        if g.get('id') == 'g24721':
            g_inner = g
            break

    if g_inner is None:
        print("Error: g24721 not found")
        return

    # Create Layer 1: Keep only path18851 in g_main (remove g_inner)
    tree1 = copy.deepcopy(tree)
    root1 = tree1.getroot()
    g_main1 = root1.find('.//*[@id="g18855"]', ns)
    # Remove g24721 from g18855
    for child in list(g_main1):
        if child.get('id') == 'g24721':
            g_main1.remove(child)
    tree1.write('assets/avatar/jerseys/jersey_layer_1.svg', encoding='UTF-8', xml_declaration=True)
    print("Created jersey_layer_1.svg")

    # Create Layer 2: Keep only path24639 inside g_inner
    tree2 = copy.deepcopy(tree)
    root2 = tree2.getroot()
    g_main2 = root2.find('.//*[@id="g18855"]', ns)
    # Remove path18851 from g18855
    for child in list(g_main2):
        if child.get('id') == 'path18851':
            g_main2.remove(child)
    
    g_inner2 = g_main2.find('.//*[@id="g24721"]', ns)
    # Keep only path24639 in g_inner2
    for child in list(g_inner2):
        if child.get('id') != 'path24639':
            g_inner2.remove(child)
            
    tree2.write('assets/avatar/jerseys/jersey_layer_2.svg', encoding='UTF-8', xml_declaration=True)
    print("Created jersey_layer_2.svg")

    # Create Layer 3: Keep everything else inside g_inner
    tree3 = copy.deepcopy(tree)
    root3 = tree3.getroot()
    g_main3 = root3.find('.//*[@id="g18855"]', ns)
    # Remove path18851 from g18855
    for child in list(g_main3):
        if child.get('id') == 'path18851':
            g_main3.remove(child)
            
    g_inner3 = g_main3.find('.//*[@id="g24721"]', ns)
    # Remove path24639 from g_inner3
    for child in list(g_inner3):
        if child.get('id') == 'path24639':
            g_inner3.remove(child)
            
    tree3.write('assets/avatar/jerseys/jersey_layer_3.svg', encoding='UTF-8', xml_declaration=True)
    print("Created jersey_layer_3.svg")

if __name__ == '__main__':
    split_svg()
