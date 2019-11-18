from BaseRunner import BaseRunner


class Surelog(BaseRunner):
    def __init__(self):
        super().__init__("Surelog", "surelog")

        self.url = "https://github.com/alainmarcel/Surelog"

    def prepare_run_cb(self, tmp_dir, params):
        self.cmd = [self.executable, '-nobuiltin', '-parse']

        for incdir in params['incdirs']:
            self.cmd.append('-I' + incdir)

        self.cmd += params['files']
