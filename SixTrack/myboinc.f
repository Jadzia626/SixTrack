!     program maincr
!     call worker()
!     end
      subroutine boinc_time_to_checkpoint(timech)
      implicit none
      integer timech
      timech=1
      end
      subroutine boincrf(myname,filename)
      implicit none
      character*(*) myname
      character*256 filename 
      filename=myname
      end
      subroutine boinc_finish(flag)
      implicit none
      integer flag
      end
      subroutine boinc_fraction_done(f)
      implicit none
      double precision f
      end
      subroutine boinc_init()
      implicit none
      end
!     subroutine boinc_init_graphics
!     implicit none
!     end
!     subroutine sixtrack_unzip
!     implicit none
!     end
!     subroutine graphic_progress(n,numl)
!     implicit none
!     integer n,numl
!     end
      subroutine boinc_checkpoint_completed
      implicit none
      end
!     subroutine boinc_finish_graphics
!     implicit none
!     end
      subroutine boinc_zip(mode,zipfile,path)
      implicit none
      integer mode
      character*(*) zipfile,path
      end
