clear;clc;
testingMarks = ["$"; "$1"; "$2"; "$#";...
    "!@#$%^&*()/-+,.[];\<>:{}"; "ml-2"; "ml-3"; "$%"; "q"; "!!!"];
environment = ver;
isOctave = exist('OCTAVE_VERSION','builtin');
% Octave needs backslash to be escaped
if isOctave
    testingMarks = ["$"; "$1"; "$2"; "$#";...
      "!@#$%^&*()/-+,.[];\\<>:{}"; "ml-2"; "ml-3"; "$%"; "q"; "!!!"];
end
location = what('tests');
path = location.path;

% strip all comments completely
stripfile(sprintf("%s/%s", path, "testfile.m"), ...
        sprintf("%s/out-deleted-all.m", path));

[len, ~] = size(testingMarks);
% use deletion marks
for ii = 1:len
    stripfile(sprintf("%s/%s", path, "testfile.m"), ...
        sprintf("%s/out-%s.m", path, num2str(ii)),...
        strtrim(testingMarks(ii,:)));
end