from logging import captureWarnings
import subprocess
from os import listdir


filename = "./toplevel.native"
testsPath = "./tests/"
args = "./tests/test0.roll"

onlyfiles = [f for f in listdir(testsPath)]
for f in onlyfiles:
    f = testsPath + f
    output = subprocess.run([filename, f], capture_output=True)
    if output.stderr != b'':
        print(f + ": Failed")
    else:
        print(f + ": Passed")
