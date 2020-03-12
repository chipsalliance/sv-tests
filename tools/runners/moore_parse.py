from runners.moore import moore


class moore_parse(moore):
    def __init__(self):
        super().__init__("moore-parse")

    def prepare_run_cb(self, tmp_dir, params):
        self.cmd = [self.executable, '--dump-ast']
        self.cmd += params['files']
