# Matlab Comment Stripper

A small set of tools for deleting specific comments in MATLAB/Octave code.

## Requirements

* python
* git - required for function `striprepo`

## Usage

### In MATLAB

Use `stripfile(inputFile, outputFile)` to delete all comments from a file.

```Matlab
% a comment
foo = 'bar'; % another comment
%{
    multiline comment
%}
```
`>> stripfile('path/to/your/file.m', 'output.m')`
```Matlab
foo = 'bar'; 
```

Use `stripfile(inputFile, outputFile, deletionMark)` to delete only marked comments.

```Matlab
% a comment
foo = 'bar'; %?! this one is marked
%{
    multiline comment
    %{
        ?!
        marked and nested comment
    %}
%}
```

`>> stripfile('file.m', 'file.m', '?!')`

```Matlab
% a comment
foo = 'bar'; 
%{
    multiline comment
%}
```

Use `striprepo(deletionMark)` to delete marked comments from all files within git repository. Make sure current working directory is located at the level of .git directory or lower.

To delete all comments, use empty string explicitly: `striprepo('')`

### Outside MATLAB

You can call `stripmatlabcomments.py` using command line.

```
usage: stripmatlabcomments.py [-h] (-s InputString | -i InputFile) [-o OutputFile] [-m DeletionMark]

Delete comments from MATLAB code.

optional arguments:
  -h, --help            show this help message and exit
  -s InputString, --string InputString
                        directly pass string to be processed
  -i InputFile, --ifile InputFile
                        specify file to be processed
  -o OutputFile, --ofile OutputFile
                        specify output file; prints result if absent
  -m DeletionMark, --mark DeletionMark
                        specify mark which will qualify a comment to be deleted; deletes all comments if absent
```

## More

See function descriptions for more info.
