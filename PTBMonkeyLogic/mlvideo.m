function result = mlvideo(fxn, varargin)
%SYNTAX LIST:
%mlvideo('init');
%mlvideo('devices');
%mlvideo('setmode', devicenum, bufferpages);
%mlvideo('closewin', winptr);
%mlvideo('maketex', deviceptr, imdata);
%mlvideo('drawtex', deviceptr, textureptr, [sourceRect], [destinationRect])
%mlvideo('flip', deviceptr)
%mlvideo('setbg', deviceptr)
%mlvideo('verticalblank', deviceptr)
%mlvideo('rasterline', deviceptr)
%mlvideo('waitflip', deviceptr, yrasterthresh)
%mlvideo('release')
%mlvideo('hidecursor', screenid)
%mlvideo('showcursor', screenid)
%mlvideo('flush')
%
%Function OnScreenWin is a sub-function that is defined at the end of this
%m file. It is used to find an onscreen window on the specified device.
%Created by RK April, 2013

result = [];
fxn = lower(fxn);

switch fxn
	
	case 'init'
	%initialize OpenGL routines. This will throw errors if the system is
	%not running OpenGL. Also set verbosity to 2, which sets Screen
	%Preferences so that only severe error messages are displayed. Also
	%closes all onscreen and offscreen windows if any are open.
		AssertOpenGL;
		Screen('Preference', 'Verbosity', 2);
		Screen('Preference', 'SkipSyncTests', 0);
		
		if ~isempty(Screen('Windows'))
			Screen('CloseAll');
		end
		
	case 'devices'
	%Count and return number of present screens. Usually, on a
	%multi-display system, 0 is the whole screen (all displays), 1 is the
	%primary display, 2 is the secondary display, and so on. So the total
	%number of screens is 1 less than the different displays detected.
		result = max(Screen('Screens'));
		
	case 'setmode'
	%Open window using Screen('OpenWindow') to prepare display for showing
	%stimuli. Flip through all the buffers.
		mlvideo('init');
		devicenum = varargin{1};
		bufferpages = varargin{2};
		black = BlackIndex(devicenum);
		
		result = Screen('OpenWindow', devicenum, black, [], [], bufferpages);
		
		for i = 1 : bufferpages
			Screen('Flip', result, 0, 2);
		end
		
	case 'closewin'
	%Close a specified window. The window could be an onscreen window or a
	%texture. This replaces 'releasedevice' and 'releasebuffer'
		winptr = varargin{1};
		
		Screen('Close', winptr);
		
	case 'maketex'
	%Make a texture. This replaces 'createbuffer' and 'copybuffer'. If the
	%device number is being provided, the flag should be anything but 1. If
	%the device pointer is being provided, the flag should be 1.
		deviceptr = varargin{1};
		
		imdata = varargin{2};
		result = Screen('MakeTexture', deviceptr, imdata);
		
	case 'drawtex'
	%Draw texture to device's buffer. This replaces 'blit'.
		deviceptr = varargin{1};
		
		texptr = varargin{2};
		sourceRect = [];
		
		if length(varargin) <= 2
			destinationRect = [];
		else
			xpos = varargin{3};
			ypos = varargin{4};
			xsize = varargin{5};
			ysize = varargin{6};
			destinationRect = [xpos ypos (xpos + xsize) (ypos + ysize)];
		end
		
		Screen('DrawTexture', deviceptr, texptr, sourceRect, destinationRect);
		
	case 'flip'
	%flips the backbuffer to the screen. I am setting it up so that it doesn't
	%sync with the vertical blank; it flips immediately.
		deviceptr = varargin{1};
		
		Screen('Flip', deviceptr, [], 2, 1);
		
	case 'setbg'
	%sets the background color for the backbuffer. Replaces 'clear'.
		deviceptr = varargin{1};
		
		color = varargin{2};
		if max(color) <= 1
			color = round(255.*color);
		end
		
		Screen('FillRect', deviceptr, color);
		
	case 'rasterline'
		deviceptr = varargin{1};
		
		result = Screen('GetWindowInfo', deviceptr, 1);
		
	case 'verticalblank'
	%returns whether or not the rasterbeam is in a vertical blank
		deviceptr = varargin{1};
		
		result = ~ Screen('GetWindowInfo', deviceptr, 1);
		
	case 'waitflip'
	%This syncs flip with behavioral codes. It waits until the rasterbeam
	%is not in a vertical blank and it is not past a certain threshold to
	%flip the screen.
		deviceptr = varargin{1};
		
		thresh = varargin{2};
		result = 0;
		
		while ~result || result > thresh
			result = Screen('GetWindowInfo', deviceptr, 1);
		end
		
		mlvideo('Flip', deviceptr);
		
	case 'release'
	%Closes all windows
		if ~isempty(Screen('Windows'))
			for i = Screen('Windows')
				mlvideo('closewin', i);
			end
		end
		
	case 'hidecursor'
	%Hides cursor on specified screen
		devicenum = varargin{1};
		HideCursor(devicenum);
		
	case 'showcursor'
	%Shows cursor on specified screen
		devicenum = varargin{1};
		ShowCursor([], devicenum);
		
	case 'flush'
	%Closes all open windows and makes sure that the cursor is visible on
	%all screens
		mlvideo('init');
		for i = Screen('Screens')
			mlvideo('showcursor', i);
		end
		mlvideo('release');
	
end
end