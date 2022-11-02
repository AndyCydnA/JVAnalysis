function JVImportV4(filePath)

%filepath="C:\Users\Andre\Documents\0. Data from various instruments\Solar Sim 2 Data\Andrew Clarke\Batch 211001_PTQ10IDIC2"; %for testing. Leave this line commeneted out unless testing as a script rather than a function.
dateAndTime=datestr(now,'mm-dd-yyyyHH-MM-SSAM');
if ~exist(append(filePath,"\JVAnalysisV4 exports",dateAndTime), 'dir') %create export folder if it doesn't exist already
    mkdir(append(filePath,"\JVAnalysisV4 exports",dateAndTime));
end
exportPath= append(filePath,"\JVAnalysisV4 exports",dateAndTime); %export file path
headings=["Filename"	"Batch" "Device ID" "Device description" "Device #" "Pixel #" "Seq #"	"Swp #"	"Dir"	"Light /Dark"	"Irradiance" ...
    "Voc (V) Stabilised (True/False)"	"Isc (mA)" "Jsc (mA/Cm²)" "Fill Factor (%)"	"PCE (%)" "Pmax/Pstab (W)" "Imax/IStab (mA)" ...
    "Vmax/Vhold  (V)" "Power (mW)" "R at ISC (Ohms)" "R at Voc (Ohms)" "Actual Test Time (s)"	"Presweep Soak (s)"...
    "SweepRate (V/s)" "Output file"	"Date state" "Time Start"	"Date end" "Time End"]; %Headers for summary data file

listOfFiles=dir(fullfile(filePath,"*.SEQ")); %create list of all SEQ files
summaryCellArray=strings(length(listOfFiles),30); %generate empty array of correct size (although it may become longer later if multiple IV data stored in a single SEQ file). If this becomes problematic, instead define the array length by the number of .IV files instead of .SEQ files. Doing it this way should not cause issues though.

%% find positions of data within the files and import the real data into the array "summaryCellArray"
% this array is later sorted into a new array, "sortedArray"

recentlyEditedLine=0; %initialise loop parameter; this stores most recently edited line in the full summary array, 'summaryCellArray', so it is not overwritten during the looping

for nCurrentFile=1:length(listOfFiles)
    positioningData=importFirstLineV4(append(filePath,"\",listOfFiles(nCurrentFile).name)); %import first column in the first file for use to determine data positioning
    cellIDPosition=find(strcmp(positioningData(:,1),"Batch ID : ")); %positioning of batch/cell ID data in file
    mainSummaryDataPosition=find(strcmp(positioningData(:,1),"Sequence #")); %first line of data is on the row after this row
    mainSummaryDataPositionEnd=find(strcmp(positioningData(:,1),"#############################################")); %end of data is on the row 3 rows prior to this
    
    for currentIVDataLine=1:(mainSummaryDataPositionEnd - 2 - mainSummaryDataPosition - 1) %in some cases multiple IV data is stored in a single SEQ file. This line loops over however many data lines are present
        %this usually occurs if you have an automatic dark sweep before or
        %after the light sweep. Equally I think having both forward & reverse
        %sweeps may also have the same effect although not yet tested this.
        %This section treats these lines one line at a time and uses
        %parameter recentlyEditedLine to keep track of the most recently updated line in the
        %full summary array, 'summaryCellArray'.
        
        summaryCellArray(recentlyEditedLine+currentIVDataLine,1)=listOfFiles(nCurrentFile).name; %first column is file name
        %disp(listOfFiles(n).name); %for debugging
        %disp(recentlyEditedLine);
        %disp(currentIVDataLine);
        summaryCellArray(recentlyEditedLine+currentIVDataLine,2:4)=transpose(table2array(importCellIDV4(append(filePath,"\",listOfFiles(nCurrentFile).name),[cellIDPosition, cellIDPosition+2]))); %columns 2-4 are cell identifiers
        tempVar=split(summaryCellArray(recentlyEditedLine+currentIVDataLine,3),"-"); %split cell name into cell # and pixel #
        summaryCellArray(recentlyEditedLine+currentIVDataLine,5)=tempVar(1); %cell #
        summaryCellArray(recentlyEditedLine+currentIVDataLine,6)=tempVar(2); %pixel #
        summaryCellArray(recentlyEditedLine+currentIVDataLine,7:30)=table2array(importMainV4(append(filePath,"\",listOfFiles(nCurrentFile).name),[mainSummaryDataPosition + currentIVDataLine, mainSummaryDataPosition + currentIVDataLine])); %import other data directly from SEQ file
    end
    recentlyEditedLine=recentlyEditedLine+currentIVDataLine; %updates the most recently edited line in the array summaryArrayCell so that during the next loop it doesn't overwrite previous data
end

sortedArray=sortrows(summaryCellArray,[10,3]); %sort data by cell #, then light/dark

%% Setup the Import Options for importing JV data
opts = delimitedTextImportOptions("NumVariables", 16);

% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = "\t";

% Specify column names and types
opts.VariableNames = ["VSourceV", "CurrentDensitymAcm", "IMeasuremA", "PowermW", "Times", "VarName6", "VarName7", "VarName8", "VarName9", "VarName10", "VarName11", "VarName12", "VarName13", "VarName14", "VarName15", "VarName16"];
opts.VariableTypes = ["string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["VSourceV", "CurrentDensitymAcm", "IMeasuremA", "PowermW", "Times", "VarName6", "VarName7", "VarName8", "VarName9", "VarName10", "VarName11", "VarName12", "VarName13", "VarName14", "VarName15", "VarName16"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["VSourceV", "CurrentDensitymAcm", "IMeasuremA", "PowermW", "Times", "VarName6", "VarName7", "VarName8", "VarName9", "VarName10", "VarName11", "VarName12", "VarName13", "VarName14", "VarName15", "VarName16"], "EmptyFieldRule", "auto");



%% start the processing and exporting

if isempty(find(strcmp(sortedArray(:,10),"Light")))
else %if there is light data do the following, otherwise this is skipped
    lightData=sortedArray(transpose(find(strcmp(sortedArray(:,10),"Light"))),:); %select light data only
    uniqueLight=unique(lightData(:,5)); %number of cells for light data
    for dataCellLoop=1:length(uniqueLight) %loop over all cells for light data
        currentLightCell=lightData(transpose(find(strcmp(lightData(:,5),uniqueLight(dataCellLoop)))),:); %summary data from current cell
        for dataPixelLoop=1:length(currentLightCell(:,1)) % loop over all pixels for current cell
            
            lightIVFullPath=split(currentLightCell(dataPixelLoop,26),"\"); %IV file path
            lightIVFilePath=lightIVFullPath(end); %IV file name
            lightIV=readmatrix(append(filePath,"\",lightIVFilePath),opts); %import IV file
            
            if strlength(strtok(currentLightCell(dataPixelLoop,1),".")) > 31 %check that the length of the excel sheet name wont be too long and shorten it if it is
                sheetName=extractBefore(strtok(currentLightCell(dataPixelLoop,1),"."),30);
            else
                sheetName=strtok(currentLightCell(dataPixelLoop,1),".");
            end
            writematrix(lightIV,...
                append(exportPath,"\lightIV-",currentLightCell(dataPixelLoop,2),"-",uniqueLight(dataCellLoop),".xlsx"),'sheet',sheetName,...
                'Range','A1') %write to file IV data for each pixel
        end
        writematrix([headings; currentLightCell],append(exportPath,"\LightSummary-",currentLightCell(dataPixelLoop,2),".xlsx"),'sheet',uniqueLight(dataCellLoop),...
            'Range','A1') %write to file summary data from current cell
    end
end

if isempty(find(strcmp(sortedArray(:,10),"Dark")))
else %if there is dark data do the following, otherwise this is skipped
    darkData=sortedArray(transpose(find(strcmp(sortedArray(:,10),"Dark"))),:); %select dark data only
    uniqueDark=unique(darkData(:,5)); %number of cells for dark data
    for dataCellLoop=1:length(uniqueDark) %loop over all cells for dark data
        currentDarkCell=darkData(transpose(find(strcmp(darkData(:,5),uniqueDark(dataCellLoop)))),:); %summary data from current cell
        for dataPixelLoop=1:length(currentDarkCell(:,1)) % loop over all pixels for current cell
            
            darkIVFullPath=split(currentDarkCell(dataPixelLoop,26),"\"); %IV file path
            darkIVFilePath=darkIVFullPath(end); %IV file name
            darkIV=readmatrix(append(filePath,"\",darkIVFilePath),opts); %import IV file
            
            if strlength(strtok(currentDarkCell(dataPixelLoop,1),".")) > 31 %check that the length of the excel sheet name wont be too long and shorten it if it will
                sheetName=extractBefore(strtok(currentDarkCell(dataPixelLoop,1),"."),31);
            else
                sheetName=strtok(currentDarkCell(dataPixelLoop,1),".");
            end
            writematrix(darkIV,...
                append(exportPath,"\darkIV-",currentDarkCell(dataPixelLoop,2),"-",uniqueDark(dataCellLoop),".xlsx"),'sheet',sheetName,...
                'Range','A1') %write to file IV data for each pixel to sheet called sheetname
        end
        writematrix([headings; currentDarkCell],append(exportPath,"\DarkSummary-",currentDarkCell(dataPixelLoop,2),".xlsx"),'sheet',uniqueDark(dataCellLoop),...
            'Range','A1') %write to file summary data from current cell
    end
end




