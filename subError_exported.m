classdef subError_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        Error       matlab.ui.Figure
        MoreInfo    matlab.ui.control.Label
        Code        matlab.ui.control.Label
        OK          matlab.ui.control.Button
        Label       matlab.ui.control.Label
        ErrorLabel  matlab.ui.control.Label
    end


    % properties are private since no other window uses them
    properties (Access = private)
        main; % handle of main window
        father; % handle of father window (can be main window)
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function init(app, main, father, reason)
            app.main=main;
            app.father=father;

            % make father window non-interactive and continue if there is no other error window
            % otherwise exit
            if app.main.hasError==0
                app.main.hasError=1;
                app.father.disableAll;
            else
                app.father.closeIt(app);
            end

            % choose error text and display
            if reason=="load-empty"
                app.Code.Text='Code: 21';
                app.Label.Text='Your input file does not exist.';
            elseif reason=="load-invalid"
                app.Code.Text='Code: 22';
                app.Label.Text='Your input file is not a valid audio file.';
            elseif reason=="load-not-dtmf"
                app.Code.Text='Code: 23';
                app.Label.Text='Your input file is not a valid DTMF audio file.';
            elseif reason=="input-invalid"
                app.Code.Text='Code: 24';
                app.Label.Text='Your input is invalid. Please try again.';
            elseif reason=="input-save-empty"
                app.Code.Text='Code: 25';
                app.Label.Text='Please give a valid input before saving.';
            elseif reason=="save-occupied"
                app.Code.Text='Code: 26';
                app.Label.Text='Your input location is occupied. Please use another one.';
            elseif reason=="save-empty"
                app.Code.Text='Code: 27';
                app.Label.Text='Your input is empty. Please give a valid input.';
            elseif reason=="save-invalid"
                app.Code.Text='Code: 28';
                app.Label.Text='The save location is invalid. Please use another one.';
            end
        end

        % Button pushed function: OK
        function ok(app, event)
            app.main.hasError=0; % reset hasError since error window will be closed
            app.father.closeIt(app);
        end

        % Close request function: Error
        function closeWindow(app, event)
            app.main.hasError=0; % reset hasError since error window will be closed
            app.father.closeIt(app);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create Error and hide until all components are created
            app.Error = uifigure('Visible', 'off');
            app.Error.Position = [100 100 482 191];
            app.Error.Name = 'Error - DTMF';
            app.Error.Icon = 'photo.jpg';
            app.Error.CloseRequestFcn = createCallbackFcn(app, @closeWindow, true);

            % Create ErrorLabel
            app.ErrorLabel = uilabel(app.Error);
            app.ErrorLabel.HorizontalAlignment = 'center';
            app.ErrorLabel.FontName = 'Arial';
            app.ErrorLabel.FontSize = 32;
            app.ErrorLabel.FontColor = [1 0 0];
            app.ErrorLabel.Position = [199 130 85 50];
            app.ErrorLabel.Text = 'Error';

            % Create Label
            app.Label = uilabel(app.Error);
            app.Label.HorizontalAlignment = 'center';
            app.Label.FontName = 'Times New Roman';
            app.Label.FontSize = 18;
            app.Label.Position = [34 93 416 29];
            app.Label.Text = '';

            % Create OK
            app.OK = uibutton(app.Error, 'push');
            app.OK.ButtonPushedFcn = createCallbackFcn(app, @ok, true);
            app.OK.FontName = 'Arial';
            app.OK.FontSize = 16;
            app.OK.Position = [192 21 100 27];
            app.OK.Text = 'OK';

            % Create Code
            app.Code = uilabel(app.Error);
            app.Code.FontName = 'Arial';
            app.Code.FontSize = 16;
            app.Code.Position = [1 170 68 22];
            app.Code.Text = 'Code: ';

            % Create MoreInfo
            app.MoreInfo = uilabel(app.Error);
            app.MoreInfo.HorizontalAlignment = 'center';
            app.MoreInfo.FontName = 'Times New Roman';
            app.MoreInfo.FontSize = 18;
            app.MoreInfo.Position = [34 65 416 29];
            app.MoreInfo.Text = 'See 6th part of document for more information.';

            % Show the figure after all components are created
            app.Error.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = subError_exported(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.Error)

            % Execute the startup function
            runStartupFcn(app, @(app)init(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.Error)
        end
    end
end