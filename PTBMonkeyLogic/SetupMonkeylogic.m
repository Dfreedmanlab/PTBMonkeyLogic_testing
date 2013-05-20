%Created by RK on 1/15/2013
%This script installs the Psychtoolbox version of Monkelogic. If 
%Psychtoolbox is not already installed, it also downloads and installs the
%latest version of psychtoolbox.
%
%Currently, Monkeylogic is only supported on windows.
%
%In order to set up Monkeylogic, first download and extract the latest 
%version from the website. Then, in Matlab, cd to the extracted folder and
%install Monkeylogic by running this script.
%
%It is advisable to run Matlab as an administrator when installing
%Monkeylogic to allow access to the files that savepath writes to.

function SetupMonkeylogic

fprintf('Now setting up Monkeylogic\n\n\n');

%List of expressions and strings that will be used later on.
expr1 = 'pcwin';                                                %Windows OS is either pcwin or pcwin64. This will be used to check if we are on windows.
expr2 = ['[^' pathsep ']+'];                                    %Multiple successive occurences of non search path characters. Will be used to separate the 'path' string.
expr3 = 'monkeylogic';
expr4 = 'yes';
expr5 = 'y';
targetdirectory = fileparts(mfilename('fullpath'));             %full path for SetupMonkeylogic mfile
current = mfilename;                                            %name of mfile being run
psych = 'Psychtoolbox';                                         %will use to check for existence of Psychtoolbox

%--------------------------------------------------------------------------
%Determine the OS. Currently, only Windows is supported.
OS = computer;

if isempty(regexpi(OS, expr1))       %not windows
    fprintf('Monkeylogic currently only runs on Windows.\n');
    fprintf('We are working on porting it to other platforms.\n\n');
    error('Unsupported operating system: %s', OS);
end

%--------------------------------------------------------------------------
%Determine whether we are in the correct directory
if ~strcmpi(targetdirectory, pwd)
    fprintf('Please make sure your current directory is the monkeylogic directory.\n\n');
    error('Incorrect working directory: %s', pwd);
end

%--------------------------------------------------------------------------
%Does savepath or path2rc work?
if exist('savepath', 'file')
    err = savepath;
else
    err = path2rc;
end

                               %----------------------------
%Quit if neither works 
if err
    fprintf('Sorry, savepath failed. We probably do not have sufficient priveleges to write to pathdef.m\n');
    fprintf('Please ask an administrator to grant you write priveleges and then run %s again.\n\n', current);
    error('Insufficient priveleges for savepath.');
end

%--------------------------------------------------------------------------
%Find out if Monkeylogic has been previously installed
paths = regexp(path, expr2, 'match');        %cell containing all the different paths in matlab

if any(regexpi(path, expr3))
    fprintf('There are other instances of monkeylogic in the search path.\n');
    answer = input('Would you like to see them?', 's');
    
                         %---------------------------
    %Show all occurrences of Monkeylogic in the search path
    if (strcmpi(answer, expr4) || strcmpi(answer, expr5))       %expr4 and expr5 are 'yes' and 'y'
        fprintf('\n');
        for p = paths
            s = char(p);
            if any(regexpi(s, expr3))                           %expr3 = 'monkeylogic'
                fprintf('%s\n', s);
            end
        end
    end
    
                        %----------------------------               
    %Remove previous Monkeylogics from the search path
    answer = input('\nShould I go ahead and remove the previous installations?', 's');
    if (strcmpi(answer, expr4) || strcmpi(answer, expr5))
        fprintf('\nNow removing all instances of Monkeylogic from the search path...\n\n');
        for p = paths
            s = char(p);
            if any(regexpi(s, expr3))                           %expr3 = 'monkeylogic'
                rmpath(s);
            end
        end
        
        %Try to save the new search path
        attempt_save();											%defined at next bookmark
        
                         %----------------------------    
        %if user answered no, then we can't continue with set up.
    else
        fprintf('\nYou did not say yes, so I am taking that as a no.\n');
        fprintf('Cannot continue with setup without removing pre-existing instances.\n\n');
        error('Please remove Monkeylogic from the search path manually and try again.');
    end
end

%--------------------------------------------------------------------------                       
%Add this Monkeylogic to the search path
fprintf('Now adding Monkeylogic to the Matlab search path.\n\n');
p = targetdirectory;
pp = genpath(p);
addpath(pp);

                         %----------------------------
%Attempt to save the new path. If the attempt fails, display an error.
attempt_save();													%defined at next bookmark

%--------------------------------------------------------------------------
%Check for existence of psychtoolbox. If it does not exist, ask if we
%should go ahead and download it.
psych_exist = ver(psych);

if exist([pwd filesep psych], 'dir')                %download should include a folder that contains DownloadPsychtoolbox
    if isempty(psych_exist)                         %Psychtoolbox not installed
        fprintf('Psychtoolbox not detected. It is required for Monkeylogic to run.\n\n');
        answer = input('Would you like me to download and set up the latest Psychtoolbox?', 's');
        
                            %-------------------------                         
        if (strcmpi(answer, expr4) || strcmpi(answer, expr5))       %if yes
            DownloadPsychtoolbox([pwd filesep psych]);
        else
            fprintf('You have indicated that you would not like me to download and set up Psychtoolbox for you.\n');
            fprintf('Please note that Monkeylogic will not run without Psychtoolbox.\n');
            fprintf('Please install Psychtoolbox before attempting to run Monkeylogic.\n\n');
            rmpath([targetdirectory filesep psych]);				%Don't need to download or install Psychtoolbox
            
                           %--------------------------
            %Save the new path.
            attempt_save();											%Defined at next bookmark
            
                          %--------------------------
            %Remove the directory containing the Psychtoolbox downloader
            rmdir(psych,  's');
        end
        
%--------------------------------------------------------------------------        

    else            %In case the user is simply doing a fresh install and not a fresh download, we do not want to accidentally remove Psychtoolbox
        fprintf('Would you like me to remove the Psychtoolbox downloader that is included with the Monkeylogic download?\n');
        fprintf('This will remove the folder %s from the current folder.\n', psych)
        fprintf('If this is the folder that contains Psychtoolbox on this machine, please say no.\n\n');
        answer = input('Yes or no?', 's');
        
                          %--------------------------   
        if (strcmpi(answer, expr4) || strcmpi(answer, expr5))
            rmpath([targetdirectory filesep psych]);
             
                          %--------------------------
            %Save the new path.
            attempt_save();

                         %-------------------------                
            %Remove the directory containing the Psychtoolbox downloader
            rmdir(psych, 's');
            
%--------------------------------------------------------------------------

        end
    end
else
	warning('PsychToolbox:No_Folder', 'Psychtoolbox downloader not found. If this is a fresh download, other files might also not have downloaded properly.\n');
	
    if isempty(psych_exist)     %if psychtoolbox is already installed and the Psychtoolbox setup directory does not exist, we don't have to do anything.
        fprintf('\nPsychtoolbox is required for Monkeylogic to run.\n');
        fprintf('A Psychtoolbox downloader is included in the Monkeylogic download, but I could not detect\n');
        fprintf('the folder that we usually include with the download.\n');
        fprintf('Please download Psychtoolbox from the Psychtoolbox website.\n\n');
    end
end

%--------------------------------------------------------------------------

fprintf('\n\nAND WE''RE DONE\n\n\n');
end

function attempt_save
	%Try to save the new search path
	if exist('savepath', 'file')
		err = savepath;
	else
		err = path2rc;
	end

	%If savepath didn't work, ask user to try again with sufficient
	%priveleges
	if err
		fprintf('\nCould not save the updated search path.\n\n');
		error('Savepath error.');
	end
end