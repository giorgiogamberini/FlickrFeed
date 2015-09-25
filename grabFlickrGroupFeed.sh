#!/bin/bash
#
#FL_TAGS="beauty,girls,portrait"; FL_PERPAGE="100"; FL_SORT="relevant"; curl -s "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=77a96d545bc27d4bbb8f4327e2a713b8&format=rest&tags=$FL_TAGS&safe_search=1&sort=$FL_SORT&safe_search=1&dimension_search_mode=min&height=1280&width=1024&orientation=landscape&per_page=$FL_PERPAGE" | grep "photo id" | awk -F '"' '{printf "https://farm"}{printf $10}{printf ".staticflickr.com/"}{printf $8}{printf "/"}{printf $2}{printf "_"}{printf $6}{print "_b.jpg"}' | xargs -L1 curl -sk -O
#
if ! cd ~/FlickrFeed ; then
  logger "grabFlickrFeed: failed to cd to ~/Pictures/FlickrFeed; exiting"
  exit 1
fi

if ! curl -s "http://api.flickr.com/" > /dev/null 2>&1 ; then
  logger "grabFlickrFeed: couldn't connect to Yahoo API; exiting"
  exit 1
fi

# this grabs pics from ">> Beauty Shot <<", ID 996637@N22
FL_PERPAGE="100"
FL_PAGE=$[${RANDOM}%37+1]
FL_GROUP_ID="996637@N22"

logger "grabFlickrGroupFeed: grabbing groupId $FL_GROUP_ID, $FL_PERPAGE items on page $FL_PAGE"
curl -s "https://api.flickr.com/services/rest/?method=flickr.groups.pools.getPhotos&&api_key=77a96d545bc27d4bbb8f4327e2a713b8&group_id=$FL_GROUP_ID&per_page=$FL_PERPAGE&page=$FL_PAGE"\
  | grep "photo id"\
  | awk -F '"' '{printf "https://farm"}{printf $10}{printf ".staticflickr.com/"}{printf $8}{printf "/"}{printf $2}{printf "_"}{printf $6}{print "_b.jpg"}'\
  | xargs -L1 curl -sk -O

find . -mtime +12h -exec rm -f {} +

# Now remove fiels not of JPG type
DIR="../FlickrFeed_failed_jpgs"

if [[ ! -e $DIR ]]; then
  mkdir $DIR
elif [[ ! -d $DIR ]]; then
  logger "$DIR already exists but is not a directory!!"
fi

for file in $(find . -name "*.jpg"); do
  if [[ $(file -b $file) = "HTML document text" ]]; then
    mv $file $DIR/$file
  else
    # NOP
    :
  fi
done


NO_IMAGES=$(ls | wc -l | sed "s/ //g")

logger "grabFlickrFeed: completed; $NO_IMAGES images"
