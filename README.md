## Description

Bash scripts for managing media I get from [Bandcamp](https://bandcamp.com). 
I've only tested this on a linux system, but it should work as long as you have bash.

## Installation

`git clone` this repo and fire scripts at will :)

## Scripts

### scripts/extraction.sh

Bandcamp has you download music in a zipfile. Managing the zip files is always a pain.

This script asks where you keep your music (i.e. "~/music"). If it finds any zip files there, it will parse the titles and extract them to the appropriate folders.

EX: 
Music Folder: /home/bob/music
Downloded bandcamp zip: My Band - My Album.zip

- Creates -> /home/bob/music/My Band/My Album
- Extracts all songs from zip file there
- Deletes zip file

```
/home/bob/Music
├── Boy Harsher
│   └── The Runner (Original Soundtrack)
│       ├── Boy Harsher - The Runner (Original Soundtrack) - 01 Tower.mp3
│       ├── Boy Harsher - The Runner (Original Soundtrack) - 02 Give Me a Reason.mp3
│       ├── Boy Harsher - The Runner (Original Soundtrack) - 03 Autonomy (Ft. Lucy - Cooper B. Handy).mp3
│       ├── Boy Harsher - The Runner (Original Soundtrack) - 04 The Ride Home.mp3
│       ├── Boy Harsher - The Runner (Original Soundtrack) - 05 Escape.mp3
│       ├── Boy Harsher - The Runner (Original Soundtrack) - 06 Machina (Ft. Ms. BOAN - Mariana Saldaña).mp3
│       ├── Boy Harsher - The Runner (Original Soundtrack) - 07 Untitled (Piano).mp3
│       ├── Boy Harsher - The Runner (Original Soundtrack) - 08 I Understand.mp3
│       └── cover.jpg
```
