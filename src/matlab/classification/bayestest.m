function bayestest(counttest, params)
% Erstellt Testdaten und testet den Bayes Klassifikator.
%
% Parameter
%   counttest   Wie viele Bilder erstellt und analysiert werden sollen
%   params      Die Parameter des Bayes-Klassifikators. Sie können mit 
%               bayestrain erstellt werden.

% Anzahl Klassen ermitteln
lmax = length(params);

%**************************************************************************
% Klassifikator anwenden
[xn xk] = createdata(counttest, lmax);

% singles trennen
singles = xn(:,4) == 0 | xn(:,4) == 1;
xn = xn(~singles,:);
xks = xk(singles);
xk = xk(~singles);

%Diskriminanzfunktion für Testdaten berechnen
len = length(xn);
dtest = zeros(lmax,len);
for i=2:lmax
    dtest(i,:) = mvnpdf(xn,params(i).mu,params(i).sigma2);
end

%Klassenzugehörigkeit der Testdaten ermitteln
[C,Itest] = max(dtest);
Itest = [Itest ones(1,length(xks))];
xk = [xk;xks];

%lokale Darstellung für Konfusionsmatrix
%Klassifikationserfolg der Testdaten durch Konfusionsmatix berechnen
Ctest = confusion(ind2vec(xk'),ind2vec(Itest))

%Erfolgsangabe für Testdaten in Prozent
sumxk = sum(xk);
sumItest = sum(Itest);
diffxkItest = abs(sumxk-sumItest);
diffpercent = 100*(diffxkItest/sumxk);

disp(['Sum Data:     ' num2str(sumxk)]);
disp(['Sum Test:     ' num2str(sumItest)]);
disp(['Diff:         ' num2str(diffxkItest)]);
disp(['Diff Percent: ' num2str(diffpercent)]);
