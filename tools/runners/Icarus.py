from BaseRunner import BaseRunner


class Icarus(BaseRunner):
    def __init__(self):
        super().__init__("icarus", "iverilog")

        self.url = "http://iverilog.icarus.com/"

    def prepare_run_cb(self, tmp_dir, params):
        self.cmd = [self.executable, '-i', '-g2012', '-o iverilog.out']

        for incdir in params['incdirs']:
            self.cmd.append('-I' + incdir)

        if params['top_module'] != '':
            self.cmd.append('-s ' + params['top_module'])

        self.cmd += params['files']
