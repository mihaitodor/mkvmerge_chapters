# Prints chapter entries in a format compatible with mkvmerge.
# The chapters will mark the boundaries of the merged files.
# If the input files contain any chapters, they will be ignored.

# Dependencies: mkvinfo from MKVToolNix 

if [ "$#" -ne 1 ] || [ ! -d "$1" ]; then
    echo "Please specify the folder containing the .mkv files."
    exit 1
fi

dir=$1

print_time() {
    hh=$(awk "BEGIN {printf(\"%02d\", int(${1} / 3600)); exit}")
    mm=$(awk "BEGIN {printf(\"%02d\", int(${1} % 3600 / 60)); exit}")
    ss=$(awk "BEGIN {printf(\"%02d\", int(${1} % 60)); exit}")
    ms=$(awk "BEGIN {printf(\"%03d\", (${1} - int(${1})) * 1000); exit}")
    echo "${hh}:${mm}:${ss}.${ms}"
}

print_chapter() {
    printf "CHAPTER%03d=%s\n" ${1} "$(print_time ${2})"
    printf "CHAPTER%03dNAME=%s\n" ${1} "Chapter ${1}"
}

seconds=0
chapter=1
for file in $dir/*.mkv
do
    print_chapter "$chapter" "$seconds"
    duration=$(./mkvinfo -G $file | grep -E "| \+ Duration: [0-9]*\.[0-9]*s \(.*\)\s*$" | grep -o "[0-9]*\.[0-9]*" | head -1)
    seconds=$(awk "BEGIN {print $seconds + $duration; exit}")
    chapter=$((chapter + 1))
done
print_chapter "$chapter" "$seconds"
