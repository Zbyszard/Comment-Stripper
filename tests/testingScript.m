clear;clc;
testingMarks = ["", "$", "$1", "$2", "$#", "ml-1", "ml-2",...
    "ml-3", "$%", "q", "!!!"];
location = what;
path = location.path;

ii = 0;
for mark = testingMarks
    stripfile(sprintf("%s/%s", path, 'testfile.m'), ...
        sprintf("%s/out%s.m", path, string(ii)), mark);
    ii = ii + 1;
end