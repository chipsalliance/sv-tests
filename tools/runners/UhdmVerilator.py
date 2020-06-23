import os
import shutil

from BaseRunner import BaseRunner


class UhdmVerilator(BaseRunner):
    def __init__(self):
        super().__init__("verilator-uhdm", "verilator-uhdm", {"simulation"})

        self.url = "https://github.com/alainmarcel/uhdm-integration"

    def prepare_run_cb(self, tmp_dir, params):
        mode = params['mode']
        conf = os.environ['CONF_DIR']
        scr = os.path.join(tmp_dir, 'scr.sh')

        shutil.copy(os.path.join(conf, 'runners', 'vmain.cpp'), tmp_dir)

        build_dir = 'vbuild'
        build_exe = 'vmain'

        with open(scr, 'w') as f:
            f.write("set -e\n")
            f.write('set -x\n')
            f.write('surelog-uhdm -nopython -nobuiltin -parse -sverilog')
            for i in params['incdirs']:
                f.write(f' -I{i}')

            for fn in params['files']:
                f.write(f' {fn}')

            f.write("\n")

            f.write(f'{self.executable} $@ || exit $?\n')
            f.write(f'make -C {build_dir} -f Vtop.mk\n')
            f.write(f'./vbuild/{build_exe}\n')

        # verilator executable is a script but it doesn't
        # have shell shebang on the first line
        self.cmd = ['sh', scr]

        self.cmd += ['--uhdm-ast -cc slpp_all/surelog.uhdm']

        # Flags for compliance testing:
        self.cmd += [
            '-Wno-fatal', '-Wno-UNOPTFLAT', '-Wno-BLKANDNBLK', '-Wpedantic',
            '-Wno-context'
        ]

        top = self.get_top_module_or_guess(params)

        # surelog changes the name to work@<top>
        # and then verilator changes @ -> _
        if top is not None:
            self.cmd.append(f'--top-module work_{top}')

        self.cmd += [
            '--Mdir', build_dir, '--prefix', 'Vtop', '--exe', '-o', build_exe
        ]

        self.cmd.append('vmain.cpp')
