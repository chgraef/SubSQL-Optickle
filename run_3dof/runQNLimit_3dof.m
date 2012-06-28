%%%
%%% File:           runQNLimit_3dof.m
%%% Description:    Calculates the quantum noise limit of the SubSQL IFO
%%%                 3dof starting configuration
%%% Author:         Christian Graef for the AEI 10m Prototype Team
%%%
%%% Rev. history:   2012-06-27 -- First version, derived from 5dof file: 
%%%                                 
%%%
%%% Dependencies:   'getSSIGlobalParms.m', hosted on the Glasgow GEO-ISC 
%%%                 repository
%%%


clear all;


%% Read in 'immutable' parameters
ps = getSSIGlobalParms();

    
%% Constants
parms.Constants.Lambda0 = ps.lambda0;


%% Laser parameters
parms.Laser.Pin = ps.Pin;


%% RF modulation parameters
parms.Modulation.fm1 = 21.61965e6;
parms.Modulation.midx1 = 0.3;

parms.Modulation.fm2 = 77.728e6;
parms.Modulation.midx2 = 0.3;

parms.Modulation.vFrf = [-parms.Modulation.fm2 -parms.Modulation.fm1 0 parms.Modulation.fm1 parms.Modulation.fm2]';

%%% uncomment to overwrite modulation indices and disable pm 
parms.Modulation.midx1=1E-6;
parms.Modulation.midx2=1E-6;
parms.Modulation.vFrf = 0; 


%% Demodulation phases
parms.DemodPhases.PDa.fm1 = 0.0;
parms.DemodPhases.PDa.fm2 = 0.0;

parms.DemodPhases.PDs.fm1 = 0.0;
parms.DemodPhases.PDs.fm2 = 0.0;

parms.DemodPhases.PDxTrans.fm1 = 0.0;
parms.DemodPhases.PDxTrans.fm2 = 0.0;

parms.DemodPhases.PDyTrans.fm1 = 0.0;
parms.DemodPhases.PDyTrans.fm2 = 0.0;


%% Lengths
parms.Lengths.ArmCav.x = ps.LX;
parms.Lengths.ArmCav.y = ps.LY;

parms.Lengths.MI.x = 0.5;
parms.Lengths.MI.y = 0.5;
 
parms.Lengths.SchnuppAsy = 0.2; % def'd as abs( l_x - l_y )

%% Optical parameters
parms.Optics.EMx.RoC = ps.IMx.ROC;
parms.Optics.EMx.T = ps.EM.T;
parms.Optics.EMx.L = ps.EM.L;
parms.Optics.EMx.phi = 0.0;

parms.Optics.EMy.RoC = ps.IMx.ROC; 
parms.Optics.EMy.T = ps.EM.T;
parms.Optics.EMy.L = ps.EM.L;
parms.Optics.EMy.phi = 0.0;

parms.Optics.IMx.RoC = ps.IMx.ROC;
parms.Optics.IMx.T = ps.IM.T;
parms.Optics.IMx.L = ps.IM.L;
parms.Optics.IMx.phi = 0.0;

parms.Optics.IMy.RoC = ps.IMx.ROC;
parms.Optics.IMy.T = ps.IM.T;
parms.Optics.IMy.L = ps.IM.L;
parms.Optics.IMy.phi = 0.0;

parms.Optics.BS.L = ps.BS.L;
parms.Optics.BS.T = ps.BS.T;
parms.Optics.BS.alpha = 45.0;
parms.Optics.BS.phi=0.0;


% set mirror tunings
parms.Optics.IMx.phi = 0.0;
parms.Optics.EMx.phi = 180.0;
parms.Optics.IMy.phi = 0.0;
parms.Optics.EMy.phi = 180.0;

% set all optical losses to zero, disable pm sidebands
parms.Optics.BS.T=0.5;
parms.Laser.Pin=5.55555;

%%% zpk data for sub-SQL IFO suspensions taken from suspension model on
%%% Prototype labbook p. 299
z=[-1.86252815473909 + 139.089258722136i;...
    -1.86252815473909 - 139.089258722136i;...
    -2.11309422391103 + 63.8650736287248i;...
    -2.11309422391103 - 63.8650736287248i;...
    -1.08680662146273 + 8.55126647811396i;...
    -1.08680662146273 - 8.55126647811396i;...
    -0.914915777454092 + 13.7904453896075i;...
    -0.914915777454092 - 13.7904453896075i;...
    -2.47426812566045 + 26.4818608170205i;...
    -2.47426812566045 - 26.4818608170205i];

p=[-1.86252689191963 + 139.089276525150i;...
    -1.86252689191963 - 139.089276525150i;...
    -2.11303491074597 + 63.8652019997573i;...
    -2.11303491074597 - 63.8652019997573i;...
    -2.47337075485747 + 26.4886646746418i;...
    -2.47337075485747 - 26.4886646746418i;...
    -0.803612074542179 + 13.9721459078681i;...
    -0.803612074542179 - 13.9721459078681i;...
    -1.08644917259189 + 9.31136577554612i;...
    -1.08644917259189 - 9.31136577554612i;...
    -0.112619098568645 + 4.48061323389906i;...
    -0.112619098568645 - 4.48061323389906i];

k=10;

parms.zpk_SUS=zpk(z,p,k);


% set optical losses
parms.Optics.IMx.L=ps.IM.L;
parms.Optics.IMy.L=ps.IM.L;
parms.Optics.EMx.L=ps.EM.L;
parms.Optics.EMy.L=ps.EM.L;
parms.Optics.BS.L=ps.BS.L;

% dark fringe offset at the main BS in rad
parms.Optics.BS.phi=2*(2*pi/360);


%% Do some analyses with the model

% build the IFO object
opt = optSubSQL_3dof(parms);

% get drive indices
didx.nIMx = getDriveIndex(opt, 'IMx');
didx.nIMy = getDriveIndex(opt, 'IMy');
didx.nEMx = getDriveIndex(opt, 'EMx');
didx.nEMy = getDriveIndex(opt, 'EMy');

% get probe indices
pidx.nPDa_DC = getProbeNum(opt, 'PDa_DC');
pidx.nPDs_DC = getProbeNum(opt, 'PDs_DC');
pidx.nPDx_Trans_DC = getProbeNum(opt, 'PDxTrans_DC');
pidx.nPDy_Trans_DC = getProbeNum(opt, 'PDyTrans_DC');
pidx.nACx_DC = getProbeNum(opt, 'ACx_DC');
pidx.nACy_DC = getProbeNum(opt, 'ACy_DC');

f = logspace(-1, 4, 500)';
[fDC, sigDC, sigAC, mMech, noiseAC] = tickle(opt, [], f);

% extract tf data
h = getTF(sigAC, pidx.nPDa_DC, didx.nEMx)

% extract noise data
n = noiseAC(pidx.nPDa_DC, :)'

% plot the data
figure
loglog(f, abs(n ./ h),'LineWidth',2)
ylim([1E-21 1E-17]);
xlim([5E0 5E3]);
xlabel('Frequency [Hz]');
ylabel('Displacement m/sqrt(Hz)')
title('Sub-SQL IFO Quantum Noise Limit', 'fontsize', 14);
grid

