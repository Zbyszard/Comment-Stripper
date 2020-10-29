function [status, errmsg] = stripfile(inputFile, outputFile, deletionMark)
%STRIPFILE Delete comments from MATLAB code.
%   STATUS = STRIPFILE(IFILE, OFILE) deletes all comments from file 
%   located at IFILE and writes result to file at OFILE
%   STATUS different than 0 signals an error.
%   
%   STATUS = STRIPFILE(IFILE, OFILE, DELMARK) deletes only comments 
%   which start with DELMARK.
%   For grouped comments: deletes comments containing only DELMARK
%   in first comment line. Works for nested groups. 
%   Using empty string as DELMARK is equal to STRIPFILE(IFILE, OFILE).
%   
%   [STATUS, ERRMSG] = STRIPFILE(IFILE, OFILE, DELMARK) returns message
%   in ERRMSG if an error occured
%   
%   NOTE: Grouped comments terminated inappropriately can cause loss of
%   all lines below

    % check if python is installed
    [pythonNotFound, ~] = system("python -V 2>&1");
    python = "python";
    if pythonNotFound
        [pythonNotFound, ~] = system("py -V 2>&1");
        python = "py";
    end
    if pythonNotFound
        error(['Python not found. Make sure python is installed or '...
            'adjust "python" variable in this file']);
    elseif nargin < 2
        error("Input or output file not specified");
    elseif nargin < 3
        deletionMark = '';
    end
    deletionMark = char(deletionMark);
    
    isOctave = exist('OCTAVE_VERSION','builtin');
    % validate arguments
    args = {inputFile, outputFile, deletionMark};
    for ii = 1:nargin
        isString = ischar(args{ii});
        % additional check for MATLAB strings
        if ~isOctave && ~isString
            isString = isstring(args{ii});
        end
        if ~isString
             error("Argument %d is not a string", ii);
        end
    end
    % find absolute path to python script
    scriptPath = which("stripmatlabcomments.py");
    if isempty(scriptPath)
        error("Python script not found");
    end
    % construct command
    command = sprintf("%s '%s' -i '%s' -o '%s'", python, scriptPath,...
        inputFile, outputFile);
    if ~isempty(deletionMark)
        command = sprintf("%s -m '%s' 2>&1", command, deletionMark);
    end
    if ispc
        command = strrep(command, "'", '"');
    end        
    % execute command
    [status, errmsg] = system(command);
end
