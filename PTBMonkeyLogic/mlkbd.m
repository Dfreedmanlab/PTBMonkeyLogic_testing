function result = mlkbd(fxn, varargin)
%SYNTAX LIST:
%  mlkbd('init');
%  mlkbd('flush');
%  mlkbd('getkey');
%  mlkbd('release');

result = [];
fxn = lower(fxn);
switch fxn
	%Create queue to start recording keystrokes and start recording key
	%presses
    case 'init',
		KbQueueCreate();
		KbQueueStart();
        
    case 'flush',
	%Flush the keyboard queue
		KbQueueFlush();
        
    case 'getkey',
	%Get the most recent key pressed. Note that this is not the name of the
	%key pressed, merely the scan code.
		[pressed, ~, ~, lastPress] = KbQueueCheck();
		if pressed
			pressedcodes = find(lastPress);
			result = pressedcodes(end);
		end
		mlkbd('flush');
        
    case 'release',
	%Release the queue.
		KbQueueRelease();
        
end
