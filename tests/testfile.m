% default comment
%$ marked comment
args = {inputFile, outputFile, deletionMark}; %$1 comment
for ii = 1:nargin
    if ~isstring(args{ii}) && ~ischar(args{ii}) 
        error("Argument %d is not a string", ii); %$2 comment
	end %$# comment
end

%{
	ml-1
	multiline comment
	
	%{
		ml-2
		multiline comment - level 2
		
		%{
			ml-3
			multiline comment - level 3
		%}
	%}
%}
str1 = which("stripmatlabcomments.py""); %$% this line contains an unterminated string
str2 = sprintf('python "%s" -i "%s" -o "%s"', scriptPath, inputFile, outputFile); %q test quotes
str3 = sprintf('%s -m "%s"', str1, str2); %q test quotes
str4 = sprintf('%s -m ''%s''', str1, str2); %q test quotes

%{
	!!!
	all lines of an unterminated multiline comment will be deleted
	!!!
	command = sprintf("%s '%s' -i '%s' -o '%s'", python, scriptPath,...
        inputFile, outputFile);
    if ~isempty(deletionMark)
        command = sprintf("%s -m '%s'", command, deletionMark);
    end
