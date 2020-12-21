# Matlab Comment Stripper

A small set of tools for deleting specific comments in MATLAB/Octave code.

## Requirements

* git - required for function `striprepo`

## Setup

Download repository and add src directory to MATLAB's path:
```Matlab
addpath path/to/Matlab-Comment-Stripper/src
```

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
`>> stripfile('path/to/your/file.m', 'path/to/output.m')`
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

## More

See function descriptions for more info.

## Credits

[Peter John Acklam](https://github.com/pjacklam) - main regular expression is based on the one provided in [% MATLAB Comment Stripping Toolbox](https://www.mathworks.com/matlabcentral/fileexchange/4645-matlab-comment-stripping-toolbox)
