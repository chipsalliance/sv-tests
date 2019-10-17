from BaseRunner import BaseRunner


class Sv2v_zachjs(BaseRunner):
    def __init__(self):
        super().__init__("zachjs-sv2v", "zachjs-sv2v")

        self.url = "https://github.com/zachjs/sv2v"

    def prepare_run_cb(self, tmp_dir, params):
        self.cmd = [self.executable]

        for incdir in params['incdirs']:
            self.cmd.append('-I' + incdir)

        self.cmd += params['files']

    def get_version(self):
        version = super().get_version()

        # sv2v stores the actual version at the second position
        revision = version.split()[1]

        # return it without the trailing comma
        return " ".join([self.name, revision[:-1]])
