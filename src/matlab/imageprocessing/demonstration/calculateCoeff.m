function calculateCoeff()
%Berechnung der Blockgroesse
%CALCULATECOEFF berechnet die Koeffizienten des Polynom ersten Grades zur
%Berechnung der Blocksize zum adaptiven Thresholding.
%
%Erstellt durch Ch. Baumberger, Juni 2008

	clc, close all, clear all

	% Werte aus Versuchen bei den maximalen idealen Kreisen
	values = [126.19 139.9 281.3 44.99 26 17 162 144 20 247 303 269.8 282 ...
	    295.88 261.6 313 284 290 342.8 165 285 328 425; 23 25 39 17 19 21 ...
	    29 21 21 29 31 29 29 29 31 37 29 29 41 31 31 37 33];

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
	plot(xcoeff, ycoeff)
	% Plot beschriften
	xlabel('Durchschnittsgrösse der Kerne')
	ylabel('ideale Blockgrösse')
	title('Approximieren der Blockgrösse durch eine lineare Funktion')

end
% Ende Funktion CALCULATECOEFF