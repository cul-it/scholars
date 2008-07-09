// Hex colors for Top and Bottom colors (color outside of container) specified with third and fourth parameters (cannot be second) 
// to override Nifty's auto-color-picker since it does not detect color within background images, transparent ones in particular

// Full list of parameters here: http://www.html.it/articoli/niftycube/index.html
// Format: Nifty("selector","options","topcolor","bottomcolor")

window.onload=function(){
    Nifty("div#news","all","#031D1D","#193335");
    Nifty("div#seminars","all","#193335");
    Nifty("div#searchBox","all","#193335");
    Nifty("div#apply","all","#193335");   
    Nifty("div.cornered ul","big all","#031D1D","#173133"); 
    Nifty("div#departmentsInField","big","#0A2424","#193335"); 
    Nifty("h3.facilityGroup","all","#193335"); 
    Nifty("#faculty-research","big all","#193335"); 
    Nifty("#faculty-publications","big all","#193335"); 
    Nifty("#faculty-teaching","big all","#193335"); 
    Nifty("#contactInfo","small bottom","#193335"); 
}