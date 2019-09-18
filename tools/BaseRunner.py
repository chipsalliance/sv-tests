import subprocess


class BaseRunner:
    """Common base class shared by all runners
    Each runner must either implement prepare_run_cb
    or override the run method.

    prepare_run_cb is responsible for generating command to run
    and preparing the command working directory if required by the tool.

    Runners must be located in tools/runners subdirectory
    to be detected and launched by the Makefile.
    """

    def __init__(self, name):
        self.name = name

    def run(self, tmp_dir, params):
        """Run the provided test case
        This method is called by the main runner script (tools/runner).

        Arguments:
        tmp_dir -- temporary directory created for this test run.
        params -- dictionary with all metadata from the test file.
                  All keys are used without colons, ie. :tags: becomes tags.

        Returns a tuple containing command execution log and return code.
        """
        self.prepare_run_cb(tmp_dir, params)

        proc = subprocess.Popen(self.cmd, cwd=tmp_dir,
                                stdout=subprocess.PIPE,
                                stderr=subprocess.STDOUT)

        log, _ = proc.communicate()

        return (log.decode('utf-8'), proc.returncode)
