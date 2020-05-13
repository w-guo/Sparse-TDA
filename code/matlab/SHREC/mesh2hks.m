function result = mesh2hks(base_dir, subjects, varargin)
% mesh2hks computes heat-kernel signatures (HKS) for 3D meshes of 
% available in OBJ format.

% Modified from https://github.com/rkwitt/persistence-learning/blob/master/code/matlab/utilities/pl_mesh2hks.m (mesh normalization is removed as height matters for human subject classfication)

    % Additional arguments
    if nargin == 2
       alpha = 2;
       T1 = -11:-2;
       verbose = 1;
    elseif nargin == 3
       alpha = varargin{1};
       T1 = -11:-2;
       verbose = 1;
    elseif nargin == 4
        alpha =  varargin{1};
        T1 = varargin{2};
        verbose = 1;
    end

    % Create cell array for data from all subjects
    subject_data = cell(length(subjects),1);

    % Iterate over all subjects
    for subject_id = 1:length(subjects)
        file_name = subjects{subject_id};
        
        % Sanity check:
        % Make sure mesh file exists; if not, it might have been removed
        stat = exist(fullfile(base_dir, file_name), 'file' );
        if stat ~= 2
            if verbose
                fprintf('Subject %d missing or removed\n', subject_id);
            end
            continue;
        end

        % Possibly repair mesh
        [vertices, faces] = objread(fullfile(base_dir, file_name));
        [vertices_fixed, faces_fixed] = ...
            meshcheckrepair(vertices, faces);  

        % Save mesh data
        subject_data{subject_id}.V = vertices_fixed';
        subject_data{subject_id}.X = vertices_fixed(:,1)';
        subject_data{subject_id}.Y = vertices_fixed(:,2)';
        subject_data{subject_id}.Z = vertices_fixed(:,3)';
        subject_data{subject_id}.TRIV = faces_fixed;
        subject_data{subject_id}.file = fullfile(base_dir, file_name);

        % Compute HKS
        subject_data{subject_id}.f_hks = compute_hks(...
            subject_data{subject_id}, alpha, T1);
    end

    result.config.target_scaling = target_scaling;
    result.config.alpha = alpha;
    result.config.T1 = T1;
    result.data = subject_data;
end

function f_hks = compute_hks(data, alpha, T1)
    opt.dtype = 'cotangent';
    [W,A] = mshlp_matrix(data, opt);
    A = spdiags(A, 0, size(A,1), size(A,1));
    [evecs,evals] = eigs(W, A, 300, 'SM');
    evals = -diag(evals);
    f_hks = hks(evecs, evals, alpha.^T1);  
end
