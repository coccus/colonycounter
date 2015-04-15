function make_cvlib(opt)
%  make_cvlib -- Make the cvlib_mex in windows. It probably will
%  work as well in Linux/Mac with only minor changes
%
%  Author:	Joaquim Luis
%  Date:	07-Sept-2006

if nargin == 0
    opt = '-O';
end

if ispc

    % Adjust for your own path
    INCLUDE_CV = '"C:\Program Files\OpenCV\cv\include"';
    INCLUDE_CXCORE = '"C:\Program Files\OpenCV\cxcore\include"';
    LIB_CV = '"C:\Program Files\OpenCV\lib\cv.lib"';
    LIB_CXCORE = '"C:\Program Files\OpenCV\lib\cxcore.lib"';

    % -------------------------- Stop editing ---------------------------
    include_cv = ['-I' INCLUDE_CV ' -I' INCLUDE_CXCORE];
    library_cv = [LIB_CV ' ' LIB_CXCORE];

    if (ispc)
        opt_cv = [opt ' -DWIN32 -DDLL_CV100 -DDLL_CXCORE100'];
    else
        opt_cv = opt;
    end

    clear('cvlib_mex.mexw32');
    if exist('cvlib_mex.mexw32') ~= 0
        delete('cvlib_mex.mexw32');
    end
    if exist('cvlib_mex.mexw32.pdb') ~= 0
        delete('cvlib_mex.mexw32.pdb');
    end
    if exist('cvlib_mex.ilk') ~= 0
        delete('cvlib_mex.ilk');
    end

    cmd = ['mex cvlib_mex.cpp ' include_cv ' ' library_cv ' ' opt_cv];        
    eval(cmd) 
end

if isunix
    [s,r] = unix('pkg-config --cflags --libs opencv');
    eval(['mex ' r(1:end-1) ' cvlib_mex.cpp']);
end
    
