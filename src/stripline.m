function result = stripline(line, deletionMark)

    persistent regex;
    if isempty(regex)
        regst = ...
            ['(                   ' ... % code group
             '  ^                 ' ... % line beginning
             '    (               ' ... % 
             '      (             ' ... % 
             '        [\]\)}\w.]  ' ... % any char than can be followed by
             '        ''+         ' ... % one or more transpose operators
             '        |           ' ... % or
             '        [^''"%]     ' ... % any char excluding quotes
             '      )+            ' ... % 
             '      |             ' ... % 
             '      (?<str>       ' ... % string group
             '        (?<single>  ' ... % single quote string group
             '          ''        ' ... % match single quote
             '          [^''\n]*  ' ... % and other signs excluding single quote and new line
             '          (         ' ... % 
             '            ''''    ' ... % match embedded single quote
             '            [^''\n]*' ... % and other signs excluding single quote and new line
             '          )*        ' ... % 
             '          ''?       ' ... % try to match string ending
             '        )           ' ... % single quote string group end
             '        |           ' ... % 
             '        (?<double>  ' ... % double quote string group
             '          "         ' ... % match double quote
             '          [^"\n]*   ' ... % and other signs excluding double quote and new line
             '          (         ' ... % 
             '            ""      ' ... % match embedded double quote
             '            [^"\n]* ' ... % and other signs excluding double quote and new line
             '          )*        ' ... % 
             '          "?        ' ... % try to match string ending
             '        )           ' ... % double quote string group end
             '      )             ' ... % string group end
             '    )*              ' ... % 
             '  )                 ' ... % 
             '([^\n]*)            ' ... % rest of the line should be a comment
             '(\n)?'];                  % new line char
        regex = strrep(regst, ' ', '');
    end
    
    if isempty(line) || sum(isspace(line)) == length(line)
        result = line;
        return;
    end
    
    if nargin < 2 || deletionMark == ""
        deletionMark = '%';
    else % transform deletionMark into %deletionMark + space
        deletionMark = strtrim(deletionMark);
        deletionMark = sprintf('%%%s ', deletionMark);
    end
    
    match = regexp(line, regex, 'tokens');        
    code = match{1}{1};
    comment = match{1}{2};
    newln = match{1}{3};
    
    % there are 3 cases that indicate if comment should be deleted
    % no deletion mark specified
    % comment starts with deletion mark and space
    % comment consists only of deletion mark
    shouldDelete = deletionMark == "%";
    if ~shouldDelete && length(deletionMark) <= length(comment)
        shouldDelete = strcmp(comment(1:length(deletionMark)), deletionMark);
    elseif ~shouldDelete && length(deletionMark) - 1 == length(comment)
        shouldDelete = strcmp(comment(1:length(comment)), ...
            deletionMark(1:length(deletionMark) - 1));
    end
    if shouldDelete
        % return empty string if code group is empty
        if isempty(regexprep(code, '^\s*$', ''))
            result = '';
            return;
        end
        comment = '';
    end
        
    result = sprintf('%s%s%s', code, comment, newln);
end
