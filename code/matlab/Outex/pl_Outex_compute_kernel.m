function K = pl_Outex_compute_kernel(X, sigma, options)
%  Modified from https://github.com/rkwitt/persistence-learning/blob/master/code/matlab/experiments/pl_experiment_OASIS_run_mmd.m      

%--------------------------------------------------------------------------
%                                                                 Configure
%--------------------------------------------------------------------------
root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
diagram_distance_binary = fullfile(root,'dipha-pss/build/diagram_distance');
[status,~,~] = mkdir(options.dst_dir);
assert(status == 1);

%--------------------------------------------------------------------------
%                                                          Build list files
%--------------------------------------------------------------------------

% File containing list of .diagram file names
lst_file = fullfile(options.dst_dir, [options.label '_lst.txt']);

lst_fid = fopen(lst_file, 'w');
assert(lst_fid > 0);

for i=1:length(X.data)
    [~,base_file_name,~] = fileparts(X.data{i}.file);
    diagram_file_name = fullfile(options.src_dir, ...
        [...
        options.label '_' ...
        base_file_name ...
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
fprintf('PSS-sigma=%e\n', sigma);

scale_str = ['scale_' num2str(sigma, '%e')];
dim_str = ['dim_' num2str(options.dim)];
kernel_file = fullfile(options.dst_dir, ...
    [...
    options.label '_' ...           % e.g., clbp_s
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

            


