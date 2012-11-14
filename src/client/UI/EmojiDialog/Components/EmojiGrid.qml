// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import "../js/emojihelper.js" as EmojiHelper;
import "../../common/js/Global.js"as Helpers;
import "../../common/js/settings.js" as MySettings;
import QtQuick 1.1
import com.nokia.meego 1.0

Flickable{
    id: emojiGrid

    property int w_portrait:8;
    property int w_landscape: 14
    property int start;
    property int end;
    property int rows;
    
    property bool showRecent: false
    property int recentCount: 0

    contentHeight:h*emojiHeight
    property int w:appWindow.inPortrait?w_portrait:w_landscape;
    property int h: Math.ceil((showRecent? recentCount : (end-start)) / w)
    property int emojiWidth:Math.floor(parent.width/w);
    property int emojiHeight:emojiWidth;
    x: (width-(w*emojiWidth))/2

    visible:false
    clip: true

    state:screen.currentOrientation == Screen.Portrait?"Portrait":"Landscape"

    onStateChanged: {
        if(visible){
            showEmoji();
        }
    }

    function loadEmoji(){
        _loadPortrait();
        _loadLandscape();
    }

    // if(!initializationDone){
      //   splashPage.setSubOperation(curr+"/"+(end-start))
        // breathe();
     //}
     
    function loadRecentEmoji(){
	if (showRecent)
	{
	    var emojilist= MySettings.getSetting("RecentEmoji", "")

	    var emoji = []
	    if (emojilist!="")
		    emoji = emojilist.split(',')
	    recentCount = emoji.length
	    return emoji
	}
	else
	    return []
    }
     
    function _loadLandscape(){
	var emoji = loadRecentEmoji()
	
        rows=  Math.ceil((showRecent? recentCount : (end-start)) /w_landscape);
        var emojiSet = EmojiHelper.emoji_landscape;

        for (var i=0; i<rows; i++){

            emojiSet[i] = new Array();

            for(var j=0; j<w_landscape; j++){
		if (showRecent)
		{
		    if(emoji.length === 0)
			return
		    var emote = emoji.pop();
		    emojiSet[i][j] = EmojiHelper.addEmoji(emote, get32(emote));
		    emojiSet[i][j].landscape = true
		}
		else
		{
		    var curr = j + (i*w_landscape)
		    if(curr+start > end)
			return
		    emojiSet[i][j] =   EmojiHelper.addEmoji(Helpers.emoji_code[curr+start], get32(Helpers.emoji_code[curr+start]));
		    emojiSet[i][j].landscape = true
		}
            }
        }
    }

    function _loadPortrait(){
	var emoji = loadRecentEmoji()
      
        rows=  Math.ceil((showRecent? recentCount : (end-start)) /w_portrait);
        var emojiSet = EmojiHelper.emoji;

        for (var i=0; i<rows; i++){

            emojiSet[i] = new Array();

            for(var j=0; j<w_portrait; j++){
                if (showRecent)
		{
		    if(emoji.length === 0)
			return
		    var emote = emoji.pop();
		    emojiSet[i][j] = EmojiHelper.addEmoji(emote, get32(emote));
		    emojiSet[i][j].landscape = false
		}
		else
		{
		    var curr = j + (i*w_portrait)
		    if(curr+start > end)
			return
		    emojiSet[i][j] =   EmojiHelper.addEmoji(Helpers.emoji_code[curr+start], get32(Helpers.emoji_code[curr+start]));
		    emojiSet[i][j].landscape = false
		}
            }
        }
    }


    function showEmoji(){

        var emojiSet = appWindow.inPortrait?EmojiHelper.emoji:EmojiHelper.emoji_landscape;

        if(showRecent || !emojiSet.length)
            if(appWindow.inPortrait)_loadPortrait(); else _loadLandscape();

          emojiGrid.visible = true;

          for (var i=0; i<rows; i++){
               for(var j=0; j<w; j++){
                        var curr = j + (i*w)
			
			if (showRecent)
			{
			  if (curr > recentCount-1)
			    break
			}
                        else 
			  if(curr+start > end)
                            break

                        var emoji = emojiSet[i][j];
                        emoji.x = 0;
                        emoji.y = 0;

                        emoji.spawned = true
                        emoji.x = j*emojiWidth;
                        emoji.y = i*emojiHeight;

                        emoji.spawned = false
               }
          }
    }
}
