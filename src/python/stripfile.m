function [status, output] = stripfile(inputFilePath, outputFilePath, deletionMark)
%STRIPFILE Summary of this function goes here
%   Detailed explanation goes here
    [pythonNotPresent, ~] = system('python -V');
    if pythonNotPresent
        error("Python not found");
    elseif nargin < 2
        error("Input or output file not specified");
    elseif nargin < 3
        deletionMark = '';
    end
    command = sprintf('python stripmatlabcomments.py -i "%s" -o "%s"',...
        inputFilePath, outputFilePath);
    if ~isempty(deletionMark)
        command = sprintf('%s -m "%s"', command, deletionMark);
    end
    [status, output] = system(command);
end