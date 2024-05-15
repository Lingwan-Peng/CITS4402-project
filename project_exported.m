classdef project_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        SliceIDSliderValueLabel        matlab.ui.control.Label
        AnnotationSwitch               matlab.ui.control.Switch
        AnnotationSwitchLabel          matlab.ui.control.Label
        ExtractRadiomicFeaturesButton  matlab.ui.control.Button
        ExtractConventionalFeaturesButton  matlab.ui.control.Button
        SliceIDSlider                  matlab.ui.control.Slider
        SliceIDSliderLabel             matlab.ui.control.Label
        ChannelDropDown                matlab.ui.control.DropDown
        ChannelDropDownLabel           matlab.ui.control.Label
        LoadSliceDirectoryButton       matlab.ui.control.Button
        UIAxes                         matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        channelID = 1
        annotation = 0
        sliceID = 96

        dirPath
        
        volumeID = 1
    end
    
    methods (Access = private)
        
        function displayImage(app, channelID, annotation, sliceID)
            %% handles sliceID
            % extract the number from the directory name using regular expressions
            expression = 'volume_(\d+)'; % match "volume_" followed by one or more digits
            disp(app.dirPath);
            tokens = regexp(app.dirPath, expression, 'tokens');
            app.volumeID = str2double(tokens{1}{1});

            % use volume and slice ID to specify the image for testing
            fn = strcat("volume_", num2str(app.volumeID), "_slice_", num2str(sliceID), ".h5");
            fullFileName = fullfile(app.dirPath, fn);

            % read the specified h5 file
            % h5disp(fullFileName);
            data = h5read(fullFileName, '/image');
            
            % im = squeeze(data(channelID, :, :));
            %% handles annotation
            if strcmp(annotation, 'On')
                maskData = h5read(fullFileName, '/mask');
                masks = mat2gray(sum(maskData, 1));
                disp(size(masks));

                data = masks + data;
            end
           
            % select the required channel using channel ID and display
            im = squeeze(data(channelID, :, :));
            imshow(im, [], 'Parent', app.UIAxes);
        end
        
        %% place holder for testing csv output
        function convFeatures = ExtractConventioalFeatures(app, path, volume_ID)
            Amax = FindMaxArea(path, volume_ID, 155);
            Dmax = FindMaxDiameter(path, volume_ID, 155);
            Envol = FindOuterLayerEnvolvement(path, volume_ID, 155);
            
            convFeatures = [Amax, Dmax, Envol];
        end
        
        function radFeatures = ExtractRadiomicFeatures(app, path, volume_ID)
            radFeatures = 1:30;
        end
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.SliceIDSlider.Value = 96;
            app.SliceIDSliderValueLabel.Text = num2str(96);
        end

        % Button pushed function: LoadSliceDirectoryButton
        function LoadSliceDirectoryButtonPushed(app, event)
            % Allow user to select directory containing H5 files
            app.dirPath = uigetdir();

            if isequal(app.dirPath,0)
                disp('User selected Cancel');
            else
                displayImage(app, app.channelID, app.annotation, app.sliceID);
            end
        end

        % Value changed function: ChannelDropDown
        function ChannelDropDownValueChanged(app, event)
            channelName = app.ChannelDropDown.Value;
            % disp(app.channelID);
            switch channelName
                case "T2-FLAIR"
                    app.channelID = 1;
                case "T1"
                    app.channelID = 2;
                case "T1Gd"
                    app.channelID = 3;
                case "T2"
                    app.channelID = 4;
            end

            displayImage(app, app.channelID, app.annotation, app.sliceID);
        end

        % Value changed function: AnnotationSwitch
        function AnnotationSwitchValueChanged(app, event)
            app.annotation = app.AnnotationSwitch.Value;
            % disp(app.annotation);
            
            displayImage(app, app.channelID, app.annotation, app.sliceID);
        end

        % Value changing function: SliceIDSlider
        function SliceIDSliderValueChanging(app, event)
            app.sliceID = round(event.Value);
            app.SliceIDSliderValueLabel.Text = num2str(app.sliceID);
            % disp(app.sliceID);

            displayImage(app, app.channelID, app.annotation, app.sliceID);
        end

        % Button pushed function: ExtractConventionalFeaturesButton
        function ExtractConventionalFeaturesButtonPushed(app, event)
            % Allow user to select directory containing multiple subfolders
            directory = uigetdir();
            subfolders = dir(directory);
            
            % Create an empty cell array to store the extracted features
            featureData = cell(0, 4); % Four columns
            
            % Add heading row
            featureData = [{' ', 'area', 'diameter', 'out_layer_involvement'}; featureData];
            
            % Loop through each subfolder
            for i = 1:numel(subfolders) % starting from 3 to skip '.' and '..' directories 
                
                if subfolders(i).isdir
                    % Extract conventional features from each subfolder
                    % Check if the subfloder name starts by 'volume_' if not, will skip
                    if startsWith(subfolders(i).name, 'volume_')
                        ConvFeatures = ExtractConventioalFeatures(app, fullfile(directory), subfolders(i).name);
                    
                        % Append the extracted features to the featureData array
                        featureData = [featureData; [{subfolders(i).name}, num2cell(ConvFeatures)]];
                        disp(strcat(subfolders(i).name, ' extracted'));
                    end
                end
            end
            
            % Write the extracted features to a CSV file named 'conventional_features.csv'
            filename = fullfile(directory, 'conventional_features.csv');
            writecell(featureData, filename);
 
        end

        % Button pushed function: ExtractRadiomicFeaturesButton
        function ExtractRadiomicFeaturesButtonPushed(app, event)
            % Allow user to select directory containing multiple subfolders
            directory = uigetdir();
            subfolders = dir(directory);
            
            % Create an empty cell array to store the extracted features
            % Create an empty cell array to store the extracted features
            featureData = cell(0, 24); % 24 columns
            
            % Add heading row
            featureData = [{'volume ID', 'VolumeMesh3D', 'VolumeVoxelCount3D', 'SurfaceAreaMesh3D', ...
                            'SurfaceVolumeRatio3D', 'Compactness1_3D', 'Compactness2_3D', 'SphericalDisproportion3D', ...
                            'Sphericity3D', 'Asphericity3D', 'CentreOfMassShift3D', 'Maximum3dDiameter3D', ...
                            'MajorAxisLength3D', 'MinorAxisLength3D', 'LeastAxisLength3D', 'Elongation3D', ...
                            'Flatness3D', 'VolumeDensityAABB_3D', 'AreaDensityAABB_3D', 'VolumeDensityAEE_3D', ...
                            'AreaDensityAEE_3D', 'VolumeDensityConvexHull3D', 'AreaDensityConvexHull3D', 'IntegratedIntensity3D'}; featureData];
            
            % Loop through each subfolder
            for i = 1:numel(subfolders) % starting from 3 to skip '.' and '..' directories 
                
                if subfolders(i).isdir
                    % Extract conventional features from each subfolder
                    % Check if the subfloder name starts by 'volume_' if not, will skip
                    
                    if isfolder(fullfile(directory, subfolders(i).name)) && startsWith(subfolders(i).name, 'volume_')
                        radiomicFeat = ExtractRadiomic(fullfile(directory), subfolders(i).name);
                        
                        % Get the real ID of the volume
                        matches = regexp(subfolders(i).name, '\d+', 'match');

                        % Append the extracted features to the featureData array
                        featureData = [featureData; [{str2double(matches{end})}, table2cell(radiomicFeat)]];
                        disp(strcat(subfolders(i).name, ' extracted'));
                    end
                end
            end
            
            % Write the extracted features to a CSV file named 'conventional_features.csv'
            filename = fullfile(directory, 'radiomic_features.csv');
            writecell(featureData, filename);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Image Display')
            app.UIAxes.XTick = [];
            app.UIAxes.YTick = [];
            app.UIAxes.Position = [212 268 294 185];

            % Create LoadSliceDirectoryButton
            app.LoadSliceDirectoryButton = uibutton(app.UIFigure, 'push');
            app.LoadSliceDirectoryButton.ButtonPushedFcn = createCallbackFcn(app, @LoadSliceDirectoryButtonPushed, true);
            app.LoadSliceDirectoryButton.Position = [101 199 123 23];
            app.LoadSliceDirectoryButton.Text = 'Load Slice Directory';

            % Create ChannelDropDownLabel
            app.ChannelDropDownLabel = uilabel(app.UIFigure);
            app.ChannelDropDownLabel.HorizontalAlignment = 'right';
            app.ChannelDropDownLabel.Position = [114 151 49 22];
            app.ChannelDropDownLabel.Text = 'Channel';

            % Create ChannelDropDown
            app.ChannelDropDown = uidropdown(app.UIFigure);
            app.ChannelDropDown.Items = {'T2-FLAIR', 'T1', 'T1Gd', 'T2'};
            app.ChannelDropDown.ValueChangedFcn = createCallbackFcn(app, @ChannelDropDownValueChanged, true);
            app.ChannelDropDown.Position = [113 130 100 22];
            app.ChannelDropDown.Value = 'T2-FLAIR';

            % Create SliceIDSliderLabel
            app.SliceIDSliderLabel = uilabel(app.UIFigure);
            app.SliceIDSliderLabel.HorizontalAlignment = 'right';
            app.SliceIDSliderLabel.Position = [255 200 46 22];
            app.SliceIDSliderLabel.Text = 'Slice ID';

            % Create SliceIDSlider
            app.SliceIDSlider = uislider(app.UIFigure);
            app.SliceIDSlider.Limits = [1 155];
            app.SliceIDSlider.ValueChangingFcn = createCallbackFcn(app, @SliceIDSliderValueChanging, true);
            app.SliceIDSlider.Position = [255 188 353 3];
            app.SliceIDSlider.Value = 1;

            % Create ExtractConventionalFeaturesButton
            app.ExtractConventionalFeaturesButton = uibutton(app.UIFigure, 'push');
            app.ExtractConventionalFeaturesButton.ButtonPushedFcn = createCallbackFcn(app, @ExtractConventionalFeaturesButtonPushed, true);
            app.ExtractConventionalFeaturesButton.Position = [255 108 177 23];
            app.ExtractConventionalFeaturesButton.Text = 'Extract Conventional Features';

            % Create ExtractRadiomicFeaturesButton
            app.ExtractRadiomicFeaturesButton = uibutton(app.UIFigure, 'push');
            app.ExtractRadiomicFeaturesButton.ButtonPushedFcn = createCallbackFcn(app, @ExtractRadiomicFeaturesButtonPushed, true);
            app.ExtractRadiomicFeaturesButton.Position = [255 71 157 23];
            app.ExtractRadiomicFeaturesButton.Text = 'Extract Radiomic Features';

            % Create AnnotationSwitchLabel
            app.AnnotationSwitchLabel = uilabel(app.UIFigure);
            app.AnnotationSwitchLabel.HorizontalAlignment = 'center';
            app.AnnotationSwitchLabel.Position = [129 94 63 22];
            app.AnnotationSwitchLabel.Text = 'Annotation';

            % Create AnnotationSwitch
            app.AnnotationSwitch = uiswitch(app.UIFigure, 'slider');
            app.AnnotationSwitch.ValueChangedFcn = createCallbackFcn(app, @AnnotationSwitchValueChanged, true);
            app.AnnotationSwitch.Position = [140 75 45 20];

            % Create SliceIDSliderValueLabel
            app.SliceIDSliderValueLabel = uilabel(app.UIFigure);
            app.SliceIDSliderValueLabel.HorizontalAlignment = 'right';
            app.SliceIDSliderValueLabel.Position = [332 200 25 22];
            app.SliceIDSliderValueLabel.Text = '0';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = project_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end