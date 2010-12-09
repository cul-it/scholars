//This code was created by the fine folks at Switch On The Code - http://blog.paranoidferret.com
//This code can be used for any purpose

function  slideDiagonally(elementId, headerElement, containerElement)
{
   var element = document.getElementById(elementId);
   var containerDiv = document.getElementById(containerElement);
   var child = headerElement.getElementsByTagName("div");

   if( element.down )
   {     
	  animate(elementId, 649, 0, 0, 0, 250, null);
      element.up = true;
      element.down = false;
      child[0].innerHTML = '&nbsp; + Help Improve VIVO';
	  element.style.borderWidth = "0px";
	  var t = setTimeout("resizeContainerElement()", 1000);

   }
   else
   {
	  containerDiv.style.height = "362px";
      containerDiv.style.width = "650px";
      animate(elementId, 0, 0, 648, 360, 250, null);
      element.down = true;
      element.up = false;
      child[0].innerHTML = '&nbsp; - Close';
	  element.style.borderWidth = "1px";
   }
}
function resizeContainerElement() {
		document.getElementById("panelContainer").style.height = "26px";
        document.getElementById("panelContainer").style.width = "176px";
}
function animate(elementID, newLeft, newTop, newWidth,
      newHeight, time, callback)
{
  var el = document.getElementById(elementID);
  if(el == null)
    return;
 
  var cLeft = parseInt(el.style.left);
  var cTop = parseInt(el.style.top);
  var cWidth = parseInt(el.style.width);
  var cHeight = parseInt(el.style.height);
 
  var totalFrames = 1;
  if(time> 0)
    totalFrames = time/40;

  var fLeft = newLeft - cLeft;
  if(fLeft != 0)
    fLeft /= totalFrames;
 
  var fTop = newTop - cTop;
  if(fTop != 0)
    fTop /= totalFrames;
 
  var fWidth = newWidth - cWidth;
  if(fWidth != 0)
    fWidth /= totalFrames;
 
  var fHeight = newHeight - cHeight;
  if(fHeight != 0)
    fHeight /= totalFrames;
   
  doFrame(elementID, cLeft, newLeft, fLeft,
      cTop, newTop, fTop, cWidth, newWidth, fWidth,
      cHeight, newHeight, fHeight, callback);
}

function doFrame(eID, cLeft, nLeft, fLeft,
      cTop, nTop, fTop, cWidth, nWidth, fWidth,
      cHeight, nHeight, fHeight, callback)
{
   var el = document.getElementById(eID);
   if(el == null)
     return;

  cLeft = moveSingleVal(cLeft, nLeft, fLeft);
  cTop = moveSingleVal(cTop, nTop, fTop);
  cWidth = moveSingleVal(cWidth, nWidth, fWidth);
  cHeight = moveSingleVal(cHeight, nHeight, fHeight);

  el.style.left = Math.round(cLeft) + 'px';
  el.style.top = Math.round(cTop) + 'px';
  el.style.width = Math.round(cWidth) + 'px';
  el.style.height = Math.round(cHeight) + 'px';
 
  if(cLeft == nLeft && cTop == nTop && cHeight == nHeight
    && cWidth == nWidth)
  {
    if(callback != null)
      callback();
    return;
  }
   
  setTimeout( 'doFrame("'+eID+'",'+cLeft+','+nLeft+','+fLeft+','
    +cTop+','+nTop+','+fTop+','+cWidth+','+nWidth+','+fWidth+','
    +cHeight+','+nHeight+','+fHeight+','+callback+')', 40);
}

function moveSingleVal(currentVal, finalVal, frameAmt)
{
  if(frameAmt == 0 || currentVal == finalVal)
    return finalVal;
 
  currentVal += frameAmt;
  if((frameAmt> 0 && currentVal>= finalVal)
    || (frameAmt <0 && currentVal <= finalVal))
  {
    return finalVal;
  }
  return currentVal;
}
