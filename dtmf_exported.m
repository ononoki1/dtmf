classdef dtmf_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        DTMF              matlab.ui.Figure
        Help              matlab.ui.container.Menu
        Document          matlab.ui.container.Menu
        About             matlab.ui.container.Menu
        Perfect           matlab.ui.control.StateButton
        Here              matlab.ui.control.Button
        YLabel            matlab.ui.control.Label
        XLabel            matlab.ui.control.Label
        StrShow           matlab.ui.control.Label
        AudioLoad         matlab.ui.control.Button
        Save              matlab.ui.control.Button
        Play              matlab.ui.control.Button
        StrInput          matlab.ui.control.EditField
        StringInputLabel  matlab.ui.control.Label
        ButtonD           matlab.ui.control.Button
        ButtonHashtag     matlab.ui.control.Button
        Button0           matlab.ui.control.Button
        ButtonAsterisk    matlab.ui.control.Button
        ButtonC           matlab.ui.control.Button
        Button9           matlab.ui.control.Button
        Button8           matlab.ui.control.Button
        Button7           matlab.ui.control.Button
        ButtonB           matlab.ui.control.Button
        Button6           matlab.ui.control.Button
        Button5           matlab.ui.control.Button
        Button4           matlab.ui.control.Button
        ButtonA           matlab.ui.control.Button
        Button3           matlab.ui.control.Button
        Button2           matlab.ui.control.Button
        Button1           matlab.ui.control.Button
        PicT              matlab.ui.control.UIAxes
        PicTIn            matlab.ui.control.UIAxes
        PicW              matlab.ui.control.UIAxes
    end


    % properties and methods are all public so that sub windows can use them
    properties (Access = public)
        SubSave; % handle of subSave
        SubLoad; % handle of subLoad
        SubError; % handle of subError
        SubWarning; % handle of subWarning
        SubDocument; % handle of subDocument
        SubAbout; % handle of subAbout
        SubStr; % handle of subStr
        hasSub=0; % =1 if there is a subLoad/subSave/subStr window
        hasError=0; % =1 if there is a subError window
        % =2 if there is a subWarning window with corresponding reason now
        % =1 if there was a subWarning window with corresponding reason
        hasWarning=[0,0];
        data=[697,770,852,941,1209,1336,1477,1633]; % DTMF frequency
        fs=8000; % sample rate to write, default 8000
        loadFs; % sample rate of loaded audio
        audioTime=0.5; % time of generated audio of every char, default 0.5s
        silenceTime=[0.1,0.5]; % range of generated random silence time, default 0.1s-0.5s
        audio; % matrix of generated audio
        audioIn; % matrix of loaded audio
        audioW; % matrix of frequency wave of loaded audio
        strIn; % DTMF string from loaded audio
        picTInLine; % handle of line in PicTIn
        indexes=1; % matrix of indexes of splited loaded audio
        splits={}; % cell array of splited loaded audio
        audioPickTime=0.03; % time of picking PicTIn when clicking, default 0.03s
        deviation=0.1; % max deviation of getting char from frequency, default 10%
    end

    methods (Access = public)

        % check whether str is valid DTMF string
        % return 2 if error
        % return 1 if warning
        % return 0 if valid
        function result = checkStrInput(~,str)
            valid='0123456789*#ABCDabcd';
            warn='abcd';
            result=0;
            for k=1:length(str)
                if contains(valid,str(k))==0 % give error if str(k) is not in valid string
                    result=2;
                    return;
                end
                if contains(warn,str(k))==1 % give warning if str(k) is in warn string
                    result=1;
                end
            end
        end

        % make DTMF signal according to input string
        function audio = makeSignal(app,str)
            if isempty(str) % return empty matrix if str is empty
                audio=[];
                return;
            end

            % use makeSingleSignal to make every char's signal and cat them with random silence
            audio=app.makeSingleSignal(str(1));
            for k=2:length(str)
                audio=[audio,app.randSilence,app.makeSingleSignal(str(k))];
            end
        end

        % make DTMF signal for input char
        function f = makeSingleSignal(app,char)
            f=app.getData(char,app.audioTime); % see getData function for details
        end

        % generate random silence according to silenceTime
        function result = randSilence(app)
            timeEnd=app.silenceTime(1)+(app.silenceTime(2)-app.silenceTime(1))*rand;
            result=zeros(1,round(timeEnd*app.fs));
        end

        % used as button pushed callback
        function buttonInput(app,char)
            app.StrInput.Value=app.StrInput.Value+string(char); % update StrInput.Value
            app.audio=app.makeSignal(app.StrInput.Value); % update audio
            t=0:1/app.fs:(length(app.audio)-1)/app.fs;
            plot(app.PicT,t,app.audio); % update PicT
            fShort=app.getData(char,app.audioTime);
            sound(fShort); % play char's DTMF audio
        end

        % make DTMF signal according to input char and time
        function f = getData(app,char,time)
            t=0:1/app.fs:time;
            if contains('123Aa',char)==1 % get lower frequency according to DTMF data
                f1=sin(2*pi*app.data(1)*t);
            elseif contains('456Bb',char)==1
                f1=sin(2*pi*app.data(2)*t);
            elseif contains('789Cc',char)==1
                f1=sin(2*pi*app.data(3)*t);
            else
                f1=sin(2*pi*app.data(4)*t);
            end
            if contains('147*',char)==1 % get higher frequency according to DTMF data
                f2=sin(2*pi*app.data(5)*t);
            elseif contains('2580',char)==1
                f2=sin(2*pi*app.data(6)*t);
            elseif contains('369#',char)==1
                f2=sin(2*pi*app.data(7)*t);
            else
                f2=sin(2*pi*app.data(8)*t);
            end
            f=f1+f2; % add them
        end

        % make main window non-interactive when there is certain sub window
        % used by sub windows
        function disableAll(app)
            app.StrInput.Enable=0;
            app.Button0.Enable=0;
            app.Button1.Enable=0;
            app.Button2.Enable=0;
            app.Button3.Enable=0;
            app.Button4.Enable=0;
            app.Button5.Enable=0;
            app.Button6.Enable=0;
            app.Button7.Enable=0;
            app.Button8.Enable=0;
            app.Button9.Enable=0;
            app.ButtonA.Enable=0;
            app.ButtonB.Enable=0;
            app.ButtonC.Enable=0;
            app.ButtonD.Enable=0;
            app.ButtonAsterisk.Enable=0;
            app.ButtonHashtag.Enable=0;
            app.Play.Enable=0;
            app.Save.Enable=0;
            app.AudioLoad.Enable=0;
            app.Here.Enable=0;
        end

        % make main window interactive when certain sub window closes
        % used by sub windows
        function enableAll(app)
            if app.hasSub==0 % check hasSub since there might be more than one sub window
                app.StrInput.Enable=1;
                app.Button0.Enable=1;
                app.Button1.Enable=1;
                app.Button2.Enable=1;
                app.Button3.Enable=1;
                app.Button4.Enable=1;
                app.Button5.Enable=1;
                app.Button6.Enable=1;
                app.Button7.Enable=1;
                app.Button8.Enable=1;
                app.Button9.Enable=1;
                app.ButtonA.Enable=1;
                app.ButtonB.Enable=1;
                app.ButtonC.Enable=1;
                app.ButtonD.Enable=1;
                app.ButtonAsterisk.Enable=1;
                app.ButtonHashtag.Enable=1;
                app.Play.Enable=1;
                app.Save.Enable=1;
                app.AudioLoad.Enable=1;
                app.Here.Enable=1;
            end
        end

        % gracefully close certain sub window
        % used by sub windows
        function closeIt(app,sub)
            app.enableAll;
            delete(sub);
        end

        % find smallest positive number's index in an incremental array
        % this function is a little confusing
        % see how it is used in click function to better understand it
        function index = minPositive(~,arr)
            for k=1:length(arr)
                if arr(k)>0
                    index=k;
                    return;
                end
            end

            % if not return before this step
            % it means every element in array is non-positive
            % so user's hit is invalid and need to return an odd number
            % use 1 here
            % you can also use 3,5,7,9,...
            index=1;
        end
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function init(app)
            rng("shuffle"); % make sure generated random numbers are not repeatable
        end

        % Value changed function: StrInput
        function strInput(app, event)
            str = app.StrInput.Value;
            if app.checkStrInput(str)==2 % give error if input string is invalid
                app.SubError=subError(app,app,"input-invalid");
                return;
            elseif app.checkStrInput(str)==1 % give warning if input string contains lower case letters
                app.SubWarning=subWarning(app,app,"input-lower");
            end
            app.audio=app.makeSignal(str); % see makeSignal function for details
            t=0:1/app.fs:(length(app.audio)-1)/app.fs;
            if isempty(t) % clear PicT if input string is empty
                cla(app.PicT);
            else % else plot it
                plot(app.PicT,t,app.audio);
            end
        end

        % Button pushed function: Save
        function save(app, event)
            if isempty(app.StrInput.Value) % give error if input string is empty or invalid
                app.SubError=subError(app,app,"input-save-empty");
            elseif app.hasError==0 && app.checkStrInput(app.StrInput.Value)==2 % make error type consistent
                app.SubError=subError(app,app,"input-invalid");
            elseif app.hasError==1 || app.hasWarning(2)==2 % not pop up when there is error/warning window
                return;
            else % else pop up save window
                app.SubSave=subSave(app);
            end
        end

        % Button pushed function: Play
        function play(app, event)
            sound(app.audio,app.fs); % use sample rate fs to play audio
        end

        % Button pushed function: Button1
        function button1(app, event)
            app.buttonInput('1'); % see buttonInput function for details
        end

        % Button pushed function: Button2
        function button2(app, event)
            app.buttonInput('2'); % see buttonInput function for details
        end

        % Button pushed function: Button3
        function button3(app, event)
            app.buttonInput('3'); % see buttonInput function for details
        end

        % Button pushed function: ButtonA
        function buttonA(app, event)
            app.buttonInput('A'); % see buttonInput function for details
        end

        % Button pushed function: Button4
        function button4(app, event)
            app.buttonInput('4'); % see buttonInput function for details
        end

        % Button pushed function: Button5
        function button5(app, event)
            app.buttonInput('5'); % see buttonInput function for details
        end

        % Button pushed function: Button6
        function button6(app, event)
            app.buttonInput('6'); % see buttonInput function for details
        end

        % Button pushed function: ButtonB
        function buttonB(app, event)
            app.buttonInput('B'); % see buttonInput function for details
        end

        % Button pushed function: Button7
        function button7(app, event)
            app.buttonInput('7'); % see buttonInput function for details
        end

        % Button pushed function: Button8
        function button8(app, event)
            app.buttonInput('8'); % see buttonInput function for details
        end

        % Button pushed function: Button9
        function button9(app, event)
            app.buttonInput('9'); % see buttonInput function for details
        end

        % Button pushed function: ButtonC
        function buttonC(app, event)
            app.buttonInput('C'); % see buttonInput function for details
        end

        % Button pushed function: ButtonAsterisk
        function buttonAsterisk(app, event)
            app.buttonInput('*'); % see buttonInput function for details
        end

        % Button pushed function: Button0
        function button0(app, event)
            app.buttonInput('0'); % see buttonInput function for details
        end

        % Button pushed function: ButtonHashtag
        function buttonHashtag(app, event)
            app.buttonInput('#'); % see buttonInput function for details
        end

        % Button pushed function: ButtonD
        function buttonD(app, event)
            app.buttonInput('D'); % see buttonInput function for details
        end

        % Menu selected function: About
        function about(app, event)
            app.SubAbout=subAbout; % pop up about window
        end

        % Menu selected function: Document
        function document(app, event)
            app.SubDocument=subDocument; % pop up document window
        end

        % Button pushed function: AudioLoad
        function load(app, event)
            if app.hasError==0 && app.hasWarning(2)~=2
                app.SubLoad=subLoad(app); % pop up load window
            end
        end

        % Close request function: DTMF
        function closeWindow(app, event)
            % close all sub windows before closing itself
            delete(app.SubAbout);
            delete(app.SubDocument);
            delete(app.SubStr);
            delete(app.SubError);
            delete(app.SubWarning);
            delete(app.SubSave);
            delete(app.SubLoad);
            delete(app);
        end

        % Button down function: PicTIn
        function click(app, event)
            % if click PicTIn, then show corresponding frequency wave
            if app.hasSub==0 && ~isempty(app.PicTIn.Children) % make sure PicTIn has lines
                tStart=round(app.PicTIn.CurrentPoint(1,1)*app.loadFs); % get hit's x location
                if tStart<0 % return if hit exceeds valid area
                    return;
                end
                index=app.minPositive(app.indexes-tStart); % find corresponding index in indexes for tEnd
                if mod(index,2)==1 % return if hit exceeds valid area
                    return;
                end

                % determine audioPickTime
                if app.Perfect.Value~=0 % if perfect, use all valid part
                    tStart=app.indexes(index-1);
                    tEnd=app.indexes(index);
                elseif tStart+app.audioPickTime*app.loadFs>app.indexes(index) % tEnd exceeds audio end
                    % calculated tStart via tEnd exceeds audio start
                    if app.indexes(index)-app.audioPickTime*app.loadFs<app.indexes(index-1)

                        % give warning if audio time shorter than audioPickTime
                        app.SubWarning=subWarning(app,app,"audio-short");

                        tStart=app.indexes(index-1); % reset tStart and tEnd
                        tEnd=app.indexes(index);
                    else % calculated tStart is valid
                        tEnd=app.indexes(index); % reset tEnd
                        tStart=tEnd-round(app.audioPickTime*app.loadFs); % calculate tStart via tEnd
                    end
                else % both tStart and tEnd are valid
                    tEnd=tStart+round(app.audioPickTime*app.loadFs); % calculate tEnd via tStart
                end

                w=abs(fft(app.PicTIn.Children.YData(tStart:tEnd))); % do fft
                n=1:round(length(w)/2);
                plot(app.PicW,n*app.loadFs/(tEnd-tStart),w(1:round(end/2))); % calculate f from n and plot
                app.XLabel.Text="X: "+string(app.PicTIn.CurrentPoint(1,1)); % display x and y location
                app.YLabel.Text="Y: "+string(app.PicTIn.Children.YData(round(app.PicTIn.CurrentPoint(1,1)*app.loadFs)));
            end
        end

        % Button pushed function: Here
        function here(app, event)
            app.SubStr=subStr(app,app.strIn);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create DTMF and hide until all components are created
            app.DTMF = uifigure('Visible', 'off');
            app.DTMF.Position = [100 100 896 594];
            app.DTMF.Name = 'DTMF - Matlab Homework';
            app.DTMF.Icon = 'photo.jpg';
            app.DTMF.CloseRequestFcn = createCallbackFcn(app, @closeWindow, true);

            % Create Help
            app.Help = uimenu(app.DTMF);
            app.Help.Text = 'Help';

            % Create Document
            app.Document = uimenu(app.Help);
            app.Document.MenuSelectedFcn = createCallbackFcn(app, @document, true);
            app.Document.Text = 'Document';

            % Create About
            app.About = uimenu(app.Help);
            app.About.MenuSelectedFcn = createCallbackFcn(app, @about, true);
            app.About.Separator = 'on';
            app.About.Text = 'About';

            % Create PicW
            app.PicW = uiaxes(app.DTMF);
            title(app.PicW, 'Loaded Frequency Wave')
            xlabel(app.PicW, 'f/Hz')
            ylabel(app.PicW, 'Audio')
            zlabel(app.PicW, 'Z')
            app.PicW.Position = [467 27 400 224];

            % Create PicTIn
            app.PicTIn = uiaxes(app.DTMF);
            title(app.PicTIn, 'Loaded Time Wave')
            xlabel(app.PicTIn, 't/s')
            ylabel(app.PicTIn, 'Audio')
            zlabel(app.PicTIn, 'Z')
            app.PicTIn.ButtonDownFcn = createCallbackFcn(app, @click, true);
            app.PicTIn.Position = [467 305 400 276];

            % Create PicT
            app.PicT = uiaxes(app.DTMF);
            title(app.PicT, 'Generated Time Wave')
            xlabel(app.PicT, 't/s')
            ylabel(app.PicT, 'Audio')
            zlabel(app.PicT, 'Z')
            app.PicT.FontSize = 12;
            app.PicT.Position = [27 305 382 276];

            % Create Button1
            app.Button1 = uibutton(app.DTMF, 'push');
            app.Button1.ButtonPushedFcn = createCallbackFcn(app, @button1, true);
            app.Button1.FontName = 'Arial';
            app.Button1.FontSize = 16;
            app.Button1.Position = [41 198 48 27];
            app.Button1.Text = '1';

            % Create Button2
            app.Button2 = uibutton(app.DTMF, 'push');
            app.Button2.ButtonPushedFcn = createCallbackFcn(app, @button2, true);
            app.Button2.FontName = 'Arial';
            app.Button2.FontSize = 16;
            app.Button2.Position = [116 198 48 27];
            app.Button2.Text = '2';

            % Create Button3
            app.Button3 = uibutton(app.DTMF, 'push');
            app.Button3.ButtonPushedFcn = createCallbackFcn(app, @button3, true);
            app.Button3.FontName = 'Arial';
            app.Button3.FontSize = 16;
            app.Button3.Position = [190 198 48 27];
            app.Button3.Text = '3';

            % Create ButtonA
            app.ButtonA = uibutton(app.DTMF, 'push');
            app.ButtonA.ButtonPushedFcn = createCallbackFcn(app, @buttonA, true);
            app.ButtonA.FontName = 'Arial';
            app.ButtonA.FontSize = 16;
            app.ButtonA.Position = [265 198 48 27];
            app.ButtonA.Text = 'A';

            % Create Button4
            app.Button4 = uibutton(app.DTMF, 'push');
            app.Button4.ButtonPushedFcn = createCallbackFcn(app, @button4, true);
            app.Button4.FontName = 'Arial';
            app.Button4.FontSize = 16;
            app.Button4.Position = [41 159 48 27];
            app.Button4.Text = '4';

            % Create Button5
            app.Button5 = uibutton(app.DTMF, 'push');
            app.Button5.ButtonPushedFcn = createCallbackFcn(app, @button5, true);
            app.Button5.FontName = 'Arial';
            app.Button5.FontSize = 16;
            app.Button5.Position = [116 159 48 27];
            app.Button5.Text = '5';

            % Create Button6
            app.Button6 = uibutton(app.DTMF, 'push');
            app.Button6.ButtonPushedFcn = createCallbackFcn(app, @button6, true);
            app.Button6.FontName = 'Arial';
            app.Button6.FontSize = 16;
            app.Button6.Position = [190 159 48 27];
            app.Button6.Text = '6';

            % Create ButtonB
            app.ButtonB = uibutton(app.DTMF, 'push');
            app.ButtonB.ButtonPushedFcn = createCallbackFcn(app, @buttonB, true);
            app.ButtonB.FontName = 'Arial';
            app.ButtonB.FontSize = 16;
            app.ButtonB.Position = [265 159 48 27];
            app.ButtonB.Text = 'B';

            % Create Button7
            app.Button7 = uibutton(app.DTMF, 'push');
            app.Button7.ButtonPushedFcn = createCallbackFcn(app, @button7, true);
            app.Button7.FontName = 'Arial';
            app.Button7.FontSize = 16;
            app.Button7.Position = [41 116 48 27];
            app.Button7.Text = '7';

            % Create Button8
            app.Button8 = uibutton(app.DTMF, 'push');
            app.Button8.ButtonPushedFcn = createCallbackFcn(app, @button8, true);
            app.Button8.FontName = 'Arial';
            app.Button8.FontSize = 16;
            app.Button8.Position = [116 116 48 27];
            app.Button8.Text = '8';

            % Create Button9
            app.Button9 = uibutton(app.DTMF, 'push');
            app.Button9.ButtonPushedFcn = createCallbackFcn(app, @button9, true);
            app.Button9.FontName = 'Arial';
            app.Button9.FontSize = 16;
            app.Button9.Position = [190 116 48 27];
            app.Button9.Text = '9';

            % Create ButtonC
            app.ButtonC = uibutton(app.DTMF, 'push');
            app.ButtonC.ButtonPushedFcn = createCallbackFcn(app, @buttonC, true);
            app.ButtonC.FontName = 'Arial';
            app.ButtonC.FontSize = 16;
            app.ButtonC.Position = [265 116 48 27];
            app.ButtonC.Text = 'C';

            % Create ButtonAsterisk
            app.ButtonAsterisk = uibutton(app.DTMF, 'push');
            app.ButtonAsterisk.ButtonPushedFcn = createCallbackFcn(app, @buttonAsterisk, true);
            app.ButtonAsterisk.FontName = 'Arial';
            app.ButtonAsterisk.FontSize = 16;
            app.ButtonAsterisk.Position = [41 77 48 27];
            app.ButtonAsterisk.Text = '*';

            % Create Button0
            app.Button0 = uibutton(app.DTMF, 'push');
            app.Button0.ButtonPushedFcn = createCallbackFcn(app, @button0, true);
            app.Button0.FontName = 'Arial';
            app.Button0.FontSize = 16;
            app.Button0.Position = [116 77 48 27];
            app.Button0.Text = '0';

            % Create ButtonHashtag
            app.ButtonHashtag = uibutton(app.DTMF, 'push');
            app.ButtonHashtag.ButtonPushedFcn = createCallbackFcn(app, @buttonHashtag, true);
            app.ButtonHashtag.FontName = 'Arial';
            app.ButtonHashtag.FontSize = 16;
            app.ButtonHashtag.Position = [190 77 48 27];
            app.ButtonHashtag.Text = '#';

            % Create ButtonD
            app.ButtonD = uibutton(app.DTMF, 'push');
            app.ButtonD.ButtonPushedFcn = createCallbackFcn(app, @buttonD, true);
            app.ButtonD.FontName = 'Arial';
            app.ButtonD.FontSize = 16;
            app.ButtonD.Position = [265 77 48 27];
            app.ButtonD.Text = 'D';

            % Create StringInputLabel
            app.StringInputLabel = uilabel(app.DTMF);
            app.StringInputLabel.HorizontalAlignment = 'right';
            app.StringInputLabel.FontName = 'Times New Roman';
            app.StringInputLabel.FontSize = 16;
            app.StringInputLabel.Position = [41 248 87 22];
            app.StringInputLabel.Text = 'String Input:';

            % Create StrInput
            app.StrInput = uieditfield(app.DTMF, 'text');
            app.StrInput.ValueChangedFcn = createCallbackFcn(app, @strInput, true);
            app.StrInput.HorizontalAlignment = 'center';
            app.StrInput.FontName = 'Times New Roman';
            app.StrInput.FontSize = 16;
            app.StrInput.Position = [143 246 170 26];

            % Create Play
            app.Play = uibutton(app.DTMF, 'push');
            app.Play.ButtonPushedFcn = createCallbackFcn(app, @play, true);
            app.Play.FontName = 'Arial';
            app.Play.FontSize = 16;
            app.Play.Position = [349 159 60 66];
            app.Play.Text = 'Play';

            % Create Save
            app.Save = uibutton(app.DTMF, 'push');
            app.Save.ButtonPushedFcn = createCallbackFcn(app, @save, true);
            app.Save.FontName = 'Arial';
            app.Save.FontSize = 16;
            app.Save.Position = [349 77 60 66];
            app.Save.Text = 'Save';

            % Create AudioLoad
            app.AudioLoad = uibutton(app.DTMF, 'push');
            app.AudioLoad.ButtonPushedFcn = createCallbackFcn(app, @load, true);
            app.AudioLoad.FontName = 'Arial';
            app.AudioLoad.FontSize = 16;
            app.AudioLoad.Position = [41 27 107 27];
            app.AudioLoad.Text = 'Audio Load';

            % Create StrShow
            app.StrShow = uilabel(app.DTMF);
            app.StrShow.HorizontalAlignment = 'center';
            app.StrShow.WordWrap = 'on';
            app.StrShow.FontName = 'Times New Roman';
            app.StrShow.FontSize = 16;
            app.StrShow.Position = [163 27 246 27];
            app.StrShow.Text = 'Loaded String: ';

            % Create XLabel
            app.XLabel = uilabel(app.DTMF);
            app.XLabel.HorizontalAlignment = 'center';
            app.XLabel.FontName = 'Times New Roman';
            app.XLabel.FontSize = 16;
            app.XLabel.Position = [508 271 172 22];
            app.XLabel.Text = 'X: ';

            % Create YLabel
            app.YLabel = uilabel(app.DTMF);
            app.YLabel.HorizontalAlignment = 'center';
            app.YLabel.FontName = 'Times New Roman';
            app.YLabel.FontSize = 16;
            app.YLabel.Position = [679 271 178 22];
            app.YLabel.Text = 'Y: ';

            % Create Here
            app.Here = uibutton(app.DTMF, 'push');
            app.Here.ButtonPushedFcn = createCallbackFcn(app, @here, true);
            app.Here.FontName = 'Times New Roman';
            app.Here.FontSize = 16;
            app.Here.Visible = 'off';
            app.Here.Position = [349 26 38 28];
            app.Here.Text = 'here';

            % Create Perfect
            app.Perfect = uibutton(app.DTMF, 'state');
            app.Perfect.Text = 'Perfect';
            app.Perfect.FontName = 'Arial';
            app.Perfect.FontSize = 16;
            app.Perfect.Position = [349 246 60 26];

            % Show the figure after all components are created
            app.DTMF.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dtmf_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.DTMF)

            % Execute the startup function
            runStartupFcn(app, @init)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.DTMF)
        end
    end
end