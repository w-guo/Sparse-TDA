function K = pl_SHREC_compute_kernel(X, HKStime, sigma, options)
%    
%   X struct with the following fields:
%
%       .config
%       .data
%
%       .config - Struct with fields
%
%           .alpha          - Scalar
%           .T1             - Array of HKS times
%           .target_scaling - Scaling of the mesh
%
%       .data - N x 1 cell array where each entry is a struct with the
%               following fields:
%
%           .V     - 3 x M matrix of vertex coordinates
%           .X     - M x 1 array of x-coordinates for each of the M vertices
%           .Y     - M x 1 array of y-coordinates for each of the M vertices 
%           .Z     - M x 1 array of z-coordinates for each of the M vertices
%           .TRIV  - K x 3 matrix of vertex indices of each mesh triangle 
%           .f_hks - M x len(T1) matrix of HKS times for each vertex
%      
%   Typically, MAT_FILE is the file that was saved when pre-processing the 
%   segmentations of the OASIS data. This is the same input file that is
%   used for PL_EXPERIMENT_OASIS_RUN_DIPHA
%
%   WHAT is a string which identifies the field to be loaded from the
%   MAT_FILE. LABEL is the prefix that is used for all output files.
%
%   OPTIONS is a struct that is used to configure the MMD test. It needs to
%   have the following fields:
%
%       .dim                - Consider .dim homology, e.g., 1
%       .scales             - PSS kernel scales 10^-s, e.g., [1 2 3]
%       .trials             - Trials for bootstrapping, e.g., 10000
%       .alpha              - Significance level, e.g., 0.05
%       .collect_list_files - 0/1 
%       .compute_kernel     - 0/1
%       .run_mmd            - 0/1
%       .src_dir            - Source directory where .diagram files reside
%       .dst_dir            - Destination directory
%
%--------------------------------------------------------------------------
%                                                                 Configure
%--------------------------------------------------------------------------
root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
diagram_distance_binary = fullfile(root,'dipha-pss/build/diagram_distance');

%--------------------------------------------------------------------------
%                                                          Build list files
%--------------------------------------------------------------------------

time_str = ['time_' num2str(HKStime, '%.3d')];

% File containing list of .diagram file names
lst_file = fullfile(options.dst_dir, ...
    [...
    options.label '_' ...
    time_str '_lst.txt'
    ]);

lst_fid = fopen(lst_file, 'w');
assert(lst_fid > 0);

for i=1:length(X.data)
    [~,base_file_name,~] = fileparts(X.data{i}.file);
    diagram_file_name = fullfile(options.src_dir, ...
        [...
        options.label '_' ...
        base_file_name '_' ...
        num2str(HKStime, '%.3d') ...
        '.diagram'
        ]);
    
    % Make sure file exists
    stat = exist(diagram_file_name, 'file' );
    assert(stat == 2);
    
    fprintf(lst_fid, '%s\n', diagram_file_name);
end
fclose(lst_fid);

%--------------------------------------------------------------------------
%                                                        Kernel computation
%--------------------------------------------------------------------------
fprintf('HKS-time=%.2f, PSS-sigma=%e\n', HKStime, sigma);

scale_str = ['scale_' num2str(sigma, '%e')];
dim_str = ['dim_' num2str(options.dim)];
kernel_file = fullfile(options.dst_dir, ...
    [...
    options.label '_' ...                   % e.g., cc
    'K_inner_product' '_' ...       % IP kernel
    scale_str '_' ...               % PSS time (sigma)
    dim_str '.txt'                  % Hom.-dim.
    ]);

diagram_distance_options = [...
    ' --inner_product' ...
    ' --time ' num2str(sigma,'%e') ...
    ' --dim ' num2str(options.dim) ' '];
exec = [...
    diagram_distance_binary ...
    diagram_distance_options ...
    lst_file ...
    ' > ' ...
    kernel_file];
system(exec);

tmp = load(kernel_file);
K = pl_normalize_kernel(tmp);

            


