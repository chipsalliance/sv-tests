from BaseRunner import BaseRunner
import os


class Icarus(BaseRunner):
    def __init__(self):
        super().__init__("icarus", "iverilog")

        self.url = "http://iverilog.icarus.com/"

    def prepare_run_cb(self, tmp_dir, params):
        mode = params['mode']

        scr = os.path.join(tmp_dir, 'scr.sh')
        ofile = 'iverilog.out'

        with open(scr, 'w') as f:
            f.write('{} $@\n'.format(self.executable))
            if mode == 'simulation':
                f.write('vvp {}'.format(ofile))

        self.cmd = ['sh', 'scr.sh', '-g2012']

        if mode == 'preprocessing':
            self.cmd += ['-E']

        if mode == 'simulation' or mode == 'parsing':
            self.cmd += ['-i', '-o ' + ofile]

        if params['top_module'] != '':
            self.cmd.append('-s ' + params['top_module'])

        for incdir in params['incdirs']:
            self.cmd.append('-I' + incdir)

        self.cmd += params['files']

    def get_version_cmd(self):
        return [self.executable, "-V"]

    def get_version(self):
        version = super().get_version()

        # The version is the 4th word in the 1st line
        version = version.splitlines()[0].split()[3]

        return " ".join([self.name, version])
