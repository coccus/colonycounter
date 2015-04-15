function pyramidLinkingTest()
%Testen des Pyramid Linking Algorithmus
%PYRAMIDLINKINGTEST testet die Funktion pyrSegmentation aus der
%OpenCV-Library
%
%Erstellt durch Ch. Baumberger, Juni 2008

	clc, close all, clear all
	% Benötigte Pfade automatisch hinzufügen
    addpath('..');
    addpath('..\..\lib');
    addpath('..\..\lib\cvlib');

	% Bilder einlesen
	[fileName, path] = uigetfile('*.tif', 'Load Image', '..\..\..\..\Daten\Bilder\');
	original = im2uint8(imread([path fileName]));

	%Bilder vorverarbeiten
	[imPr originalB originalG] = preprocessing(original);

	% Bild anpassen
	n = 4;
	s = size(originalB);
	newS = s + (n^2 - mod(s, n^2));

	image2 = zeros(newS, 'uint8');
	image2(1:s(1), 1:s(2)) = originalB;
	% Pyramid-Segmentation durchführen
	pyr = cvlib_mex('pyrSegmentation', image2, n, 10, 20);
	pyr = pyr(1:s(1), 1:s(2));

	imvisual({'image', {originalB, pyr}, 'scale', 0.5})
    
	% Warten falls sonst Pfade zu früh entfernt werden
    input('Beenden?');
	% Hinzugefügte Pfade automatisch entfernen
    rmpath('..');
    rmpath('..\..\lib');
    rmpath('..\..\lib\cvlib');

end
% Ende Funktion PYRAMIDLINKINGTEST
