clc;
clear;
close all;

%% Source image (any odd HxW, 1 or 3 channels)
% --- Option A: your own picture --------------------------------------------
%   img = imread('myimage.png');                 % HxWx3 uint8
%   [H,W,~] = size(img);
%   img = img(1:H-(1-mod(H,2)), 1:W-(1-mod(W,2)), :);   % crop to odd sizes
% --- Option B: synthetic colour test arrow (default) ------------------------
N = 33;                                          % must be odd
% img = makeColorArrow(N);
img = imread('PlayerGlyph.png');

[H,W,P] = size(img);
assert(mod(H,2)==1 && mod(W,2)==1, 'Image height and width must both be odd.');

%% Variable Initialization
phi = 60;                                        % degrees, -180..180

%% Choose the fixed-point format from the image size
% Largest |coordinate| from the center is R. We need
%   R*(|cos|+|sin|) + rounding offset  <=  32767   (signed 16-bit)
% so the larger the image, the fewer fractional bits (SHIFT) we can afford.
R     = (max(H,W) - 1) / 2;
SHIFT = min(14, floor(log2((32767 - R) / (sqrt(2)*R + 0.5))));
SCALE = 2^SHIFT;
if SHIFT < 7
    warning(['SHIFT = %d: precision is getting coarse for this image size. ' ...
             'Consider a 32-bit accumulator (SHIFT = 14) on the CPU.'], SHIFT);
end
fprintf('Image %dx%dx%d  ->  R = %d, Q%d (SCALE = %d)\n', H, W, P, R, SHIFT, SCALE);

%% LUT Initialization (quarter-wave table + symmetry)
quarter = 0:90;
SinQ = int16(round(sin(quarter * pi/180) * SCALE));    % 91 entries

Sin_LUT = zeros(1,360,'int16');
Cos_LUT = zeros(1,360,'int16');
for a = 0:359
    Sin_LUT(a+1) = sinFromQuarter(SinQ, a);
    Cos_LUT(a+1) = sinFromQuarter(SinQ, mod(a+90, 360));   % cos(a) = sin(a+90)
end

% Overflow guarantee for 16-bit arithmetic (exact, using the real table)
maxCS = max(abs(double(Cos_LUT)) + abs(double(Sin_LUT)));
bound = R*maxCS + 2^(SHIFT-1);
assert(bound <= 32767, 'Worst-case intermediate %d overflows int16.', bound);

% Bundle everything the rotation needs
cfg.Sin   = Sin_LUT;
cfg.Cos   = Cos_LUT;
cfg.SHIFT = SHIFT;
cfg.bg    = repmat(uint8(255), 1, P);            % background colour (white)

%% Self-check: vectorized model must match the per-pixel loop (CPU algorithm)
for t = [-180 -135 -90 -45 0 7 30 45 60 90 123 179 180]
    assert(isequal(rotateLattice(img,t,cfg), rotateLatticeLoop(img,t,cfg)), ...
           'Vectorized and loop versions disagree at %d deg', t);
end
disp('Vectorized model matches the per-pixel loop.');

%% Interactive Display
fig = figure('Name', 'Integer Image Rotation', 'NumberTitle', 'off', ...
             'Position', [200 200 1000 600]);

ax1 = subplot(1,2,1);
image(img); axis equal; axis ij; grid on;
xlim([0.5 W+0.5]); ylim([0.5 H+0.5]);
title('Reference');

ax2 = subplot(1,2,2);
hImage = image(rotateLattice(img, phi, cfg));
axis equal; axis ij; grid on;
xlim([0.5 W+0.5]); ylim([0.5 H+0.5]);
hTitle = title(sprintf('Rotated: %d degrees CCW', phi));

hAngle = uicontrol('Style','text','Parent',fig,'Units','normalized', ...
    'Position',[0.40 0.02 0.20 0.04], ...
    'String',sprintf('%d degrees',phi),'FontSize',12);

slider = uicontrol('Style','slider','Parent',fig,'Units','normalized', ...
    'Position',[0.20 0.08 0.60 0.05], ...
    'Min',-180,'Max',180,'Value',phi,'SliderStep',[1/360 10/360]);

slider.Callback = @(src,~) updateRotation(src, hImage, hTitle, hAngle, img, cfg);

%% ------------------------------------------------------------------------
%  Local functions
%  ------------------------------------------------------------------------
function updateRotation(slider, hImage, hTitle, hAngle, img, cfg)
    angle = round(slider.Value);
    slider.Value = angle;
    hImage.CData = rotateLattice(img, angle, cfg);
    hTitle.String = sprintf('Rotated: %d degrees CCW', angle);
    hAngle.String = sprintf('%d degrees', angle);
    drawnow limitrate;
end

function img = makeColorArrow(N)
% Same arrow as before, but each lit pixel gets a position-dependent colour
% so you can see colour travelling with the pixels. Output: NxNx3 uint8.
    c = (N+1)/2;
    m = zeros(N,N);
    m(c, 5:25) = 1;
    tr = round(linspace(11,17,9));  tc = round(linspace(25,31,9));
    br = round(linspace(23,17,9));  bc = round(linspace(25,31,9));
    m(sub2ind([N N], tr, tc)) = 1;
    m(sub2ind([N N], br, bc)) = 1;
    [cc, rr] = meshgrid(1:N, 1:N);
    img = 255 * ones(N,N,3);                         % white background
    for p = 1:3
        switch p
            case 1, v = 255 * cc / N;
            case 2, v = 255 * (1 - cc / N);
            case 3, v = 255 * rr / N;
        end
        plane = img(:,:,p);
        plane(m > 0) = v(m > 0);
        img(:,:,p) = plane;
    end
    img = uint8(img);
end

function v = sinFromQuarter(SinQ, a)
% sin(a degrees) in Qn for a = 0..359, using only the 0..90 table.
    if a <= 90
        v =  SinQ(a+1);
    elseif a <= 180
        v =  SinQ(180-a+1);
    elseif a <= 270
        v = -SinQ(a-180+1);
    else
        v = -SinQ(360-a+1);
    end
end

function out = makeCanvas(ref, bg)
% HxWxP image filled with the background colour.
    [H,W,P] = size(ref);
    out = repmat(reshape(cast(bg,'like',ref), 1, 1, P), H, W, 1);
end

function [c, s] = lookupCosSin(phi, cfg)
    idx = int32(phi);                    % phi in -180..180
    if idx < 0, idx = idx + 360; end     % -> 0..359
    c = int32(cfg.Cos(idx+1));
    s = int32(cfg.Sin(idx+1));
end

function out = rotateLatticeLoop(ref, phi, cfg)
% Per-pixel version: this is the algorithm to port to the 16-bit CPU.
% The source coordinates are computed ONCE per pixel; the colour channels
% are just copied, with no arithmetic on colour values.
    [H,W,~] = size(ref);
    Cr = int32((H+1)/2);  Cc = int32((W+1)/2);
    [c, s] = lookupCosSin(phi, cfg);
    HALF = int32(2^(cfg.SHIFT-1));
    DIV  = int32(2^cfg.SHIFT);

    out = makeCanvas(ref, cfg.bg);
    for row = 1:H
        for col = 1:W
            xd = int32(col) - Cc;                       % x right
            yd = Cr - int32(row);                       % y up
            xs = idivide(xd*c + yd*s + HALF, DIV, 'floor');
            ys = idivide(yd*c - xd*s + HALF, DIV, 'floor');
            cs = xs + Cc;
            rs = Cr - ys;
            if cs >= 1 && cs <= W && rs >= 1 && rs <= H
                out(row,col,:) = ref(rs,cs,:);
            end
        end
    end
end

function out = rotateLattice(ref, phi, cfg)
% Vectorized, bit-identical model of rotateLatticeLoop (fast enough for the
% slider). Same integer math; only the iteration is done as array ops.
    [H,W,P] = size(ref);
    Cr = int32((H+1)/2);  Cc = int32((W+1)/2);
    [c, s] = lookupCosSin(phi, cfg);
    HALF = int32(2^(cfg.SHIFT-1));
    DIV  = int32(2^cfg.SHIFT);

    [colG, rowG] = meshgrid(1:W, 1:H);
    xd = int32(colG) - Cc;
    yd = Cr - int32(rowG);
    xs = idivide(xd*c + yd*s + HALF, DIV, 'floor');
    ys = idivide(yd*c - xd*s + HALF, DIV, 'floor');
    cs = xs + Cc;
    rs = Cr - ys;
    valid = cs >= 1 & cs <= W & rs >= 1 & rs <= H;

    lin = sub2ind([H W], double(rs(valid)), double(cs(valid)));
    out = makeCanvas(ref, cfg.bg);
    for p = 1:P
        src = ref(:,:,p);
        dst = out(:,:,p);
        dst(valid) = src(lin);
        out(:,:,p) = dst;
    end
end