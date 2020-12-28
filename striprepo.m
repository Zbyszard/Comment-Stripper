function [affectedFiles, errors] = striprepo(deletionMark, pathToGitRepo,showProgress)
%STRIPREPO Delete comments from m-files tracked by git
%   [AFFECTEDFILES, ERRORS] = STRIPREPO(DELETIONMARK) deletes all comments 
%   that start with DELETIONMARK from git repository in current working 
%   directory. Using empty string will delete all comments.
%   AFFECTEDFILES is a cell array containing paths to affected files,
%   which are relative to the repo's root path.
%   ERRORS is a cell array containing error descriptions.
%
%   STRIPREPO(DELETIONMARK, PATHTOGITREPO) processes files from git
%   repository specified by PATHTOGITREPO. Empty string defaults  to 
%   repository in current working directory.
%   
%   STRIPREPO(DELETIONMARK, PATHTOGITREPO, SHOWPROGRESS) shows
%   progress in command window if SHOWPROGRESS is true or different than 0
%   
%   See also STRIPFILE

    % check if git is installed
    [gitNotFound, ~] = system('git --version 2>&1');
    if gitNotFound
        error("Git not found"); 
    end
    if nargin < 3
        showProgress = 0;
    end
    % argument validation
    if exist('OCTAVE_VERSION','builtin')
        % Octave doesn't support 'isstring' function
        if ~ischar(deletionMark) 
            error("Passed argument is not a string");
        end
    else
        if ~isstring(deletionMark) && ~ischar(deletionMark) 
            error("Passed argument is not a string");
        end
    end
    if ~isnumeric(showProgress) && ~islogical(showProgress)...
            || length(showProgress) > 1 
        error("Second argument is not numeric or logical");
    end
    
    % get absolute path to the root of repository
    % and file paths relative to it
    if nargin < 2 || isempty(char(pathToGitRepo))
        [gitRootError, rootPathResult] = ...
            system("git rev-parse --show-toplevel 2>&1");
        [gitError, gitResult] = ...
            system("git ls-tree --full-tree -r --name-only HEAD 2>&1");
    else
        if ispc
            rootCommand = ...
                sprintf('git -C "%s" rev-parse --show-toplevel 2>&1', pathToGitRepo);
            resultCommand = ...
                sprintf('git -C "%s" ls-tree --full-tree -r --name-only HEAD 2>&1', pathToGitRepo);
        else
            rootCommand = ...
                sprintf("git -C '%s' rev-parse --show-toplevel 2>&1", pathToGitRepo);
            resultCommand = ...
                sprintf("git -C '%s' ls-tree --full-tree -r --name-only HEAD 2>&1", pathToGitRepo);
        end
        [gitRootError, rootPathResult] = system(rootCommand);
        [gitError, gitResult] = system(resultCommand);
            
    end
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
    if showProgress
            clc;
    end
    for ii = 1:mfilesCount
        if showProgress
            fprintf('Processed files: %d/%d\n%d errors',...
                ii - 1, mfilesCount, errorsLength);
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
            clc;
        end
    end
    
    affectedFiles = affectedFiles(1:affectedLength);
    errors = errors(1:errorsLength);
end
