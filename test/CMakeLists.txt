#Test that the testing tools run!
ADD_TEST(NAME SelfTest_verify10 COMMAND verify10)
set_tests_properties(SelfTest_verify10 PROPERTIES PASS_REGULAR_EXPRESSION "Error in verify10 - file 'fort.2[0|1]' was not found\n.*[1|2]")

ADD_TEST(NAME SelfTest_checkf10 COMMAND checkf10)
set_tests_properties(SelfTest_checkf10 PROPERTIES PASS_REGULAR_EXPRESSION "Error in checkf10 - file 'fort.2[0|1]' was not found\n.*[1|2]")

ADD_TEST(NAME SelfTest_compf10 COMMAND compf10)
set_tests_properties(SelfTest_compf10 PROPERTIES PASS_REGULAR_EXPRESSION "Error in compf10 - file 'fort.2[0|1]' was not found\n.*[1|2]")

ADD_TEST(NAME SelfTest_checkf110 COMMAND checkf110)
set_tests_properties(SelfTest_checkf110 PROPERTIES PASS_REGULAR_EXPRESSION "Error in checkf110 - file 'fort.2[0|1]' was not found\n.*[1|2]")

ADD_TEST(NAME SelfTest_checkf1014 COMMAND checkf1014)
set_tests_properties(SelfTest_checkf1014 PROPERTIES PASS_REGULAR_EXPRESSION "Error in checkf1014 - file 'fort.2[0|1]' was not found\n.*[1|2]")

ADD_TEST(NAME SelfTest_read90 COMMAND read90)
set_tests_properties(SelfTest_read90 PROPERTIES PASS_REGULAR_EXPRESSION "Error in read90 - file 'fort.190' was not found; try --help?\n.*19")

ADD_TEST(NAME SelfTest_readDump3 COMMAND readDump3)
set_tests_properties(SelfTest_readDump3 PROPERTIES PASS_REGULAR_EXPRESSION "Expected 2 arguments: inputfile outputfile\n.*3")

ADD_TEST(NAME CheckTestInput_BOINC WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test/ COMMAND ${CMAKE_SOURCE_DIR}/test/CheckTestInputForBOINC.sh)
set_tests_properties(CheckTestInput_BOINC PROPERTIES FAIL_REGULAR_EXPRESSION "ERROR")

ADD_TEST(NAME CheckTestInput_STF WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test/ COMMAND ${CMAKE_SOURCE_DIR}/test/CheckTestInputForSTF.sh $<TARGET_FILE:read90>)
set_tests_properties(CheckTestInput_STF PROPERTIES FAIL_REGULAR_EXPRESSION "ERROR")

##
## Needs checking: thick6dsingles (broken input files -- this test could probably be removed)
## thick6dblocks elensidealthck6d dynk_globalvars thick6ddynk - empty fort.10 (no POST block in fort.3) -- this is OK, we still test the tracking with fort.90 / STF.
##

# List of tests that do not produce a valid fort.10
SET(TESTS_NOFORT10
  orbit6d-element-trombone
  orbit6d-element-quadrupole
  orbit6d-ions
  orbit6d-element-solenoid
  orbit6d-ions-long
  exact
  thick6dblocks
  elensidealthck6d
  dynk_globalvars
  thick6ddynk
  dump_binary
  dump4
  dump5
  dump6
  fileunits_DYNK_DUMP
  rfMultipoles_2ndOrder
  rfMultipoles_3rdOrder
  rfMultipoles_4thOrder
  beam-HO_6D-simple-oldstyle
  beam-HO_6D-simple-newstyle
  beam-HO_6D-simple-newstyle-coupling
  scatter_bbelastic
  geometry
  collimation_k2_fcc_2017_h1_collision
  dump_all_highprec
  dump_2_all_ele_highprec
  beam-HO_6D-simple-newstyle-orbit
  scatter_collimation
)

if(NOT COLLIMAT)
if(LIBARCHIVE)
  SET(SIXTRACK_TESTS elensidealthin6d_DYNK_ZIPF ${SIXTRACK_TESTS})
endif()

if(NAFF)
  SET(SIXTRACK_TESTS fma_naff ${SIXTRACK_TESTS})
endif()

#These tests are always included
SET(SIXTRACK_TESTS
  bbe51
  bbe52
  bbe571ib0
  bb
  bb_ntwin1
  dipedge
  distance
  dynk_globalvars
  elensidealthin4d
  elensidealthin6d
  elensidealthin6d_DYNK
  eric
  exact
  fcc
  frs60
  frs
  javier
  javier_bignpart
  lostevery
  lost
  lostnumxv
  lostnotilt
  notilt
  orbit6d-element-quadrupole
  orbit6d-element-solenoid
  orbit6d-element-trombone
  orbit6d-ions
  orbit6d-ions-long
  prob1
  prob3
  s316
  thick4
  thick6dblocks
  tilt
  elensidealthck4d
  elensidealthck6d
  fma
  fma_binary
  dump7_fma
  dump7_fma_thin4d
  dump8_fma
  dump9
  thick6ddynk
  wire_thck4d
  wire_thck6d
  wire_thin4d
  wire_thin6d
  wire_thin6d_ibeco0
  dump_binary
  dump4
  dump5
  dump6
  fileunits_DYNK_DUMP
  geometry
  elensidealthin6d_DYNK_RANDU
  elensidealthin6d_DYNK_RANDON
  elensidealthin6d_DYNK_ONOFF
  beam-HO_4D-newstyle
  beam-HO_4D-newstyle-loadParticles
  beam-HO_4D-oldstyle
  beam-HO_6D-newstyle
  beam-HO_6D-oldstyle
  beam-HO_6D-simple-oldstyle
  beam-HO_6D-simple-newstyle
  beam-HO_6D-simple-newstyle-orbit
  beam-HO_6D-simple-newstyle-coupling
  beam-HO_LR-newstyle
  beam-HO_LR-oldstyle
  beam-HO_LR-ibbc-oldstyle
  beam-HO_LR-ibbc-newstyle
  rfMultipoles_2ndOrder
  rfMultipoles_3rdOrder
  rfMultipoles_4thOrder
  last_amp
  scatter_bbelastic
  dump_all_highprec
  dump_2_all_ele_highprec
  perf1
  ${SIXTRACK_TESTS}
)
else()
  set(SIXTRACK_TESTS scatter_collimation ${SIXTRACK_TESTS})
endif(NOT COLLIMAT)

# Tests that require SixDA executable
if(SIXDA)
  list(APPEND SIXTRACK_DA_TESTS frs_da thick4_da)
endif()

#Collimation tests (needs backtrk)
#use extra checks on fort.999 and other collimation loss files
if(COLLIMAT AND BACKTRK)
  if(NOT FLUKA OR NOT MERLINSCATTER OR NOT G4COLLIMAT)
    SET(SIXTRACK_TESTS collimation_k2_fcc_2017_h1_collision ${SIXTRACK_TESTS})
  endif(NOT FLUKA OR NOT MERLINSCATTER OR NOT G4COLLIMAT)
  # if(NOT FLUKA OR NOT G4COLLIMAT)
  #   SET(SIXTRACK_TESTS collimation_merlin_fcc_2017_h1_collision ${SIXTRACK_TESTS})
  # endif(NOT FLUKA OR NOT MERLINSCATTER OR NOT G4COLLIMAT)
endif(COLLIMAT AND BACKTRK)

#For CR builds, test the CR functions, so kill/resume the test
if(CR)
  SET(CR_ENABLE 1)
  #Should at least be able to reach the standard TIMEOUT.
  SET(CR_KILL_TIME "2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,16384,16384,16384,16384,16384,16384,16384,16384,16384")
else()
  SET(CR_ENABLE 0)
  SET(CR_KILL_TIME 0)
endif(CR)

#Test commands
foreach(TST IN ITEMS ${SIXTRACK_TESTS})

  #determine what we need to do:

  #Check fort.10 by default
  SET(FORT10 1)
  LIST(FIND TESTS_NOFORT10 ${TST} NO_FORT10)
  if(NOT ${NO_FORT10} MATCHES -1)
    SET(FORT10 0)
  else()
    SET(FORT10 1)
  endif()

  #if STF, we need to use the STF flag on read90, and disable checking fort.90
  if(STF)
    SET(STF_ENABLE 1)
    SET(FORT90 0)
  else()
    SET(STF_ENABLE 0)
    SET(FORT90 1)
  endif(STF)

  if(LIBARCHIVE)
    if(TST MATCHES elensidealthin6d_DYNK_ZIPF)
      SET(SIXOUT_NUMFILES 6)
    else()
      SET(SIXOUT_NUMFILES 0)
    endif()
  else()
    SET(SIXOUT_NUMFILES 0)
  endif(LIBARCHIVE)

  SET( DUMP_BIN_FILE NONE )
  if(TST MATCHES dump_binary)
    SET( DUMP_BIN_FILE dump.dat,dumpStart.dat )
  elseif(TST MATCHES fma_binary)
    SET( DUMP_BIN_FILE START_DUMP_1,IP2_DUMP_1,IP2_DUMP_2,IP2_DUMP_3,IP3_DUMP_1,IP3_DUMP_2,IP3_DUMP_3 )
  elseif(TST MATCHES dump7_fma)
    SET( DUMP_BIN_FILE IP3_DUMP_1 )
  elseif(TST MATCHES dump8_fma)
    SET( DUMP_BIN_FILE START_DUMP_1,IP3_DUMP_1 )
  elseif(TST MATCHES dump7_fma_thin4d)
    SET( DUMP_BIN_FILE dump_ip3 )
  endif()

  ADD_TEST(
    NAME ${TST} WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test/${TST}
    COMMAND SixTestWrapper $<TARGET_FILE:SixTrackCR> $<TARGET_FILE:checkf10> $<TARGET_FILE:read90> ${FORT10} ${FORT90} ${STF_ENABLE} ${SIXOUT_NUMFILES} ${CR_ENABLE} ${CR_KILL_TIME} $<TARGET_FILE:readDump3> ${DUMP_BIN_FILE}
  )

  #some tests take a very long time (set a 2 day timeout)
  set_tests_properties(${TST} PROPERTIES TIMEOUT "172800")

endforeach()

# DA Tests
if(SIXDA)
  foreach(TST IN ITEMS ${SIXTRACK_DA_TESTS})

    SET(FORT10 0)
    SET(FORT90 0)
    SET(STF_ENABLE 0)
    SET(SIXOUT_NUMFILES 0)
    SET(CR_ENABLE 0)
    SET(CR_KILL_TIME 0)
    SET(DUMP_BIN_FILE NONE)

    ADD_TEST(
      NAME ${TST} WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test/${TST}
      COMMAND SixTestWrapper $<TARGET_FILE:SixTrackDA> $<TARGET_FILE:checkf10> $<TARGET_FILE:read90> ${FORT10} ${FORT90} ${STF_ENABLE} ${SIXOUT_NUMFILES} ${CR_ENABLE} ${CR_KILL_TIME} $<TARGET_FILE:readDump3> ${DUMP_BIN_FILE}
    )

    #some tests take a very long time (set a 2 day timeout)
    set_tests_properties(${TST} PROPERTIES TIMEOUT "172800")

  endforeach()
endif()

#test files
foreach(TST IN ITEMS ${SIXTRACK_TESTS} ${SIXTRACK_DA_TESTS})
  add_custom_target(test_copy_${TST})
  add_custom_command(TARGET test_copy_${TST} POST_BUILD COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/test/${TST}/)

  file(GLOB TEST_INPUTS LIST_DIRECTORIES FALSE ${CMAKE_SOURCE_DIR}/test/${TST}/*)
  #message(STATUS "${CMAKE_SOURCE_DIR}/../test/${TST}/")

  if(NOT BOINC)
    foreach(TSFILE IN ITEMS ${TEST_INPUTS})
      get_filename_component(TFILE ${TSFILE} NAME)

      if(NOT WIN32)
        #create_symlink old new
        add_custom_command(TARGET test_copy_${TST} POST_BUILD COMMAND ${CMAKE_COMMAND} -E create_symlink ${TSFILE} ${CMAKE_BINARY_DIR}/test/${TST}/${TFILE})
      else()
        add_custom_command(TARGET test_copy_${TST} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy ${TSFILE} ${CMAKE_BINARY_DIR}/test/${TST}/${TFILE})
      endif()
    endforeach()
  else()
    if(NOT WIN32)
      add_custom_command(TARGET test_copy_${TST} POST_BUILD COMMAND ${CMAKE_COMMAND} -E create_symlink ${CMAKE_SOURCE_DIR}/test/${TST}/Sixin.zip ${CMAKE_BINARY_DIR}/test/${TST}/Sixin.zip)
    else()
      add_custom_command(TARGET test_copy_${TST} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/test/${TST}/Sixin.zip ${CMAKE_BINARY_DIR}/test/${TST}/Sixin.zip)
    endif()

    #Also need the canonicals
    file(GLOB TEST_INPUT_CANONICAL LIST_DIRECTORIES FALSE ${CMAKE_SOURCE_DIR}/test/${TST}/*canonical)
    foreach(CANONICAL_FILES IN ITEMS ${TEST_INPUT_CANONICAL})
      get_filename_component(CANONICAL_FILE ${CANONICAL_FILES} NAME)
      if(NOT WIN32)
        add_custom_command(TARGET test_copy_${TST} POST_BUILD COMMAND ${CMAKE_COMMAND} -E create_symlink ${CANONICAL_FILES} ${CMAKE_BINARY_DIR}/test/${TST}/${CANONICAL_FILE})
      else()
        add_custom_command(TARGET test_copy_${TST} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy ${CANONICAL_FILES} ${CMAKE_BINARY_DIR}/test/${TST}/${CANONICAL_FILE})
      endif()
    endforeach()

    #And extra_checks.txt
    file(GLOB TEST_INPUT_EXTRAS LIST_DIRECTORIES FALSE ${CMAKE_SOURCE_DIR}/test/${TST}/extra_checks.txt)
    foreach(EXTRA_FILES IN ITEMS ${TEST_INPUT_EXTRAS})
      get_filename_component(EXTRA_FILE ${EXTRA_FILES} NAME)
      if(NOT WIN32)
        add_custom_command(TARGET test_copy_${TST} POST_BUILD COMMAND ${CMAKE_COMMAND} -E create_symlink ${EXTRA_FILES} ${CMAKE_BINARY_DIR}/test/${TST}/${EXTRA_FILE})
      else()
        add_custom_command(TARGET test_copy_${TST} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy ${EXTRA_FILES} ${CMAKE_BINARY_DIR}/test/${TST}/${EXTRA_FILE})
      endif()
    endforeach()

  endif(NOT BOINC)

  add_dependencies( SixTrackLib test_copy_${TST})
endforeach()

#add labels to tests
#Lets say fast tests take <60 seconds to run
SET(FAST_TESTS
  orbit6d-element-quadrupole
  orbit6d-element-solenoid
  thick4
  thick6dblocks
  thick6ddynk
  exact
  javier
  bb
  bb_ntwin1
  notilt
  lost
  lostnotilt
  lostnumxv
  s316
  dipedge
  dynk_globalvars
  elensidealthin4d
  elensidealthck4d
  elensidealthck6d
  elensidealthin6d
  elensidealthin6d_DYNK
  elensidealthin6d_DYNK_ZIPF
  wire_thck4d
  wire_thck6d
  wire_thin4d
  wire_thin6d
  wire_thin6d_ibeco0
  dump_binary
  dump4
  dump5
  dump6
  dump7_fma
  dump7_fma_thin4d
  dump8_fma
  dump9
  fileunits_DYNK_DUMP
  geometry
  fcc
  elensidealthin6d_DYNK_RANDU
  elensidealthin6d_DYNK_RANDON
  elensidealthin6d_DYNK_ONOFF
  beam-HO_4D-newstyle
  beam-HO_4D-newstyle-loadParticles
  beam-HO_4D-oldstyle
  beam-HO_6D-newstyle
  beam-HO_6D-oldstyle
  beam-HO_LR-newstyle
  beam-HO_LR-oldstyle
  beam-HO_6D-simple-newstyle
  beam-HO_6D-simple-oldstyle
  beam-HO_6D-simple-newstyle-coupling
  beam-HO_LR-ibbc-oldstyle
  beam-HO_LR-ibbc-newstyle
  rfMultipoles_2ndOrder
  rfMultipoles_3rdOrder
  rfMultipoles_4thOrder
  last_amp
  scatter_bbelastic
  dump_all_highprec
  dump_2_all_ele_highprec
  orbit6d-element-trombone
  orbit6d-ions
  beam-HO_6D-simple-newstyle-orbit
)
if(SIXDA)
  list(APPEND FAST_TESTS thick4_da frs_da)
endif()

#Medium tests take < 30 mins to run
SET(MEDIUM_TESTS
  bbe571ib0
  tilt
  lostevery
  fma
  fma_binary
  fma_naff
  frs
  frs60
  eric
  distance
  bbe51
  bbe52
  javier_bignpart
  collimation_k2_fcc_2017_h1_collision
  orbit6d-ions-long
)

#Slow is everything longer
SET(SLOW_TESTS
  prob1
  prob3
)

#Performance test
SET(PERF_TESTS
  perf1
)

foreach(TST IN ITEMS ${SIXTRACK_TESTS} ${SIXTRACK_DA_TESTS})

  list(FIND FAST_TESTS ${TST} LABEL_FAST)
  list(FIND MEDIUM_TESTS ${TST} LABEL_MEDIUM)
  list(FIND SLOW_TESTS ${TST} LABEL_SLOW)
  list(FIND PERF_TESTS ${TST} LABEL_PERF)

  if(${LABEL_FAST} GREATER -1)
    set_property(TEST ${TST} PROPERTY LABELS fast)
  elseif(${LABEL_MEDIUM} GREATER -1)
    set_property(TEST ${TST} PROPERTY LABELS medium)
  elseif(${LABEL_SLOW} GREATER -1)
    set_property(TEST ${TST} PROPERTY LABELS slow)
  elseif(${LABEL_PERF} GREATER -1)
    set_property(TEST ${TST} PROPERTY LABELS perf)
  else()
    message(STATUS "TEST ${TST} needs a label setting!")
    set_property(TEST ${TST} PROPERTY LABELS NeedsLabel)
  endif()
endforeach()

#Tools
SET(SELFTEST_TOOLS
  SelfTest_verify10
  SelfTest_compf10
  SelfTest_checkf1014
  SelfTest_checkf10
  SelfTest_checkf110
  SelfTest_read90
  SelfTest_readDump3
)
foreach(TOOL IN ITEMS ${SELFTEST_TOOLS})
  set_property(TEST ${TOOL} PROPERTY LABELS tool fast)
endforeach()

#Inputs
SET(SELFTEST_INPUT
  CheckTestInput_BOINC
  CheckTestInput_STF
)
foreach(TOOL IN ITEMS ${SELFTEST_INPUT})
  set_property(TEST ${TOOL} PROPERTY LABELS input fast)
endforeach()