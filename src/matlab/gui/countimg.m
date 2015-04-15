function [resimg results] = countimg(hObject, img, lastresults)
% Zählt die Bakterienkolonien auf einem Bild

warning off all

% Weitere Daten eingeben
promt = {'Strain?','Concentration?','Tag?'};
title = 'Image Information?';
while true
    if isempty(lastresults)
        res = inputdlg(promt,title,1);
    else
        defAns = {lastresults.name, lastresults.conc, lastresults.tag};
        res = inputdlg(promt,title,1,defAns);
    end

    if ~isempty(res)
        break;
    end
end

pause(1);

% Bildgrösse und Position
x = 770;
y = 778;
r = 710;

% Das Bild zurechtschneiden falls es von der Kamera kommt
if size(img,1) == 1536 && size(img,2) == 1536 
    original = cutout(img, x, y, r);
else
    original = img;
end

% Bild segemntieren
[image area] = segmentation(original);

% Durchschnittliche Fläche berechnen
areamm2 = round((84/(r*2))^2*area*100)/100;

% Segmente klassifizieren
load('params.mat');
[count labels] = bayescount(image, params);

if ~isempty(count)
    % Overlay mit segmenten erstellen
    c = [0 0 0; 1 0 0; 0 1 0];
    resimg = imoverlay(original(:,:,3),label2rgb(labels,c(count+1,:),[0 0 0]));
    countn = sum(count);
else
    % Bild zurückgeben
    resimg = original(:,:,3);
    countn = 0;
end
    
results = struct();
results.name = res{1};
results.conc = res{2};
results.tag = res{3};
results.count = countn;
results.size = areamm2;

warning on all
