clear;clc;
testingMarks = ["$"; "$1"; "$2"; "$#"; "ml-1"; "ml-2";...
    "ml-3"; "$%"; "q"; "!!!"];
location = what('tests');
path = location.path;

for ii = 1:length(testingMarks)
    stripfile(sprintf("%s/%s", path, "testfile.m"), ...
        sprintf("%s/out%s.m", path, num2str(ii)), testingMarks(ii));
end

stripfile(sprintf("%s/%s", path, "testfile.m"), ...
        sprintf("%s/out.m", path), "");