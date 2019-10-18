from BaseRunner import BaseRunner


class sv_parser(BaseRunner):
    def __init__(self):
        super().__init__("sv-parser", "parse_sv", {"preprocessing", "parsing"})

        self.url = "https://github.com/dalance/sv-parser"

    def prepare_run_cb(self, tmp_dir, params):
        self.cmd = [self.executable]

        for incdir in params['incdirs']:
            self.cmd.append('--include')
            self.cmd.append(incdir)

        self.cmd += params['files']
