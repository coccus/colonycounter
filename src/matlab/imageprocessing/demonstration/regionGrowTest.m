function regionGrowTest()
%Testen des Segmentiertungsalgorithmus Region Grow
%REGIONGROWTEST prueft den ob sich der Algorithmus Region Grow fue die
%Bakterienkolonien eignet.
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
	% Der Algorithmus benoetigt diverse Keimpunkte, von denen aus die Objekte
	% wachsen. Es werden nun 20 Keimpunkte mit dem Zufallsgenerator erzeugt.
	[m n] = size(originalB);
	Seedpoints = zeros(m, n) == 1;
	for i = 1:20
	   Seedpoints(randint(1,1,[0,m]), randint(1,1,[0,n])) = 1; 
	end
	% Segmentierung durchfuehren
	[g, nr, si, ti] = regiongrow(imPr, Seedpoints, 4);

	imvisual({'image', {originalB, g, si, ti}, 'scale', 0.5})
    
	% Warten falls sonst Pfade zu früh entfernt werden
    input('Beenden?');
	% Hinzugefügte Pfade automatisch entfernen
    rmpath('..');
    rmpath('..\..\lib');

end
% Ende der Funktion REGIONGROWTEST
