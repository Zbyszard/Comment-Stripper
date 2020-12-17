function [out, processedLines] = stripgroups(lines, deletionMark)

    startReg = '^\s*%{\s*$';
    stopReg = '^\s*%}\s*$';
    procStack = 0;
    out = cell(1, length(lines));
    out(:) = {''};
    outLength = 0;
    processedLines = [];
    
    for ii = 1:length(lines)
        line = lines{ii};
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
            if procStack(length(procStack)) == 2 || noDelMark || ...
                    nextLineExists && nextLineIsDelmark
                procStack = [procStack, 2];
            else
                procStack = [procStack, 1];
            end
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
