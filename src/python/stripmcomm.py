import sys
import argparse
import re
from timeit import default_timer as timer


def main(arg_obj):
    stripper = MatlabCommentStripper(arg_obj.mark)
    start = timer()
    if arg_obj.string:
        istr_lines = arg_obj.string.split('\n')
    else:
        istr_lines = stripper.read_from(arg_obj.ifile)
    ostr = stripper.strip_lines(istr_lines)
    if arg_obj.ofile:
        stripper.write_to(arg_obj.ofile, ostr)
    else:
        print(ostr)
    stop = timer()
    print(f"Execution time: {stop - start}")


line_regex_str = r"""
    (?P<code>
        ^
        (?:
            (?:
                [\]\)}\w.]
                    '+
                |
                [^'\"%\n]
            )+
            |
            (?P<q>'|\")
                (?:
                    (?:(?P=q){2})*
                    (?:(?!(?P=q)|\n).)*
                )*
            (?P=q)?
        )*
    )
    (?P<comment>[^\n]*\n?)
    """
line_regex_str = re.sub(r"\s*", '', line_regex_str)
line_regex = re.compile(line_regex_str)

start_multiline_regex = re.compile(r"^\s*%{\s*\n?$")
end_multiline_regex = re.compile(r"^\s*%}\s*\n?$")


class MatlabCommentStripper:
    start_multiline_regex = start_multiline_regex
    end_multiline_regex = end_multiline_regex
    line_regex = line_regex

    def __init__(self, deletion_mark: str):
        self.deletion_mark = deletion_mark

    def strip_lines(self, istr_lines: list) -> str:
        istr_lines, ml_comment_lines = self.strip_multiline_comments(
            istr_lines)
        istr_lines = self.strip_line_comments(istr_lines, ml_comment_lines)
        return ''.join(istr_lines)

    def strip_multiline_comments(self, istr_lines: list) -> (list, list):
        """returns list of lines and a list of multiline comment line numbers"""
        out = []
        out_line_num = -1
        comment_line_nums = []
        content_stack = ["code"] 
        line_num = -1
        max_line = len(istr_lines) - 1
        while line_num < max_line:
            line_num += 1
            if content_stack[-1] != "delete":
                out_line_num += 1
            line = istr_lines[line_num]
            next_line = istr_lines[line_num +
                                   1] if line_num + 1 < max_line else None
            if self.start_multiline_regex.match(line):
                if not self.deletion_mark or \
                    next_line and re.sub(r"\s*", '', next_line) == self.deletion_mark or \
                        content_stack[-1] == "delete":
                    content_stack.append("delete")
                else:
                    content_stack.append("comment")
            elif self.end_multiline_regex.match(line):
                prev_state = content_stack.pop()
                if prev_state == "comment":
                    comment_line_nums.append(out_line_num)
                elif prev_state == "delete":
                    continue
            if content_stack[-1] == "delete":
                continue
            elif content_stack[-1] == "comment":
                comment_line_nums.append(out_line_num)
            out.append(line)
        return out, comment_line_nums

    def strip_line_comments(self, istr_lines: list, line_nums_to_omit: list) -> list:
        out = []
        deletion_mark = '%' + (self.deletion_mark or "")
        for i, line in enumerate(istr_lines):
            if i in line_nums_to_omit or line.isspace():
                out.append(line)
                continue
            match = self.line_regex.match(line)
            code = match.group("code")
            comment = match.group("comment")
            # if comment starts with deletion mark, delete comment
            if comment[:len(deletion_mark)] == deletion_mark:
                # if comment is deleted and there is no code, don't append line
                if re.match(r"^\s*$", code):
                    continue
                comment = '\n'
            out.append(code + comment)
        return out

    @staticmethod
    def read_from(file_path: str) -> str:
        try:
            with open(file_path, 'r') as file:
                return file.readlines()
        except OSError as e:
            print(e)
            exit(1)

    @staticmethod
    def write_to(file_path: str, content) -> None:
        try:
            with open(file_path, 'w') as file:
                file.write(content)
        except OSError as e:
            print(e)
            exit(1)


del line_regex_str, line_regex, start_multiline_regex, end_multiline_regex


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="")
    parser.add_argument("-m", "--mark", metavar="DeletionMark",
                        help="specify mark which will qualify a comment to be deleted; "
                        "deletes all comments if absent")
    ex_group = parser.add_mutually_exclusive_group(required=True)
    ex_group.add_argument("-s", "--string", metavar="InputString",
                          help="directly pass string to be processed")
    ex_group.add_argument("-i", "--ifile", metavar="InputFile",
                          help="specify file to be processed")
    parser.add_argument("-o", "--ofile", metavar="OutputFile",
                        help="specify output file; prints result if absent")
    if len(sys.argv) < 2:
        parser.print_help()
    else:
        main(parser.parse_args())
