function setup()
% setup adds packages to the path.

[a,~,~] = fileparts(mfilename('fullpath'));
[a,~,~] = fileparts(a) ;
root = a ;

% These libraries we require for basic usage
addpath(fullfile(root, 'external/dipha/matlab'                     ));
addpath(fullfile(root, 'matlab/utilities'                          ));
addpath(fullfile(root, 'matlab/utilities/libsvm-ovr-multiclass'    ));
addpath(fullfile(root, 'matlab/utilities/optimized-sparse-sampling'));
addpath(fullfile(root, 'matlab/SHREC'                              ));
addpath(fullfile(root, 'matlab/Outex'                              ));

fprintf('Trying to load additional packages ...\n');

if (exist(fullfile(root,'external/sihks'), 'dir') == 7)
    addpath(fullfile(root, 'external/sihks'));
    fprintf('Found/Loaded: sihks\n');    
end
if (exist(fullfile(root,'external/iso2mesh'), 'dir') == 7)
    addpath(fullfile(root, 'external/iso2mesh'));
    fprintf('Found/Loaded: iso2mesh\n');    
end
if (exist(fullfile(root,'external/CLBP'), 'dir') == 7)
    addpath(fullfile(root, 'external/CLBP'));
    fprintf('Found/Loaded: CLBP\n');    
end
if (exist(fullfile(root,'external/PersistenceImages'), 'dir') == 7)
    addpath(fullfile(root, 'external/PersistenceImages'));
    fprintf('Found/Loaded: PersistenceImages\n');    
end

fprintf('Setup is ready.\n');