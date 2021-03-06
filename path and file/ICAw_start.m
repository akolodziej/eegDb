function ICAw_start(PTH, varargin)

% function for starting your work with ICAw
% FIXHELPINFO

% CHECK, CHANGE this function and to a stable, relatively final form

% TODOs:
% [ ] ! if output is specified do not evalin in base workspace !
% [ ] add some more options?

% TEMPORARY argument checks:
innm = 'ICAw ';
if nargin > 1
    arg = strcmp(varargin, 'inname');
    if sum(arg) > 0
        arg = find(arg) + 1;
        innm = varargin{arg};
    end
end

% initial operations
% CONSIDER different approach to cd() and addpath();
disp('adding paths...');

% look for correct path
PTH = ICAw_path(PTH);

% go to the path
cd(PTH);
% add to search path
addpath(PTH);
% check for files
all_fls = dir(fullfile(PTH, '*.mat'));
all_fls = {all_fls.name};

% take only ICAw databases:
disp('looking for current database...');
i = regexp(all_fls, innm, 'once');
em = ~cellfun(@isempty, i);
fls= all_fls(em);

%% decipher dates and choose the current database
if length(fls) > 1
pat = ['[0-9]{4}\.[0-9]{2}\.[0-9]{2} ',...
    '[0-9]{2}\.[0-9]{2}\.[0-9]{2}\.[0-9]{3}'];

i = regexp(fls, pat, 'once');

% remove empty ones
emp = cellfun(@isempty, i);
i(emp) = [];
fls(emp) = [];

dts = zeros(length(fls), 7);

for a = 1:length(i)
    dt = cellfun(@str2num, strsep(fls{a}(i{a}:i{a}+9), '.'));
    tm = cellfun(@str2num, strsep(fls{a}(i{a}+11:i{a}+22), '.'));
    dts(a,:) = [dt', tm'];
end

% iterative maxing:
for d = 1:size(dts, 2)
    win = dts(:,d) == max(dts(:,d));
    if sum(win) == 1
        winner = fls{win};
        break
    else
        dts(~win,:) = 0;
    end
end
clear d a win dts dt tm a i pat em fls
else
    winner = fls{1};
end
%% load current ICAw
disp('loading the database...');
ld = load(fullfile(PTH, winner));
clear winner
flds = fields(ld);
ICAw = ld.(flds{1});
clear flds ld
assignin('base', 'ICAw', ICAw);
disp('done.');

%% load current profile:
profile_names = {'current_profile\.mat', 'profile\.mat'};

for p = 1:length(profile_names)
    f = find( ~cellfun(@isempty, ...
        regexp(all_fls, profile_names{p}, 'once') ) );
    if ~isempty(f)
        f = f(1); % CHANGE - ensure first is taken...
        ld = load(fullfile(PTH, all_fls{f}));
        clear winner
        flds = fields(ld);
        prof = ld.(flds{1});
        clear flds ld
        assignin('base', 'ICAw_winrej_current_profile', prof);
        disp('Found and loaded profile.');
        return
    end
end