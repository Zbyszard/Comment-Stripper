function result = stripline(line, deletionMark)

    persistent regex;
    if isempty(regex)
        regst = ...
            ['(                   ' ... % code group
             '  ^                 ' ... % line beginning
             '    (?:             ' ... % 
             '      (?:           ' ... % 
             '        [\]\)}\w.]  ' ... % any char than can be followed by
             '        ''+         ' ... % one or more transpose operators
             '        |           ' ... % or
             '        [^''"%]     ' ... % any char excluding quotes
             '      )+            ' ... % 
             '      |             ' ... % 
             '      (?:           ' ... % string group
             '        (?:         ' ... % single quote string group
             '          ''        ' ... % match single quote
             '          [^''\n]*  ' ... % and other signs excluding single quote and new line
             '          (?:       ' ... % 
             '            ''''    ' ... % match embedded single quote
             '            [^''\n]*' ... % and other signs excluding single quote and new line
             '          )*        ' ... % 
             '          ''?       ' ... % try to match string ending
             '        )           ' ... % single quote string group end
             '        |           ' ... % 
             '        (?:         ' ... % double quote string group
             '          "         ' ... % match double quote
             '          [^"\n]*   ' ... % and other signs excluding double quote and new line
             '          (?:       ' ... % 
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
    
    if nargin < 2 || strcmp(deletionMark, '')
        deletionMark = '%';
    else % transform deletionMark into %deletionMark + space
        deletionMark = strtrim(deletionMark);
        deletionMark = sprintf('%%%s ', deletionMark);
    end
    
    match = regexp(line, regex, 'tokens');
    match = match{1};
    if ~exist('OCTAVE_VERSION','builtin')
        code = match{1};
        comment = match{2};
        newln = match{3};
    else
        code = ''; comment = ''; newln = '';
        for ii = 1:length(match)
            if isempty(match{ii})
                continue
            elseif match{ii}(1) == '%'
                comment = match{ii};
            elseif match{ii}(1) == char(10)
                newln = char(10);
            else
                code = match{ii};
            end
        end
    end
    
    % there are 3 cases that indicate if comment should be deleted
    % no deletion mark specified
    % comment starts with deletion mark and space
    % comment consists only of deletion mark
    shouldDelete = strcmp(deletionMark, '%');
    
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
