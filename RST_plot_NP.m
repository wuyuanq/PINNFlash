% This is the RST_plot_HT() function which uses the data file to draw the sparse
% grid hash table.

% Input parameters:
% soludoc: the result document

% Author: Yuanqing Wu. Email: wuyuanq@gmail.com
% Last edited on October 23rd, 2017

function RST_plot_NP()
    
    fh = figure();
    h = title('The number of the collocation points');
    set(h, 'fontsize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    h = xlabel('Epoch');
    set(h, 'fontsize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    h = ylabel('Number');
    set(h, 'fontsize', 16, 'FontWeight', 'bold', 'VerticalAlignment', 'middle');
    hold on;
    
    %y = [1581, 367, 367, 367, 367, 367, 367, 367, 367, 367, 367, 367, 367, 367, 367, 367, 367, 367, 367, 367];
    y = [1581, 2702, 1620, 1483, 1483, 1483, 2834, 1483, 1483, 1483, 1483, 1483, 1483, 1483, 1483, 1483, 1483, 1483, 1483, 1512];
    plot(y,'k.-','MarkerSize',20);
    %y = [1581, 749, 749, 749, 770, 844, 1447, 776, 1526, 1213, 1147, 1750, 749, 749, 749, 749, 761, 849, 1020, 1222];
    y = [1581, 1483, 1483, 1483, 1561, 1483, 1483, 1483, 1483, 1483, 1483, 1483, 1483, 1483, 1483, 1483, 1483, 1483, 1483, 1483];
    plot(y,'r.-','MarkerSize',20);
    %y = [459, 459, 459, 459, 459, 459, 459, 459, 459, 459, 459, 459, 459, 459, 459, 459, 459, 459, 459, 459];
    y = [1701, 1701, 1701, 1701, 1701, 1701, 1701, 1701, 1701, 1701, 1701, 1701, 1701, 1701, 1701, 1701, 1701, 1701, 1701, 1701];
    plot(y,'b.-','MarkerSize',20);
    
    legend('No hierarchical priority', 'Hierarchical priority', 'No sparse-grid guide');
    hold off;
    
    saveas(fh, 'numPoints.fig');

end
