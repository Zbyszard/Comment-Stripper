function [out, processedLines] = stripgroups(lines, deletionMark)

    persistent startReg, persistent stopReg;
    if isempty(startReg)
        % line start, whitespaces, %{, whitespaces, line end
        startReg = '^\s*%{\s*$';
        % analogously to ^
        stopReg = '^\s*%}\s*$';
    end
    % top of the stack indicates if current line is:
    % 0 - code
    % 1 - comment
    % 2 - comment marked for deletion
    procStack = 0;
    out = cell(1, length(lines));
    out(:) = {''};
    outLength = 0;
    % numbers of lines in groupped comments
    processedLines = [];
    
    for ii = 1:length(lines)
        line = lines{ii};
        % break if current line is the last one and is empty
        if isempty(regexprep(line, '\s+', '')) && ii == length(lines)
            break
        end
        isStart = ~isempty(regexp(line, startReg, 'match', 'once'));
        noDelMark = isempty(deletionMark);
        isStop = ~isempty(regexp(line, stopReg, 'match', 'once'));
        nextLineExists = ii < length(lines);
        if nextLineExists
            nextLineIsDelmark = ...
                strcmp(regexprep(lines{ii + 1}, '\s*', ''), deletionMark);
        end
        if procStack(length(procStack)) ~= 2
            outLength = outLength + 1;
        end
        if isStart
            % there are 3 cases after which next line should be deleted:
            % current comment block is inside antoher one marked for deletion
            % no deletion mark was specified
            % next line contains deletion mark
            if procStack(length(procStack)) == 2 || noDelMark || ...
                    nextLineExists && nextLineIsDelmark
                procStack = [procStack, 2];
            else
                procStack = [procStack, 1];
            end
        % match '%}' only if there is a corresponding '%{' line
        elseif isStop && procStack(length(procStack)) ~= 0
            prev = procStack(length(procStack));
            procStack = procStack(1:length(procStack)-1);
            if prev == 2
                continue;
            elseif prev == 1
                processedLines = setappend(processedLines, outLength);
                out{outLength} = line;
                continue;
            end
        end
        if procStack(length(procStack)) == 2
            continue;
        elseif procStack(length(procStack)) == 1
            processedLines = setappend(processedLines, outLength);
        end
        out{outLength} = line;
    end
    out = out(1:outLength);
end
