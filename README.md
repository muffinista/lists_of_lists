
This is the code for the twitter bot https://twitter.com/lists_of_lists

Profile image is https://commons.wikimedia.org/wiki/File:List_icon.svg

Background image is https://en.wikipedia.org/wiki/Michael_Mandiberg#/media/File:Print_Wikipedia_by_Michael_Mandiberg,_NYC_June_18,_2015-19.jpg





```
curl https://dumps.wikimedia.org/enwiki/latest/enwiki-latest-all-titles-in-ns0.gz > enwiki-latest-all-titles-in-ns0.gz && gzcat enwiki-latest-all-titles-in-ns0.gz | grep -i 'List_of\|Lists_of' > tmpfile.txt
gshuf tmpfile.txt > lists.txt
```


