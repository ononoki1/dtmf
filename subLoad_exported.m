classdef subLoad_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        Load                           matlab.ui.Figure
        WavSelect                      matlab.ui.control.Button
        Cancel                         matlab.ui.control.Button
        LoadButton                     matlab.ui.control.Button
        Wav                            matlab.ui.control.EditField
        wavfilelocationEditFieldLabel  matlab.ui.control.Label
        Button                         matlab.ui.container.ButtonGroup
        NoGenerated                    matlab.ui.control.Label
        External                       matlab.ui.control.RadioButton
        Generated                      matlab.ui.control.RadioButton
    end


    % properties and methods are all public so that sub windows can use them
    properties (Access = public)
        main; % handle of main window
    end

    methods (Access = public)

        % find f1 and f2 in frequency wave
        function [f1,f2] = findFrequency(app,index)
            m=app.main.splits{index};
            [~,f]=maxk(m(1:round(end/2)),2); % get max 2 values' indexes
            if f(1)<f(2) % clarify which one is max and make sure f1<f2
                f1_=f(1);
                f2_=f(2);
            else
                f1_=f(2);
                f2_=f(1);
            end
            f1=f1_/app.lenT(index); % calculate f from n
            f2=f2_/app.lenT(index);
        end

        % get DTMF string according to loaded audio
        function str = getStr(app)
            str="";
            app.split; % see split function for details
            for k=1:length(app.main.splits) % get every section's char and cat them
                [f1,f2]=app.findFrequency(k); % get corresponding frequency
                [result,status]=app.findNear(f1,f2); % get char according to frequency
                if status==0 % if valid
                    str=str+string(result);
                else % return empty string if invalid
                    str="";
                    return;
                end
            end
        end

        % split loaded audio into splits and indexes
        function split(app)
            app.main.indexes=1;
            app.main.splits={}; % use cell array so that it can deal with variable length audio
            audio=app.main.audioIn;
            nowZero=0;
            startAudio=1;
            temp=[];
            splits_={};
            if ~isempty(audio) && audio(1)==0
                for k=1:length(audio)
                    if audio(k)~=0
                        startAudio=k;
                        app.main.indexes=k;
                        break;
                    end
                end
            end
            for k=startAudio:length(audio)-1
                % now is silence only when both audio(k) and audio(k+1) are 0
                if audio(k)~=0 || audio(k+1)~=0 % now is not silence
                    if nowZero~=0 % means audio(k-1) is thought as silence
                        nowZero=0; % reset nowZero
                        app.main.indexes(end+1)=k;
                    end
                    temp(end+1)=audio(k);
                elseif nowZero==0 % now is silence but audio(k-1) is not thought as silence
                    nowZero=1; % mark silence
                    app.main.indexes(end+1)=k;
                    splits_{end+1}=temp;
                    temp=[];
                end
            end
            if audio(end)~=0 || nowZero==0
                app.main.indexes(end+1)=length(audio);
                temp(end+1)=audio(end);
                splits_{end+1}=temp;
            end
            for k=1:length(splits_) % do fft
                app.main.splits{k}=abs(fft(splits_{k}));
            end
        end

        % get char according to frequency
        function [result,status] = findNear(app,f1,f2)
            data1=app.main.data(1:4);
            data2=app.main.data(5:8);
            [value1,index1] = min(abs(data1-f1)); % find nearest frequency and it's index
            [value2,index2] = min(abs(data2-f2));
            % if deviation is too large, return empty string and non-zero status
            if max(value1/data1(index1),value2/data2(index2))>app.main.deviation
                result='';
                status=1;
            else
                allChar='123A456B789C*0#D';
                result=allChar((index1-1)*4+index2);
                status=0;
            end
        end

        % used to calculate f from n
        function len = lenT(app,index)
            len=(length(app.main.splits{index})-1)/app.main.loadFs;
        end

        % make this window non-interactive when there is certain sub window
        % used by sub windows
        function disableAll(app)
            app.Button.Enable='off';
            app.Wav.Enable=0;
            app.WavSelect.Enable=0;
            app.LoadButton.Enable=0;
            app.Cancel.Enable=0;
        end

        % make this window interactive when certain sub window closes
        % used by sub windows
        function enableAll(app)
            app.Button.Enable='on';
            app.Wav.Enable=1;
            app.WavSelect.Enable=1;
            app.LoadButton.Enable=1;
            app.Cancel.Enable=1;
        end

        % gracefully close certain sub window
        % used by sub windows
        function closeIt(app,sub)
            app.enableAll;
            delete(sub);
        end
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function init(app, main)
            app.main=main;

            % make main window non-interactive and continue if there is no other sub window
            % otherwise exit
            if app.main.hasSub==0
                app.main.hasSub=1;
                app.main.disableAll;
            else
                app.main.closeIt(app);
            end

            if isempty(app.main.audio) % if there is no generated audio
                app.Generated.Enable=0; % make Generated button disabled
                app.NoGenerated.Visible=1; % prompt Generated button unavailable
                app.Button.SelectedObject=app.External; % set initial selection to External
                app.Wav.Visible=1; % make .wav file input visible
                app.wavfilelocationEditFieldLabel.Visible=1;
                app.WavSelect.Visible=1;
            end
        end

        % Selection changed function: Button
        function select(app, event)
            % if select External, make .wav file input visible
            % otherwise the opposite
            if app.Button.SelectedObject==app.External
                app.Wav.Visible=1;
                app.wavfilelocationEditFieldLabel.Visible=1;
                app.WavSelect.Visible=1;
            else
                app.Wav.Visible=0;
                app.wavfilelocationEditFieldLabel.Visible=0;
                app.WavSelect.Visible=0;
            end
        end

        % Button pushed function: LoadButton
        function load(app, event)
            if app.Button.SelectedObject==app.External
                if isfile(app.Wav.Value)
                    try % give error if read fails
                        [app.main.audioIn,app.main.loadFs]=audioread(app.Wav.Value);
                    catch
                        app.main.SubError=subError(app.main,app,"load-invalid");
                        return;
                    end
                else % give error if input file not exists
                    app.main.SubError=subError(app.main,app,"load-empty");
                    return;
                end
            else % get audio and fs from itself if select Generated
                app.main.audioIn=app.main.audio;
                app.main.loadFs=app.main.fs;
            end
            try % give error if loaded audio is not DTMF audio
                app.main.strIn=app.getStr;
            catch
                app.main.SubError=subError(app.main,app,"load-not-dtmf");
                return;
            end
            if isempty(app.main.strIn) % give error if loaded audio is not DTMF audio
                app.main.SubError=subError(app.main,app,"load-not-dtmf");
                return;
            elseif strlength(app.main.strIn)<13 % if string is short, display it directly
                app.main.Here.Visible=0;
                app.main.StrShow.Text="Loaded String: "+app.main.strIn;
            else % if string is long, display it in a sub window
                app.main.StrShow.Text="Loaded String: see ";
                app.main.Here.Visible=1;
            end
            t=0:1/app.main.loadFs:(length(app.main.audioIn)-1)/app.main.loadFs;
            plot(app.main.PicTIn,t,app.main.audioIn,'HitTest','off'); % plot loaded audio
            app.main.hasSub=0; % reset hasSub since this window will be closed
            app.main.closeIt(app);
        end

        % Close request function: Load
        function closeWindow(app, event)
            app.main.hasSub=0; % reset hasSub since this window will be closed
            app.main.closeIt(app);
        end

        % Button pushed function: Cancel
        function cancel(app, event)
            app.main.hasSub=0; % reset hasSub since this window will be closed
            app.main.closeIt(app);
        end

        % Button pushed function: WavSelect
        function wavSelect(app, event)
            [file,path]=uigetfile('*.wav'); % prompt a getfile ui
            if file~=0 % if user select a file, use fullfile to cat path and file
                app.Wav.Value=fullfile(path,file);
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create Load and hide until all components are created
            app.Load = uifigure('Visible', 'off');
            app.Load.Position = [100 100 483 209];
            app.Load.Name = 'Load - DTMF';
            app.Load.Icon = 'photo.jpg';
            app.Load.CloseRequestFcn = createCallbackFcn(app, @closeWindow, true);

            % Create Button
            app.Button = uibuttongroup(app.Load);
            app.Button.SelectionChangedFcn = createCallbackFcn(app, @select, true);
            app.Button.BorderType = 'none';
            app.Button.TitlePosition = 'centertop';
            app.Button.Position = [106 110 276 82];

            % Create Generated
            app.Generated = uiradiobutton(app.Button);
            app.Generated.Text = 'Use generated audio';
            app.Generated.FontName = 'Times New Roman';
            app.Generated.FontSize = 18;
            app.Generated.Position = [16 61 169 22];
            app.Generated.Value = true;

            % Create External
            app.External = uiradiobutton(app.Button);
            app.External.Text = 'Use external audio';
            app.External.FontName = 'Times New Roman';
            app.External.FontSize = 18;
            app.External.Position = [17 5 157 22];

            % Create NoGenerated
            app.NoGenerated = uilabel(app.Button);
            app.NoGenerated.HorizontalAlignment = 'center';
            app.NoGenerated.FontName = 'Arial';
            app.NoGenerated.Visible = 'off';
            app.NoGenerated.Position = [14 40 246 22];
            app.NoGenerated.Text = 'Not available since no valid audio generated.';

            % Create wavfilelocationEditFieldLabel
            app.wavfilelocationEditFieldLabel = uilabel(app.Load);
            app.wavfilelocationEditFieldLabel.FontName = 'Arial';
            app.wavfilelocationEditFieldLabel.Visible = 'off';
            app.wavfilelocationEditFieldLabel.Position = [47 77 97 22];
            app.wavfilelocationEditFieldLabel.Text = '.wav file location:';

            % Create Wav
            app.Wav = uieditfield(app.Load, 'text');
            app.Wav.FontName = 'Arial';
            app.Wav.Visible = 'off';
            app.Wav.Position = [158 77 234 22];

            % Create LoadButton
            app.LoadButton = uibutton(app.Load, 'push');
            app.LoadButton.ButtonPushedFcn = createCallbackFcn(app, @load, true);
            app.LoadButton.FontName = 'Arial';
            app.LoadButton.FontSize = 16;
            app.LoadButton.Position = [119 26 100 27];
            app.LoadButton.Text = 'Load';

            % Create Cancel
            app.Cancel = uibutton(app.Load, 'push');
            app.Cancel.ButtonPushedFcn = createCallbackFcn(app, @cancel, true);
            app.Cancel.FontName = 'Arial';
            app.Cancel.FontSize = 16;
            app.Cancel.Position = [269 26 100 27];
            app.Cancel.Text = 'Cancel';

            % Create WavSelect
            app.WavSelect = uibutton(app.Load, 'push');
            app.WavSelect.ButtonPushedFcn = createCallbackFcn(app, @wavSelect, true);
            app.WavSelect.FontName = 'Arial';
            app.WavSelect.Visible = 'off';
            app.WavSelect.Position = [392 77 50 22];
            app.WavSelect.Text = 'Select';

            % Show the figure after all components are created
            app.Load.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = subLoad_exported(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.Load)

            % Execute the startup function
            runStartupFcn(app, @(app)init(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.Load)
        end
    end
end