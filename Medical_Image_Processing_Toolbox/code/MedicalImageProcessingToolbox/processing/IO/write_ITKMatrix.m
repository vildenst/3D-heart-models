function write_ITKMatrix(filename,M)

 fid = fopen(filename, 'w');
 fprintf(fid,'# itkMatrix 4 x 4\n');
 fprintf(fid,'%f\t%f\t%f\t%f\n',M');
 fclose(fid);

end

