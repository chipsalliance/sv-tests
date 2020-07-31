import os

from BaseRunner import BaseRunner


class YosysSv(BaseRunner):
    def __init__(self):
        super().__init__("yosys-sv", "antmicro-yosys")

        self.url = "http://www.clifford.at/yosys/"

    def prepare_run_cb(self, tmp_dir, params):
        scr = os.path.join(tmp_dir, 'scr.ys')

        self.cmd = [self.executable, '-Q', '-T', 'scr.ys']

        inc = ""

        for incdir in params['incdirs']:
            inc += ' -I' + incdir

        with open(scr, 'w') as f:
            for svf in params['files']:
                f.write('read_verilog -sv' + inc + ' ' + svf + '\n')

    def get_version_cmd(self):
        return [self.executable, "-V"]

    def get_version(self):
        version = super().get_version()
        note = "This runner is based on Antmicro fork of Yosys. It was added to"
        " test new features related to SystemVerilog."

        return " ".join([self.name, version.split()[1], note])
