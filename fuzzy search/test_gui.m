% TODOs:
% [ ] enter - accept
% [ ] highlight
% [ ] arrows - move highlight
% [ ] text centering
% [ ] different color choosing
% [ ] text color adjustment to background color
% [ ] allow setting text color
% [x] change ordering basing on match
% [x] fix blank
% [x] fix backspace action

function opt = fuzzy_gui_test()

menu_items = {'AkredytacjaWielkiejWierzby',...
    'to som chyba miesnie', 'bardzo brzydki sygnal',...
    'dziwne warczenie'};

% create user data structure
udat.textItems = length(menu_items);
udat.boxColor = 0.7 + rand(udat.textItems,3)*0.3;
udat.origText = menu_items;
udat.lowerText = cellfun(@lower, menu_items, 'Uni', false);
udat.active = true(1, udat.textItems);

% setup stuff
udat.allowSorting = true;
udat.allowHighlight = true;

% create figure
figPos = [550, 90, 450, 450];
h = figure('Position', figPos, ...
    'DockControls', 'off', 'MenuBar', 'none',...
    'Name', 'Select mark', 'Toolbar', 'none',...
    'Visible', 'off', 'color', [0.25, 0.25, 0.25]);

% dimensional data
figSpace = figPos([3,4]);
udat.figSpace = figSpace;
horLim   = [10, figSpace(2) - 10];
keyw     = diff(horLim);
keyh     = 60;
keyDist  = 15;
keyStart = 100;

% edit box color
EditColor = [0.2, 0.1, 0.0];
HighlighColor = [255, 255, 100]/255;

% create invisible background axis
udat.hAxis = axes('Position', [0, 0, 1, 1],...
    'Visible', 'off');
set(udat.hAxis, 'Xlim', [0, figSpace(1)],'YLim', [0, figSpace(2)]);



% create highlight
% ----------------
up = figSpace(2) - keyStart;
if udat.allowHighlight
    udat.highlightPosition = 1;
    udat.highlightRim = [horLim(1), 8, horLim(1), 8];
    udat.hHighlight = patch('vertices', [0, up + udat.highlightRim(2);...
        0, up - keyh - udat.highlightRim(4);...
        figSpace(1), up - keyh - udat.highlightRim(4);...
         figSpace(1), up + udat.highlightRim(2)],...
        'Visible', 'on', 'faceColor', HighlighColor, 'edgecolor',...
        'none', 'Faces', 1:4);
end

% create 'edit box'
% -----------------
up = figSpace(2) - 20;
udat.hEditFrame = patch('vertices', [horLim(1), up; horLim(1), ...
    up - keyh; horLim(2), up - keyh; horLim(2), up],...
    'Visible', 'on', 'faceColor', EditColor, 'edgecolor',...
    'none', 'Faces', 1:4);

udat.hEditText = text('String', '', 'FontSize', 15,...
    'Position', [horLim(1), up - keyh/2] + [35, 0], ...
    'Visible', 'on', 'Color', [0.8, 0.85, 0.9]);

% create option buttons
% ---------------------
for i = 1:udat.textItems
    
    butUp = figSpace(2) - keyStart - (i-1) * (keyh + keyDist);
    
    hButton(i) = patch('vertices', [horLim(1), butUp; horLim(1), butUp - keyh;...
        horLim(2), butUp - keyh; horLim(2), butUp], 'Visible', 'on',...
        'faceColor', udat.boxColor(i, :), 'edgecolor', 'none',...
        'Faces', 1:4);

    % ADD text centering etc.
    hTxt(i) = text('String', menu_items{i}, 'FontSize', 15,...
     'Position', [horLim(1), butUp - keyh/2] + [35, 0], 'Visible', 'on');
end


udat.hButton = hButton;
udat.hText = hTxt;
udat.typed = '';

if udat.allowSorting
    udat.sortInds = 1:udat.textItems;
end

set(h, 'UserData',  udat);
set(h, 'WindowKeyPressFcn', @fuzzy_buttonpress);
set(h, 'Visible', 'on');

uiwait(h);

udat = get(h, 'UserData');

% resume and return
if udat.allowHighlight
