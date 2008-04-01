// IE PNG Fix v1.0 RC4
// Detailed at http://www.twinhelix.com/css/iepngfix/
// Issues: Users cannot right-click to save, works best with fixed-size elements, background PNGs cannot be tiled, padding and borders do not indent PNG

if (document.all && document.styleSheets && document.styleSheets[0] &&
document.styleSheets[0].addRule)
{
 document.styleSheets[0].addRule('body#departments td.deptLink a', 'behavior: url(js/iepngfix.htc)');
}