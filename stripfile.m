function [status, errmsg] = stripfile(deletionMark, inputFile, outputFile)
%STRIPFILE Delete specified comments from MATLAB/Octave code.
%   [STATUS, ERRMSG] = STRIPFILE(DELETIONMARK, IFILEPATH) deletes comments
%   which start with DELETIONMARK from file located at IFILEPATH.
%   For block comments: deletes comments containing only DELETIONMARK
%   or whitespace chars in the first comment line after '%{'.
%   Works for nested blocks.
%   To delete all comments use empty string or char vector.
%   STATUS different than 0 signals an error.
%   ERRMSG contains error message if an error occured.
%   
%   STRIPFILE(DELETIONMARK, IFILEPATH, OFILEPATH) writes result to
%   OFILEPATH.

    if nargin < 3
        outputFile = inputFile;
    end
    
    if strcmp(char(deletionMark), '')
        deletionMark = '';
    end
    
    [fid, errmsg] = fopen(inputFile, 'r');
    if fid == -1
        status = -1;
        errmsg = sprintf('Cannot read file ''%s'': %s', inputFile, errmsg);
        return;
    end
    % Octave loses some special characters while using fscanf on Windows
    if exist('OCTAVE_VERSION','builtin') && ispc
        lines = {};
        while true
            line = fgetl(fid);
            if line == -1
                break;
            end
            lines(length(lines) + 1) = sprintf('%s\n', line);
        end
    else
        text = fscanf(fid, '%c');    
        % regexp is used instead of strsplit in order to keep new line chars
        lines = regexp(text, '[^\n]*(\n|$)', 'match');
    end
    
    fclose(fid);
    [lines, groupCommentLineNums] = stripgroups(lines, deletionMark);
    for ii = 1:length(lines)
        % omit groupped comments
        if sum(ii == groupCommentLineNums) == 1
            continue
        end
        lines{ii} = stripline(lines{ii}, deletionMark);
    end
    
    [fid, errmsg] = fopen(outputFile, 'w');
    if fid == -1
        status = -1;
        errmsg = sprintf('Cannot write to ''%s'': %s', outputFile, errmsg);
        return;
    end
    fprintf(fid, '%s', strjoin(lines, ''));
    fclose(fid);
    status = 0;
end
