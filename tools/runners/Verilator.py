import os
import shutil

from BaseRunner import BaseRunner


class Verilator(BaseRunner):
    def __init__(self):
        super().__init__("verilator", "verilator")

        self.url = "https://verilator.org"

    def get_version_cmd(self):
        # Scripts like Verilator require calling through SHELL
        return [os.getenv("SHELL"), self.executable, "--version"]

    def prepare_run_cb(self, tmp_dir, params):
        mode = params['mode']
        conf = os.environ['CONF_DIR']
        scr = os.path.join(tmp_dir, 'scr.sh')

        shutil.copy(os.path.join(conf, 'runners', 'vmain.cpp'), tmp_dir)

        build_dir = 'vbuild'
        build_exe = 'vmain'

        with open(scr, 'w') as f:
            f.write('{0} $@\n'.format(self.executable))
            if mode == 'simulation':
                f.write(
                    'make -C {} -f Vtop.mk > /dev/null 2>&1\n'.format(
                        build_dir))
                f.write('./vbuild/{}'.format(build_exe))

        # verilator executable is a script but it doesn't
        # have shell shebang on the first line
        self.cmd = ['sh', 'scr.sh']

        if mode == 'simulation':
            self.cmd += ['--cc']
        elif mode == 'preprocessing':
            self.cmd += ['-E']
        else:
            self.cmd += ['--lint-only']

        self.cmd += ['-Wno-fatal', '-Wno-UNOPTFLAT', '-Wno-BLKANDNBLK']
        # Flags for compliance testing:
        self.cmd += ['-Wpedantic', '-Wno-context']

        if params['top_module'] != '':
            self.cmd.append('--top-module ' + params['top_module'])

        if mode == 'preprocessing':
            self.cmd += ['-P', '-E']

        for incdir in params['incdirs']:
            self.cmd.append('-I' + incdir)

        if mode == 'simulation':
            self.cmd += [
                '--Mdir', build_dir, '--prefix', 'Vtop', '--exe', '-o',
                build_exe
            ]
            self.cmd.append('vmain.cpp')

        self.cmd += params['files']
