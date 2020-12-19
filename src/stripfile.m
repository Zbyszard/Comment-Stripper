function [status, errmsg] = stripfile(inputFile, outputFile, deletionMark)

    if nargin < 3
        deletionMark = '';
    end
    
    [fid, errmsg] = fopen(inputFile, 'r');
    if fid == -1
        status = -1;
        errmsg = sprintf('Cannot read file ''%s'': %s', inputFile, errmsg);
        return;
    end
    text = fscanf(fid, '%c');
    fclose(fid);
    lines = regexp(text, '[^\n]*\n?', 'match');
    [lines, groupCommentLineNums] = stripgroups(lines, deletionMark);
    for ii = 1:length(lines)
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

