classdef subDocument_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        Document  matlab.ui.Figure
        HTML      matlab.ui.control.HTML
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create Document and hide until all components are created
            app.Document = uifigure('Visible', 'off');
            app.Document.Position = [100 100 803 582];
            app.Document.Name = 'Document - DTMF';
            app.Document.Icon = 'photo.jpg';

            % Create HTML
            app.HTML = uihtml(app.Document);
            app.HTML.HTMLSource = 'document.html';
            app.HTML.Position = [2 1 802 582];

            % Show the figure after all components are created
            app.Document.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = subDocument_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.Document)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.Document)
        end
    end
end