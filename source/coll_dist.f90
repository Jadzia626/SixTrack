! ================================================================================================ !
!  Dist Module for Collimation
!  Extracted from collimation module
! ================================================================================================ !
module coll_dist

  use parpro
  use floatPrecision
  use numerical_constants

  implicit none

  ! Other Settings
  integer,                  public,  save :: cdist_logUnit  = -1
  real(kind=fPrec),         public,  save :: cdist_energy   = zero

  ! Twiss
  real(kind=fPrec),         public,  save :: cdist_alphaX   = zero
  real(kind=fPrec),         public,  save :: cdist_alphaY   = zero
  real(kind=fPrec),         public,  save :: cdist_betaX    = zero
  real(kind=fPrec),         public,  save :: cdist_betaY    = zero
  real(kind=fPrec),         public,  save :: cdist_emitX    = zero
  real(kind=fPrec),         public,  save :: cdist_emitY    = zero

  ! Distribution Settings
  real(kind=fPrec),         public,  save :: cdist_ampX     = zero
  real(kind=fPrec),         public,  save :: cdist_ampY     = zero
  real(kind=fPrec),         public,  save :: cdist_ampR     = zero
  real(kind=fPrec),         public,  save :: cdist_smearX   = zero
  real(kind=fPrec),         public,  save :: cdist_smearY   = zero
  real(kind=fPrec),         public,  save :: cdist_smearR   = zero
  real(kind=fPrec),         public,  save :: cdist_spreadE  = zero
  real(kind=fPrec),         public,  save :: cdist_bunchLen = zero

  character(len=mFileName), public,  save :: cdist_fileName = " "

contains

! ================================================================================================ !
!  V.K. Berglyd Olsen, BE-ABP-HSS
!  Created: 2019-03-26
!  Updated: 2019-04-16
!  Generate the distribution in the correct order, based on the distFormat flag
! ================================================================================================ !
subroutine cdist_makeDist(distFormat)

  use crcoall

  integer, intent(in) :: distFormat

  select case(distFormat)
  case(0)
    return
  case(1)
    call cdist_makeDist_fmt1
  case(2)
    call cdist_makeDist_fmt1
    call cdist_makeDist_fmt2
  case(3)
    call cdist_makeDist_fmt1
    call cdist_makeDist_fmt2
    call cdist_makeDist_fmt3
  case(4)
    call cdist_makeDist_fmt4
  case(5)
    call cdist_makeDist_fmt3
    call cdist_makeDist_fmt5
  case(6)
    call cdist_makeDist_fmt4
    call cdist_makeDist_fmt6
  case default
    write(lerr,"(a)") "COLLDIST> ERROR Unknown distribution format. Valid is 0 to 6, got ",distFormat
    call prror
  end select

end subroutine cdist_makeDist

! ================================================================================================ !
!  V.K. Berglyd Olsen, BE-ABP-HSS
!  Created: 2019-04-16
!  Updated: 2019-04-16
!  The radial format is just format 1 with a different set of parameters
! ================================================================================================ !
subroutine cdist_makeRadial

  real(kind=fPrec) tmpVal(4)

  tmpVal(1)    = cdist_ampX
  tmpVal(2)    = cdist_ampY
  tmpVal(3)    = cdist_smearX
  tmpVal(4)    = cdist_smearY

  cdist_ampX   = cdist_ampR/sqrt(two)
  cdist_ampY   = cdist_ampR/sqrt(two)
  cdist_smearX = cdist_smearR/sqrt(two)
  cdist_smearY = cdist_smearR/sqrt(two)

  call cdist_makeDist_fmt1

  cdist_ampX   = tmpVal(1)
  cdist_ampY   = tmpVal(2)
  cdist_smearX = tmpVal(3)
  cdist_smearY = tmpVal(4)

end subroutine cdist_makeRadial

! ================================================================================================ !
!  Generation of Distribution Format 1
!  This routine generates particles in phase space X/XP and Y/YP ellipses, as defined in the input
!  parameters. Distribution is flat in the band. X and Y are fully uncorrelated.
! ================================================================================================ !
subroutine cdist_makeDist_fmt1

  use crcoall
  use mod_ranlux
  use mathlib_bouncer
  use mod_common, only : napx
  use mod_common_main, only : xv1, xv2, yv1, yv2, ejv, sigmv

  real(kind=fPrec) :: emitX, emitY, sigmaX, sigmaY
  integer          :: j

  if(cdist_ampX > zero) then
    do j=1, napx
      emitX  = cdist_emitX*(cdist_ampX + ((two*(rndm4()-half))*cdist_smearX))**2
      sigmaX = sqrt(cdist_betaX*emitX)
      xv1(j) = sigmaX * sin_mb(twopi*rndm4())
      if(rndm4() > half) then
        yv1(j) = sqrt(emitX/cdist_betaX-xv1(j)**2/cdist_betaX**2)-(cdist_alphaX*xv1(j))/cdist_betaX
      else
        yv1(j) = -one*sqrt(emitX/cdist_betaX-xv1(j)**2/cdist_betaX**2)-(cdist_alphaX*xv1(j))/cdist_betaX
      end if
    end do
  else
    xv1(:) = zero
    yv1(:) = zero
  end if

  if(cdist_ampY > zero) then
    do j=1, napx
      emitY  = cdist_emitY*(cdist_ampY + ((two*(rndm4()-half))*cdist_smearY))**2
      sigmaY = sqrt(cdist_betaY*emitY)
      xv2(j) = sigmaY * sin_mb(twopi*rndm4())
      if(rndm4() > half) then
        yv2(j) = sqrt(emitY/cdist_betaY-xv2(j)**2/cdist_betaY**2)-(cdist_alphaY*xv2(j))/cdist_betaY
      else
        yv2(j) = -one*sqrt(emitY/cdist_betaY-xv2(j)**2/cdist_betaY**2)-(cdist_alphaY*xv2(j))/cdist_betaY
      end if
    end do
  else
    xv2(:) = zero
    yv2(:) = zero
  end if

  ejv(:)   = cdist_energy
  sigmv(:) = zero

end subroutine cdist_makeDist_fmt1

! ================================================================================================ !
!  Generation of Distribution Format 2
!  Uses format 1, and generates the transverse beam size in the direction set to zero in fort.3
!  Written by:   S. Redaelli, 2005-05-08
!  Rewritten by: V.K. Berglyd Olsen, 2019-03-26
! ================================================================================================ !
subroutine cdist_makeDist_fmt2

  use crcoall
  use mathlib_bouncer
  use mod_ranlux
  use mod_common, only : napx
  use mod_common_main, only : xv1, xv2, yv1, yv2, ejv, sigmv

  real(kind=fPrec) :: iiX, iiY, phiX, phiY
  integer          :: j

  if(cdist_ampX > zero .and. cdist_ampY > zero) then
    write(lerr,"(a)") "COLLDIST> ERROR Distribution parameters for format 2 are incorrectly set."
    write(lerr,"(a)") "COLLDIST>       Both X and Y amplitude is larger than zero. Use format 1 instead."
    call prror
  end if

  if(cdist_ampX < pieni) then
    do j=1,napx
      phiX   = twopi*rndm4()
      iiX    = (-one*cdist_emitX) * log_mb(rndm4())
      xv1(j) = sqrt((two*iiX)*cdist_betaX) * cos_mb(phiX)
      yv1(j) = (-one*sqrt((two*iiX)/cdist_betaX)) * (sin_mb(phiX) + cdist_alphaX * cos_mb(phiX))
    end do
  end if

  if(cdist_ampY < pieni) then
    do j=1,napx
      phiY   = twopi*rndm4()
      iiY    = (-one*cdist_emitY) * log_mb(rndm4())
      xv2(j) = sqrt((two*iiY)*cdist_betaY) * cos_mb(phiY)
      yv2(j) = (-one*sqrt((two*iiY)/cdist_betaY)) * (sin_mb(phiY) + cdist_alphaY * cos_mb(phiY))
    end do
  end if

end subroutine cdist_makeDist_fmt2

! ================================================================================================ !
!  Generation of Distribution Format 3
!  Uses format 2, and adds the energy spread and the finite bunch length. (Gaussian assumed)
!  Written by:   S. Redaelli, 2005-05-09
!  Rewritten by: V.K. Berglyd Olsen, 2019-03-26
! ================================================================================================ !
subroutine cdist_makeDist_fmt3

  use crcoall
  use mathlib_bouncer
  use mod_ranlux
  use mod_common, only : napx
  use mod_common_main, only : xv1, xv2, yv1, yv2, ejv, sigmv

  real(kind=fPrec) :: long_cut, a_st, b_st
  integer          :: j

  ! For longitudinal phase-space, add a cut at 2 sigma
  long_cut = 2

  do j=1,napx
    ! 1st: Generate napx numbers within the chosen cut
    a_st = ran_gauss(five)
    b_st = ran_gauss(five)

    do while ((a_st**2 + b_st**2) > long_cut**2)
      a_st = ran_gauss(five)
      b_st = ran_gauss(five)
    end do

    ! 2nd: give the correct values
    ejv(j)   = cdist_energy * (one + b_st*cdist_spreadE)
    sigmv(j) = cdist_bunchLen*a_st
  end do

end subroutine cdist_makeDist_fmt3

! ================================================================================================ !
!  Generation of Distribution Format 4 (Read File)
!  Written by:   S. Redaelli, 2005-05-09
!  Rewritten by: V.K. Berglyd Olsen, 2019-03-26
!  File format: x[m], xp[rad], y[m], yp[rad], s[mm], dE [MeV]
! ================================================================================================ !
subroutine cdist_makeDist_fmt4

  use crcoall
  use parpro
  use mod_units
  use string_tools
  use mod_common, only : napx
  use mod_common_main, only : xv1, xv2, yv1, yv2, ejv, sigmv

  integer :: j, inUnit

  character(len=mInputLn) inLine
  character(len=:), allocatable :: lnSplit(:)
  integer nSplit
  logical spErr, fErr

  write(lout,"(a)") "COLLDIST> Reading input distributions from file '"//trim(cdist_fileName)//"'"

  fErr  = .false.
  spErr = .false.
  call f_requestUnit(cdist_fileName, inUnit)
  call f_open(unit=inUnit,file=cdist_fileName,formatted=.true.,mode="r",err=fErr,status="old")
  if(fErr) then
    write(lerr,"(a)") "COLLDIST> ERROR Could not read file '"//trim(cdist_fileName)//"'"
    call prror
  end if

  do j=1,napx
    read(inUnit,"(a)",end=10,err=20) inLine
    call chr_split(inLine, lnSplit, nSplit, spErr)
    if(spErr) then
      write(lerr,"(a)") "COLLDIST> ERROR Failed to parse input line from particle distribution file."
      call prror
    end if
    if(nSplit /= 6) then
      write(lerr,"(a)") "COLLDIST> ERROR Expected 6 values per line in particle distribution file."
      call prror
    end if
    call chr_cast(lnSplit(1),xv1(j),  spErr)
    call chr_cast(lnSplit(2),yv1(j),  spErr)
    call chr_cast(lnSplit(3),xv2(j),  spErr)
    call chr_cast(lnSplit(4),yv2(j),  spErr)
    call chr_cast(lnSplit(5),sigmv(j),spErr)
    call chr_cast(lnSplit(6),ejv(j),  spErr)
    if(spErr) then
      write(lerr,"(a)") "COLLDIST> ERROR Failed to parse value from particle distribution file."
      call prror
    end if
  end do
  call f_close(inUnit)
  write(lerr,"(a,i0)") "COLLDIST> Number of particles read from the file is ",napx

  return

10 continue
  write(lerr,"(a,i0,a)") "COLLDIST> ERROR Dsitribution file contained less than ",napx," particles"
  call prror
  return

20 continue
  write(lerr,"(a)") "COLLDIST> ERROR Could not read file '"//trim(cdist_fileName)//"'"
  call prror

end subroutine cdist_makeDist_fmt4

! ================================================================================================ !
!  Generation of Distribution Format 5
!  Written by:   J. Barranco, 2009-08-06
!  Rewritten by: V.K. Berglyd Olsen, 2019-03-26
!  Radial transverse distribution of radius Ar
! ================================================================================================ !
subroutine cdist_makeDist_fmt5

  use crcoall
  use parpro
  use mod_ranlux
  use mod_common, only : napx
  use mod_common_main, only : xv1, xv2, yv1, yv2, ejv, sigmv

  real(kind=fPrec) :: emitX, emitY, sigmaX, sigmaY
  integer          :: j

  do j=1, napx
    emitX  = cdist_emitX
    sigmaX = sqrt(cdist_betaX*emitX)
    xv1(j) = sigmaX*ran_gauss(cdist_ampX)
    yv1(j) = ran_gauss(cdist_ampX)*sqrt(emitX/cdist_betaX)-((cdist_alphaX*xv1(j))/cdist_betaX)

    emitY  = cdist_emitY
    sigmaY = sqrt(cdist_betaY*emitY)
    xv2(j) = sigmaY*ran_gauss(cdist_ampY)
    yv2(j) = ran_gauss(cdist_ampY)*sqrt(emitY/cdist_betaY)-((cdist_alphaY*xv2(j))/cdist_betaY)
  end do

#ifdef BEAMGAS
  xv1(1)   = zero
  xv2(1)   = zero
  yv1(1)   = zero
  yv2(1)   = zero
  ejv(1)   = cdist_energy
  sigmv(1) = zero
#endif

end subroutine cdist_makeDist_fmt5

! ================================================================================================ !
!  Generation of Distribution Format 6 (Read File)
!  Rewritten by: V.K. Berglyd Olsen, 2019-03-26
!  A normalized distribution with x,xp,y,yp,z,zp is read and transformed with the TAS matrix T,
!  which is the transformation matrix from normalized to physical coordinates. It is scaled with
!  the geometric emittances in diag matrix S. x = T*S*normx
!  Units of TAS matrix # m,rad,m,rad,m,1
!  The collimation coordinates/units are x[m], x'[rad], y[m], y'[rad]$, sig[mm], dE [MeV].
! ================================================================================================ !
subroutine cdist_makeDist_fmt6

  use crcoall
  use parpro
  use mod_common, only : napx, iclo6
  use mod_common_main, only : xv1, xv2, yv1, yv2, ejv, sigmv, tas, clop6v

  real(kind=fPrec) :: tmpX, tmpY, tmpXP, tmpYP, tmpS, tmpE
  real(kind=fPrec) :: emitX, emitY, emitZ
  integer          :: j

  if(iclo6 == 0) then
    write(lerr,"(a)") "COLLDIST> ERROR The 6D closed orbit (iclo6 > 0) is required for format 6."
    call prror
  endif

  emitX = cdist_emitX
  emitY = cdist_emitY
  emitZ = cdist_bunchLen*c1m3 * cdist_spreadE

  do j=1,napx

    tmpX = &
      xv1(j)   * sqrt(emitX)*tas(1,1) + &
      yv1(j)   * sqrt(emitX)*tas(1,2) + &
      xv2(j)   * sqrt(emitY)*tas(1,3) + &
      yv2(j)   * sqrt(emitY)*tas(1,4) + &
      sigmv(j) * sqrt(emitZ)*tas(1,5) + &
      ejv(j)   * sqrt(emitZ)*tas(1,6) * c1m3

    tmpXP = &
      xv1(j)   * sqrt(emitX)*tas(2,1) + &
      yv1(j)   * sqrt(emitX)*tas(2,2) + &
      xv2(j)   * sqrt(emitY)*tas(2,3) + &
      yv2(j)   * sqrt(emitY)*tas(2,4) + &
      sigmv(j) * sqrt(emitZ)*tas(2,5) + &
      ejv(j)   * sqrt(emitZ)*tas(2,6) * c1m3

    tmpY = &
      xv1(j)   * sqrt(emitX)*tas(3,1) + &
      yv1(j)   * sqrt(emitX)*tas(3,2) + &
      xv2(j)   * sqrt(emitY)*tas(3,3) + &
      yv2(j)   * sqrt(emitY)*tas(3,4) + &
      sigmv(j) * sqrt(emitZ)*tas(3,5) + &
      ejv(j)   * sqrt(emitZ)*tas(3,6) * c1m3

    tmpYP = &
      xv1(j)   * sqrt(emitX)*tas(4,1) + &
      yv1(j)   * sqrt(emitX)*tas(4,2) + &
      xv2(j)   * sqrt(emitY)*tas(4,3) + &
      yv2(j)   * sqrt(emitY)*tas(4,4) + &
      sigmv(j) * sqrt(emitZ)*tas(4,5) + &
      ejv(j)   * sqrt(emitZ)*tas(4,6) * c1m3

    tmpS = &
      xv1(j)   * sqrt(emitX)*tas(5,1) + &
      yv1(j)   * sqrt(emitX)*tas(5,2) + &
      xv2(j)   * sqrt(emitY)*tas(5,3) + &
      yv2(j)   * sqrt(emitY)*tas(5,4) + &
      sigmv(j) * sqrt(emitZ)*tas(5,5) + &
      ejv(j)   * sqrt(emitZ)*tas(5,6) * c1m3

    tmpE = &
      xv1(j)   * sqrt(emitX)*tas(6,1)*c1e3 + &
      yv1(j)   * sqrt(emitX)*tas(6,2)*c1e3 + &
      xv2(j)   * sqrt(emitY)*tas(6,3)*c1e3 + &
      yv2(j)   * sqrt(emitY)*tas(6,4)*c1e3 + &
      sigmv(j) * sqrt(emitZ)*tas(6,5)*c1e3 + &
      ejv(j)   * sqrt(emitZ)*tas(6,6)

    ! Add the momentum, convert to canonical variables dE/E with unit [1] from the closed orbit is added
    ! For the 4D coordinates the closed orbit will be added by SixTrack itself later on.
    xv1(j)   = tmpX
    xv2(j)   = tmpY
    yv1(j)   = tmpXP*(one+tmpE+clop6v(3))
    yv2(j)   = tmpYP*(one+tmpE+clop6v(3))
    sigmv(j) = tmpS*c1e3
    ejv(j)   = cdist_energy*(one+tmpE)

  end do

end subroutine cdist_makeDist_fmt6

end module coll_dist
