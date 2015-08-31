#!/bin/bash
# Change this if your clang-format executable is somewhere else
# find 'NetEasePatch' \( -name '*.h' -or -name '*.m' -or -name '*.mm' \) ! -path '*Wax/*' ! -path '*patch/*' ! -path '*JSPatch/*' -print0
#设置需要格式化的目录，以空格隔开
INCLUDEDIR="LDBus LDBusBundle LDBusBundleTests LDBusTests"
#设置需要隔离的目录，以空格隔开
EXCLUDEDIR=""

#生成Exclude指定目录的format命令
FORMAT_EXCLUDEDIR=""
for TMPDIR in $EXCLUDEDIR
do
	FORMAT_EXCLUDEDIR+=" ! -path '*"$TMPDIR"/*' "
done
echo $FORMAT_EXCLUDEDIR 

#对指定文件夹执行format命令
CLANG_FORMAT="$HOME/Library/Application Support/Alcatraz/Plug-ins/ClangFormat/bin/clang-format"
for DIRECTORY in $INCLUDEDIR
do
    echo "Formatting code under $DIRECTORY/"
    eval "find \"$DIRECTORY\" \( -name '*.h' -or -name '*.m' -or -name '*.mm' \) $FORMAT_EXCLUDEDIR -print0 | xargs -0 \"$CLANG_FORMAT\" -i"
done
