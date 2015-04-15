function watershedTest()
%Testet den Watershed-Algorithmus
%WATERSHED prueft, wie sich das Verfahren von Watershed bei den
%Bakterienkolonien eignet. Genauer gesagt wird einen marker controlled
%watershed Segmentation durchgefuehrt. Die Theorie wird in der
%Dokumentation behandelt.
%
%Erstellt durch Ch. Baumberger, Juni 2008

	clc, close all, clear all
	% Benötigte Pfade automatisch hinzufügen
    addpath('..');
    addpath('..\..\lib');

	% Bilder einlesen
	[fileName, path] = uigetfile('*.tif', 'Load Image', '..\..\..\..\Daten\Bilder\');
	original = im2uint8(imread([path fileName]));

	%Bilder vorverarbeiten
	[imPr originalB originalG] = preprocessing(original);

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% marker controlled watershed segmentation %
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% Stoppuhr der watershed segmentation starten
	tic 
	% Komplement bilden, da die watershed-Transformation nach Senken sucht 
	originalBComp = imcomplement(originalB);    
	CompDouble = double(originalBComp);

	% Gradientenbild erzeugen
	h = fspecial('sobel');
	g = sqrt(imfilter(CompDouble, h, 'replicate') .^2 + ...
	    imfilter(CompDouble, h', 'replicate') .^2);
	g = mat2gray(g);
	% watershed direkt auf Gradientenbild -> Uebersegmentiertung
	L = watershed(g);
	Lbw = L == 0;
	overlayDirekt = imoverlay(originalB, Lbw, [.3 1 .3]);

	%%%%%%%%%%%%%%%%%%%%%%%%%
	% find internal markers %
	%%%%%%%%%%%%%%%%%%%%%%%%%   
	% Regionale Minima der H-Transformation suchen 
	imex = imextendedmin(originalBComp, 10);
	colonyBW = imex == 1;
	overlayBW = imoverlay(originalBComp, colonyBW, [.3 1 .3]);

	%%%%%%%%%%%%%%%%%%%%%%%%%
	% find external markers %   
	%%%%%%%%%%%%%%%%%%%%%%%%%
	% Wasserscheidentransformation auf Distanztransformation anwenden
	dist = mat2gray(bwdist(~colonyBW));
	Lim = watershed(imcomplement(dist));
	em = Lim == 0;
	overlaydist = imoverlay(originalBComp, em, [.3 1 .3]);

	% Die Marker im Gradientenbild markieren
	g2 = imimposemin(g, colonyBW | em);
	L2 = watershed(g2);
	L2bw = L2 == 0;
	overlayWater = imoverlay(originalB, L2bw, [.3 1 .3]);

	toc % Stoppuht der watershed segmentation stopen

	% Die Bilder mit der Funktion imvisual darstellen
	imvisual({'image',{originalB, overlayDirekt, overlayBW, overlaydist, g, g2, overlayWater}, 'scale', 0.5});
    
	% Warten falls sonst Pfade zu früh entfernt werden
    input('Beenden?');
	% Hinzugefügte Pfade automatisch entfernen
    rmpath('..');
    rmpath('..\..\lib');

end
% Ende Funktion WATERSHED
