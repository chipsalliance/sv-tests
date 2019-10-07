import os

from BaseRunner import BaseRunner


class Verilator(BaseRunner):
    def __init__(self):
        super().__init__("verilator", "verilator")

        self.url = "https://www.veripool.org/wiki/verilator"

    def prepare_run_cb(self, tmp_dir, params):
        scr = os.path.join(tmp_dir, 'scr.sh')

        with open(scr, 'w') as f:
            f.write('{0} $@\n'.format(self.executable))

        # verilator executable is a script but it doesn't
        # have shell shebang on the first line
        self.cmd = ['sh', 'scr.sh', '-Wno-fatal', '--cc']

        for incdir in params['incdirs']:
            self.cmd.append('-I' + incdir)

        if params['top_module'] != '':
            self.cmd.append('--top-module ' + params['top_module'])

        self.cmd += params['files']
