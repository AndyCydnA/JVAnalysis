function firstLine = importFirstLineV4(fileName, dataLines)
%this function defines the file structure and data to import when importing
%the first line from the data file. This could likely be refactored in future
%to simplify the code.

%% Input handling

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [1, Inf];
end

%% Setup the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 5);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = "\t";

% Specify column names and types
opts.VariableNames = ["VSourceForward", "Var2", "Var3", "Var4", "Var5"];
opts.SelectedVariableNames = "VSourceForward";
opts.VariableTypes = ["string", "string", "string", "string", "string"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["VSourceForward", "Var2", "Var3", "Var4", "Var5"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["VSourceForward", "Var2", "Var3", "Var4", "Var5"], "EmptyFieldRule", "auto");

% Import the data
firstLine = readmatrix(fileName, opts);

end