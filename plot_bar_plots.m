function plot_bar_plots()

if ~isdeployed
    disp('loading paths')
    addpath(genpath('/N/u/brlife/git/encode'))
    addpath(genpath('/N/u/brlife/git/vistasoft'))
    addpath(genpath('/N/u/brlife/git/jsonlab'))
    addpath(genpath('/N/u/brlife/git/mba'))
    addpath(genpath('/N/u/brlife/git/wma'))
end

config = loadjson('config.json');
load(fullfile(config.segmentation));
tracts = fg_classified;

if length(tracts) == 20
    disp('AFQ segmentation selected. The plots of the following tracts will be returned:')
    disp('Left and Rigth Corticospinal, Left and Right IFOF, Left and Right SLF, Left and Right Arcuate.')
    tr_idx = [3, 4, 11, 12, 15, 16, 19, 20];
    tag = 'afq';
else
    disp('Wma segmentation selected. The plots of the following tracts will be returned:')
    disp('Left and Rigth pArc, Left and Rigth TPC, Left and Rigth MdLF-SPL, Left and Rigth MdLF-Ang.')
    tr_idx = [38, 39, 40, 41, 42, 43, 44, 45];
    tag = 'wma';
end    
    
step_size = 0.2;
possible_error = 0;

num_left_tracts = 4;
num_right_tracts = 4;

left_tract_xs = cell(1, num_left_tracts);
right_tract_xs = cell(1, num_right_tracts);

left_tract_ys = zeros([1, num_left_tracts]);
right_tract_ys = zeros([1, num_right_tracts]);

left_tract_ys1 = zeros([1, num_left_tracts]);
right_tract_ys1 = zeros([1, num_right_tracts]);

left_tract_ys2 = zeros([1, num_left_tracts]);
right_tract_ys2 = zeros([1, num_right_tracts]);

left_tract_idx = 1;
right_tract_idx = 1;

%write on txt file
fileID = fopen(strcat(tag, '_output_counts.txt'), 'w');
fprintf(fileID, '%12s %12s %12s\n', 'num_str', 'num_nodes', 'avg_str_len');

%write on mat file
output_counts = zeros(length(tr_idx), 3);
num_iter=0;

for i = tr_idx
    name = tracts(i).name;
    num_fibers = length(tracts(i).fibers);
    basename = name;
    
    num_nodes = 0;
    for j = 1 : num_fibers
        num_nodes = num_nodes + length(tracts(i).fibers{j,1});  
    end 
    tot_fiber_len = step_size * (num_nodes - num_fibers);
    avg_fiber_len = tot_fiber_len / num_fibers;

    line = [num_fibers; num_nodes; avg_fiber_len];
    fprintf(fileID, '%12i %12i %12f\n', line);

    num_iter=num_iter+1;
    output_counts(num_iter,1) = num_fibers;
    output_counts(num_iter,2) = num_nodes;
    output_counts(num_iter,3) = avg_fiber_len;
    
    if startsWith(basename, 'Right ')
        basename = extractAfter(basename, 6);
    end
    if endsWith(basename, ' R')
        basename = extractBefore(basename, length(basename) - 1);
    end
    
    if startsWith(basename, 'Left ')
        basename = extractAfter(basename, 5);
    end
    if endsWith(basename, ' L')
        basename = extractBefore(basename, length(basename) - 1);
    end
    
    if startsWith(name, 'Right ') || endsWith(name, ' R')
        right_tract_xs{right_tract_idx} = basename;
        right_tract_ys(right_tract_idx) = num_fibers;
        right_tract_ys1(right_tract_idx) = num_nodes;
        right_tract_ys2(right_tract_idx) = avg_fiber_len;
        right_tract_idx = right_tract_idx + 1;
    else
        left_tract_xs{left_tract_idx} = basename;
        left_tract_ys(left_tract_idx) = num_fibers;
        left_tract_ys1(right_tract_idx) = num_nodes;
        left_tract_ys2(right_tract_idx) = avg_fiber_len;
        left_tract_idx = left_tract_idx + 1;
    end
end

fclose(fileID);
save(strcat(tag, '_output_counts.mat'), 'output_counts') 

%number of fibers graph
barplot = struct;
barplot.type = 'plotly';
barplot.name = 'Number of Fibers';

bar1 = struct;
bar1.x = left_tract_xs;
bar1.y = left_tract_ys;
bar1.type = 'bar';
bar1.name = 'Left Tracts';
bar1.marker = struct;
bar1.marker.color = 'rgb(49,130,189)';

bar2 = struct;
bar2.x = right_tract_xs;
bar2.y = right_tract_ys;
bar2.type = 'bar';
bar2.name = 'Right Tracts';
bar2.marker = struct;
bar2.marker.color = 'rgb(204, 204, 204)';

barplot.data = {bar1, bar2};

barlayout = struct;
barlayout.xaxis = struct;
barlayout.xaxis.tickfont = struct;
barlayout.xaxis.tickfont.size = 8;
barlayout.barmode = 'group';
barplot.layout = barlayout;

%number of nodes graph
barplot1 = struct;
barplot1.type = 'plotly';
barplot1.name = 'Number of Nodes';

bar3 = struct;
bar3.x = left_tract_xs;
bar3.y = left_tract_ys1;
bar3.type = 'bar';
bar3.name = 'Left Tracts';
bar3.marker = struct;
bar3.marker.color = 'rgb(49,130,189)';

bar4 = struct;
bar4.x = right_tract_xs;
bar4.y = right_tract_ys1;
bar4.type = 'bar';
bar4.name = 'Right Tracts';
bar4.marker = struct;
bar4.marker.color = 'rgb(204, 204, 204)';

barplot1.data = {bar3, bar4};

barlayout = struct;
barlayout.xaxis = struct;
barlayout.xaxis.tickfont = struct;
barlayout.xaxis.tickfont.size = 8;
barlayout.barmode = 'group';
barplot1.layout = barlayout;

%number of nodes graph
barplot2 = struct;
barplot2.type = 'plotly';
barplot2.name = 'Average length';

bar5 = struct;
bar5.x = left_tract_xs;
bar5.y = left_tract_ys2;
bar5.type = 'bar';
bar5.name = 'Left Tracts';
bar5.marker = struct;
bar5.marker.color = 'rgb(49,130,189)';

bar6 = struct;
bar6.x = right_tract_xs;
bar6.y = right_tract_ys2;
bar6.type = 'bar';
bar6.name = 'Right Tracts';
bar6.marker = struct;
bar6.marker.color = 'rgb(204, 204, 204)';

barplot2.data = {bar5, bar6};

barlayout = struct;
barlayout.xaxis = struct;
barlayout.xaxis.tickfont = struct;
barlayout.xaxis.tickfont.size = 8;
barlayout.barmode = 'group';
barplot2.layout = barlayout;

% output product.json
product = {barplot, barplot1, barplot2};
if possible_error == 1
    message = struct;
    message.type = 'error';
    message.msg = 'ERROR: Some tracts have less than 20 streamlines. Check quality of data!';
    product = {barplot, message};
end
savejson('brainlife', product, 'product.json');

end