// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import "../js/emojihelper.js" as EmojiHelper;
import "../../common/js/Global.js"as Helpers;
import QtQuick 1.1
import com.nokia.meego 1.0

Flickable{
    id: emojiGrid

    property int w_portrait:8;
    property int w_landscape: 14
    property int start;
    property int end;


    contentHeight:h*emojiHeight
    property int w:appWindow.inPortrait?w_portrait:w_landscape;
    property int h: Math.ceil((end-start)/w)
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
    function _loadLandscape(){

        var rows=  Math.ceil((end-start)/w_landscape);
        var emojiSet = EmojiHelper.emoji_landscape;

        for (var i=0; i<rows; i++){

            emojiSet[i] = new Array();

            for(var j=0; j<w_landscape; j++){
                var curr = j + (i*w_landscape)
                if(curr+start > end)
                    return
                emojiSet[i][j] =   EmojiHelper.addEmoji(Helpers.emoji_code[curr+start], get32(Helpers.emoji_code[curr+start]));
                emojiSet[i][j].landscape = true
            }
        }
    }

    function _loadPortrait(){
        var rows=  Math.ceil((end-start)/w_portrait);
        var emojiSet = EmojiHelper.emoji;

        for (var i=0; i<rows; i++){

            emojiSet[i] = new Array();

            for(var j=0; j<w_portrait; j++){
                var curr = j + (i*w_portrait)
                if(curr+start > end)
                    return
                emojiSet[i][j] =   EmojiHelper.addEmoji(Helpers.emoji_code[curr+start], get32(Helpers.emoji_code[curr+start]));
                emojiSet[i][j].landscape = false
            }
        }
    }


    function showEmoji(){

        var emojiSet = appWindow.inPortrait?EmojiHelper.emoji:EmojiHelper.emoji_landscape;

        if(!emojiSet.length)
            if(appWindow.inPortrait)_loadPortrait(); else _loadLandscape();

          emojiGrid.visible = true;


          for (var i=0; i<h; i++){
               for(var j=0; j<w; j++){

                        var curr = j + (i*w)
                       if(curr+start > end)
                           return

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
