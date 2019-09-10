import os

from BaseRunner import BaseRunner


class Verilator(BaseRunner):
    maptable = { 'QUEUE_FULL': 'queue full' }

    def __init__(self):
        super().__init__("verilator")

    def prepare_run_cb(self, tmp_dir, params):
        scr = os.path.join(tmp_dir, 'scr.sh')

        # Top file
        top_path = os.path.join(tmp_dir, 'vmain.cpp')
        with open(top_path, 'w') as f:
            f.write('#include <verilated.h>\n')
            f.write('#include <Vtop.h>\n')
            f.write('int main(int argc, char *argv[]) {\n')
            f.write(' Vtop *top = new Vtop;\n')
            f.write(' for (int i = 0 ; i < 1000 && !Verilated::gotFinish() ; ++i)\n')
            f.write('  top->eval();\n')
            f.write(' top->final();\n')
            f.write(' delete top;\n')
            f.write(' return 0;\n')
            f.write('}\n')

        #verilator --cc --Mdir build --top-module top --exe -o main 7.4-packed-arrays.sv main.cpp
        vbuild_path = os.path.join(tmp_dir, 'vbuild')
        with open(scr, 'w') as f:
            f.write('verilator $@\n')
            f.write('make -C ' + vbuild_path + ' -f Vtop.mk\n')
            f.write(vbuild_path + '/vmain\n')

        # verilator executable is a script but it doesn't
        # have shell shebang on the first line
        self.cmd = ['sh', 'scr.sh', '-Wno-fatal', '--cc', '--Mdir', vbuild_path, '--exe', '-o', 'vmain']

        for incdir in params['incdirs']:
            self.cmd.append('-I' + incdir)

        if params['top_module'] != '':
            self.cmd.append('--top-module ' + params['top_module'])
        else:
            self.cmd.append('--top-module top')

        self.cmd += params['files']

        self.cmd.append(top_path)

    def mapexp(self, key):
        return self.maptable.get(key, None)
