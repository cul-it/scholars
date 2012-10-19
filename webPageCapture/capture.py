#!/usr/bin/python
# should be python 2.7
import os
import re
import time
from urllib import quote_plus
import sys
from pyvirtualdisplay import Display
from easyprocess import EasyProcess
import pyscreenshot as ImageGrab
from selenium import webdriver

# make a screen shot for each URL in STDIN
# output resulting png to STDOUT

### to install pyvirtualdisplay on RHEL5:
# sudo bash
# curl http://python-distribute.org/distribute_setup.py | python
# curl -k https://raw.github.com/pypa/pip/master/contrib/get-pip.py | python



### Functions for URL to file name conversion ###

def queryToPath( queryStr ):
  """Convert the query string of a URL to a path"""    
  return "/".join(  map( quote_plus, queryStr.split("&") ) )
  
def urlToFileName( url ):
  """Convert the URL and query string into a file path.
     The returned string will not start with a slash. """
  urlToPathAndQuery = re.compile(r"^http://([^\?]*)\?(.*)")
  match = urlToPathAndQuery.match( url )
  if match is not None:
    #query found, try this:
    return match.groups()[0] + "/" + queryToPath( match.groups()[1])
  else:
    urlregex = re.compile(r"^http://(.*)$")
    match = urlregex.match( url )
    if match is not None:
      return match.groups()[0] + "Image"
    else:
      #not sure what it is but it might be a hostname
      return url
  

basePath = "./webPageImages/" 

display = Display(visible=0,size=(800,600))
display.start()
browser = webdriver.Firefox()

for url in sys.stdin:
    sys.stdout.write("url: " + url + "\n")

    saveTo = basePath + urlToFileName( url )
    dirname = os.path.dirname(saveTo)
    filename = os.path.basename(saveTo) 
       
    sys.stdout.write("dir: " + dirname + "\n")
    sys.stdout.write("filename: " + filename + "\n")

    if not os.path.exists(dirname) :
        os.makedirs( dirname )
 
    browser.get( url )
    browser.save_screenshot( dirname + '/' + filename + ".png")

  #return image file contents as binary data
  #sys.stdout.write(
#	"Content-type: image/"+imageType+"\r\n\r\n" +
#	file(imageFile,"rb").read() )

browser.quit()
display.stop()
