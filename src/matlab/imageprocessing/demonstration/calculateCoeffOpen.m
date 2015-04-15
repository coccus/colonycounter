function calculateCoeffOpen()
%Berechnen der idealen Maskengrösse
%CALCULATECOEFFOPEN berechnet die Koeffizienten der linearen Funktion zur
%Berechnung der idealen Maskengrösse zum Reinigen des Binaerbildes.
%
%Erstellt durch Ch. Baumberger, Juni 2008

	clc, close all, clear all

	%Werte aus Versuchen bei den maximalen idealen Kreisen
	values = [89 97 286 48 77 56 68 125 233 286 276 282 365 296 330 374 188 205; 2 2 4 1 1 1 1 2 4 5 4 4 5 4 5 6 4 4];

	values = values';
	sortValues = sortrows(values);
	n = 1;
	x = sortValues(:,1);
	y = sortValues(:,2);
	figure, plot(x', y', 'o')
	hold on
	% Koeffizienten mit polyfit berechnen
	coeff = polyfit(x,y,n);
	% Resultat darstellen
	xcoeff = linspace(min(x), max(x), 1000);
	ycoeff = coeff(1).*xcoeff.^(n) + coeff(2);
	plot(xcoeff, ycoeff)
	% Plot beschriften
	xlabel('Durchschnittsgrösse der Kerne')
	ylabel('ideale Maskengrösse')
	title('Approximieren der Maskengrösse durch eine lineare Funktion')
    
end
% Ende Funktion CALCULATECOEFFOPEN