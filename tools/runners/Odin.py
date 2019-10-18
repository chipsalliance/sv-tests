from BaseRunner import BaseRunner


class Odin(BaseRunner):
    def __init__(self):
        super().__init__("odin", "odin_II")

        self.url = "https://verilogtorouting.org/"

    def prepare_run_cb(self, tmp_dir, params):

        self.cmd = [self.executable, '--permissive', '-o odin.blif', '-V']

        # odin doesn't seem to support include directories
        # and thus only list of files is provided to it

        if params['top_module'] != '':
            self.cmd.append('--top_module ' + params['top_module'])

        self.cmd += params['files']

    def get_version_cmd(self):
        # get it from the help
        return [self.executable, "-h"]

    def get_version(self):
        version = super().get_version()

        # The version is the 6th word in the 2nd line
        version = version.splitlines()[1].split()[5]

        return " ".join([self.name, version])
