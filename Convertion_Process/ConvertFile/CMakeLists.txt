
cmake_minimum_required(VERSION 2.8)

PROJECT(ConvertFile)

find_package(VTK REQUIRED)
include(${VTK_USE_FILE})

add_executable(ConvertFile MACOSX_BUNDLE ConvertFile)

if(VTK_LIBRARIES)
  target_link_libraries(ConvertFile ${VTK_LIBRARIES})
else()
  target_link_libraries(ConvertFile vtkHybrid vtkWidgets)
endif()
