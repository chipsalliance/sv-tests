from BaseRunner import BaseRunner


class Verible(BaseRunner):
    def __init__(self):
        super().__init__("verible", "verible-verilog-syntax", {"parsing"})

        self.url = "https://github.com/google/verible"

    def prepare_run_cb(self, tmp_dir, params):
        self.cmd = [self.executable]

        self.cmd += params['files']
