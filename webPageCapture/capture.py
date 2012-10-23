#!/usr/bin/python
# should be python 2.7
import os
import re
import time
import sys
import math

from urllib import quote_plus
from pyvirtualdisplay import Display
from selenium import webdriver
from PIL import Image
from decimal import *

# make a screen shot for each URL in STDIN
# output resulting png to STDOUT

# ## to intall selenium:
# sudo pip install -U selenium

# ## to install pyvirtualdisplay on RHEL5:
# sudo bash
# curl http://python-distribute.org/distribute_setup.py | python
# curl -k https://raw.github.com/pypa/pip/master/contrib/get-pip.py | python

# The .png or .jpg at the end of the file sufix controls 
# the image format of the file.  
# The tomcat servlet expects png.
imageType = ".png"
fileSufix = "Image" + imageType

### Functions for URL to file name conversion ###

def queryToPath(queryStr):
  """Convert the query string of a URL to a path"""    
  return "/".join(map(quote_plus, queryStr.split("&")))
  
def urlToFileName(url):
  """Convert the URL and query string into a file path.
     The returned string will not start with a slash. """
  urlToPathAndQuery = re.compile(r"^http://([^\?]*)\?(.*)")
  match = urlToPathAndQuery.match(url)
  if match is not None:
    # query found, try this:
    return match.groups()[0] + "/" + queryToPath(match.groups()[1])
  else:
    urlregex = re.compile(r"^http://(.*)$")
    match = urlregex.match(url)
    if match is not None:
      return match.groups()[0] + fileSufix
    else:
      # not sure what it is but it might be a hostname
      return url

def fileNameToThumbnailName( filename ):
    return 'thumbnail.' + filename
    
def makeLargeAndThumbnail( saveTo, largeSize, thumbnailSize ):
    ''' Makes thumbnail and then replaces saveTo with 
        cropped and resized image.'''            
    try:                        
        img = Image.open(saveTo)
    except Exception, err:
        sys.stderr.write('ERROR: Could not open image. %s\n' % str(err))
    
    try:
        dirname = os.path.dirname(saveTo)
        filename = os.path.basename(saveTo)
        cropAndResizeImage( img, dirname+'/'+fileNameToThumbnailName(filename), thumbnailSize)
    except Exception, err:
        sys.stderr.write('ERROR: Could not crop and resize image. %s\n' % str(err))
            
    try:         
        cropAndResizeImage( img, saveTo, largeSize)
    except Exception, err:
        sys.stderr.write('ERROR: Could not crop and resize image. %s\n' % str(err))
        
    
def cropAndResizeImage( orgImage, saveToFileName, size):
    '''Crop image to get the most width of the original image and 
       preserve the aspect ratio of the size. Then resize and save
       as saveToFileName.
       Parameter orgImage must be a PIL image object.
       Parameter size must be a tuple of (width,height) ex. (800,500)  '''
                                                    
    img = orgImage.copy()
            
    orgWidth = img.size[0]
    aspectRatio = float( size[0])/float( size[1])
    cropHeight = int(math.ceil( float(orgWidth) / aspectRatio ))             
    area = img.crop( (0,0, orgWidth, cropHeight ) )
            
    resized = area.resize( size , Image.ANTIALIAS)
    resized.save( saveToFileName, quality=100 )        
                                     

#### main script ####

largeSize = (400, 300) # width height
thumbnailSize = (200, 150) # width height
basePath = "./imageCache/"

try:
    url = sys.argv[1]    
    if not url:
        sys.stderr.write('need URL')
        sys.exit(1)
        
    if len(sys.argv) >= 3 and sys.argv[2] == 'thumbnail':
        type = 'thumbnail'
    else:
        type = 'large'            
        
    saveTo = basePath + urlToFileName(url)
    dirname = os.path.dirname(saveTo)
    filename = os.path.basename(saveTo) 	   
    if not os.path.exists(dirname):            
        os.makedirs(dirname)
    	 
    if not os.path.exists( saveTo ):
        try:
            try:
                display = Display(visible=0, size=(800, 500))
                display.start()
                browser = webdriver.Firefox()
                browser.get( url )
            except Exception, err:
                sys.stderr.write('ERROR: Could not open browser to page. %s\n' % str(err))                        
            try:
                browser.save_screenshot(saveTo)
            except Exception, err:
                sys.stderr.write('ERROR: Could not take screenshot. %s\n' % str(err))                
        except Exception, err:
            sys.stderr.write('ERROR: %s\n' % str(err))                        
        finally:
            browser.quit()
            display.stop()
        makeLargeAndThumbnail( saveTo, largeSize, thumbnailSize )
    else:
        sys.stderr.write(" file exists")
        
    if type == 'thumbnail' :
        sys.stderr.write('doing thumbnail')
        fileToOutput = dirname + '/' + fileNameToThumbnailName(filename)        
    else:
        sys.stderr.write('doing large')
        fileToOutput = saveTo
    
    # return image file contents as binary data    
    sys.stdout.write(file(fileToOutput, "rb").read())
    sys.stdout.flush()
    
except Exception, err:
        sys.stderr.write('ERROR: %s\n' % str(err))
        exit(1)
    
