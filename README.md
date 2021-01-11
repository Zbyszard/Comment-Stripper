# Matlab Comment Stripper

A small set of tools for deleting specific comments in MATLAB/Octave code.

## Requirements

* git - required for function `striprepo`

## Setup

Download repository and add src directory to MATLAB's path:
```Matlab
addpath path/to/Matlab-Comment-Stripper
```

## Usage

### `striprepo`

Use `striprepo(deletionMark, pathToGitRepo, showProgress)` to delete specified comments from all m-files within git repository at *pathToGitRepo* (either relative to current or to absolute path). Empty *pathToGitRepo* defaults to current working directory. Argument *showProgress* different than 0 will print current number or processed files.

`striprepo(deletionMark)` is equivalent to `striprepo(deletionMark, '', 0)`.

To delete all comments, use empty string explicitly: `striprepo('')`

Note: if you don't use '%' sign at the beginning of *deletionMark*, only block comments will be affected.

### Examples:

Let's assume that this is one of many files in your repository.

```Matlab
% a comment
foo = 'bar'; %?! this one is marked

%{
    block comment
    %{
        %?!
        marked and nested block
    %}
%}
a = 1 + 2; % one plus two
```

Use `striprepo('%?!')` cut out unwanted comments.

`>> [files, errors] = striprepo('%?!')`

```Matlab
% a comment
foo = 'bar'; 

%{
    block comment
%}
a = 1 + 2; % one plus two
```

Use `striprepo('')` to get rid of all the comments:

`>> [files, errors] = striprepo('')`

There is no comments in any of your files now.

```Matlab
foo = 'bar'; 

a = 1 + 2; 
```

### `stripfile`

Use `stripfile(deletionMark, inputFile)` to delete specified comments from a file.

Use `stripfile(deletionMark, inputFile, outputFile)` to write result to another file.

### Example:

Let's say your working directory is `/home/project/src` and you also have `/home/project/copy` directory.

`>> [status, errorMsg] = stripfile('%@', 'file.m', '../copy/filecopy.m')`

```Matlab
% hello
foo = 'bar'; %@ temp comment
```

The file at `/home/project/copy` directory:

```Matlab
% hello
foo = 'bar'; 
```

## More

See function descriptions for more info.

## Credits

[Peter John Acklam](https://github.com/pjacklam) - main regular expression is based on the one used in [% MATLAB Comment Stripping Toolbox](https://www.mathworks.com/matlabcentral/fileexchange/4645-matlab-comment-stripping-toolbox)
