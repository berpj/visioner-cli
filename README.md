# Visioner

Automatically rename your pictures using Google Vision API.

## Installation

    $ bundle
    $ rake install

## Usage

    $ export GOOGLE_VISION_API_KEY=...
    $ bin/visioner image ...

Example:

    $ export GOOGLE_VISION_API_KEY=BI34SyB5DhqV5ReVnkmIM79812yux9UFazNdynD
    $ bin/visioner ~/Desktop/travel-south-korea-2016/*.jpg
      bin/visioner ~/Desktop/travel-south-korea-2016/IMG_213.jpg -> sea.jpg
      bin/visioner ~/Desktop/travel-south-korea-2016/IMG_214.jpg -> tower.jpg
      bin/visioner ~/Desktop/travel-south-korea-2016/IMG_215.jpg -> people.jpg
      bin/visioner ~/Desktop/travel-south-korea-2016/IMG_216.jpg -> sea2.jpg
