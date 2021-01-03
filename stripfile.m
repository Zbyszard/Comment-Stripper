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

    if nargin < 3
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
