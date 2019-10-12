import os

from BaseRunner import BaseRunner
import sys

ROOT = os.path.join(os.path.dirname(__file__), "..", "..")


class HdlConvertor_parse(BaseRunner):
    """
    Test part of HdlConvertor responsible for parsing from Python.
    """

    def __init__(self):
        exe = os.path.join(ROOT, "third_party", "tools", "hdlConvertor_exe.py")
        super().__init__("hdlConvertor_parse", exe)

        self.url = "https://github.com/Nic30/hdlConvertor"

    def prepare_run_cb(self, tmp_dir, params):
        self.cmd = [self.executable, '--std', 'sv2012']
        build_py_module_path = os.path.join(
            ROOT, "out", "runners", "usr", "local", "lib",
            "python" + sys.version[0:3], "dist-packages")
        PYTHONPATH = os.environ.get("PYTHONPATH", None)
        if PYTHONPATH is not None:
            PYTHONPATH = build_py_module_path + ":" + PYTHONPATH
        else:
            PYTHONPATH = build_py_module_path
        self.env_extra = {"PYTHONPATH": PYTHONPATH}

        for incdir in params['incdirs']:
            self.cmd.append('-I' + incdir)

        self.cmd += params['files']
