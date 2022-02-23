classdef subSave_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        Save                     matlab.ui.Figure
        WavSelect                matlab.ui.control.Button
        MatSelect                matlab.ui.control.Button
        A                        matlab.ui.control.NumericEditField
        AmplitudeEditFieldLabel  matlab.ui.control.Label
        ALabel                   matlab.ui.control.Label
        Cancel                   matlab.ui.control.Button
        SaveButton               matlab.ui.control.Button
        Mat                      matlab.ui.control.EditField
        matfilelocationLabel     matlab.ui.control.Label
        WavLabel                 matlab.ui.control.Label
        MatLabel                 matlab.ui.control.Label
        WavCheck                 matlab.ui.control.CheckBox
        Wav                      matlab.ui.control.EditField
        wavfilelocationLabel     matlab.ui.control.Label
    end


    % properties and methods are all public so that sub windows can use them
    properties (Access = public)
        main; % handle of main window
        data; % struct that will be written to file
        a=1; % amplitude, default is 1
    end

    methods (Access = public)

        % make this window non-interactive when there is certain sub window
        % used by sub windows
        function disableAll(app)
            app.A.Enable=0;
            app.Mat.Enable=0;
            app.MatSelect.Enable=0;
            app.Wav.Enable=0;
            app.WavSelect.Enable=0;
            app.WavCheck.Enable=0;
            app.SaveButton.Enable=0;
            app.Cancel.Enable=0;
        end

        % make this window interactive when certain sub window closes
        % used by sub windows
        function enableAll(app)
            app.A.Enable=1;
            app.Mat.Enable=1;
            app.MatSelect.Enable=1;
            app.Wav.Enable=1;
            app.WavSelect.Enable=1;
            app.WavCheck.Enable=1;
            app.SaveButton.Enable=1;
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
        end

        % Value changed function: WavCheck
        function wavCheck(app, event)
            % if save .wav file, make .wav file input visible
            % otherwise the opposite
            app.Wav.Visible=app.WavCheck.Value;
            app.wavfilelocationLabel.Visible=app.WavCheck.Value;
            app.WavSelect.Visible=app.WavCheck.Value;
        end

        % Button pushed function: SaveButton
        function saveFile(app, event)
            % give error if .mat location is empty or choose to save .wav but .wav location is empty
            if isempty(app.Mat.Value) || app.WavCheck.Value==1 && isempty(app.Wav.Value)
                app.main.SubError=subError(app.main,app,"save-empty");
                return;
            end

            % give error if folder with same name already exists
            % note that there is no prompt if file with same name exists
            % this is because new file can cover original file but cannot cover folder
            if isfolder(app.Mat.Value) || app.WavCheck.Value==1 && isfolder(app.Wav.Value)
                app.main.SubError=subError(app.main,app,"save-occupied");
                return;
            end

            % /2 is because sum of f1 and f2's amplitude cannot >1
            app.data.wavdata=app.a/2*app.main.audio;

            app.data.string=app.main.StrInput.Value;
            app.data.Fs=app.main.fs;
            audioData=app.data;
            try % give error if save fails
                save(app.Mat.Value,'audioData');
            catch
                app.main.SubError=subError(app.main,app,"save-invalid");
                return;
            end
            if app.WavCheck.Value==1
                try % give error if save fails
                    audiowrite(app.Wav.Value,app.data.wavdata,app.data.Fs);
                catch
                    app.main.SubError=subError(app.main,app,"save-invalid");
                    return;
                end
            end
            app.main.hasSub=0; % reset hasSub since this window will be closed
            app.main.closeIt(app);
        end

        % Close request function: Save
        function closeWindow(app, event)
            app.main.hasSub=0; % reset hasSub since this window will be closed
            app.main.closeIt(app);
        end

        % Button pushed function: Cancel
        function cancel(app, event)
            app.main.hasSub=0; % reset hasSub since this window will be closed
            app.main.closeIt(app);
        end

        % Value changed function: A
        function aCheck(app, event)
            if app.A.Value==0 || app.A.Value>1 || app.A.Value<-1
                app.A.Value=1; % amplitude must be in [-1,0)U(0,1]
            end
            app.a=app.A.Value;
        end

        % Button pushed function: MatSelect
        function matSelect(app, event)
            path=uigetdir; % prompt a getdir ui
            if path~=0 % if user select a folder, cat path and default filename
                app.Mat.Value=path+"\audio.mat";
            end
        end

        % Button pushed function: WavSelect
        function wavSelect(app, event)
            path=uigetdir; % prompt a getdir ui
            if path~=0 % if user select a folder, cat path and default filename
                app.Wav.Value=path+"\audio.wav";
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create Save and hide until all components are created
            app.Save = uifigure('Visible', 'off');
            app.Save.Position = [100 100 507 313];
            app.Save.Name = 'Save - DTMF';
            app.Save.Icon = 'photo.jpg';
            app.Save.CloseRequestFcn = createCallbackFcn(app, @closeWindow, true);

            % Create wavfilelocationLabel
            app.wavfilelocationLabel = uilabel(app.Save);
            app.wavfilelocationLabel.FontName = 'Arial';
            app.wavfilelocationLabel.Visible = 'off';
            app.wavfilelocationLabel.Position = [53 75 97 22];
            app.wavfilelocationLabel.Text = '.wav file location:';

            % Create Wav
            app.Wav = uieditfield(app.Save, 'text');
            app.Wav.FontName = 'Arial';
            app.Wav.Visible = 'off';
            app.Wav.Position = [155 75 256 22];

            % Create WavCheck
            app.WavCheck = uicheckbox(app.Save);
            app.WavCheck.ValueChangedFcn = createCallbackFcn(app, @wavCheck, true);
            app.WavCheck.Text = 'Also save .wav file';
            app.WavCheck.FontName = 'Times New Roman';
            app.WavCheck.FontSize = 16;
            app.WavCheck.Position = [183 110 145 22];

            % Create MatLabel
            app.MatLabel = uilabel(app.Save);
            app.MatLabel.HorizontalAlignment = 'center';
            app.MatLabel.FontName = 'Times New Roman';
            app.MatLabel.FontSize = 16;
            app.MatLabel.Position = [136 280 239 22];
            app.MatLabel.Text = 'The struct will be saved as .mat file.';

            % Create WavLabel
            app.WavLabel = uilabel(app.Save);
            app.WavLabel.HorizontalAlignment = 'center';
            app.WavLabel.FontName = 'Times New Roman';
            app.WavLabel.FontSize = 16;
            app.WavLabel.Position = [37 249 437 22];
            app.WavLabel.Text = 'Please specify the location and choose whether also save .wav file.';

            % Create matfilelocationLabel
            app.matfilelocationLabel = uilabel(app.Save);
            app.matfilelocationLabel.FontName = 'Arial';
            app.matfilelocationLabel.Position = [53 146 95 22];
            app.matfilelocationLabel.Text = '.mat file location:';

            % Create Mat
            app.Mat = uieditfield(app.Save, 'text');
            app.Mat.FontName = 'Arial';
            app.Mat.Position = [155 146 256 22];

            % Create SaveButton
            app.SaveButton = uibutton(app.Save, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @saveFile, true);
            app.SaveButton.FontName = 'Arial';
            app.SaveButton.FontSize = 16;
            app.SaveButton.Position = [136 22 100 27];
            app.SaveButton.Text = 'Save';

            % Create Cancel
            app.Cancel = uibutton(app.Save, 'push');
            app.Cancel.ButtonPushedFcn = createCallbackFcn(app, @cancel, true);
            app.Cancel.FontName = 'Arial';
            app.Cancel.FontSize = 16;
            app.Cancel.Position = [275 22 100 27];
            app.Cancel.Text = 'Cancel';

            % Create ALabel
            app.ALabel = uilabel(app.Save);
            app.ALabel.HorizontalAlignment = 'center';
            app.ALabel.FontName = 'Times New Roman';
            app.ALabel.FontSize = 16;
            app.ALabel.Position = [138 218 235 22];
            app.ALabel.Text = 'You can also specify the amplitude.';

            % Create AmplitudeEditFieldLabel
            app.AmplitudeEditFieldLabel = uilabel(app.Save);
            app.AmplitudeEditFieldLabel.FontName = 'Arial';
            app.AmplitudeEditFieldLabel.Position = [184 183 62 22];
            app.AmplitudeEditFieldLabel.Text = 'Amplitude:';

            % Create A
            app.A = uieditfield(app.Save, 'numeric');
            app.A.Limits = [-1 1];
            app.A.ValueChangedFcn = createCallbackFcn(app, @aCheck, true);
            app.A.HorizontalAlignment = 'left';
            app.A.FontName = 'Arial';
            app.A.Position = [258 183 68 22];
            app.A.Value = 1;

            % Create MatSelect
            app.MatSelect = uibutton(app.Save, 'push');
            app.MatSelect.ButtonPushedFcn = createCallbackFcn(app, @matSelect, true);
            app.MatSelect.FontName = 'Arial';
            app.MatSelect.Position = [411 146 50 22];
            app.MatSelect.Text = 'Select';

            % Create WavSelect
            app.WavSelect = uibutton(app.Save, 'push');
            app.WavSelect.ButtonPushedFcn = createCallbackFcn(app, @wavSelect, true);
            app.WavSelect.FontName = 'Arial';
            app.WavSelect.Visible = 'off';
            app.WavSelect.Position = [411 75 50 22];
            app.WavSelect.Text = 'Select';

            % Show the figure after all components are created
            app.Save.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = subSave_exported(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.Save)

            % Execute the startup function
            runStartupFcn(app, @(app)init(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.Save)
        end
    end
end