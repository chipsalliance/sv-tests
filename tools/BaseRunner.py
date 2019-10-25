import resource
import shutil
import subprocess


def set_process_limits():
    """Make sure processes behave. Limit memory to 4GiB"""
    resource.setrlimit(resource.RLIMIT_DATA, (4 << 30, 4 << 30))


class BaseRunner:
    """Common base class shared by all runners
    Each runner must either implement prepare_run_cb
    or override the run method.

    prepare_run_cb is responsible for generating command to run
    and preparing the command working directory if required by the tool.

    Runners must be located in tools/runners subdirectory
    to be detected and launched by the Makefile.
    """
    def __init__(self, name, executable=None):
        """Base runner class constructor
        Arguments:
        name -- runner name.
        executable -- name of an executable used by the particular runner
        can be omitted if default can_run method isn't used.
        """
        self.name = name
        self.executable = executable

        self.url = "https://github.com/symbiflow/sv-tests"

    def run(self, tmp_dir, params):
        """Run the provided test case
        This method is called by the main runner script (tools/runner).

        Arguments:
        tmp_dir -- temporary directory created for this test run.
        params -- dictionary with all metadata from the test file.
                  All keys are used without colons, ie. :tags: becomes tags.

        Returns a tuple containing command execution log, return code,
        user time, system time and ram usage
        """
        self.prepare_run_cb(tmp_dir, params)

        proc = subprocess.Popen(
            self.cmd,
            cwd=tmp_dir,
            preexec_fn=set_process_limits,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT)

        log, _ = proc.communicate()

        usage = resource.getrusage(resource.RUSAGE_CHILDREN)
        profiling_data = (usage.ru_utime, usage.ru_stime, usage.ru_maxrss)

        return (log.decode('utf-8'), proc.returncode) + profiling_data

    def can_run(self):
        """Check if runner can be used
        This method is called by the main runner script (tools/runner) as
        a sanity check to verify that tool used by the runner is properly
        installed.

        Returns True when tool is installed and can be used, False otherwise.
        """
        return shutil.which(self.executable) is not None

    def get_version_cmd(self):
        """ Get version command

        Returns a list containing the command and arguments needed to get the
                version.
        """

        # assume sane defaults
        return [self.executable, "--version"]

    def get_version(self):
        """Attempt to get the version of the tool

        Returns a version string
        """

        try:
            cmd = self.get_version_cmd()

            proc = subprocess.Popen(
                cmd,
                preexec_fn=set_process_limits,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT)

            log, _ = proc.communicate()

            if proc.returncode != 0:
                return self.name

            return log.decode('utf-8')
        except (TypeError, NameError, OSError):
            return self.name
