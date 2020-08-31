function [affectedFiles, errors] = striprepo(deletionMark)
%STRIPREPO Summary of this function goes here
%   Detailed explanation goes here
    [gitNotFound, ~] = system('git --version');
    if gitNotFound
        error("Git not found");
    elseif nargin == 0
        deletionMark = "";
    end
    if ~isstring(deletionMark) && ~ischar(deletionMark)
        error("Passed argument is not a string");
    end
    [gitError, gitResult] = system("git ls-tree --full-tree -r --name-only HEAD");
    if gitError
        error(gitResult);
    end
    gitResult = strtrim(gitResult);
    files = string(strsplit(gitResult, '\n'));
    mfiles = string(zeros(1, length(files)));
    mfilesCount = 0;
    for ii = 1:length(files)
        if regexp(files(ii), "^.+\.m$")
            mfiles(mfilesCount + 1) = files(ii);
            mfilesCount = mfilesCount + 1;
        end
    end
    if mfilesCount == 0
        return;
    else
        mfiles = mfiles(1:mfilesCount);
    end
    affectedFiles = string(zeros(length(mfiles)));
    affectedLength = 0;
    errors = string(zeros(length(mfiles)));
    errorsLength = 0;
    for ii = 1:mfilesCount
        [failed, errmsg] = stripfile(mfiles(ii), mfiles(ii), deletionMark);
        if failed
            errors(errorsLength + 1) = sprintf("%s: %s", mfiles(ii), errmsg);
            errorsLength = errorsLength + 1;
        else
            affectedFiles(affectedLength + 1) = mfiles(ii);
            affectedLength = affectedLength + 1;
        end
    end
    affectedFiles = affectedFiles(1:affectedLength);
    errors = errors(1:errorsLength);
end

