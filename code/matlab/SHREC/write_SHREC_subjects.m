function subject_list = write_SHREC_subjects(subject_file)
% write_SHREC_subjects writes the filenames of all human subjects into cell
% arrays

subjects = importdata(subject_file);
subject_list =  cell(length(subjects),1);    
    
for subject_id=1:length(subjects)
    subject_list{subject_id} = sprintf('%s', subjects{subject_id});
end