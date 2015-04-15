function threshold()
%Es werden diverse Thresholdverfahren durchgef�hrt
%THRESHOLD f�hrt verschieden Thresholdverfahren zum Binarisiern durch
%
%Erstellt durch Ch. Baumberger, Juni 2008

	clc, close all, clear all
 	% Ben�tigte Pfade automatisch hinzuf�gen
    addpath('..');
    addpath('..\..\lib');
    addpath('..\..\lib\cvlib');

	% Bilder einlesen
	[fileName, path] = uigetfile('*.tif', 'Load Image', '..\..\..\..\Daten\Bilder\');
	original = im2uint8(imread([path fileName]));

	%Bilder vorverarbeiten
	[imPr originalB originalG] = preprocessing(original);
	    
	%%%%%%%%%%%%%%%%%%%%%%%
	% Global Thresholding %
	%%%%%%%%%%%%%%%%%%%%%%%

	% graythresh mit otsu's Methode auf Originalbild
	otsuOrig = im2bw(imPr, graythreshCircle(originalB));
	% graythresh mit otsu's Methode auf vorverabeitetes Bild
	OtsuPrepro = im2bw(imPr, graythreshCircle(imPr));

	% Iterative Methode aus Buch "Digital Image Processing using Matlab"
	T = 0.5*(double(min(imPr(:))) + double(max(imPr(:))));
	done = false;
	while ~done
	    g = imPr >= T;
	    Tnext = 0.5 * (mean(imPr(g)) + mean(imPr(~g)));
	    done = abs(T - Tnext) < 0.5;
	    T = Tnext;
	end
	bwiterativ = imPr > T;

	%%%%%%%%%%%%%%%%%%%%%%%%
	% Lokales Thresholding %
	%%%%%%%%%%%%%%%%%%%%%%%%

	% Filtertyp:  g = gaussian oder a = average
	filtertype = 'g';
	% Blockgr�sse
	block_size = 27;
	% Globaler Threshold
	glThreshold = -10;
	% Sigma falls mit gaussian gefiltert wird
	sigma = (block_size/2-1)*0.3+0.8;

	% adaptives lokales Binarisieren
	if (filtertype == 'a')
	    filtermask = fspecial('average', block_size);
	elseif (filtertype == 'g')
	    filtermask = fspecial('gaussian', block_size, sigma);
	end
	locSmooth = imfilter(originalB, filtermask, 'replicate');
	locDiff = originalB - locSmooth + glThreshold;
	locBW = locDiff > 0;

	%adaptives lokales Binarisieren mit der opencv library
	max_value = 255;
	adaptive_method = 0;    % 0 fuer blur, 1 fuer gaussian
	threshold_type = 0;
	opencvBW = cvlib_mex('adaptiveThreshold', originalB, max_value,...
	    adaptive_method, threshold_type, block_size, glThreshold);


	% Resulatat ausgeben
	imvisual({'image', {originalB, imPr, otsuOrig, OtsuPrepro, bwiterativ, ...
	    locBW, opencvBW}, 'scale', 0.5});
    
	% Warten falls sonst Pfade zu fr�h entfernt werden
    input('Beenden?');
	% Hinzugef�gte Pfade automatisch entfernen
    rmpath('..');
    rmpath('..\..\lib');
    rmpath('..\..\lib\cvlib');

end
% Ende Funktion THRESHOLD
