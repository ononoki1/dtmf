classdef subStr_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        Str       matlab.ui.Figure
        Loaded    matlab.ui.control.Label
        Close     matlab.ui.control.Button
        StrLabel  matlab.ui.control.Label
    end


    properties (Access = private)
        main;
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function init(app, main, str)
            app.main=main;

            % make main window non-interactive and continue if there is no other sub window
            % otherwise exit
            if app.main.hasSub==0
                app.main.hasSub=1;
                app.main.disableAll;
            else
                app.main.closeIt(app);
            end

            app.StrLabel.Text=str;
        end

        % Button pushed function: Close
        function close(app, event)
            app.main.hasSub=0; % reset hasSub since this window will be closed
            app.main.closeIt(app);
        end

        % Close request function: Str
        function closeWindow(app, event)
            app.main.hasSub=0; % reset hasSub since this window will be closed
            app.main.closeIt(app);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create Str and hide until all components are created
            app.Str = uifigure('Visible', 'off');
            app.Str.Position = [100 100 621 378];
            app.Str.Name = 'String - DTMF';
            app.Str.Icon = 'photo.jpg';
            app.Str.CloseRequestFcn = createCallbackFcn(app, @closeWindow, true);
            app.Str.Scrollable = 'on';

            % Create StrLabel
            app.StrLabel = uilabel(app.Str);
            app.StrLabel.HorizontalAlignment = 'center';
            app.StrLabel.WordWrap = 'on';
            app.StrLabel.FontName = 'Times New Roman';
            app.StrLabel.FontSize = 18;
            app.StrLabel.Position = [31 69 564 242];
            app.StrLabel.Text = '';

            % Create Close
            app.Close = uibutton(app.Str, 'push');
            app.Close.ButtonPushedFcn = createCallbackFcn(app, @close, true);
            app.Close.FontName = 'Arial';
            app.Close.FontSize = 16;
            app.Close.Position = [263 19 100 27];
            app.Close.Text = 'Close';

            % Create Loaded
            app.Loaded = uilabel(app.Str);
            app.Loaded.HorizontalAlignment = 'center';
            app.Loaded.FontName = 'Arial';
            app.Loaded.FontSize = 24;
            app.Loaded.Position = [236 330 155 29];
            app.Loaded.Text = 'Loaded String';

            % Show the figure after all components are created
            app.Str.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = subStr_exported(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.Str)

            % Execute the startup function
            runStartupFcn(app, @(app)init(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.Str)
        end
    end
end