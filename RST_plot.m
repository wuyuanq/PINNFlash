
n_samples = 100;
Nc = 2;

% get the true data
dataPath = '/Users/yuanqingwu/research/DeepLearning/GenerateTrueFlashData_2c/trueData/';

liquid = zeros(n_samples, n_samples);
ftxt = [dataPath, 'liquid.txt'];
temp = load(ftxt);
k = 1;
for j = 1 : n_samples % p
    for i = 1 : n_samples % z
        liquid(i,j) = temp(k);
        k = k + 1;
    end
end

gas = zeros(n_samples, n_samples);
ftxt = [dataPath, 'gas.txt'];
temp = load(ftxt);
k = 1;
for j = 1 : n_samples % p
    for i = 1 : n_samples % z
        gas(i,j) = temp(k);
        k = k + 1;
    end
end

phase = zeros(n_samples, n_samples);
for j = 1 : n_samples % p
    for i = 1 : n_samples % z
        phase(i,j) = liquid(i,j) - gas(i,j);
    end
end

xo = zeros(Nc, n_samples, n_samples);
for m = 1 : Nc
    ftxt = [dataPath, 'xW', num2str(m), '.txt'];
    temp = load(ftxt);
    k = 1;
    for j = 1 : n_samples % p
        for i = 1 : n_samples % z
            xo(m,i,j) = temp(k);
            k = k + 1;
        end
    end
end

xg = zeros(Nc, n_samples, n_samples);
for m = 1 : Nc
    ftxt = [dataPath, 'xN', num2str(m), '.txt'];
    temp = load(ftxt);
    k = 1;
    for j = 1 : n_samples % p
        for i = 1 : n_samples % z
            xg(m,i,j) = temp(k);
            k = k + 1;
        end
    end
end

% get the estimated data
phase_pre = zeros(n_samples, n_samples);
ftxt = 'phase_pre.txt';
temp = load(ftxt);
k = 1;
for j = 1 : n_samples % p
    for i = 1 : n_samples % z
        phase_pre(i,j) = temp(k);
        k = k + 1;
    end
end

xo_pre = zeros(Nc, n_samples, n_samples);
for m = 1 : Nc
    ftxt = ['xo', num2str(m), '_pre.txt'];
    temp = load(ftxt);
    k = 1;
    for j = 1 : n_samples % p
        for i = 1 : n_samples % z
            xo_pre(m,i,j) = temp(k);
            k = k + 1;
        end
    end
end

xg_pre = zeros(Nc, n_samples, n_samples);
for m = 1 : Nc
    ftxt = ['xg', num2str(m), '_pre.txt'];
    temp = load(ftxt);
    k = 1;
    for j = 1 : n_samples % p
        for i = 1 : n_samples % z
            xg_pre(m,i,j) = temp(k);
            k = k + 1;
        end
    end
end

% get the error
phase_err = zeros(n_samples, n_samples);
ftxt = 'phase_error.txt';
temp = load(ftxt);
k = 1;
for j = 1 : n_samples % p
    for i = 1 : n_samples % z
        phase_err(i,j) = temp(k);
        k = k + 1;
    end
end

xo_err = zeros(Nc, n_samples, n_samples);
for m = 1 : Nc
    ftxt = ['xo', num2str(m), '_error.txt'];
    temp = load(ftxt);
    k = 1;
    for j = 1 : n_samples % p
        for i = 1 : n_samples % z
            xo_err(m,i,j) = temp(k);
            k = k + 1;
        end
    end
end

xg_err = zeros(Nc, n_samples, n_samples);
for m = 1 : Nc
    ftxt = ['xg', num2str(m), '_error.txt'];
    temp = load(ftxt);
    k = 1;
    for j = 1 : n_samples % p
        for i = 1 : n_samples % z
            xg_err(m,i,j) = temp(k);
            k = k + 1;
        end
    end
end

% begin to draw the images
x = 0:1/(n_samples-1):1;
y = 0:1/(n_samples-1):1;
[X,Y] = meshgrid(x,y); 

fh = figure();
h = title('True phase diagram');
set(h, 'fontsize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
h = xlabel('x1');
set(h, 'fontsize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
h = ylabel(char(['p',771]));
pos = axis;
set(h, 'fontsize', 16, 'FontWeight', 'bold', 'Position', [pos(1)-0.07 pos(4)/2], 'Rotation', 0);
hold on;

firsto = true; 
firstg = true; 
firstog = true; 
for j = 1 : n_samples % p
    for i = 1 : n_samples % z
        if((liquid(i,j)==1) && (gas(i,j)==0))
            if(firsto)
                ho = plot((i-1)/(n_samples-1),(j-1)/(n_samples-1),'.r','MarkerSize',10);
                firsto = false;
            else
                plot((i-1)/(n_samples-1),(j-1)/(n_samples-1),'.r','MarkerSize',10);
            end
            hold on;
        elseif((liquid(i,j)==0) && (gas(i,j)==1))
            if(firstg)
                hg = plot((i-1)/(n_samples-1),(j-1)/(n_samples-1),'.b','MarkerSize',10);
                firstg = false;
            else
                plot((i-1)/(n_samples-1),(j-1)/(n_samples-1),'.b','MarkerSize',10);
            end
            hold on;
        else
            if(firstog)
                hog = plot((i-1)/(n_samples-1),(j-1)/(n_samples-1),'.g','MarkerSize',10);
                firstog = false;
            else
                plot((i-1)/(n_samples-1),(j-1)/(n_samples-1),'.g','MarkerSize',10);
            end
            hold on;
        end
    end
end

if((~firsto) && (~firstg) && (~firstog))
    legend([ho hg hog], 'oil', 'gas', 'oil & gas','FontSize',14)
elseif((~firsto) && (firstg) && (firstog))
    legend(ho, 'oil','FontSize',14)
elseif((firsto) && (~firstg) && (firstog))
    legend(hg, 'gas','FontSize',14)
elseif((firsto) && (firstg) && (~firstog))
    legend(hog, 'oil & gas','FontSize',14)
elseif((~firsto) && (~firstg) && (firstog))
    legend([ho hg], 'oil', 'gas','FontSize',14)
elseif((~firsto) && (firstg) && (~firstog))
    legend([ho hog], 'oil', 'oil & gas','FontSize',14)
elseif((firsto) && (~firstg) && (~firstog))
    legend([hg hog], 'gas', 'oil & gas','FontSize',14)
end
hold off;

saveas(fh, 'phase.fig');

  
for m = 1 : Nc
    fh = figure();
    strtitle = ['xo', num2str(m)];
    h = title(strtitle);
    set(h, 'fontsize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    h = xlabel('x1');
    set(h, 'fontsize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    h = ylabel(char(['p', 771]));
    pos = axis;
    set(h, 'fontsize', 16, 'FontWeight', 'bold', 'Position', [pos(1)-0.07 pos(4)/2], 'Rotation', 0);
    hold on;

    Z = reshape(xo(m,:,:), n_samples, n_samples);
    contourf(Y, X, Z, 0:0.001:1, 'linecolor', 'none');
    t = colorbar;
    set(get(t,'title'), 'string', 'xo', 'Fontsize', 12);
    set(t, 'ylim', [0, 1]);
    hold off;

    fstr = ['xo', num2str(m), '.fig'];
    saveas(fh, fstr);
end


for m = 1 : Nc
    fh = figure();
    strtitle = ['xg', num2str(m)];
    h = title(strtitle);
    set(h, 'fontsize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    h = xlabel('x1');
    set(h, 'fontsize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    h = ylabel(char(['p', 771]));
    pos = axis;
    set(h, 'fontsize', 16, 'FontWeight', 'bold', 'Position', [pos(1)-0.07 pos(4)/2], 'Rotation', 0);
    hold on;

    Z = reshape(xg(m,:,:), n_samples, n_samples);
    contourf(Y, X, Z, 0:0.001:1, 'linecolor', 'none');
    t = colorbar;
    set(get(t,'title'), 'string', 'xg', 'Fontsize', 12);
    set(t, 'ylim', [0, 1]);
    hold off;

    fstr = ['xg', num2str(m), '.fig'];
    saveas(fh, fstr);
end


fh = figure();
h = title('Approximated phase diagram');
set(h, 'fontsize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
h = xlabel('x1');
set(h, 'fontsize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
h = ylabel(char(['p',771]));
pos = axis;
set(h, 'fontsize', 16, 'FontWeight', 'bold', 'Position', [pos(1)-0.07 pos(4)/2], 'Rotation', 0);
hold on;

firsto = true; 
firstg = true; 
firstog = true; 
for j = 1 : n_samples % p
    for i = 1 : n_samples % z
        if(phase_pre(i,j) == 1)
            if(firsto)
                ho = plot((i-1)/(n_samples-1),(j-1)/(n_samples-1),'.r','MarkerSize',10);
                firsto = false;
            else
                plot((i-1)/(n_samples-1),(j-1)/(n_samples-1),'.r','MarkerSize',10);
            end
            hold on;
        elseif(phase_pre(i,j) == -1)
            if(firstg)
                hg = plot((i-1)/(n_samples-1),(j-1)/(n_samples-1),'.b','MarkerSize',10);
                firstg = false;
            else
                plot((i-1)/(n_samples-1),(j-1)/(n_samples-1),'.b','MarkerSize',10);
            end
            hold on;
        else
            if(firstog)
                hog = plot((i-1)/(n_samples-1),(j-1)/(n_samples-1),'.g','MarkerSize',10);
                firstog = false;
            else
                plot((i-1)/(n_samples-1),(j-1)/(n_samples-1),'.g','MarkerSize',10);
            end
            hold on;
        end
    end
end

if((~firsto) && (~firstg) && (~firstog))
    legend([ho hg hog], 'oil', 'gas', 'oil & gas','FontSize',14)
elseif((~firsto) && (firstg) && (firstog))
    legend(ho, 'oil','FontSize',14)
elseif((firsto) && (~firstg) && (firstog))
    legend(hg, 'gas','FontSize',14)
elseif((firsto) && (firstg) && (~firstog))
    legend(hog, 'oil & gas','FontSize',14)
elseif((~firsto) && (~firstg) && (firstog))
    legend([ho hg], 'oil', 'gas','FontSize',14)
elseif((~firsto) && (firstg) && (~firstog))
    legend([ho hog], 'oil', 'oil & gas','FontSize',14)
elseif((firsto) && (~firstg) && (~firstog))
    legend([hg hog], 'gas', 'oil & gas','FontSize',14)
end
hold off;

saveas(fh, 'phase_pre.fig');


for m = 1 : Nc
    fh = figure();
    strtitle = ['xo', num2str(m), '_pre'];
    h = title(strtitle);
    set(h, 'fontsize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    h = xlabel('x1');
    set(h, 'fontsize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    h = ylabel(char(['p', 771]));
    pos = axis;
    set(h, 'fontsize', 16, 'FontWeight', 'bold', 'Position', [pos(1)-0.07 pos(4)/2], 'Rotation', 0);
    hold on;

    Z_pre = reshape(xo_pre(m,:,:), n_samples, n_samples);
    contourf(Y, X, Z_pre, 0:0.001:1, 'linecolor', 'none');
    t = colorbar;
    set(get(t,'title'), 'string', 'xo_pre', 'Fontsize', 12);
    set(t, 'ylim', [0, 1]);
    hold off;

    fstr = ['xo', num2str(m), '_pre.fig'];
    saveas(fh, fstr);
end


for m = 1 : Nc
    fh = figure();
    strtitle = ['xg', num2str(m), '_pre'];
    h = title(strtitle);
    set(h, 'fontsize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    h = xlabel('x1');
    set(h, 'fontsize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    h = ylabel(char(['p', 771]));
    pos = axis;
    set(h, 'fontsize', 16, 'FontWeight', 'bold', 'Position', [pos(1)-0.07 pos(4)/2], 'Rotation', 0);
    hold on;

    Z_pre = reshape(xg_pre(m,:,:), n_samples, n_samples);
    contourf(Y, X, Z_pre, 0:0.001:1, 'linecolor', 'none');
    t = colorbar;
    set(get(t,'title'), 'string', 'xg_pre', 'Fontsize', 12);
    set(t, 'ylim', [0, 1]);
    hold off;

    fstr = ['xg', num2str(m), '_pre.fig'];
    saveas(fh, fstr);
end


fh = figure();
h = title('Phase error');
set(h, 'fontsize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
h = xlabel('x1');
set(h, 'fontsize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
h = ylabel(char(['p',771]));
pos = axis;
set(h, 'fontsize', 16, 'FontWeight', 'bold', 'Position', [pos(1)-0.07 pos(4)/2], 'Rotation', 0);
axis([0, 1, -inf, inf]);
hold on;

for j = 1 : n_samples % p
    for i = 1 : n_samples % z
        if(phase_err(i,j) ~= 0)
            plot((i-1)/(n_samples-1),(j-1)/(n_samples-1),'.k','MarkerSize',10);
            hold on;
        end
    end
end

saveas(fh, 'phase_error.fig');


error = zeros(n_samples, n_samples);
for m = 1 : Nc
    fh = figure();
    strtitle = ['Error of xo', num2str(m)];
    h = title(strtitle);
    set(h, 'fontsize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    h = xlabel('x1');
    set(h, 'fontsize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    h = ylabel(char(['p',771]));
    pos = axis;
    set(h, 'fontsize', 16, 'FontWeight', 'bold', 'Position', [pos(1)-0.07 pos(4)/2], 'Rotation', 0);
    hold on;

    Z_pre = reshape(xo_pre(m,:,:),n_samples,n_samples);
    Z = reshape(xo(m,:,:),n_samples,n_samples);
    max = 0;
    for j = 1 : n_samples % p
        for i = 1 : n_samples % z
            error(i,j) = abs(Z_pre(i,j)-Z(i,j));
            if(error(i,j) > max)
                max = error(i,j);
            end
        end
    end
    contourf(Y, X, error, 0:0.001:max, 'linecolor', 'none');
    t = colorbar;
    set(get(t,'title'), 'string', 'error', 'Fontsize', 12);
    if(max > 0)
        set(t, 'ylim', [0,max]);
    end
    hold off;

    fstr = ['xo', num2str(m), '_error.fig'];
    saveas(fh,fstr);
end


for m = 1 : Nc
    fh = figure();
    strtitle = ['Error of xg', num2str(m)];
    h = title(strtitle);
    set(h, 'fontsize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    h = xlabel('x1');
    set(h, 'fontsize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    h = ylabel(char(['p',771]));
    pos = axis;
    set(h, 'fontsize', 16, 'FontWeight', 'bold', 'Position', [pos(1)-0.07 pos(4)/2], 'Rotation', 0);
    hold on;

    Z_pre = reshape(xg_pre(m,:,:),n_samples,n_samples);
    Z = reshape(xg(m,:,:),n_samples,n_samples);
    max = 0;
    for j = 1 : n_samples % p
        for i = 1 : n_samples % z
            error(i,j) = abs(Z_pre(i,j)-Z(i,j));
            if(error(i,j) > max)
                max = error(i,j);
            end
        end
    end
    contourf(Y, X, error, 0:0.001:max, 'linecolor', 'none');
    t = colorbar;
    set(get(t,'title'), 'string', 'error', 'Fontsize', 12);
    if(max > 0)
        set(t, 'ylim', [0,max]);
    end
    hold off;

    fstr = ['xg', num2str(m), '_error.fig'];
    saveas(fh,fstr);
end


