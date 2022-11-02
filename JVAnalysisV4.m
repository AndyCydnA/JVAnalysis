function JVAnalysisV4()

%Code will generate summary files from JV data files. User must select the
%folder where the JV data files are located.

%get directory of files to process
filepath=uigetdir(pwd,'Please select data folder');
JVImportV4(filepath);

end