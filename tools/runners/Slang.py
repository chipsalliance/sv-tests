from BaseRunner import BaseRunner


class Slang(BaseRunner):
    def __init__(self):
        super().__init__("slang", "slang-driver")

        self.url = "https://github.com/MikePopoloski/slang"

    def prepare_run_cb(self, tmp_dir, params):
        self.cmd = [self.executable]

        for incdir in params['incdirs']:
            self.cmd.append('-I' + incdir)

        self.cmd += params['files']
