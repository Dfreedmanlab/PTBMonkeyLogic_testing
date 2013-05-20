function POST
%Created by RK on 1/17/2013
%
%This script runs as soon as monkeylogic runs. It makes sure that
%everything is in order. These are the things it checks:
%1.    Does the current folder contain the monkeylogic m file?
%2.    Is the current folder in the search path?
%3.    Are there multiple instances of monkeylogic in the search path?
%4.    Are all of the required files and folders present?
%5.    Is psychtoolbox set up?

%--------------------------------------------------------------------------
%Constants and expressions
ml_loc = fileparts(mfilename('fullpath'));              %location of the monkeylogic being currently run
work_dir = pwd;                                         %Working directory
mlab_sp = path;                                         %Matlab search path
exp1 = ['[^' pathsep ']+monkeylogic[^' pathsep ']*'];   %Will use this expression to extract instances of monkeylogic occuring in the search path
psych = ver('Psychtoolbox');							%This will only be used to check if psychtoolbox is present

%--------------------------------------------------------------------------
%First, let's make sure that monkeylogic is in the search path and that we
%are running the correct version of monkeylogic if there are multiple
%installations.

fprintf('Now checking to make sure that everything is in order.\n');
fprintf('First let''s check that the correct MonkeyLogic is being run and that we are in the MonkeyLogic directory.\n\n');

%Is the working directory the same as the directory that contains the
%monkeylogic m-file?
if isequal(ml_loc, work_dir)
    %make sure the working directory is in the search path. If it is not,
    %then monkeylogic is probably not properly installed. If it is, then we
    %can go to the next step of the startup check.
    if isempty(findstr(mlab_sp, work_dir))
        fprintf('The MonkeyLogic folder %s is not in the matlab search path.\n', ml_loc);
        fprintf('Please set up MonkeyLogic using the setup file that is included with the download.\n\n');
        error('MonkeyLogic not properly set up.');
    end
    
    fprintf('MonkeyLogic folder is in matlab''s search path.\n\n');
    
                   %--------------------
else
    %Are there multiple different monkeylogics installed?
    ml_paths = regexpi(mlab_sp, exp1, 'match');                                         %this extracts all occurrences of monkeylogic in the search path
    ml_paths_length = regexpi(mlab_sp, exp1, 'end') - regexpi(mlab_sp, exp1, 'start');  %this is the length of each folder location (not exactly, it is the length - 1)
    
    [~, shortest_path_index] = min(ml_paths_length);
    shortest_path = ml_paths{shortest_path_index};
    
                   %---------------------
    %if shortest_path is not present in every occurence of monkeylogic in
    %the search path, then we can be sure that there are multiple
    %monkeylogic folders in the search path.
    multiple_mls = 0;                   %this will be used to report whether or not there are multiple monkeylogic folders in the search path
    
    for p = ml_paths
        s = char(p);
        if ~strfind(s, shortest_path)
            multiple_mls = 1;           %if there are multiple MonkeyLogics, multiple_mls = 1
            break;
        end
    end
    
                  %----------------------            
    %If there are multiple occurrences of MonkeyLogic in the search path,
    %inform the user and ask what we should do next.
    if ~multiple_mls
        fprintf('Great, only one instance of MonkeyLogic found in the search path.\n\n');
		
		%Attempt to cd to the monkeylogic directory
		try_cd(ml_loc);				%function defined at next bookmark
        
		work_dir = pwd;             %update working directory
        fprintf('Successfully changed matlab''s working directory.\n\n');
                  %----------------------             
    else
        fprintf('Multiple instances of MonkeyLogic found in the matlab search path.\n');
        fprintf('Currently using the monkeylogic.m file in %s.\n', ml_loc);
        answer = input('Continue with this MonkeyLogic folder? (yes or no)', 's');
        
        if isempty(regexpi(answer, 'y|yes'))        %User does not want to run the MonkeyLogic.m file in the location indicated.
            fprintf('I did not see a yes, so I will take that as a no.\n');
            fprintf('You have indicated that the current MonkeyLogic is not the one you want to run.\n');
            fprintf('Please cd to the desired MonkeyLogic folder and then run MonkeyLogic again.\n\n');
            error('Incorrect MonkeyLogic being run.');
            
                 %-----------------------    
        else
            fprintf('You have indicated that you would like to continue with the monkeylogic.m file in %s.\n', ml_loc);
            fprintf('In order to avoid possible inconsistencies between different instances of MonkeyLogic found in the search path,\n')
            fprintf('I am changing the working directory to %s.\n\n', ml_loc);
            
            %Attempt to cd to the monkeylogic directory
            try_cd(ml_loc);			%function defined at next bookmark
            
                %--------------------------
            work_dir = pwd;             %update working directory
            fprintf('Successfully changed matlab''s working directory.\n');
        end
        
                %--------------------------
    end
    
                %--------------------------
end

%--------------------------------------------------------------------------
fprintf('Next, let''s make sure that you have all the required files.\n\n')
% 1/23/2013 I am not doing anything to this section yet. I will see what
% scripts, functions etc are actually required as I go through the
% monkeylogic code and figure everything out. For now, I know only that
% the priority_control toolbox is required.
% 4/1/13 Updated. Used list of files from mlpackage.m

files = {...
	'adjust_eye_calibration.m' ...
    'behaviorgraph.m' ...
    'behaviorsummary.m' ...
    'benchmarkmov.avi' ...
    'benchmarkpic.jpg' ...
    'bhv_read.m' ...
    'bhv_write.m' ...
    'changevars.m' ...
    'chartblocks.m' ...
    'chooseblock.m' ...
    'chooseerrorhandling.m' ...
    'codes.txt' ...
	'conditionpercentcorrect.m' ...
    'earth.jpg' ...
    'embedtimingfile.m' ...
    'generate_condition.m' ...
    'genicon.jpg' ...
	'genimgsample.jpg' ...
    'impokehole.m' ...
    'initcontrolscreen.m' ...
    'initializing.avi' ...
	'initio.m' ...
    'initstim.m' ...
    'ioheader.jpg' ...
    'ioscan.m' ...
    'iotest.m' ...
    'load_conditions.m' ...
    'makecircle.m' ...
    'makesquare.m' ...
    'mlflush.m' ...
    'mlkbd.m' ...
    'mlmenu.m' ...
    'mlpackage.m' ...
    'mltimetest.m' ...
    'mlvideo.m' ...
    'mlwebsummary.html' ...
    'mlwebsummary.m' ...
    'monkeylogic.m' ...
    'monkeylogic_alert.m' ...
    'monkeys2.jpg' ...
    'movieicon.jpg' ...
    'parse.m' ...
    'parse_object.m' ...
	'POST.m' ...
    'runbutton.jpg' ...
    'runbuttondim.jpg' ...
    'runbuttonoff.jpg' ...
    'set_ml_directories.m' ...
    'set_ml_preferences.m' ...
	'SetupMonkeylogic.m' ...
    'smooth.m' ...
    'sort_taskobjects.m' ...
    'sortblocks.m' ...
    'soundicon.jpg' ...
    'stimulationicon.jpg' ...
    'taskheader.jpg' ...
    'textblank.jpg' ...
    'tfinit.jpg' ...
    'threemonkeys.jpg' ...
    'trackvarchanges.m' ...
    'trialholder.m' ...
    'ttlicon.jpg' ...
    'videoheader.jpg' ...
    'xycalibrate.m' ...
    };

               %---------------------------
%Check if all required files exist
for f = files
	s = char(f);
	if ~exist([work_dir filesep s], 'file')
		fprintf('Could not find file %s.\n\n', s);
		error('Required file(s) not found.\n');
	end
end

fprintf('All required files are present.\n\n');

%--------------------------------------------------------------------------
%Finally, check for psychtoolbox. I might re-work this later to check what
%version is installed.
fprintf('Now checking for existence of psychtoolbox.\n\n');

if isempty(psych)
	fprintf('You do not have Psychtoolbox installed.\n');
	fprintf('You can download and install Psychtoolbox using the downloader in the Psychtoolbox folder that is included with the MonkeyLogic download.\n');
	fprintf('Or you can run SetupMonkeylogic, which will download and set up Psychtoolbox for you.\n');
	error('Psychtoolbox not installed.\n');
end

fprintf('Psychtoolbox seems to be properly set up.\n');
%We are done. On to actual MonkeyLogic.
%--------------------------------------------------------------------------

end

function try_cd(dir_name)
try
	cd(dir_name);
catch ME
    fprintf('I could not change matlab''s working directory.\n');
    fprintf('The ''cd'' function returned the error: %s', ME.message);
    fprintf('Please manually change the working directory to the desired MonkeyLogic folder and then try running the program again.\n\n');
    error('Could not change matlab''s working directory.');
end
end