% default comment without code - this line will be deleted completely
%$ marked comment without code - this line will be deleted completely
args = {inputFile, outputFile, deletionMark}; %$1 comment after code - only comment will be deleted
for ii = 1:nargin
    if ~isstring(args{ii}) && ~ischar(args{ii}) 
        error("Argument %d is not a string", ii); %$2 comment after code
	end %$# comment after code
end %!@#$%^&*()/-+,.[];\<>:{} comment after code

%{
	grouped comments
	deleting this comment will include deleting all nested comment groups in this scope
	
	%{
		ml-2
		marked grouped comments - level 2

		%{
			ml-3
			marked grouped comments - level 3
		%}
	%}
%}

str0 = which("stripmatlabcomments.py""); %$% this line contains an unterminated string - comment won't be deleted
str1 = 'text'; %q comment after code
str2 = "text"; %q comment after code
str3 = 'text''text''text'; %q comment after code
str4 = "text""text""text"; %q comment after code
str5 = 'text"text'; %q comment after code
str6 = 'text"text"text'; %q comment after code
str7 = "text'text"; %q comment after code
str8 = "text'text'text"; %q comment after code
str9 = "text'text""text"; %q comment after code
str10 = 'text"text''text'; %q comment after code
str11 = 'text"text"text"text"text"""""'; %q comment after code
str12 = 'text''text''text''text''text'''''''''''; %q comment after code
str13 = "text""text""text""text""text"""""""""""; %q comment after code
str14 = "text''text''text''text''text''''''''''"; %q comment after code
str15 = sprintf('python "%s" -i "%s" -o "%s"', scriptPath, inputFile, outputFile); %q comment after code
str16 = sprintf('%s -m "%s"', str1, str2); %q comment after code
str17 = sprintf('%s -m ''%s''', str1, str2); %q comment after code

%{
	!!!
	all lines of an unterminated grouped comment will be deleted
    
	command = sprintf("%s '%s' -i '%s' -o '%s'", python, scriptPath,...
        inputFile, outputFile);
    if ~isempty(deletionMark)
        command = sprintf("%s -m '%s'", command, deletionMark);
    end
