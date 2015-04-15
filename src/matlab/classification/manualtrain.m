function manualtrain
% Trainiert den Klassifikator mit den ausgezählen Bildern.

addpath('..\lib');

% Pfade zu den Bildern
pathData = '..\..\..\Daten\';
pathCounted = [pathData 'Matlab\'];
pathOriginal = [pathData 'Bilder\'];

% Kopfzeile für die Excel-Tabelle
countheader1 = {'', '', '', '', '', '', '', 'Objekte', '', '', 'Ohne Fehler', '', '', 'Mit Fehler', '', '', '', ''};
countheader2 = {'Nr.', 'Bild', 'Fehler', '1er', '2er', '>2er', 'Kerne', 'Anzahl', 'Diff', 'Diff [%]', 'Anzahl', 'Diff', 'Diff [%]', 'Anzahl', 'Diff', 'Diff [%]', 'Fehler/Kerne [%]', 'Fehler/Objekte [%]'};
col_k = 1;
col_img = 2;
col_info = 3:10;
col_testplain = 11:13;
col_testerrors = 14:16;
col_errors = 17:18;
col_error = 3;
col_cores = 7;
col_objects = 8;

% Welche Bilder auszählen
images = [
    08, 01; 08, 05; 08, 07; 08, 08; 08, 10; 08, 11; 08, 12; 08, 13;
    08, 14; 08, 15; 08, 16; 08, 17; 08, 18; 08, 19; 08, 20; 08, 22;
    08, 23; 08, 24; 08, 25; 08, 26; 11, 01; 11, 02; 11, 05; 11, 36;
    11, 38; 11, 40; 17, 01; 17, 03; 17, 05; 17, 06; 17, 13; 17, 15;
    17, 21; 17, 22; 17, 23; 17, 24; 17, 25; 17, 26; 17, 27; 17, 35;
    17, 41; 17, 42; 17, 43; 17, 44; 17, 46; 17, 55; 17, 56; 17, 57;
];

% Daten neu berechnen
calcdata = true;

% Achsenverhältnis
axisratio = 1.5;

% Nur 1er und 2er Gruppen klassifizieren
lmax = 2;

% Falls Daten neu Berechnen
if calcdata

    warning off all
    
    % Zwischenspeicher für Daten
    count = zeros(length(images),length(countheader1));
    data = cell(1,length(images));

    %Daten einlesen
    xn = [];
    xk = [];
    for k = 1:length(images)
        %Das segmentierte, ausgezählte Bild laden
        load([pathCounted num2str(k,'%02d') '_counted.mat']);
        
        %Bild analysieren
        x = analyseimage(labels > 0);

        % Fehler und nicht klassifizierbare entfernen
        x = [x{1}' x{2}' x{3}' x{4}' x{5}'];

        used = s > 0;
        xn = [xn;x(used,:)];
        xk = [xk;s(used)];

        diff = abs(sum(s)-length(s));
        diffpercent = round(10000*(diff/sum(s)))/100;
        count(k,col_info) = [sum(s == 0) sum(s == 1) sum(s == 2) sum(s > 2) sum(s) length(s) diff diffpercent];
        data{k} = {x, s};

        disp([num2str(k,'%02d') ' - ' num2str(images(k,1),'%02d') '.' num2str(images(k,2),'%02d') ' done']);
    end
    warning on all

else
    % Daten aus Variable laden
    xn = [];
    xk = [];
    for k = 1:length(images)
        [x, s] = data{k}{:};
        used = s > 0;
        xn = [xn;x(used,:)];
        xk = [xk;s(used)];
    end
end

xntemp = xn;
xktemp = xk;

% Trainingsmenge bestimmen
xn = xntemp(1:2:end,:);
xk = xktemp(1:2:end);

% Einzelne Kerne von den Gruppen trennen, es werden nur die Klassen bis lmax
% mit dem Bayes-Klassifikator behandelt.
singles = (xn(:,4) == 0 | xn(:,4) == 1) & xn(:,1) < axisratio;
xn = xn(~singles,:);
xks = xk(singles);
xk = xk(~singles);


%**************************************************************************
% Bayes-Klassifikator trainieren -> Parameter fuer Bayesklassifikator 
% schätzen

% Die Striktur der Parameter erstellen.
params = struct('mu',cell(1,lmax),'sigma2',cell(1,lmax));

% Parameter (mu, sigma^2) der Normalverteilungsfunktion berechnen
for k = 1:lmax
    % Alle Gruppen mit der gleichen grösse k aussortieren
    xr = xn(xk == k,:);
    % Klassifikator kann nur trainiert werden, wenn mehr als 1 Element in
    % jeder Klasse ist.
    if size(xr,1) <= 1;
        rmpath('..\lib');
        error(['Class ' num2str(k) ': Not enough Elements in Class']);
        return;
    end
    
    % mu berechnen, der Mittelwert
    params(k).mu = mean(xr);
    % simga2 berechnen, die Kovariantmatrix
    params(k).sigma2 = cov(xr);
    
    % überprüfen ob sigma2 symetrisch und positiv ist
    [R,p] = chol(params(k).sigma2);
    if p > 0
        rmpath('..\lib');
        error(['Class ' num2str(k) ': SIGMA2 must be symmetric and positive definite.']);
        return;
    end
end

[filename pathname] = uiputfile('params.mat','Save Parameter');
save(filename,'params');


%**************************************************************************
% Bayes-Klassifikator testen mit Trainingsmenge

% Dikriminanzfunktion des Bayesklassifikators bestimmen
len = size(xn,1);
d = zeros(lmax,len);
for i = 1:lmax
    d(i,:) = mvnpdf(xn, params(i).mu, params(i).sigma2);
end

% Gruppen kommen in die Klasse mit grösster Wahrscheinlichkeit
[C,I] = max(d);
I = [I ones(1,length(xks))];
xk = [xk;xks];

% Umwandlung der codierten Darstellung von der Klassenzugehörigkeit in eine
% lokale Darstellung, um die Funktion confusion(...) gebrauchen zu können.
% Klassifikationserfolg durch Konfusionsmatix berechnen
Ctrain = confusion(ind2vec(xk'),ind2vec(I))

% Erfolgsangabe für Testdaten in Prozent
sumxk = sum(xk);
sumI = sum(I);
diffxkI = abs(sumxk-sumI);
diffpercent = 100*(diffxkI/sumxk);

disp('Klassifikator trainieren');
disp(['Sum Data:     ' num2str(sumxk)]);
disp(['Sum Test:     ' num2str(sumI)]);
disp(['Diff:         ' num2str(diffxkI)]);
disp(['Diff Percent: ' num2str(diffpercent)]);
disp(char([13 13]));


%**************************************************************************
% Bayes-Klassifikator testen mit Testmenge

% Testmenge bestimmen
xn = xntemp(2:2:end,:);
xk = xktemp(2:2:end);

% Einzelne Kerne von den Gruppen trennen, es werden nur die Klassen bis lmax
% mit dem Bayes-Klassifikator behandelt.
singles = (xn(:,4) == 0 | xn(:,4) == 1) & xn(:,1) < axisratio;
xn = xn(~singles,:);
xks = xk(singles);
xk = xk(~singles);

% Dikriminanzfunktion des Bayesklassifikators bestimmen
len = size(xn,1);
d = zeros(lmax,len);
for i = 1:lmax
    d(i,:) = mvnpdf(xn, params(i).mu, params(i).sigma2);
end

% Gruppen kommen in die Klasse mit grösster Wahrscheinlichkeit
[C,I] = max(d);
I = [I ones(1,length(xks))];
xk = [xk;xks];

% Umwandlung der codierten Darstellung von der Klassenzugehörigkeit in eine
% lokale Darstellung, um die Funktion confusion(...) gebrauchen zu können.
% Klassifikationserfolg durch Konfusionsmatix berechnen
Ctest = confusion(ind2vec(xk'),ind2vec(I))

% Erfolgsangabe für Testdaten in Prozent
sumxk = sum(xk);
sumI = sum(I);
diffxkI = abs(sumxk-sumI);
diffpercent = 100*(diffxkI/sumxk);

disp('Klassifikator testen');
disp(['Sum Data:     ' num2str(sumxk)]);
disp(['Sum Test:     ' num2str(sumI)]);
disp(['Diff:         ' num2str(diffxkI)]);
disp(['Diff Percent: ' num2str(diffpercent)]);
disp(char([13 13]));


%**************************************************************************
% Bayes-Klassifikator einzeln Testen ohne Fehler

disp([13 'ohne Fehler']);
disp('   Nr   Data  Test  Diff    Diff%')
for k = 1:length(images)
    
    % Daten ohne Fehler benutzen
    [x, s] = data{k}{:};
    used = s > 0;
    xn = x(used,:);
    xk = s(used);
    
    % Einzelne Kerne von den Gruppen trennen, es werden nur die Klassen bis-lmax
    % mit dem Bayes-Klassifikator behandelt.
    singles = (xn(:,4) == 0 | xn(:,4) == 1) & xn(:,1) < axisratio;
    xn = xn(~singles,:);
    xks = xk(singles);
    xk = xk(~singles);

    if ~isempty(xn)
        % Dikriminanzfunktion des Bayesklassifikators bestimmen
        len = size(xn,1);
        d = zeros(lmax,len);
        for i = 1:lmax
            d(i,:) = mvnpdf(xn, params(i).mu, params(i).sigma2);
        end

        % Gruppen kommen in die Klasse mit grösster Wahrscheinlichkeit
        [C,I] = max(d);
    else
        % Wenn nichts zum Klassifizieren vorhanden
        I = [];
    end
    
    I = [I ones(1,length(xks))];
    xk = [xk;xks];

    % Erfolgsangabe für Testdaten in Prozent
    sumxk = sum(xk);
    sumI = sum(I);
    diffxkI = abs(sumxk-sumI);
    diffpercent = round(10000*(diffxkI/sumxk))/100;
    
    disp(['   ' sprintf('% 3d % 5d % 5d % 5d', [k sumxk sumI diffxkI]) '    ' num2str(diffpercent)]);
    
    count(k,col_testplain) = [sumI diffxkI diffpercent];
end

%**************************************************************************
% Bayes-Klassifikator einzeln Testen mit Fehler

disp([13 'mit Fehler']);
disp('   Nr   Data  Test  Diff    Diff%')
for k = 1:length(images)
    
    % Daten mit Fehler benutzen
    [xn, xk] = data{k}{:};
    
    % Einzelne Kerne von den Gruppen trennen, es werden nur die Klassen bis-lmax
    % mit dem Bayes-Klassifikator behandelt.
    singles = (xn(:,4) == 0 | xn(:,4) == 1) & xn(:,1) < axisratio;
    xn = xn(~singles,:);
    xks = xk(singles);
    xk = xk(~singles);

    if ~isempty(xn)
        % Dikriminanzfunktion des Bayesklassifikators bestimmen
        len = size(xn,1);
        d = zeros(lmax,len);
        for i = 1:lmax
            d(i,:) = mvnpdf(xn, params(i).mu, params(i).sigma2);
        end

        % Gruppen kommen in die Klasse mit grösster Wahrscheinlichkeit
        [C,I] = max(d);
    else
        % Wenn nichts zum Klassifizieren vorhanden
        I = [];
    end
    
    I = [I ones(1,length(xks))];
    xk = [xk;xks];

    % Erfolgsangabe für Testdaten in Prozent
    sumxk = sum(xk);
    sumI = sum(I);
    diffxkI = abs(sumxk-sumI);
    diffpercent = round(10000*(diffxkI/sumxk))/100;
    
    disp(['   ' sprintf('% 3d % 5d % 5d % 5d', [k sumxk sumI diffxkI]) '    ' num2str(diffpercent)]);
    
    count(k,col_testerrors) = [sumI diffxkI diffpercent];
end

%**************************************************************************
% Resultate ins Excel-Sheet schreiben

% Fehlerantele berechnen
% Fehler / Kerne und Fehler / Objekte
count(:,col_errors) = [round(10000*count(:,col_error)./count(:,col_cores))/100 round(10000*count(:,col_error)./count(:,col_objects))/100];

countoutput = [countheader1; countheader2; num2cell(count)];
for k = 1:length(images)
    countoutput{k+2,col_k} = k;
    countoutput{k+2,col_img} = ['''' num2str(images(k,1),'%02d') '.' num2str(images(k,2),'%02d')];
end

[filename pathname] = uiputfile('count.xls','Save Data');
if exist([pathname filename])
    delete([pathname filename]);
end
xlswrite(filename,countoutput);

rmpath('..\lib');
