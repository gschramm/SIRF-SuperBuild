#========================================================================
# Author: Benjamin A Thomas
# Author: Kris Thielemans
# Copyright 2017 University College London
#
# This file is part of the CCP PETMR Synergistic Image Reconstruction Framework (SIRF) SuperBuild.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0.txt
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#=========================================================================

#This needs to be unique globally
set(proj ISMRMRD)

# Set dependency list
set(${proj}_DEPENDENCIES "HDF5;Boost;FFTW3")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${proj}_DEPENDENCIES)

# Set external name (same as internal for now)
set(externalProjName ${proj})

set(${proj}_SOURCE_DIR "${SOURCE_ROOT_DIR}/${proj}" )
set(${proj}_BINARY_DIR "${SUPERBUILD_WORK_DIR}/builds/${proj}/build" )
set(${proj}_DOWNLOAD_DIR "${SUPERBUILD_WORK_DIR}/downloads/${proj}" )
set(${proj}_STAMP_DIR "${SUPERBUILD_WORK_DIR}/builds/${proj}/stamp" )
set(${proj}_TMP_DIR "${SUPERBUILD_WORK_DIR}/builds/${proj}/tmp" )

if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")

  ### --- Project specific additions here
  set(ISMRMRD_Install_Dir ${SUPERBUILD_INSTALL_DIR})

  if (NOT WIN32)
    if (USE_SYSTEM_Boost)
      find_package(Boost 1.43 COMPONENTS unit_test_framework)
      if (NOT Boost_UNIT_TEST_FRAMEWORK_FOUND)
        message(STATUS "Boost Unit Test Framework not found. No ISMRMRD tests")
        set(HAVE_ISMRMRD_TEST OFF)
      else()
        set(HAVE_ISMRMRD_TEST ON)
      endif()
    else()
      set(HAVE_ISMRMRD_TEST ON)
    endif()
    if (HAVE_ISMRMRD_TEST)
      # Default to on, as we cannot disable it, and they're quite fast
      option(BUILD_TESTING_${proj} "Build tests for ${proj}" ON)
    endif()
  endif ()

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    GIT_REPOSITORY ${${proj}_URL}
    GIT_TAG ${${proj}_TAG}
    SOURCE_DIR ${${proj}_SOURCE_DIR}
    BINARY_DIR ${${proj}_BINARY_DIR}
    DOWNLOAD_DIR ${${proj}_DOWNLOAD_DIR}
    STAMP_DIR ${${proj}_STAMP_DIR}
    TMP_DIR ${${proj}_TMP_DIR}

    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX=${ISMRMRD_Install_Dir}
      -DCMAKE_PREFIX_PATH=${SUPERBUILD_INSTALL_DIR}
      -DCMAKE_LIBRARY_PATH=${SUPERBUILD_INSTALL_DIR}/lib
      ${HDF5_CMAKE_ARGS}
      -DBOOST_ROOT=${BOOST_ROOT}
    INSTALL_DIR ${ISMRMRD_Install_Dir}
    DEPENDS
        ${${proj}_DEPENDENCIES}
  )

    set(ISMRMRD_DIR        ${ISMRMRD_Install_Dir}/lib/cmake/ISMRMRD)

  if (BUILD_TESTING_${proj})
    add_test(NAME ${proj}_TESTS
         COMMAND ${CMAKE_COMMAND} --build . --config $<CONFIGURATION> --target check
         WORKING_DIRECTORY ${${proj}_BINARY_DIR})
  endif()

  else()
      if(${USE_SYSTEM_${externalProjName}})
        find_package(${proj} ${${externalProjName}_REQUIRED_VERSION} REQUIRED)
        message(STATUS "USING the system ${externalProjName}, set ${externalProjName}_DIR=${${externalProjName}_DIR}")
   endif()
   ExternalProject_Add_Empty(${proj} DEPENDS "${${proj}_DEPENDENCIES}"
    SOURCE_DIR ${${proj}_SOURCE_DIR}
    BINARY_DIR ${${proj}_BINARY_DIR}
    DOWNLOAD_DIR ${${proj}_DOWNLOAD_DIR}
    STAMP_DIR ${${proj}_STAMP_DIR}
    TMP_DIR ${${proj}_TMP_DIR}
   )
  endif()

  mark_as_superbuild(
    VARS
        ${externalProjName}_DIR:PATH
    LABELS
      "FIND_PACKAGE"
  )
