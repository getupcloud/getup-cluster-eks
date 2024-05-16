#!/usr/bin/env python

import re
import sys
import json

output_re = re.compile('^(\s*)([^\s]+):\s+(.*)#output:(.+)$')

with open(sys.argv[1], 'r') as f:
    data = json.load(f)

for k, v in data.items():
    data[k] = v["value"]

with open(sys.argv[2], 'r') as f:
    for line in f.readlines():
        if '#output:' not in line:
            print(line, end='')
            continue

        match = output_re.match(line)
        if not match:
            print(line, end='')
            continue

        try:
            indent, name, _, tpl = match.groups()
            value = eval(f"f'{tpl}'", data)
            print(f'{indent}{name}: {value} #output:{tpl}')
        except NameError:
            print(line, end='')
