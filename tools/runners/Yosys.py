import os

from BaseRunner import BaseRunner


class Yosys(BaseRunner):
    def __init__(self):
        super().__init__("yosys")

    def prepare_run_cb(self, tmp_dir, params):
        scr = os.path.join(tmp_dir, 'scr.ys')

        self.cmd = ['yosys', '-Q', '-T', 'scr.ys']

        inc = ""

        for incdir in params['incdirs']:
            inc += ' -I' + incdir

        with open(scr, 'w') as f:
            for svf in params['files']:
                f.write('read_verilog -sv' + inc + ' ' + svf + '\n')
