import sys
import argparse
import re
from enum import Enum


def main(arg_obj):
    stripper = MatlabCommentStripper(arg_obj.mark)

    # get lines from argument or from file
    if arg_obj.string:
        istr_lines = arg_obj.string.split('\n')
    else:
        istr_lines = read_from(arg_obj.ifile)

    # strip comments
    ostr = stripper.strip_lines(istr_lines)

    # write to file or print
    if arg_obj.ofile:
        write_to(arg_obj.ofile, ostr)
    else:
        print(ostr)


line_regex_str = r"""
    (?P<code>                                   (?# code group)
        ^                                       (?# line beginning)
        (?:                                 
            (?:                                 
                [\]\)}\w.]                      (?# any char than can be followed by)
                    '+                          (?# one or more transpose operators)
                |                               (?# or)
                [^'\"%\n]                       (?# any char excluding quotes)
            )+                              
            | 
            (?:                                 (?# string group)
                (?P<q>'|\")                     (?# match starting quote and remember it)
                    (?:                         (?# string content group)
                        (?:(?P=q){2})*          (?# try to match many embedded starting quotes)
                        (?:(?!(?P=q)|\n).)*     (?# or any other chars except new lines)
                    )*                          
                (?P=q)?                         (?# try to match ending quote)
                                                (?# if string is not ended with proper quote)
                                                (?# then rest of the line is treated as a string)
            )                                   (?# end string group)                                   
        )*                                      
    )                                           (?# end code group)
    (?P<comment>[^\n]*\n?$)
    """
# delete white spaces and comments from regex
line_regex_str = re.sub(r"(\s*)|(\(\?\#.*\))", '',
                        line_regex_str)
line_regex = re.compile(line_regex_str)

# match multiline comment start or end and nothing more except white spaces
start_multiline_regex = re.compile(r"^\s*%{\s*\n?$")
end_multiline_regex = re.compile(r"^\s*%}\s*\n?$")


class LineCheckingState(Enum):
    """enum class for processing multiline comments"""
    # currently processing code
    CODE = 0
    # currently processing muliline comment not marked for deletion
    COMMENT = 1
    # currently deleting comments
    DELETE = 2


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
        """returns list of lines and a list of numbers of lines being multiline comments"""
        
        out = []
        # numbers of every line being a multiline comment
        comment_line_nums = []
        # number of current output line
        out_line_num = -1
        processing_stack = [LineCheckingState.CODE]

        line_num = -1
        max_line = len(istr_lines) - 1
        while line_num < max_line:
            line_num += 1
            if processing_stack[-1] != LineCheckingState.DELETE:
                out_line_num += 1
            line = istr_lines[line_num]
            next_line = istr_lines[line_num +
                                   1] if line_num + 1 < max_line else None

            # if multiline comment started
            if self.start_multiline_regex.match(line):
                # if already deleting comments
                # or next line is marked for deletion
                if processing_stack[-1] == LineCheckingState.DELETE or not self.deletion_mark or \
                        next_line and re.sub(r"\s*", '', next_line) == self.deletion_mark:
                    processing_stack.append(LineCheckingState.DELETE)
                else:
                    processing_stack.append(LineCheckingState.COMMENT)
            # if multiline comment ended
            elif self.end_multiline_regex.match(line) and processing_stack[-1] != LineCheckingState.CODE:
                prev_state = processing_stack.pop()
                if prev_state == LineCheckingState.DELETE:
                    continue
                elif prev_state == LineCheckingState.COMMENT:
                    comment_line_nums.append(out_line_num)
                    out.append(line)
                    continue

            if processing_stack[-1] == LineCheckingState.DELETE:
                continue
            elif processing_stack[-1] == LineCheckingState.COMMENT:
                comment_line_nums.append(out_line_num)
            out.append(line)

        return out, comment_line_nums

    def strip_line_comments(self, istr_lines: list, line_nums_to_omit: list) -> list:
        """returns list of code lines with stripped comments"""

        out = []
        # if deletion mark specified, check for '%' followed
        # directly by the mark and space
        # otherwise match every comment
        if self.deletion_mark:
            deletion_mark = '%' + self.deletion_mark + ' '
        else:
            deletion_mark = '%'

        for i, line in enumerate(istr_lines):
            if i in line_nums_to_omit or line.isspace():
                out.append(line)
                continue
            match = self.line_regex.match(line)
            code = match.group("code")
            comment = match.group("comment")

            # if comment starts with deletion mark, delete it
            # also check if marked comment is empty (ignore space)
            if comment[:len(deletion_mark)] == deletion_mark \
                    or comment[:len(comment) - 1] == deletion_mark[:len(comment) - 1]:
                # if comment is deleted and there is no code, don't append line
                if re.match(r"^\s*$", code):
                    continue
                comment = '\n'
            out.append(code + comment)

        return out


# delete variables from file scope
del line_regex_str, line_regex, start_multiline_regex, end_multiline_regex


def read_from(file_path: str) -> str:
    try:
        with open(file_path, 'r') as file:
            return file.readlines()
    except OSError as e:
        print(e)
        exit(e.errno)


def write_to(file_path: str, content) -> None:
    try:
        with open(file_path, 'w') as file:
            file.write(content)
    except OSError as e:
        print(e)
        exit(e.errno)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Delete comments from MATLAB code.")
    ex_group = parser.add_mutually_exclusive_group(required=True)
    ex_group.add_argument("-s", "--string", metavar="InputString",
                          help="directly pass string to be processed")
    ex_group.add_argument("-i", "--ifile", metavar="InputFile",
                          help="specify file to be processed")
    parser.add_argument("-o", "--ofile", metavar="OutputFile",
                        help="specify output file; prints result if absent")
    parser.add_argument("-m", "--mark", metavar="DeletionMark",
                        help="specify mark which will qualify a comment to be deleted, "
                        "this mark must be followed by space in code; "
                        "deletes all comments if absent")
    if len(sys.argv) < 2:
        parser.print_help()
    else:
        main(parser.parse_args())
