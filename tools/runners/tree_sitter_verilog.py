import os
import sys

from tree_sitter import Language, Parser
from BaseRunner import BaseRunner


class tree_sitter_verilog(BaseRunner):
    def __init__(self):
        super().__init__("tree-sitter-verilog")

    def walk(self, node):
        if node.has_error != 0:
            self.log += str(node.start_point) + ' ' + str(node.type) + '\n'
            self.ret = 1

        for child in node.children:
            self.walk(child)

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
            with open(src, 'rb') as f:
                try:
                    tree = parser.parse(f.read())
                    self.walk(tree.root_node)
                except Exception as e:
                    self.log += str(e)
                    self.ret = 1

        return (self.log, self.ret)
