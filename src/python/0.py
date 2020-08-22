import sys
import getopt
import re

def main(argv):
    pass

line_regex_str = r"""
    (?P<ok>
        (?:^|\n)
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
    (?P<out>[^\n]*)
    """
line_regex_str = re.sub(r"\s*", '', line_regex_str)
line_regex = re.compile()

class

def strip_string(istr: str) -> str:
    match = regex.findall(istr)
    separated = [(groups[0], groups[2]) for groups in match]
    return separated


if __name__ == "__main__":
    main(sys.argv[1:])