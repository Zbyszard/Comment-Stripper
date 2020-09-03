function [affectedFiles, errors] = striprepo(deletionMark, showProgress)
%STRIPREPO Delete comments from m-files tracked by git
%   [AFFECTEDFILES, ERRORS] = STRIPREPO(DELETIONMARK) deletes all comments 
%   from current repository that start with DELETIONMARK. Using empty
%   string will delete all comments. AFFECTEDFILES is a cell array 
%   containing paths to affected files, which are relative to the root 
%   path. ERRORS is a cell array containing error descriptions.
%   
%   [AFFECTEDFILES, ERRORS] = STRIPREPO(DELETIONMARK, SHOWPROGRESS) shows
%   progress in command window if SHOWPROGRESS is true or different than 0
%   
%   NOTE: In order to use this function, current working directory or one
%   of directories above must contain .git directory
%   
%   See also STRIPFILE

    % check if git is installed
    [gitNotFound, ~] = system('git --version');
    if gitNotFound
        error("Git not found"); 
    end
    if nargin < 2
        showProgress = 0;
    end
    % argument validation
    if ~isstring(deletionMark) && ~ischar(deletionMark) 
        error("Passed argument is not a string");
    end
    if ~isnumeric(showProgress) && ~islogical(showProgress)...
            || length(showProgress) > 1 
        error("Second argument is not numeric or logical");
    end
    
    % get absolute path to the root of repository
    % and file paths relative to it
    [gitRootError, rootPathResult] = system("git rev-parse --show-toplevel");
    [gitError, gitResult] = system("git ls-tree --full-tree -r --name-only HEAD");
    if gitRootError
        error(rootPathResult);
    elseif gitError
        error(gitResult);
    end
    rootPathResult = strtrim(rootPathResult);
    gitResult = strtrim(gitResult);
    % cell array of repository files
    files = strsplit(gitResult, '\n');
    mfiles = cell(1, length(files));
    mfilesCount = 0;
    % get all m-files (*.m)
    for ii = 1:length(files)
        if regexp(files{ii}, "^.+\.m$")
            mfiles{mfilesCount + 1} = files{ii};
            mfilesCount = mfilesCount + 1;
        end
    end
    if mfilesCount == 0
        return;
    else
        mfiles = mfiles(1:mfilesCount);
    end
    
    affectedFiles = cell(1, mfilesCount);
    affectedLength = 0;
    errors = cell(1, mfilesCount);
    errorsLength = 0;
    % try to strip every file
    for ii = 1:mfilesCount
        if showProgress
            progress = sprintf('Processed files: %d/%d\n%d errors',...
                ii - 1, mfilesCount, errorsLength);
            disp(progress);
        end
        absolutePath = sprintf('%s/%s', rootPathResult, mfiles{ii});
        [failed, errmsg] = stripfile(absolutePath, absolutePath, deletionMark);
        if failed
            errors{errorsLength + 1} = sprintf('%s: %s', mfiles{ii}, errmsg);
            errorsLength = errorsLength + 1;
        else
            affectedFiles{affectedLength + 1} = mfiles{ii};
            affectedLength = affectedLength + 1;
        end
        if showProgress
            % clear progress info; will not work in Octave
            fprintf(repmat('\b', 1, length(progress) + 1));
        end
    end
    
    affectedFiles = affectedFiles(1:affectedLength);
    errors = errors(1:errorsLength);
end

