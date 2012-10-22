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

# ## to install pyvirtualdisplay on RHEL5:
# sudo bash
# curl http://python-distribute.org/distribute_setup.py | python
# curl -k https://raw.github.com/pypa/pip/master/contrib/get-pip.py | python


# the .png or .jpg at the end of the file sufix controls 
# the image format of the file
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
  

basePath = "./imageCache/" 



try:
    url = sys.argv[1]    
    if not url:
        sys.stderr.write('need URL')
        sys.exit(1)
        
    saveTo = basePath + urlToFileName(url)
    dirname = os.path.dirname(saveTo)
    filename = os.path.basename(saveTo) 	   
    sys.stderr.write("web page save to: " + saveTo + "\n")
    if not os.path.exists(dirname):            
        os.makedirs(dirname)
    else:
        sys.stderr.write(" dir exists")	 
    if not os.path.exists( saveTo ):
        try:
            try:
                display = Display(visible=0, size=(800, 600))
                display.start()
                browser = webdriver.Firefox()
                browser.get( url )
            except Exception as e :
                #the following line is causing an error
                sys.stderr.write( e )
            try:
                browser.save_screenshot(saveTo)
            except Exception as e :
                #the following line is causing an error
                sys.stderr.write( e )        
        finally:
            browser.quit()
            display.stop()
    else:
        sys.stderr.write(" file exists")
    
    # return image file contents as binary data
    sys.stdout.write(file(saveTo, "rb").read())
    sys.stdout.flush()
except:
    sys.err.write("some kind of problem")
    

