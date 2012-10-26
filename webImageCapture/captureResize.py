import os
import sys
import math

from PIL import Image
from captureUrls import *
    
def makeLargeAndThumbnail( saveTo, largeSize, thumbnailSize ):
    ''' Makes thumbnail and then replaces saveTo with 
        cropped and resized image.'''            
    try:
        img = Image.open(saveTo)
        img.load()
    except Exception, err:
        sys.stderr.write('ERROR: Could not open image. %s\n' % str(err))
    
    try:
        dirname = os.path.dirname(saveTo)
        filename = os.path.basename(saveTo)        
        thumbnailname = '{}/{}'.format( dirname , fileNameToThumbnailName(filename) )
              
        sys.stderr.write("dirname: '%s'\n" % dirname)
        sys.stderr.write("fiename: '%s'\n" % filename)
        sys.stderr.write("thumb: '%s'\n" % thumbnailname )
                
    except Exception, err:
        sys.stderr.write('ERROR: set up names for image files. %s\n' % str(err))
        
    try:
        cropAndResizeImage( img, thumbnailname , thumbnailSize)
    except Exception, err:
        sys.stderr.write('ERROR: Could not crop and resize thumbnail image. %s\n' % str(err))
            
    try:
        cropAndResizeImage( img, saveTo, largeSize)        
    except Exception, err:
        sys.stderr.write('ERROR: Could not crop and resize large image. %s\n' % str(err))
        
    
def cropAndResizeImage( orgImage, saveToFileName, size):
    '''Crop image to get the most width of the original image and 
       preserve the aspect ratio of the size. Then resize and save
       as saveToFileName.
       Parameter orgImage must be a PIL image object.
       Parameter size must be a tuple of (width,height) ex. (800,500)  '''

    sys.stderr.write("a")
                                                    
    img = orgImage.copy()

    sys.stderr.write("b")    
    orgWidth = img.size[0]
    aspectRatio = float( size[0])/float( size[1])
    cropHeight = int(math.ceil( float(orgWidth) / aspectRatio ))             
    area = img.crop( (0,0, orgWidth, cropHeight ) )
    
    sys.stderr.write("c")
    resized = area.resize( size , Image.ANTIALIAS)
    sys.stderr.write("d")    
    resized.save( saveToFileName, quality=100 )        
    sys.stderr.write("e")                                 
