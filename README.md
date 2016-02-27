# Visioner

Automatically rename your pictures using Google Vision API and metadata.

## Installation

    $ bundle install
    $ rake install

## Usage

    $ export GOOGLE_VISION_API_KEY=...
    $ bin/visioner [options] image ...

**Options:**

-c, --country                    Adds country to the new filename (ex: south-korea)

-d, --date                       Adds date to the new filename (ex: 29/07/2016)

-h, --help                       Displays help

**Examples:**

    $ export GOOGLE_VISION_API_KEY=BI34SyB5DhqV5ReVnkmIM79812yux9UFazNdynD
    
    $ bin/visioner /Desktop/travel-south-korea-2016-2/*.jpg
      /Desktop/travel-south-korea-2016-2/IMG_213.jpg -> sea.jpg
      /Desktop/travel-south-korea-2016-2/IMG_214.jpg -> tower.jpg
      /Desktop/travel-south-korea-2016-2/IMG_215.jpg -> people.jpg
      /Desktop/travel-south-korea-2016-2/IMG_216.jpg -> sea2.jpg
      
    $ bin/visioner --date /Desktop/travel-south-korea-2016-3/*.jpg
      /Desktop/travel-south-korea-2016-3/IMG_213.jpg -> 02-28-2015_sea.jpg
      /Desktop/travel-south-korea-2016-3/IMG_214.jpg -> 02-15-2015_tower.jpg
      /Desktop/travel-south-korea-2016-3/IMG_215.jpg -> 03-28-2015_people.jpg
      /Desktop/travel-south-korea-2016-3/IMG_216.jpg -> 04-02-2015_sea2.jpg
      
    $ bin/visioner --country --date /Desktop/travel-south-korea-2016-4/*.jpg
      /Desktop/travel-south-korea-2016-4/IMG_213.jpg -> south-korea_02-28-2015_sea.jpg
      /Desktop/travel-south-korea-2016-4/IMG_214.jpg -> south-korea_03-15-2015_tower.jpg
      /Desktop/travel-south-korea-2016-4/IMG_215.jpg -> south-korea_03-28-2015_people.jpg
      /Desktop/travel-south-korea-2016-4/IMG_216.jpg -> south-korea_04-02-2015_sea2.jpg
