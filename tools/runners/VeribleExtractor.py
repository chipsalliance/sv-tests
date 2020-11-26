from BaseRunner import BaseRunner

import os
import shlex


class VeribleExtractor(BaseRunner):
    def __init__(self):
        super().__init__(
            "verible_extractor", "verible-verilog-kythe-extractor",
            {"parsing"})

        self.url = "https://github.com/google/verible"

    def prepare_run_cb(self, tmp_dir, params):
        src_list_path = os.path.join(tmp_dir, "src_list")
        script_path = os.path.join(tmp_dir, "run.sh")

        with open(src_list_path, "w") as src_list:
            print("\n".join(params.get("files", [])), file=src_list)

        inc_dirs = ",".join(params.get("incdirs", []))

        with open(script_path, "w") as script:
            s = (
                'log="$({executable}'
                ' --file_list_root ""'
                ' --include_dir_paths {inc_dirs}'
                ' --file_list_path {src_list_path}'
                ' 2>&1 1>/dev/null)"\n'
                'if [ -n "$log" ]; then echo "$log"; exit 1; fi\n').format(
                    executable=self.executable,
                    inc_dirs=shlex.quote(inc_dirs),
                    src_list_path=shlex.quote(src_list_path))
            script.write(s)

        self.cmd = ['sh', script_path]
