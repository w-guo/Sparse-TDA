function pl_Outex_run_dipha(struct, label, out_dir)
% pl_Outex_run_dipha constructs cubical complexes from images with
% the sign component of CLBP operators computed at each pixel.
%
%   pl_Outex_run_dipha(struct, label, out_dir) takes as
%   input a struct that is a saved struct with the following fields:
%
%       .config
%       .data   
%
%       .config - Struct with fields
%
%           .radius          - Scalar for computing CLBP
%           .numNeighbor     - Scalar
%           .downsample_rate - Scalar for downsampling each image
%
%       .data - N x 1 cell array where each entry is a struct with the
%               following fields:
%
%           .clbp_s   - M x M matrix computed by the sign component of CLBP
%           .clbp_m   - M x M matrix computed by the magnitude component of CLBP
%           .file     - Source directory where each image resides
%
%   label is the prefix that is used for all output files and
%   out_dir is the directory where all output files will be written to
%   (will be created if it does not exist).
   
    % DIPHA binary
    root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
    dipha_binary = fullfile(root,'/external/dipha/build/dipha');
    [status,~,~] = mkdir(out_dir);
    assert(status == 1);
   
    %----------------------------------------------------------------------
    %                                   Create complexes + compute diagrams
    %----------------------------------------------------------------------
    for i = 1:length(struct.data)
        X = struct.data{i};
        
        if isempty(X)
            continue;
        end
        
        pixel_values = X.clbp_s;
        [~,base_file_name,~] = fileparts(X.file);
        
        % Write cubical complexes
        complex_file_name = fullfile(out_dir, ...
            [label '_' ...
            base_file_name ...
            '.complex'
            ]);
        
        % Avoid unnecessary recomputation
        if (exist(complex_file_name, 'file' ) ~= 2)
            pl_image2dipha(pixel_values, complex_file_name);
        end
        
        % Compute persistence diagrams
        diagram_file_name = fullfile(out_dir, ...
            [label '_' ...
            base_file_name ...
            '.diagram' ...
            ]);
        exec = [dipha_binary ' ' ...
            complex_file_name ' ' ...
            diagram_file_name];
        fprintf('%s\n', dipha_binary);
        fprintf('%s\n', complex_file_name);
        fprintf('%s\n', diagram_file_name);
        % Again, avoid unnecessary recomputation
        if (exist(diagram_file_name, 'file' ) ~= 2)
            system( exec );
        end
        delete(complex_file_name)
        fprintf('DONE with %s\n', X.file);
    end
end

