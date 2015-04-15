function korrelationTest()
%Testen von Template-Matching
%KORRELATIONTEST FÜHRT ein Test mit Template-Matching durch.
%Zuerst wird ein ideales Objekt gesucht und anschliessend mit dem ganzen
%Bild korreliert.
%
%Erstellt durch Ch. Baumberger, Juni 2008

	clc, close all, clear all;
	% Benötigte Pfade automatisch hinzufügen
    addpath('..');
    addpath('..\..\lib');

	circleTolerance = 0.2;         %Toleranz zum perfekten Kreis, 0.15 = 15%

	% Bilder einlesen
	[fileName, path] = uigetfile('*.tif', 'Load Image', '..\..\..\..\Daten\Bilder\');
	original = im2uint8(imread([path fileName]));

	% Bilder vorverarbeiten
	% ->imPr = Vorverarbeitetes Bild des Blauanteiles
	% ->originalB = Blauanteil des Bildes
	% ->originalG = Gruenanteil des Bildes
	[imPr originalB originalG] = preprocessing(original);

	% Binarisieren mit einem globalen Threshold, abgeaenderte
	% graythresh-Funktion anschliessendes Labeln und Eigenschaften
	bwGlobal = im2bw(imPr, graythreshCircle(imPr));
	labGlobal = bwlabel(bwGlobal, 4);
	stGlobal = regionprops(labGlobal, 'Area', ...
	    'MajorAxisLength', 'MinorAxisLength', 'Extent');

	% Die perfekten Kreise heraussuchen
	[ AverageAreaDef,  perfectCircles ] = features( stGlobal, circleTolerance );

	% Falls Kreise vorhanden sind!
	if (~isempty(perfectCircles))
	    
	    % Farbe des Hintergrundes berechnen und anpassen der Farbe ausserhalb der 
	    % Petrischale an die Farbe des Naehrbodens
	    originalB = backgroundColor(originalB, bwGlobal);
	    
	    % Blockgroesse und globaler Threshold berechnen
	    [ adaptiveBS glThreshold ] = calculateAdaptive(AverageAreaDef);

	    % Adaptives Binarisieren
	    [ bwAdaptive, labelAdaptive, statsAdaptive ] = binAdaptive(originalB, adaptiveBS, glThreshold);
	    
	    % Merkmale suchen
	    [ AverageArea,  perfectCircles ] = features( statsAdaptive, circleTolerance );
	    
	    % Falls perfekte Kreise vorhanden sind
	    if (perfectCircles(1) ~= 0)
	        
	        % Mittelwert und Standardabweichung des perfekten Kreises berechnen
	        [ templatePerfect, meanTemplate, stdTempPerf, meanAverage ]...
	            = cutTemplates(originalB, statsAdaptive, perfectCircles);        
	        
	        %Korrelieren
	        corr = normxcorr2(templatePerfect,originalB);
	        bincorr = im2bw(corr, graythresh(corr));
	    end
	end

	imvisual({'simpleimage', {originalB, bincorr}, 'scale', 0.5})
    
	% Warten falls sonst Pfade zu früh entfernt werden
    input('Beenden?');
	% Hinzugefügte Pfade automatisch entfernen
    rmpath('..');
    rmpath('..\..\lib');
    
end
% Ende Funktion KORRELATIONTEST
