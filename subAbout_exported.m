classdef subAbout_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        About      matlab.ui.Figure
        Hyperlink  matlab.ui.control.Hyperlink
        Close      matlab.ui.control.Button
        ID         matlab.ui.control.Label
        Author     matlab.ui.control.Label
        Image      matlab.ui.control.Image
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: Close
        function closeClick(app, event)
            delete(app);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create About and hide until all components are created
            app.About = uifigure('Visible', 'off');
            app.About.Position = [100 100 432 219];
            app.About.Name = 'About - DTMF';
            app.About.Icon = 'photo.jpg';

            % Create Image
            app.Image = uiimage(app.About);
            app.Image.Position = [23 81 121 120];
            app.Image.ImageSource = 'photo.jpg';

            % Create Author
            app.Author = uilabel(app.About);
            app.Author.FontName = 'Times New Roman';
            app.Author.FontSize = 24;
            app.Author.Position = [186 151 81 41];
            app.Author.Text = 'Author: ';

            % Create ID
            app.ID = uilabel(app.About);
            app.ID.HorizontalAlignment = 'center';
            app.ID.FontName = 'Times New Roman';
            app.ID.FontSize = 24;
            app.ID.Position = [167 90 250 41];
            app.ID.Text = 'Student ID: PB19061333';

            % Create Close
            app.Close = uibutton(app.About, 'push');
            app.Close.ButtonPushedFcn = createCallbackFcn(app, @closeClick, true);
            app.Close.FontName = 'Arial';
            app.Close.FontSize = 16;
            app.Close.Position = [167 25 100 27];
            app.Close.Text = 'Close';

            % Create Hyperlink
            app.Hyperlink = uihyperlink(app.About);
            app.Hyperlink.URL = 'https://www.ononoki.xyz/';
            app.Hyperlink.VisitedColor = [0 0 0];
            app.Hyperlink.HorizontalAlignment = 'center';
            app.Hyperlink.FontName = 'Times New Roman';
            app.Hyperlink.FontSize = 24;
            app.Hyperlink.FontWeight = 'normal';
            app.Hyperlink.FontColor = [0 0 0];
            app.Hyperlink.Position = [266 151 126 41];
            app.Hyperlink.Text = 'Xuechen Xu';

            % Show the figure after all components are created
            app.About.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = subAbout_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.About)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.About)
        end
    end
end