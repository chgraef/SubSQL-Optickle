%%%
%%% Optickle reference model (3dof)
%%% of the AEI 10m Prototype subSQL IFO 
%%%
%%% written by Christian Graef
%%% 
%%%
%%% Revision history: 
%%%     # 2012-06-27, C.G. -- Derived this model from the existing 5-dof one
%%%     
%%%
%%% Notice: Don't edit this file unless you know what you're doing!
%%%         Parameters should be changed outside and passed to the
%%%         interferometer skeleton as elements of the 'parms' struct


function opt = optSubSQL_3dof(parms)



%%
%%%%%%%%%%%%%%%%%%%%%
% create an empty model
%%%%%%%%%%%%%%%%%%%%%

vFrf = parms.Modulation.vFrf;
opt = Optickle(vFrf);

  
%%
%%%%%%%%%%%%%%%%%%%%%
% add a source
%%%%%%%%%%%%%%%%%%%%%

opt = addSource(opt, 'Laser', sqrt(parms.Laser.Pin) * (vFrf == 0));
opt = addRFmodulator(opt,'EOM1',parms.Modulation.fm1,i*parms.Modulation.midx1); 
opt = addRFmodulator(opt,'EOM2',parms.Modulation.fm2,i*parms.Modulation.midx2);   
  
%%
%%%%%%%%%%%%%%%%%%%%
% dummy optics
%%%%%%%%%%%%%%%%%%%%

opt = addBeamSplitter(opt, 'POBS', 0, 0, 0.1, 0.0, 0.0);


%%
%%%%%%%%%%%%%%%%%%%%  
% main optics
%%%%%%%%%%%%%%%%%%%%

opt = addBeamSplitter(opt, 'BS', parms.Optics.BS.alpha, 0, parms.Optics.BS.T, parms.Optics.BS.L, 0.0);

opt = addMirror(opt, 'IMx', 0, 1.0/parms.Optics.IMx.RoC, parms.Optics.IMx.T, parms.Optics.IMx.L, 0);
opt = addMirror(opt, 'IMy', 0, 1.0/parms.Optics.IMy.RoC, parms.Optics.IMy.T, parms.Optics.IMy.L, 0);
opt = addMirror(opt, 'EMx', 0, 1.0/parms.Optics.EMx.RoC, parms.Optics.EMx.T, parms.Optics.EMx.L, 0);
opt = addMirror(opt, 'EMy', 0, 1.0/parms.Optics.EMy.RoC, parms.Optics.EMy.T, parms.Optics.EMy.L, 0);


%%
%%%%%%%%%%%%%%%%%%%%  
% mechanical tfs
%%%%%%%%%%%%%%%%%%%%

opt = setMechTF(opt, 'IMx', parms.zpk_SUS);
opt = setMechTF(opt, 'EMx', parms.zpk_SUS);
opt = setMechTF(opt, 'IMy', parms.zpk_SUS);
opt = setMechTF(opt, 'EMy', parms.zpk_SUS);

%%
%%%%%%%%%%%%%%%%%%%
% sinks
%%%%%%%%%%%%%%%%%%%

opt = addSink(opt, 'AsyPort');
opt = addSink(opt, 'SymPort');

opt = addSink(opt, 'xArmTrans');
opt = addSink(opt, 'yArmTrans');


%%
%%%%%%%%%%%%%%%%%%%
% links
%%%%%%%%%%%%%%%%%%%

opt = addLink(opt,'Laser','out','EOM1','in',1.0);
opt = addLink(opt,'EOM1','out','EOM2','in',1.0);

%Links to bypass POBS
%opt = addLink(opt,'EOM1','out','BS','frA',1.0);
%opt = addLink(opt, 'BS','frB','SymPort','in',1.0);

%Links to include POBS
opt = addLink(opt, 'EOM2', 'out', 'POBS','frA', 0.001);
opt = addLink(opt, 'POBS', 'bkB','SymPort','in',1.0); 
opt = addLink(opt, 'POBS', 'frA', 'BS','frA', 1.0);
opt = addLink(opt, 'BS' ,'frB', 'POBS','frB', 1.0);

%Link to bypass rf-modulator
%opt = addLink(opt,'Laser','out','BS','frA',1.0);

opt = addLink(opt,'BS','bkA', 'IMx', 'bk', parms.Lengths.MI.x-0.5*parms.Lengths.SchnuppAsy);
opt = addLink(opt,'IMx','bk','BS','bkB', parms.Lengths.MI.x-0.5*parms.Lengths.SchnuppAsy);

opt = addLink(opt,'BS','frA','IMy','bk', parms.Lengths.MI.y+0.5*parms.Lengths.SchnuppAsy);
opt = addLink(opt,'IMy','bk','BS','frB', parms.Lengths.MI.y+0.5*parms.Lengths.SchnuppAsy);
%%%%%
opt = addLink(opt,'IMx','fr', 'EMx', 'fr', parms.Lengths.ArmCav.x);
opt = addLink(opt,'EMx','fr','IMx','fr', parms.Lengths.ArmCav.x);

opt = addLink(opt,'IMy','fr','EMy','fr', parms.Lengths.ArmCav.y);
opt = addLink(opt,'EMy','fr','IMy','fr', parms.Lengths.ArmCav.y);

opt = addLink(opt, 'BS','bkB','AsyPort','in',1.0);

opt = addLink(opt, 'EMx','bk','xArmTrans','in',1.0);
opt = addLink(opt, 'EMy','bk','yArmTrans','in',1.0);


%%
%%%%%%%%%%%%%%%%%%%
% cavity bases
%%%%%%%%%%%%%%%%%%%

%opt = setCavityBasis(opt, 'IMx','EMx');
%opt = setCavityBasis(opt, 'IMy','EMy');


%%
%%%%%%%%%%%%%%%%%%%
% probes
%%%%%%%%%%%%%%%%%%%

% asymmetric port probes
opt = addProbeAt(opt,'PDa_DC','AsyPort','in',0,0);
opt = addProbeAt(opt,'PDa_fm1_I','AsyPort','in',parms.Modulation.fm1,parms.DemodPhases.PDa.fm1);
opt = addProbeAt(opt,'PDa_fm1_Q','AsyPort','in',parms.Modulation.fm1,parms.DemodPhases.PDa.fm1+90);
opt = addProbeAt(opt,'PDa_fm2_I','AsyPort','in',parms.Modulation.fm2,parms.DemodPhases.PDa.fm2);
opt = addProbeAt(opt,'PDa_fm2_Q','AsyPort','in',parms.Modulation.fm2,parms.DemodPhases.PDa.fm2+90);

% symmetric port probes
opt = addProbeAt(opt,'PDs_DC','SymPort','in',0,0);
opt = addProbeAt(opt,'PDs_fm1_I','SymPort','in',parms.Modulation.fm1,parms.DemodPhases.PDs.fm1);
opt = addProbeAt(opt,'PDs_fm1_Q','SymPort','in',parms.Modulation.fm1,parms.DemodPhases.PDs.fm1+90);
opt = addProbeAt(opt,'PDs_fm2_I','SymPort','in',parms.Modulation.fm2,parms.DemodPhases.PDs.fm2);
opt = addProbeAt(opt,'PDs_fm2_Q','SymPort','in',parms.Modulation.fm2,parms.DemodPhases.PDs.fm2+90);

% x-arm transmission probes
opt = addProbeAt(opt, 'PDxTrans_DC','xArmTrans','in',0,0);
opt = addProbeAt(opt,'PDxTrans_fm1_I','xArmTrans','in',parms.Modulation.fm1,parms.DemodPhases.PDxTrans.fm1);
opt = addProbeAt(opt,'PDxTrans_fm1_Q','xArmTrans','in',parms.Modulation.fm1,parms.DemodPhases.PDxTrans.fm1+90);
opt = addProbeAt(opt,'PDxTrans_fm2_I','xArmTrans','in',parms.Modulation.fm2,parms.DemodPhases.PDxTrans.fm2);
opt = addProbeAt(opt,'PDxTrans_fm2_Q','xArmTrans','in',parms.Modulation.fm2,parms.DemodPhases.PDxTrans.fm2+90);

% y-arm transmission probes
opt = addProbeAt(opt,'PDyTrans_DC','yArmTrans','in',0,0);
opt = addProbeAt(opt,'PDyTrans_fm1_I','yArmTrans','in',parms.Modulation.fm1,parms.DemodPhases.PDyTrans.fm1);
opt = addProbeAt(opt,'PDyTrans_fm1_Q','yArmTrans','in',parms.Modulation.fm1,parms.DemodPhases.PDyTrans.fm1+90);
opt = addProbeAt(opt,'PDyTrans_fm2_I','yArmTrans','in',parms.Modulation.fm2,parms.DemodPhases.PDyTrans.fm2);
opt = addProbeAt(opt,'PDyTrans_fm2_Q','yArmTrans','in',parms.Modulation.fm2,parms.DemodPhases.PDyTrans.fm2+90);

% intra-cavity probes
opt = addProbeIn(opt, 'ACx_DC', 'IMx', 'fr', 0, 0);
opt = addProbeIn(opt, 'ACy_DC', 'IMy', 'fr', 0, 0);


%%
%%%%%%%%%%%%%%%%%%%%%
% offsets
%%%%%%%%%%%%%%%%%%%%%

%@ToDo: dependence of setPosOffset on ndrive for corresp. optic!
%is there an effect for the bs case? ndrive==2?
%
opt = setPosOffset(opt,'IMx', parms.Optics.IMx.phi/360.0*parms.Constants.Lambda0);
opt = setPosOffset(opt,'IMy', parms.Optics.IMy.phi/360.0*parms.Constants.Lambda0);
opt = setPosOffset(opt,'EMx', parms.Optics.EMx.phi/360.0*parms.Constants.Lambda0);
opt = setPosOffset(opt,'EMy', parms.Optics.EMy.phi/360.0*parms.Constants.Lambda0);
opt = setPosOffset(opt,'BS', parms.Optics.BS.phi/360.0*parms.Constants.Lambda0);

