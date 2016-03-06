function circle(x, y, radius, color, alpha)
xx = radius*sin(-pi:0.1*pi:pi) + x;
yy = radius*cos(-pi:0.1*pi:pi) + y;
fill(xx, yy, color, 'EdgeColor','none','FaceAlpha', alpha);
