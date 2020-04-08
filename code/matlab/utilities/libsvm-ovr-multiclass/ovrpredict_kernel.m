function [pred, ac, decv] = ovrpredict_kernel(y, kernel, model)
% modified from https://www.csie.ntu.edu.tw/~cjlin/libsvmtools/ovr_multiclass/ovrpredict.m

labelSet = model.labelSet;
labelSetSize = length(labelSet);
models = model.models;
decv= zeros(size(y, 1), labelSetSize);

for i=1:labelSetSize
  [l,a,d] = svmpredict(double(y == labelSet(i)), [(1:length(y))', kernel], models{i});
  decv(:, i) = d * (2 * models{i}.Label(1) - 1);
end
[tmp,pred] = max(decv, [], 2);
pred = labelSet(pred);
ac = sum(y==pred) / length(y);
