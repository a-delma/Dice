from logging import captureWarnings
import subprocess
from os import listdir
import sys

filename = "./toplevel.native"
testsPath = "./tests/"

onlyfiles = [f for f in listdir(testsPath)]
a_test_has_failed = False
for f in onlyfiles:
    f = testsPath + f
    output = subprocess.run([filename, f], capture_output=True)
    if output.stderr != b'':
        print(f + ": Failed")
        a_test_has_failed = True
    else:
        print(f + ": Passed")
if (a_test_has_failed):
    sys.exit(1)
