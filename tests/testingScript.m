clear;clc;
testingMarks = [{'$'}, {'$1'}, {'$2'}, {'$#'},...
    {'!@#$%^&*()/-+,.[];\<>:{}'}, {'ml-2'}, {'ml-3'},...
    {'$%'}, {'q'}, {'!!!'}];

location = what('tests');
path = location.path;

% strip all comments
[status, err] = stripfile(sprintf("%s/%s", path, "testfile.m"), ...
        sprintf("%s/out-deleted-all.m", path));

errorsLength = 0;
errors = cell(1, length(testingMarks) + 1);
if status
    errorsLength = 1;
    errors{1} = err;
end

% use deletion marks
for ii = 1:length(testingMarks)
    [status, err] = stripfile(sprintf("%s/%s", path, "testfile.m"), ...
        sprintf("%s/out-%s.m", path, num2str(ii)),...
        testingMarks{ii});
    if status
        errorsLength = errorsLength + 1;
        errors{errorsLength} = err;
    end
end

% print errors
if errorsLength
    errors = errors(1:errorsLength);
    for ii = 1:errorsLength
        fprintf("%s\n", errors{ii});
    end
end
fprintf("%d errors\n", errorsLength);
