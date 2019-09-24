// -*- mode: c++; c-basic-offset: 4; indent-tabs-mode: nil; -*-
// Dependencies: libboost-filesystem-dev libboost-regex-dev libboost-system-dev

#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>

#include <filesystem>
#include <fstream>
#include <iostream>
#include <istream>
#include <map>
#include <ostream>
#include <set>
#include <vector>

#include <boost/algorithm/string.hpp>
#include <boost/algorithm/string/predicate.hpp>
#include <boost/algorithm/string/replace.hpp>
#include <boost/filesystem.hpp>
#include <boost/regex.hpp>

using namespace boost::algorithm;
using std::string;
typedef std::istream_iterator<string> stream_it;

static constexpr char kListDir[] = "./lists/";
static constexpr char kTotalTag[] = "{Total}";

// All relevant boilerplate in code for simplicity
static constexpr char kToplevelFrameset[] = R"(
<style>
  iframe { width:100%; height:100%; }
</style>
<table width="100%" height="100%">
  <tr>
    <td><iframe src="overview-table.html"></iframe></td>
    <td width="10%"><iframe name='tool-tag-frame'></iframe></td>
    <td height="100%">
      <table width="100%" height="100%">
        <tr height="50%"><td><iframe name='log-frame'></iframe></td></tr>
        <tr><td><iframe name='src-frame'>Link to source</iframe></td></tr>
      </table></td>
  </tr>
</table>
)";

static constexpr char kHTMLHeader[] = R"(
<head>
  <title>SystemVerilog tool report</title>
  <style>
   th {  background-color:lightblue; }
   thead th { padding:1em; position:sticky; top:0; }
   td { padding: 0.5em; }
   .tag { text-align:left; }
   .good { font-family:monospace; background-color: #77FF77; }
   .poor { font-family:monospace; background-color: #FFFF77; }
   .bad  { font-family:monospace; background-color:  #FF7777; }
   div { padding: 5px; margin: 2px; }
  </style>
</head>
)";

struct SuccessAggregate {
    int expected_outcome = 0;
    int total = 0;
    const char *result_css_class() const {
        return (expected_outcome == total) ? "good"
            :  (expected_outcome > 0)      ? "poor"
            : "bad";
    }
};

void html_escape(std::string *str) {    // Slow, but ok for now.
    const char* replace[][2] = {{"&", "&amp;"}, {"\"", "&quot;"},
                                {"'", "&apos;"},{"<", "&lt;"}, {">", "&gt;"}};
    for (auto r : replace) boost::replace_all(*str, r[0], r[1]);
}

struct LogfileHeader {
    string name;
    bool should_fail;
    int return_code = -1;
    std::vector<string> tags;

    bool result_good() const { return (return_code == 0) ^ should_fail; }

    bool Read(const string& logfile) {
        *this = {};  // Clear.
        int found_items = 0;
        std::ifstream f(logfile);
        string line;
        // Crude header parser. Could be more compact.
        while (!f.eof() && getline(f, line)) {
            if (line.empty()) break;  // End of header section.
            if (starts_with(line, "name:")) {
                name = line.substr(strlen("name:"));
                found_items++;
            }
            else if (starts_with(line, "should_fail:")) {
                should_fail = atoi(line.c_str() + strlen("should_fail:"));
                found_items++;
            }
            else if (starts_with(line, "rc:")) {
                return_code = atoi(line.c_str() + strlen("rc:"));
                found_items++;
            }
            else if (starts_with(line, "tags:")) {
                std::istringstream tag_line(line.substr(strlen("tags:")));
                tags.insert(tags.end(), stream_it{tag_line}, stream_it());
                found_items++;
            }
        }
        return found_items == 4;
    }
};

// Write a HTML table for each Tool/Tag combination. Entries are color
// coded denoting the success and link to the logfile.
class TagResultWriter {
public:
    TagResultWriter(const string &base_dir) : base_dir_(base_dir) {
        boost::filesystem::create_directory(base_dir_ + kListDir);
    }

    bool Update(const string &tool, const string &tag,
                const string &logfile_link,
                const LogfileHeader &header) {
        const string filename = GetFilenameFor(tool, tag);
        // Currently, we're just opening files and write directly, might be
        // worthwhile storing in RAM and sorting by name before write.
        if (result_files_.find(filename) == result_files_.end()) {
            const int fd = open((base_dir_ + filename).c_str(),
                                O_CREAT|O_TRUNC|O_WRONLY, 0644);
            if (fd == -1) return false;
            result_files_.insert({filename, fd});
            dprintf(fd, "<table width='100%%'><thead><tr>"
                    "<th>%s<h2>%s</h2><h3>%s</h3></th></tr></thead>\n",
                    kHTMLHeader, tool.c_str(), tag.c_str());
        }
        dprintf(result_files_[filename],
                "<tr class='%s'><td><a href='../%s' target='log-frame'>%s</a>"
                "</td></tr>\n", header.result_good() ? "good" : "bad",
                logfile_link.c_str(), header.name.c_str());
        return true;
    }

    void Emit() const {
        for (auto f : result_files_) {  // Already wrote the files, just close()
            dprintf(f.second, "</table>\n");
            close(f.second);
        }
    }

    static string GetFilenameFor(const string &tool, const string &tag) {
        if (tag == kTotalTag) return "";
        return string(kListDir) + "tag_" + tag + "-tool_" + tool + ".html";
    }

private:
    const string base_dir_;
    std::map<string, int> result_files_;
};

// Write the HTML table with the color coded grid tool->tag and number
// of tests passed/failed.
class ResultAggregationGridWriter {
public:
    // Read lrm conf. We use that as a hint in which order test should be shown.
    void ReadTagDescriptions(const string& lrm_conf) {
        std::ifstream f(lrm_conf);
        string line;
        while (!f.eof() && getline(f, line)) {
            if (line.empty() || line[0] == '#') continue;
            auto tab_pos = line.find_first_of('\t');
            if (tab_pos == string::npos) continue;
            const string& tag = line.substr(0, tab_pos);
            const string& desc = line.substr(tab_pos+1);
            presorted_tags_.push_back(tag);
            tag_description_.insert({tag, desc});
        }
    }

    void Update(const string &tool, const string &tag,
                const LogfileHeader &header) {
        unique_tool_set_.insert(tool);
        SuccessAggregate& aggregate = tags_to_toolmetrics_[tag][tool];
        aggregate.total++;
        aggregate.expected_outcome += header.result_good();
    }

    void Emit(const string &base_dir, bool print_nonexistent_lrm_tests) {
        FILE *f = fopen((base_dir + "/" + "overview-table.html").c_str(), "w");
        fprintf(f, "%s", kHTMLHeader);
        fprintf(f, "<table><thead><tr><th colspan='2'>Tag</th>");
        for (auto tool : unique_tool_set_)
            fprintf(f, "<th>%s</th>", tool.c_str());
        fprintf(f, "</tr></thead><tbody style='text-align:right;'>");
        for (auto tag : presorted_tags_) {
            if (print_nonexistent_lrm_tests ||
                tags_to_toolmetrics_.find(tag) != tags_to_toolmetrics_.end()) {
                PrintMetricRow(f, tag);
            }
            tags_to_toolmetrics_.erase(tag);
        }
        for (auto tag : tags_to_toolmetrics_) {  // Print remaining.
            PrintMetricRow(f, tag.first);
        }
        fprintf(f, "</tbody></table>");
        fclose(f);
    }

private:
    void PrintMetricRow(FILE *f, const string& tag) {
        auto row = tags_to_toolmetrics_[tag];
        fprintf(f, "<tr><td>%s</td><th class='tag'>%s</th>",
                tag_description_[tag].c_str(), tag.c_str());
        for (auto tool : unique_tool_set_) {
            const auto found_result = row.find(tool);
            if (found_result == row.end())
                fprintf(f, "<td>&nbsp;</td>");
            else {
                const SuccessAggregate &aggregate = found_result->second;
                const string link = TagResultWriter::GetFilenameFor(tool, tag);
                fprintf(f, "<td class='%s'", aggregate.result_css_class());
                if (link.empty()) {
                    fprintf(f, " style='font-weight:bold;'>%d/%d</td>",
                            aggregate.expected_outcome, aggregate.total);
                } else {
                    fprintf(f, "><a href='%s' target='tool-tag-frame'>%d/%d</a>"
                            "</td>", link.c_str(),
                            aggregate.expected_outcome, aggregate.total);
                }
            }
        }
        fprintf(f, "</tr>\n");
    }

    // Information from lrm.conf
    std::vector<string> presorted_tags_;  // Tags we'd like to print in order
    std::map<string, string> tag_description_;  // In case we have

    std::set<string> unique_tool_set_;
    std::map<string, std::map<string, SuccessAggregate>> tags_to_toolmetrics_;
};

class CSVTestResultWriter {
  public:
    void Update(const string& tool, const string& logfile,
                const LogfileHeader &header) {
        unique_tool_set_.insert(tool);
        string test_name = logfile.substr(logfile.find_first_of('/') + 1);
        test_name = test_name.substr(0, test_name.length() - 4);  // remove 'log'
        auto &test_row = test_to_toolresult_[test_name];
        test_row.insert({tool, header.result_good()});
    }

    void Emit(const string &filename) {
        FILE *f = fopen(filename.c_str(), "w");
        fprintf(f, "test:string");
        for (auto tool : unique_tool_set_)
            fprintf(f, ",%s:bool", tool.c_str());
        fprintf(f, "\n");
        for (auto test : test_to_toolresult_) {
            fprintf(f, "%s,", test.first.c_str());
            for (auto tool : unique_tool_set_) {
                fprintf(f, "%s,", test.second[tool] ? "true" : "false");
            }
            fprintf(f, "\n");
        }
        fclose(f);
    }

  private:
    std::set<string> unique_tool_set_;
    std::map<string, std::map<string, bool>> test_to_toolresult_;
};

string ExtractToolNameFromLogfile(const string& logfile,
                                  const string& prefix) {
    string result = logfile.substr(prefix.length());
    if (result[0] == '/') result = result.substr(1);
    return result.substr(0, result.find_first_of('/'));
}

void EmitToplevelReport(const string &base_dir) {
    std::ofstream f(base_dir + "/" + "report.html");
    f << kToplevelFrameset;
}

// Create HTML-ified version of logfile with links to sources.
string CreateLinkedLogfile(const string &base_dir, const string &logfile,
                           const boost::regex &redact_regexp,
                           bool good) {
    static boost::regex re("(/tests/[^ ]*\\.sv)");
    // TODO: some base directory for sources, maybe even generated with
    // syntax highlight and line numbers to directly link
    const int slashes = std::count(logfile.begin(), logfile.end(), '/') - 1;
    string link_pattern = "<a href='";
    for (int i = 0; i < slashes; ++i)
        link_pattern += "../";  // Need to go back #slashes in the logfile
    link_pattern += "\\1' target='src-frame'>\\1</a>";
    std::ofstream out(logfile + ".html");
    std::ifstream in(logfile);
    bool seen_end_of_header = false;
    string line;
    out << kHTMLHeader;
    out << "<pre class='" << (good ? "good" : "bad") << "'>";
    while (!in.eof() && getline(in, line)) {
        line = boost::regex_replace(line, redact_regexp, "");
        html_escape(&line);
        out << boost::regex_replace(line, re, link_pattern) << "\n";
        if (line.empty() && !seen_end_of_header) {
            out << "</pre><pre>";  // Let's only color the header
            seen_end_of_header = true;
        }
    }
    out << "</pre>";
    return (logfile + ".html").substr(base_dir.length());  // relative link
}

int main(int argc, char *argv[]) {
    // TODO: these are currently hard-coded. These should be flags.
    const string base_dir = "./out/";
    const string lrm_conf = "conf/lrm.conf";
    const bool print_missing_tests = false;

    // Things we don't want to see in the logfile shown in reports
    char buffer[512];
    const boost::regex logfile_redact(getcwd(buffer, sizeof(buffer)));

    const string log_prefix = base_dir + "logs/";
    TagResultWriter tagresultwriter(base_dir);
    ResultAggregationGridWriter result_aggregation_grid;
    result_aggregation_grid.ReadTagDescriptions(lrm_conf);
    CSVTestResultWriter csv;

    // Extract relevant data from logfile headers.
    boost::filesystem::recursive_directory_iterator it(log_prefix);
    LogfileHeader header;
    for (auto log : it) {
        const string& logfile = log.path().string();
        if (!ends_with(logfile, ".log")) continue;
        if (!header.Read(logfile)) {
            fprintf(stderr, "Garbled header: %s\n", logfile.c_str());
            continue;
        }
        const string tool = ExtractToolNameFromLogfile(logfile, log_prefix);
        const string logfile_link = CreateLinkedLogfile(base_dir, logfile,
                                                        logfile_redact,
                                                        header.result_good());
        for (string tag : header.tags) {
            result_aggregation_grid.Update(tool, tag, header);
            tagresultwriter.Update(tool, tag, logfile_link, header);
        }
        result_aggregation_grid.Update(tool, kTotalTag, header);
        csv.Update(tool, logfile.substr(log_prefix.length()), header);
    }

    EmitToplevelReport(base_dir);    // The frameset
    result_aggregation_grid.Emit(base_dir, print_missing_tests);
    tagresultwriter.Emit();          // Links to individual logs
    csv.Emit(base_dir + "/results.csv");
}
