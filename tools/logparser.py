import re


def parseLog(log):
    res = True
    for line in log.split('\n'):
        pat = re.search(r':([a-z]+):(.*)', line.strip())
        if pat:
            if pat.group(1) == 'assert':
                expr = pat.group(2)
                try:
                    if not eval(expr):
                        res = False
                except Exception:
                    res = False
    return res
