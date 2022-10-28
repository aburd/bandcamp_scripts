## Description

Some scripts for managing media I get from [Bandcamp](https://bandcamp.com). 

## Installation

`git clone` this repo and fire scripts at will :)

## Scripts

### scripts/extraction.sh

Bandcamp has you download music in a zipfile. Managing the zip files is always a pain.

This script asks where you keep your music (i.e. "~/music"). If it finds any zip files there, it will parse the titles and extract them to the appropriate folders.

EX: 
Music Folder: /home/user/music
Downloded bandcamp zip: My Band - My Album.zip

- Creates -> /home/user/music/My Band/My Album
- Extracts all songs from zip file there
- Deletes zip file
