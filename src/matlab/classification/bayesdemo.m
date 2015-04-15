function bayesdemo
% Demonstrationsprogramm zur Mustererkennung mit dem Bayes-Klassifikator.
%   Das Demoprogramm zeigt zuerst ein automatisch generietes Bildmit den
%   Positionen der Kerne und den Labels davon. Weiter wird die Auswertung
%   des Randes, also des Winkels von zwei Vektoren am Rand, angezeigt.
%   Dabei sind die übergänge zwischen zwei Kernen gut sichtbar.
%   
%   Nun wird der Klassifikator mit drei Bildern trainiert und das
%   Trainingsresultat ausgegeben.
%   Zum testen des Klassifikators wird ein Parametersatz geladen, der von
%   uns aus 1000 Bildern trainiert wurde. Dazu werden drei Bilder
%   analysiert und klassifiziert und das Resultat ausgegeben.


% Fenster schliessen und Konsole leeren
close hidden all
clc
drawnow;

% Library Path hinzufügen
addpath('..\lib');

% Daten Demo
disp([13 'Keime Daten']);
bayesdatademo
drawnow;

% Training Demo
disp([13 13 'Bayes-Klassifikator trainieren'])
bayestrain(3, 5);

% Test Demo
disp([13 13 'Bayes-Klassifikator testen'])
load params_model.mat
bayestest(3,params);

input('Beenden?');
rmpath('..\lib');
