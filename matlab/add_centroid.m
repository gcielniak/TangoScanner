function out_image = add_centroid(image,x,y,r,d)
out_image = image;
[cols, rows] = meshgrid(1:size(image,1), 1:size(image,2));
out_circle = ((rows - y).^2 + (cols - x).^2 <= r.^2);
in_circle = ((rows - y).^2 + (cols - x).^2 <= (r-d).^2);
out_image = out_image + double(xor(out_circle,in_circle));
