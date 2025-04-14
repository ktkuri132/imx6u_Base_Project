# 基于 STM32 的 CMakeLists 模板转换，适配 i.MX6ULL (Cortex-A7)
# 原 Makefile 转换，目标芯片: i.MX6ULL (Cortex-A7)
# 若有疑问请联系: 3457532883@qq.com

cmake_minimum_required(VERSION 3.22)

# 设置交叉编译工具链前缀
set(PREFIX arm-linux-gnueabihf-)
# 配置系统为通用嵌入式系统
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR cortex-a7)

# 设置交叉编译工具链
set(CMAKE_C_COMPILER ${PREFIX}gcc)
set(CMAKE_CXX_COMPILER ${PREFIX}g++)
set(CMAKE_ASM_COMPILER ${PREFIX}gcc)
set(CMAKE_AR ${PREFIX}ar)
set(CMAKE_OBJCOPY ${PREFIX}objcopy)
set(CMAKE_OBJDUMP ${PREFIX}objdump)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# 项目名称
project(led C CXX ASM)

# 设置C标准
set(CMAKE_C_STANDARD 11)

# 指定芯片型号的相关编译选项 (Cortex-A7)
add_compile_options(-mcpu=cortex-a7)
add_compile_options(-nostdlib -g)
add_compile_options(-ffunction-sections -fdata-sections -fno-common)

# 汇编文件的预编译选项
add_compile_options($<$<COMPILE_LANGUAGE:ASM>:-x$<SEMICOLON>assembler-with-cpp>)

# 链接脚本
set(LINKER_SCRIPT ${CMAKE_SOURCE_DIR}/core/imx6ull.lds)

# 添加链接选项
add_link_options(-T ${LINKER_SCRIPT})
add_link_options(-nostdlib -g)
add_link_options(-Wl,--gc-sections)

# 源文件
set(SOURCES
    core/start.S
    project/main.c
)

# 生成可执行文件
add_executable(${PROJECT_NAME}.elf ${SOURCES})

target_include_directories(${PROJECT_NAME}.elf PUBLIC ${CMAKE_SOURCE_DIR}/include)

# 生成二进制文件
set(BIN_FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.bin)
set(DIS_FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.dis)
set(IMX_FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.imx)
set(IMG_FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.img)

# 生成反汇编文件
add_custom_command(TARGET ${PROJECT_NAME}.elf POST_BUILD
    COMMAND ${CMAKE_OBJDUMP} -D -m arm $<TARGET_FILE:${PROJECT_NAME}.elf> > ${DIS_FILE}
    COMMENT "Generating disassembly file: ${DIS_FILE}"
)

# 生成原始二进制文件
add_custom_command(TARGET ${PROJECT_NAME}.elf POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary -S $<TARGET_FILE:${PROJECT_NAME}.elf> ${BIN_FILE}
    COMMENT "Generating binary file: ${BIN_FILE}"
)

# 生成 imx 格式文件
add_custom_command(TARGET ${PROJECT_NAME}.elf POST_BUILD
    COMMAND ${CMAKE_SOURCE_DIR}/core/imxdol ${BIN_FILE}
    # COMMENT "Generating IMX file: ${IMX_FILE}"
)

# # 生成最终的 img 文件
# add_custom_command(TARGET ${PROJECT_NAME}.elf POST_BUILD
#     COMMAND dd if=/dev/zero of=1k.bin bs=1024 count=1
#     COMMAND cat 1k.bin load.imx > ${IMG_FILE}
#     COMMAND rm 1k.bin
#     COMMENT "Generating final image: ${IMG_FILE}"
# )

# 清理自定义文件
set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES 
    ${BIN_FILE}
    ${DIS_FILE}
    ${IMX_FILE}
    ${IMG_FILE}
)

