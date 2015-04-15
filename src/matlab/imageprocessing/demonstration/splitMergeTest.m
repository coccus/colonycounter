function splitMergeTest()
%Testen von Split & Merge
%SPLITMERGETEST testet die Segmentiertung mit Split & Merge. Die Funktion
%splitmerge liegt der dipum-Toolbox des Buches "Digital Image Pocessing
%using MATLAB" bei.
%
%Erstellt durch Ch. Baumberger, Juni 2008

	clc, close all, clear all
	% Benötigte Pfade automatisch hinzufügen
    addpath('..');
    addpath('..\..\lib');

	% Bilder einlesen
	[fileName, path] = uigetfile('*.tif', 'Load Image', '..\..\..\..\Daten\Bilder\');
	original = im2uint8(imread([path fileName]));

	% Bilder vorverarbeiten
	[imPr originalB originalG] = preprocessing(original);
	imPr = mat2gray(imPr);
	g = splitmerge(originalB, 2, @predicate);

	imvisual({'image', {originalB, g}, 'scale', 0.5})
    
	% Warten falls sonst Pfade zu früh entfernt werden
    input('Beenden?');
	% Hinzugefügte Pfade automatisch entfernen
    rmpath('..');
    rmpath('..\..\lib');

end
% Ende Funktion SPLITMERGETEST

%PREDICATE ist eine Hilfsfunktion fuer splitmerge
function flag = predicate(region)
	sd = std2(region);
	m = mean2(region);
	flag = (sd > 2) & (m > 10) & (m < 180);
end
% Ende Funktion PREDICATE
