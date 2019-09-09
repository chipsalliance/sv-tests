from BaseRunner import BaseRunner


class Icarus(BaseRunner):
    def __init__(self):
        super().__init__("icarus")

    def prepare_run_cb(self, tmp_dir, params):
        self.cmd = ['iverilog', '-g2012', '-o iverilog.out']

        for incdir in params['incdirs']:
            self.cmd.append('-I' + incdir)

        if params['top_module'] != '':
            self.cmd.append('-s ' + params['top_module'])

        self.cmd += params['files']
