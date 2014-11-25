dircontent=dir('../../../Images');
filenames=dircontent(3:size(dircontent,1));
fid3 = fopen('../../../sh/ztest.sh', 'wt');

for f=1:size(filenames,1),
    imname = filenames(f).name;
    imext = ['z' imname(1:size(imname,2)-4)];
    fid5 = fopen(['../../../sh/' imext '.sh'], 'wt');
    fprintf(fid5,'echo "Starting job..."\n');
    fprintf(fid5,['/opt/matlab/bin/matlab -nodisplay -r "clusterInterpretation(''' imname ''')"\n']);
    fprintf(fid5,'echo "Finishing job..."\n');
    fclose(fid5);    
    fprintf(fid3,['qsub -wd $PWD -q medium.q -l mem=3G ''' imext '.sh''\n']);
end
fclose(fid3);
