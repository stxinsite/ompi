cmake_minimum_required(VERSION 3.7.2)
include(CTest)
enable_testing()

add_custom_target(my_custom_target ALL
   COMMENT "build cudaAware-OpenMPI"
   COMMAND ./run_buildInstall.sh
    VERBATIM
)

add_test(
    NAME NoTests
    COMMAND echo "No Tests!"
)
