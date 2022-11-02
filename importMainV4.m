function mainImported = importMainV4(fileName, dataLines)
%IMPORTFILE Import the main data from the data file
%  mainImported = importMainV4(filename) reads data from text file
%  fileName for the default selection.  Returns the data as a table.
%
%  mainImported = importMainV4(fileName, dataLines) reads data for the
%  specified row interval(s) of text file fileName. Specify dataLines as
%  a positive scalar integer or a N-by-2 array of positive scalar
%  integers for dis-contiguous row intervals.
%
%  Example:
%  mainImported = importMainV4("C:\Users\Andre\Documents\0. Data from various instruments\Solar Sim 2 Data\Andrew Clarke\Batch S006\C2-2 2020-03-06 152248.SEQ", [26, 26]);
%
% This could likely be refactored in future to simplify the code.

%% Input handling

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [26, 26];
end

%% Setup the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 24);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = "\t";

% Specify column names and types
opts.VariableNames = ["Sequence", "Sweep", "Direction", "DarkMeasurment", "IrradianceSun", "VocVStabilisedtrueFalse", "IscmA", "JscmACm", "Fillfactor", "Efficiency", "PmaxPstabilisedmW", "ImaxIstabilisedmA", "VmaxVholdV", "PowermW", "RatIscOhms", "RatVocOhms", "ActSweepTimes", "PreSoakTimes", "SweepRateVs", "OutputFile", "StartDate", "StartTime", "EndDate", "EndTime"];
opts.VariableTypes = ["double", "double", "string", "string", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "string", "string", "string", "string", "string"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["Direction", "DarkMeasurment", "OutputFile", "StartDate", "StartTime", "EndDate", "EndTime"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Direction", "DarkMeasurment", "OutputFile", "StartDate", "StartTime", "EndDate", "EndTime"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, ["IrradianceSun", "VocVStabilisedtrueFalse", "IscmA", "JscmACm", "Fillfactor", "Efficiency", "PmaxPstabilisedmW", "ImaxIstabilisedmA", "VmaxVholdV", "PowermW", "RatIscOhms", "RatVocOhms", "ActSweepTimes", "PreSoakTimes", "SweepRateVs"], "TrimNonNumeric", true);
opts = setvaropts(opts, ["IrradianceSun", "VocVStabilisedtrueFalse", "IscmA", "JscmACm", "Fillfactor", "Efficiency", "PmaxPstabilisedmW", "ImaxIstabilisedmA", "VmaxVholdV", "PowermW", "RatIscOhms", "RatVocOhms", "ActSweepTimes", "PreSoakTimes", "SweepRateVs"], "ThousandsSeparator", ",");

% Import the data
mainImported = readtable(fileName, opts);

end