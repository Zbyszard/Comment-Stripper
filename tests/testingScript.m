clear;clc;
testingMarks = ["$"; "$1"; "$2"; "$#"; "!@#$%^&*()"; "ml-1"; "ml-2";...
    "ml-3"; "$%"; "q"; "!!!"];
location = what('tests');
path = location.path;

% strip all comments completely
stripfile(sprintf("%s/%s", path, "testfile.m"), ...
        sprintf("%s/out-deleted-all.m", path));

% use deletion marks
for ii = 1:length(testingMarks)
    stripfile(sprintf("%s/%s", path, "testfile.m"), ...
        sprintf("%s/out-%s.m", path, num2str(ii)),...
        strtrim(testingMarks(ii,:)));
end