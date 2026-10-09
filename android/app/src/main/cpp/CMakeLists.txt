cmake_minimum_required(VERSION 3.22.1)
project("motionf_engine" CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Optimization flags for mobile ARM architectures
add_compile_options(-O3 -fPIC -Wall -Wextra -ffast-math)

# If compiling for ARM, enable NEON SIMD
if(ANDROID_ABI MATCHES "^arm")
    add_compile_options(-mfpu=neon)
endif()

add_library(
    motionf_engine
    SHARED
    jni_bridge.cpp
)

find_library(log-lib log)
find_library(android-lib android)
find_library(gles3-lib GLESv3)
find_library(egl-lib EGL)

target_include_directories(
    motionf_engine
    PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(
    motionf_engine
    ${log-lib}
    ${android-lib}
    ${gles3-lib}
    ${egl-lib}
)
