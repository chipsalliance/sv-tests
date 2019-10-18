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

    def get_version_cmd(self):
        return [self.executable, "-V"]

    def get_version(self):
        version = super().get_version()

        # The version is the 4th word in the 1st line
        version = version.splitlines()[0].split()[3]

        return " ".join([self.name, version])
