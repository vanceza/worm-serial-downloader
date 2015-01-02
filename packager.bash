#!/bin/bash
# Package a pdf version of 'Worm' by wildbow
if [ ! -d parahumans.wordpress.com ]; then
    # Download all of worm's blog minus comments
    wget -r --no-parent -nc --reject-regex '.*replytocom.*' -R '*replytocom*' "http://parahumans.wordpress.com/" 
fi

rm -rf chapters.d chapter_order
mkdir chapters.d
# Copy the relevant raw files
for chapter in parahumans.wordpress.com/20??/*/*/*-*; do # The order is by date in the directory structure; this happens to work automatically for VERY hacky reasons around inodes creation dates and wget's traversal order
    if [ -d "$chapter" ]
    then
        chapter_name=$(basename $chapter)
        echo "Copying $chapter_name"
        cp "$chapter"/index.html chapters.d/"${chapter_name}.orig.html"
        echo "$chapter_name" >>chapter_order
    fi
done

# Process each file to include only the content of the story and no extra information
while read chapter
do
    echo "Extracting HTML content from $chapter"
    python extract_chapter.py chapters.d/"${chapter}.orig.html" extracted.html # Raw content
    # Add a header for PDF generation later
    cat >header <<HEADER
<h2>${chapter}</h2>
HEADER
    cat header extracted.html >chapters.d/"${chapter}.extracted.html"
    rm header extracted.html
done <chapter_order

# Combine all extracted files
echo "Generating combined PDF"
{
    while read chapter; do echo chapters.d/"${chapter}.extracted.html"; done <chapter_order
    echo worm.pdf
} | xargs -t -- wkhtmltopdf --load-error-handling ignore --no-images --disable-javascript --disable-internal-links --title "Worm" --default-header
