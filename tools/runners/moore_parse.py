from runners.moore import moore


class moore_parse(moore):
    def __init__(self):
        super().__init__("moore-parse")

    def prepare_run_cb(self, tmp_dir, params):
        self.cmd = [self.executable, '--syntax']

        for incdir in params['incdirs']:
            self.cmd.append('-I')
            self.cmd.append(incdir)

        self.cmd += params['files']
