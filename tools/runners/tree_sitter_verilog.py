import os
import sys

from tree_sitter import Language, Parser
from BaseRunner import BaseRunner


class tree_sitter_verilog(BaseRunner):
    def __init__(self):
        super().__init__("tree-sitter-verilog")

        self.url = "https://github.com/tree-sitter/tree-sitter-verilog"

    def log_error(self, fname, row, col, err):
        self.log += '{}:{}:{}: error: {}\n'.format(fname, row, col, err)

    def walk(self, node, fname):
        if not node.has_error:
            return False

        last_err = True

        for child in node.children:
            if self.walk(child, fname):
                last_err = False

        if last_err:
            self.log_error(fname, *node.start_point, 'node type: ' + node.type)

        return True

    def run(self, tmp_dir, params):
        self.ret = 0
        self.log = ''
        sv_lib = ''
        try:
            out = os.environ['OUT_DIR']
            sv_lib = os.path.abspath(os.path.join(out,
                                     'runners', 'lib', 'verilog.so'))
        except KeyError as e:
            print(str(e))
            sys.exit(1)

        lang = Language(sv_lib, 'verilog')

        parser = Parser()
        parser.set_language(lang)

        for src in params['files']:
            f = None
            try:
                f = open(src, 'rb')
            except IOError:
                self.ret = 1
                self.log_error(src, '', '', 'failed to open file')
                continue

            try:
                tree = parser.parse(f.read())
                if self.walk(tree.root_node, src):
                    self.ret = 1
            except Exception as e:
                self.log_error(src, '', '', 'unknown error: ' + str(e))
                self.ret = 1

        return (self.log, self.ret)

    def can_run(self):
        try:
            return os.path.isfile(os.path.abspath(os.path.join(
                                  os.environ['OUT_DIR'], 'runners',
                                  'lib', 'verilog.so')))
        except KeyError as e:
            print(str(e))
            return False
