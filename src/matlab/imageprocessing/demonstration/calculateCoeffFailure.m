function calculateCoeffFailure()
%Berechnen des Filters für das Aussortieren der Fehler
%CALCULATECOEFF berechnet die Koeffizienten des Polynom dritten Grades zur
%Berechnung des Mittelwertes des Filters beim Entfernen der Fehler
%
%Erstellt durch Ch. Baumberger, Juni 2008

	clc, close all, clear all

	%Werte aus Versuchen bei den maximalen idealen Kreisen
	values = [164.6 162.8 154.2 210.3 155 146.6 146.5 136 198.1 147.3 200.7 166.6 ...
	    168.9 186.6 191.2 164.3 172.7; 13 13 12 17 13 12 12 12 16 12 16 13 13 15 15 13 14];

	values = values';
	sortValues = sortrows(values);
	% Polynom dritten Grades
	n = 3;
	x = sortValues(:,1);
	y = sortValues(:,2);
	figure, plot(x', y', 'o')
	hold on
	% Koeffizienten mit polyfit berechnen
	coeff = polyfit(x,y,n);
	% Resulatat darstellen
	xcoeff = linspace(min(x), max(x), 1000);
	ycoeff = coeff(1).*xcoeff.^(n) + coeff(2).*xcoeff.^(n-1) + coeff(3).*xcoeff.^(n-2) + coeff(4);
	plot(xcoeff, ycoeff)
	% Plot beschriften
	xlabel('Mittelwert der perfekten Kreise')
	ylabel('Mittelwert des Filters')
	title('Approximieren des Mittelwertes des Filters durch ein Polynom 3. Grades')
    
end
% Ende Funktion CALCULATECOEFF