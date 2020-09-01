function [status, errmsg] = stripfile(inputFile, outputFile, deletionMark)
%STRIPFILE Delete comments from MATLAB code.
%   STATUS = STRIPFILE(IFILE, OFILE) deletes all comments from file 
%   located at IFILE and writes result to file at OFILE
%   STATUS different than 0 signals error
%   
%   STATUS = STRIPFILE(IFILE, OFILE, DELMARK) deletes only comments 
%   which start with DELMARK and space. 
%   For multiline comments: deletes comments containing only DELMARK
%   in the line following "%{" sign. Works for nested multiline comments.
%   
%   [STATUS, ERRMSG] = STRIPFILE(IFILE, OFILE, DELMARK) returns message
%   in ERRMSG if an error occured

    [pythonNotFound, ~] = system('python -V');
    if pythonNotFound
        error("Python not found");
    elseif nargin < 2
        error("Input or output file not specified");
    elseif nargin < 3
        deletionMark = "";
    end
    args = {inputFile, outputFile, deletionMark};
    for ii = 1:nargin
        if ~isstring(args{ii}) && ~ischar(args{ii})
            error("Argument %d is not a string", ii);
        end
    end
    scriptPath = which("stripmatlabcomments.py");
    if isempty(scriptPath)
        error("Python script not found");
    end
    command = sprintf('python "%s" -i "%s" -o "%s"', scriptPath,...
        inputFile, outputFile);
    if ~isempty(deletionMark)
        if ispc
            command = sprintf('%s -m "%s"', command, deletionMark);
        else
            command = sprintf('%s -m ''%s''', command, deletionMark);
        end
    end
    [status, errmsg] = system(command);
end
