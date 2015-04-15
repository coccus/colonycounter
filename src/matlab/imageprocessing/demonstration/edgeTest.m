function edgeTest()
%Testen von verschiedenen Kantenfiltern
%EDGETEST testet alle gängigen Kantenfilter
%
%Erstellt durch Ch. Baumberger, Juni 2008

	clc, close all, clear all
	% Benötigte Pfade automatisch hinzufügen
    addpath('..');
    addpath('..\..\lib');

	% Bilder einlesen
	[fileName, path] = uigetfile('*.tif', 'Load Image', '..\..\..\..\Daten\Bilder\');
	original = im2uint8(imread([path fileName]));

	% Bilder vorverarbeiten:
	[imPr originalB originalG] = preprocessing(original);

	% Sobel-Kantenfilter:
	[imSobel threshold] = edge(originalB, 'sobel');
	imSobel = edge(originalB, 'sobel', threshold * 0.6);

	% Prewitt-Kantenfilter:
	[imPrewitt threshold] = edge(originalB, 'prewitt');
	imPrewitt = edge(originalB, 'prewitt', threshold * 0.4);

	% Roberts-Kantenfilter:
	[imRoberts threshold] = edge(originalB, 'roberts');
	imRoberts = edge(originalB, 'roberts', threshold * 0.5);

	% Laplacian of Gaussian Kantenfilter:
	[imLog threshold] = edge(originalB, 'log' );
	imLog = edge(originalB, 'log' , threshold * 0.06, 6);

	% Zerocross-Kantenfilter:
	[imZerocross threshold] = edge(originalB, 'zerocross');
	imZerocross = edge(originalB, 'zerocross', threshold * 0.8);

	% Canny-Kantenfilter:
	[imCanny threshold] = edge(originalB, 'canny');
	imCanny = edge(originalB, 'canny', threshold * 1, 3);

	% Gaussdifferenz:
	h = fspecial('gaussian', 19, 13);
	gaussDiff = mat2gray(abs(originalB - imfilter(originalB, h, 'replicate')));
	gausshist = histeq(gaussDiff);
	gaussAdjust = imadjust(gausshist, [0.8400, 0.8600], [0, 1]);
	gaussbw = gaussAdjust > 0.9;

	imvisual({'image', {originalB, imSobel, imPrewitt, imRoberts, imLog, ...
	    imZerocross, imCanny, gaussbw}, 'scale', 0.5})
		
	% Warten falls sonst Pfade zu früh entfernt werden
    input('Beenden?');
	% Hinzugefügte Pfade automatisch entfernen
    rmpath('..');
    rmpath('..\..\lib');

end
% Ende Funktion EDGETEST