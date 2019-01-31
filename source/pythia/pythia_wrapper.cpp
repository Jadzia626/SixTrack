/*
*  SixTrack Wrapper for Pythia8
*  V.K. Berglyd Olsen, BE-ABP-HSS
*  Last modified: 2018-07-30
*/

#include "pythia_wrapper.h"

using namespace Pythia8;

extern "C" {

bool pythiaWrapper_init() {
  if(!pythia.init()) return false;
  pythia.settings.writeFile("pythia_settings.dat", true);
  std::cout << "PYTHIA> Done" << std::endl;
  return true;
}

bool pythiaWrapper_defaults() {
  std::cout << "PYTHIA> Setting defaults" << std::endl;
  pythia.settings.flag("Init:showChangedSettings", true);
  pythia.settings.flag("Init:showChangedParticleData", false);
  pythia.settings.flag("SigmaTotal:mode", 3);
  pythia.settings.flag("SigmaDiffractive:mode", 3);
  return true;
}

void pythiaWrapper_setProcess(bool sEL, bool sSD, bool sDD, bool sCD, bool sND) {
  std::cout << "PYTHIA> Setting processes" << std::endl;
  pythia.settings.flag("SoftQCD:elastic", sEL);
  pythia.settings.flag("SoftQCD:singleDiffractive", sSD);
  pythia.settings.flag("SoftQCD:doubleDiffractive", sDD);
  pythia.settings.flag("SoftQCD:centralDiffractive", sCD);
  pythia.settings.flag("SoftQCD:nonDiffractive", sND);
}

void pythiaWrapper_setCoulomb(bool sCMB, double tAbsMin) {
  pythia.settings.flag("SigmaElastic:Coulomb", sCMB);
  pythia.settings.parm("SigmaElastic:tAbsMin", tAbsMin);
}

void pythiaWrapper_setSeed(int rndSeed) {
  std::cout << "PYTHIA> Setting random seed" << std::endl;
  pythia.settings.mode("Random:seed", rndSeed);
}

void pythiaWrapper_setBeam(int frameType, int idA, int idB, double eA, double eB) {
  std::cout << "PYTHIA> Setting beam parameters" << std::endl;
  pythia.settings.mode("Beams:frameType", frameType);
  pythia.settings.mode("Beams:idA", idA);
  pythia.settings.mode("Beams:idB", idB);
  pythia.settings.parm("Beams:eA", eA);
  pythia.settings.parm("Beams:eB", eB);
}

void pythiaWrapper_readFile(char* fileName) {
  std::cout << "PYTHIA> Loading settings from external file" << std::endl;
  pythia.readFile(std::string(fileName));
}

void pythiaWrapper_getCrossSection(double& sigTot, double& sigEl) {
  // sigTot = pythia.info.sigmaGen(0);
  sigTot = pythia.parm("SigmaTotal:sigmaTot");
  sigEl  = pythia.parm("SigmaTotal:sigmaEl");
}

void pythiaWrapper_getEvent(bool& status, int& code, double& t, double& theta, double& dEE, double& dPP) {
  status = pythia.next();
  code   = pythia.info.code();
  if(!status) {
    code  = 0;
    t     = 0.0;
    theta = 0.0;
    dEE   = 0.0;
    dPP   = 0.0;
    return;
  }
  if(code == 101) {
    t     = 0.0;
    theta = 0.0;
    dEE   = 0.0;
    dPP   = 0.0;
  }
  else if(code == 102) { // Elastic
    t     =  pythia.info.tHat();
    theta =  pythia.event[3].theta();
    dEE   = (pythia.event[3].e()    - pythia.event[1].e())    / pythia.event[1].e();
    dPP   = (pythia.event[3].pAbs() - pythia.event[1].pAbs()) / pythia.event[1].pAbs();
  }
  else if(code == 104) { // Single Diffractive AB->AX
    t     =  pythia.info.tHat();
    theta =  pythia.event[3].theta();
    dEE   = (pythia.event[3].e()    - pythia.event[1].e())    / pythia.event[1].e();
    dPP   = (pythia.event[3].pAbs() - pythia.event[1].pAbs()) / pythia.event[1].pAbs();
  }
  else if(code == 106) { // Central Diffractive AB->AXB
    t     = (pythia.event[3].p()    - pythia.event[1].p()).m2Calc();
    theta =  pythia.event[3].theta();
    dEE   = (pythia.event[3].e()    - pythia.event[1].e())    / pythia.event[1].e();
    dPP   = (pythia.event[3].pAbs() - pythia.event[1].pAbs()) / pythia.event[1].pAbs();
  }
  else {
    t     = 0.0;
    theta = 0.0;
    dEE   = 0.0;
    dPP   = 0.0;
  }
}

}