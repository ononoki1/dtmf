classdef subWarning_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        Warning       matlab.ui.Figure
        MoreInfo      matlab.ui.control.Label
        Code          matlab.ui.control.Label
        Once          matlab.ui.control.Label
        Continue      matlab.ui.control.Label
        Recommend     matlab.ui.control.Label
        OK            matlab.ui.control.Button
        Wrong         matlab.ui.control.Label
        WarningLabel  matlab.ui.control.Label
    end


    % properties and methods are private since no other window uses them
    properties (Access = private)
        main;
        father;
        reason;
    end

    methods (Access = private)

        % make father window non-interactive and return 0 if there is no other warning window
        % otherwise exit and return 1
        function result = check(app,reasonNum)
            if app.main.hasWarning(reasonNum)==0
                app.main.hasWarning(reasonNum)=2;
                app.father.disableAll;
                result=0;
            else
                app.father.closeIt(app);
                result=1;
            end
        end
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function init(app, main, father, reason)
            app.main=main;
            app.father=father;
            app.reason=reason;

            % choose warning text and display
            if reason=="audio-short"
                if app.check(1)~=0
                    return;
                end
                app.Code.Text='Code: 11';
                app.Wrong.Text='The valid DTMF part of audio is too short.';
                app.Recommend.Text='It''s recommended to use longer audio.';
            elseif reason=="input-lower"
                if app.check(2)~=0
                    return;
                end
                app.Code.Text='Code: 12';
                app.Wrong.Text='Your input contains lower case letters.';
                app.Recommend.Text='It''s recommended to use upper ones.';
            end
        end

        % Button pushed function: OK
        function ok(app, event)
            if app.reason=="audio-short" % set hasWarning to 1 since warning has appeared
                app.main.hasWarning(1)=1;
            elseif app.reason=="input-lower"
                app.main.hasWarning(2)=1;
            end
            app.main.closeIt(app);
        end

        % Close request function: Warning
        function closeWindow(app, event)
            if app.reason=="audio-short" % set hasWarning to 1 since warning has appeared
                app.main.hasWarning(1)=1;
            elseif app.reason=="input-lower"
                app.main.hasWarning(2)=1;
            end
            app.main.closeIt(app);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create Warning and hide until all components are created
            app.Warning = uifigure('Visible', 'off');
            app.Warning.Position = [100 100 421 269];
            app.Warning.Name = 'Warning - DTMF';
            app.Warning.Icon = 'photo.jpg';
            app.Warning.CloseRequestFcn = createCallbackFcn(app, @closeWindow, true);

            % Create WarningLabel
            app.WarningLabel = uilabel(app.Warning);
            app.WarningLabel.HorizontalAlignment = 'center';
            app.WarningLabel.FontName = 'Arial';
            app.WarningLabel.FontSize = 32;
            app.WarningLabel.FontColor = [1 0.4118 0.1608];
            app.WarningLabel.Position = [151 198 123 50];
            app.WarningLabel.Text = 'Warning';

            % Create Wrong
            app.Wrong = uilabel(app.Warning);
            app.Wrong.HorizontalAlignment = 'center';
            app.Wrong.FontName = 'Times New Roman';
            app.Wrong.FontSize = 18;
            app.Wrong.Position = [52 165 322 25];
            app.Wrong.Text = '';

            % Create OK
            app.OK = uibutton(app.Warning, 'push');
            app.OK.ButtonPushedFcn = createCallbackFcn(app, @ok, true);
            app.OK.FontName = 'Arial';
            app.OK.FontSize = 16;
            app.OK.Position = [163 25 100 27];
            app.OK.Text = 'OK';

            % Create Recommend
            app.Recommend = uilabel(app.Warning);
            app.Recommend.HorizontalAlignment = 'center';
            app.Recommend.FontName = 'Times New Roman';
            app.Recommend.FontSize = 18;
            app.Recommend.Position = [67 141 291 25];
            app.Recommend.Text = '';

            % Create Continue
            app.Continue = uilabel(app.Warning);
            app.Continue.HorizontalAlignment = 'center';
            app.Continue.FontName = 'Times New Roman';
            app.Continue.FontSize = 18;
            app.Continue.Position = [52 93 321 25];
            app.Continue.Text = 'The program will continue to work though.';

            % Create Once
            app.Once = uilabel(app.Warning);
            app.Once.HorizontalAlignment = 'center';
            app.Once.FontName = 'Times New Roman';
            app.Once.FontSize = 18;
            app.Once.Position = [51 117 325 25];
            app.Once.Text = 'This kind of warning will only appear once.';

            % Create Code
            app.Code = uilabel(app.Warning);
            app.Code.FontName = 'Arial';
            app.Code.FontSize = 16;
            app.Code.Position = [1 248 68 22];
            app.Code.Text = 'Code: ';

            % Create MoreInfo
            app.MoreInfo = uilabel(app.Warning);
            app.MoreInfo.HorizontalAlignment = 'center';
            app.MoreInfo.FontName = 'Times New Roman';
            app.MoreInfo.FontSize = 18;
            app.MoreInfo.Position = [36 67 354 27];
            app.MoreInfo.Text = 'See 6th part of document for more information.';

            % Show the figure after all components are created
            app.Warning.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = subWarning_exported(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.Warning)

            % Execute the startup function
            runStartupFcn(app, @(app)init(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.Warning)
        end
    end
end