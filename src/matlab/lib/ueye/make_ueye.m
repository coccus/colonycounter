function make_ueye(opt)
% Kompiliert das uEye Kamera Interface
%
% Als optionaler Paramter k�nnen Einstellungen an den Compiler �bergeben
% werden. Zum Beispiel '-g' zum erstellen von Debug Informationen.

% Falls kein Parameter �bergeben wird
if nargin == 0
    opt = '-O';
end

uEyePath = 'C:\Program Files\IDS\uEye\Develop';

% MATLAB C Compiler starten, mit der uEye Library als Parameter
eval(['mex ' opt ' ueye.cpp -I"' uEyePath '\include" -L "' uEyePath '\Lib\uEye_api.lib"']);

movefile('ueye.mexw32', '..');
