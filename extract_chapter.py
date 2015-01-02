#!/usr/bin/env python
import lxml.html
import lxml.cssselect
import sys
if len(sys.argv) == 3: # Don't use stdin/stdout because of lack of binary access
    i = open(sys.argv[1], mode='rb')
    o = open(sys.argv[2], mode='wb')
else:
    raise Exception("Invalid number of arguments: {0}".format(len(sys.argv)))


html = lxml.html.parse(i)
content = lxml.cssselect.CSSSelector('''div.entry-content''')(html)[0]
# Remove some problematic content:
blacklist = [
    '''a[title="Next Chapter"]''',
    '''a[title="Last Chapter"]''',
    '''a:contains("Next Chapter")''',
    '''p:contains("Last Chapter")''',
    '''div#jp-post-flair''',
]
for path in blacklist:
    select = lxml.cssselect.CSSSelector(path)
    for e in select(content):
        e.getparent().remove(e)
content = lxml.html.tostring(content)
o.write(content)
