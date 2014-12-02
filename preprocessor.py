# Copyright (c) 2014 Frederico Zica. All Rights Reserved.

#!/usr/bin/python

import sys
import re
import os

#TODO:ensure this is the right way to find the files in the folders
def handle_includes(content, abs_path):
    new_content = content

    ms = re.finditer("(\.INCLUDE|#include) (.)(.+)(.)", new_content)

    for m in ms:
        appnotes_file =  'Appnotes/' + m.group(3)
        currentdir_file = abs_path + '/' + m.group(3)
        if m.group(2) == '\"':
            fname = currentdir_file 
            if not os.path.isfile(fname):
                fname = appnotes_file
        elif m.group(2) == '<':
            fname = appnotes_file

        with open(fname) as f:
            included_file = handle_includes(f.read(), abs_path)
        
        new_content = new_content.replace(m.group(0), included_file)

    return new_content

#FIXME: Def and set can be redefined later in the file. This behaviour won't work
def handle_equ_def_set(txt):
    regex_p = r"\.(equ|def|set)\s*(.+?)\s*=\s*(.+?)(\s+|$)"
    ms = re.findall(regex_p, txt, flags = re.IGNORECASE)
    new_txt = re.sub(regex_p + "\n", "", txt, flags = re.IGNORECASE | re.MULTILINE)

    word_boundary = r"\b"
    #reversed so it can replace symbols defined with other symbols
    for m in reversed(ms):
        new_txt = re.sub(word_boundary + m[1] + word_boundary, m[2], new_txt, flags = re.IGNORECASE)

    return new_txt

def remove_comments(txt):
    #unit tests
    new_txt = re.sub("(^;@v)", "v", txt, flags = re.MULTILINE)

    new_txt = re.sub("(^;.*$\n)", "", new_txt, flags = re.MULTILINE)
    new_txt = re.sub("(\/\*.*\*\/)", "", new_txt, flags = re.MULTILINE)
    new_txt = re.sub("(;.*)", "", new_txt)
    new_txt = re.sub("(\/\/.*)", "", new_txt)

    return new_txt


def process_literals(txt):
    #binary
    new_txt = convert_numbers(txt, r"\b(0b)([0-9]+)\b", 2)

    #hexadecimal
    new_txt = convert_numbers(new_txt, r"(\$|\b0x)([0-9abcdefABCDEF]+)\b", 16)

    #octal
    new_txt = convert_numbers(new_txt, r"\b(0)([0-9]+)\b", 8)

    return new_txt


def convert_numbers(txt, regex, base):
    new_txt = txt
    ms = re.finditer(regex, new_txt)

    for m in ms:
        int_value = int(m.group(len(m.groups())), base)
        new_txt = new_txt.replace(m.group(0), str(int_value), 1)
    
    return new_txt

filename = sys.argv[1]
abs_path = sys.argv[2]

with open(filename, 'r') as fr:
    content = fr.read()

content = handle_includes(content, abs_path)
content = handle_equ_def_set(content)
content = remove_comments(content)
content = process_literals(content)

with open(filename, 'w') as fw:
    fw.write(content)

