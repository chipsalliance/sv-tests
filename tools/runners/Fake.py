from BaseRunner import BaseRunner


class Fake(BaseRunner):
    def __init__(self):
        super().__init__("fake")

    def run(self, tmp_dir, params):
        rc = int(params["should_fail"])
        log = "FAKE RUNNER"

        return (log, rc)
