import sys
import os
print(os.getcwd())
sys.path.append("paperbnf-repo")
import paperbnf
from wisepy2 import wise

def call(file_in, file_out):
    with open(file_in) as f:
        src = f.read()
    res = paperbnf.parse(src, file_in)
    with open(file_out, 'w') as f:
        f.write(res)

if __name__ == "__main__":
    wise(call)()