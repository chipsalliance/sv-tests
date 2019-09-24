from BaseRunner import BaseRunner


class Sv2v_zachjs(BaseRunner):
    def __init__(self):
        super().__init__("zachjs-sv2v", "zachjs-sv2v")

    def prepare_run_cb(self, tmp_dir, params):
        self.cmd = [self.executable]

        for incdir in params['incdirs']:
            self.cmd.append('-i' + incdir)

        self.cmd += params['files']
