function calculateCoeffGlThr()
%Berechnen des globalen Thresholdes
%CALCULATECOEFF berechnet die Koeffizienten des Polynom ersten Grades zur
%Berechnung des globalen Thresholdes zum adaptiven Thresholding
%
%Erstellt durch Ch. Baumberger, Juni 2008

	clc, close all, clear all

	%Werte aus Versuchen bei den maximalen idealen Kreisen
	values = [124.5, 134.9, 244.8, 44.66, 24.83, 22, 52.8, 161.4, 242.6, 296,...
	    265, 277.7, 274.5, 197, 313.5, 340.25, 191.81, 212.67, 169.23, 281.37, 326.4;...
	    -8 -7 -4 -10 -10 -10 -10 -6 -4 -3 -4 -3 -4 -5 -2 -2 -5 -5 -6 -3 -2];

	values = values';
	sortValues = sortrows(values);
	x = sortValues(:,1);
	y = sortValues(:,2);
	figure, plot(x', y', 'o')
	hold on
	% Koeffizienten mit polyfit berechnen
	coeff = polyfit(x,y,1);
	% Resultat darstellen
	xcoeff = linspace(min(x), max(x), 1000);
	ycoeff = coeff(1).*xcoeff + coeff(2);
	for k = 1:length(ycoeff)
	    if (ycoeff(k) > -2)
	        ycoeff(k) = -2;
	    end
	end
	plot(xcoeff, ycoeff)
	% Plot beschriften
	xlabel('Durchschnittsgrösse der Kerne')
	ylabel('idealer globaler Threshold')
	title('Approximieren des globalen Thresholdes durch eine lineare Funktion')
    
end
% Ende Funktion CALCULATECOEFF
