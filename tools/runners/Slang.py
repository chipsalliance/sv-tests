from BaseRunner import BaseRunner


class Slang(BaseRunner):
    def __init__(self):
        super().__init__("slang")

    def prepare_run_cb(self, tmp_dir, params):
        self.cmd = ['driver']

        for incdir in params['incdirs']:
            self.cmd.append('-I' + incdir)

        self.cmd += params['files']
