% get the xpath mechanism into the workspace
import javax.xml.xpath.*
factory = XPathFactory.newInstance;
xpath = factory.newXPath;

xml_input_dir = getenv("WAFER_INPUT_DIRECTORY");
xml_input_filename = getenv("WAFER_INPUT_FILENAME");
input_full_path = sprintf('%s%s', xml_input_dir, xml_input_filename);

xmlDoc = xmlread(input_full_path);
radiusExpression = xpath.compile('data/waferRadius');
pointsExpression = xpath.compile('data/numPoints');
radiusNode = radiusExpression.evaluate(xmlDoc, XPathConstants.NODE);
pointsNode = pointsExpression.evaluate(xmlDoc, XPathConstants.NODE);

waferRadius = str2double(radiusNode.getTextContent);
numPoints = str2double(pointsNode.getTextContent);

% Parameters
%waferRadius = 150; % Wafer radius in mm
%numPoints = 1000;  % Number of data points

% Generate random data points within the wafer
theta = 2 * pi * rand(numPoints, 1); % Random angles
r = waferRadius * sqrt(rand(numPoints, 1)); % Random radii
x = r .* cos(theta); % X-coordinates
y = r .* sin(theta); % Y-coordinates
data = rand(numPoints, 1); % Random data values (e.g., measurements)

% Create the wafer plot
figure;
scatter(x, y, 20, data, 'filled'); % Scatter plot with color-coded data
colormap(jet); % Set colormap
colorbar; % Add colorbar
hold on;

% Draw the wafer boundary
thetaCircle = linspace(0, 2*pi, 100);
xCircle = waferRadius * cos(thetaCircle);
yCircle = waferRadius * sin(thetaCircle);
plot(xCircle, yCircle, 'k-', 'LineWidth', 2); % Wafer boundary

% Formatting
axis equal;
xlim([-waferRadius, waferRadius]);
ylim([-waferRadius, waferRadius]);
title('Wafer Plot');
xlabel('X (mm)');
ylabel('Y (mm)');

output_dir = getenv("WAFER_OUTPUT_DIRECTORY");
output_plot_filename = getenv("WAFER_OUTPUT_FILENAME");
output_full_path = sprintf('%s%s', output_dir, output_plot_filename);

ax = gca;
exportgraphics(ax, output_full_path,'Resolution',300);
