function [model] = ovrtrain_kernel(y, kernel, cmd)
% modified from https://www.csie.ntu.edu.tw/~cjlin/libsvmtools/ovr_multiclass/ovrtrain.m

labelSet = unique(y);
labelSetSize = length(labelSet);
models = cell(labelSetSize,1);

for i=1:labelSetSize
    models{i} = svmtrain(double(y == labelSet(i)), [(1:length(y))', kernel], cmd);
end

model = struct('models', {models}, 'labelSet', labelSet);
