import QtQuick 1.1
import com.nokia.meego 1.0
import "../common/js/Global.js" as Helpers
import "js/emojihelper.js" as EmojiHelper
import "Components"

Dialog {
	id: emojiSelector
	
	width: parent.width
	height: parent.height


    property string titleText: qsTr("Select Emoji")
    property string emojiPath:"../common/images/emoji/";

    /*function setCallback(func){

        EmojiHelper.emojiSelectCallback = func;

    }*/

    function get32(code){
        var c = ""+code;
        return emojiPath+"32/"+c+".png";
    }

    function get20(code){
        var c = ""+code;
        return emojiPath+"20/"+c+".png";
    }

    function openDialog(textarea){
        if(!textarea){
            consoleDebug("NO TEXTAREA SPECIFIED FOR EMOJI, NOT OPENING!")
            return;
        }
        textarea.lastPosition = textarea.cursorPosition
        EmojiHelper.emojiTextarea = textarea

        emojiSelector.open();
		emojiCategory.checkedButton = peopleEmoji
        showGrid(peopleGrid)
    }

    function getGrids(){
        return [peopleGrid, natureGrid, objectsGrid, placesGrid, symbolsGrid];
    }

    function loadAll(){
        var grids = getGrids();

        for(var g in grids){
            grids[g].loadEmoji();
        }
    }

    function hideAll(){
        var grids = getGrids();
        for(var g in grids){
            grids[g].visible = false;
        }
    }

    function showGrid(grid){
        hideAll();
        grid.showEmoji();
    }

	SelectionDialogStyle { id: selectionDialogStyle }

    title: Item {
    	id: header
        height: selectionDialogStyle.titleBarHeight
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        Item {
            id: labelField
            anchors.fill:  parent

            Item {
                id: labelWrapper
                anchors.left: labelField.left
                anchors.right: closeButton.left
                anchors.bottom:  parent.bottom
                anchors.bottomMargin: selectionDialogStyle.titleBarLineMargin
                height: titleLabel.height

                Label {
                    id: titleLabel
                    x: selectionDialogStyle.titleBarIndent
                    width: parent.width - closeButton.width
                    font: selectionDialogStyle.titleBarFont
                    color: selectionDialogStyle.commonLabelColor
                    elide: selectionDialogStyle.titleElideMode
                    text: emojiSelector.titleText
                }

            }

            Image {
                id: closeButton
                anchors.bottom:  parent.bottom
                anchors.bottomMargin: selectionDialogStyle.titleBarLineMargin-6
                anchors.right: labelField.right
                opacity: closeButtonArea.pressed ? 0.5 : 1.0
                source: "image://theme/icon-m-common-dialog-close"

                MouseArea {
                    id: closeButtonArea
                    anchors.fill: parent
                    onClicked:  {emojiSelector.reject();}
                }
            }
        }

        Rectangle {
            id: headerLine
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom:  header.bottom
            height: 1
            color: "#4D4D4D"
        }

    }

	content: Item {
        width: parent.width
		height: emojiSelector.height-200

        ButtonRow {
            id: emojiCategory
            checkedButton: peopleEmoji
            anchors.horizontalCenter: parent.horizontalCenter
           // width: emojiSelector.width-30
            y: 10

            Button {
                id: peopleEmoji
            platformStyle: ButtonStyle { inverted: true }
                iconSource: get32("E057");
                onClicked: showGrid(peopleGrid)
            }

            Button {
                id: natureEmoji
            platformStyle: ButtonStyle { inverted: true }
                iconSource: get32("E303");
                onClicked: showGrid(natureGrid)
            }

            Button {
                id: placesEmoji
            platformStyle: ButtonStyle { inverted: true }
                iconSource: get32("E325")
                onClicked: showGrid(placesGrid)
            }

            Button {
                id: objectsEmoji
            platformStyle: ButtonStyle { inverted: true }
                iconSource: get32("E036")
                onClicked: showGrid(objectsGrid)
            }

            Button {
                id: symbolsEmoji
            platformStyle: ButtonStyle { inverted: true }
                iconSource: get32("E210")
                onClicked: showGrid(symbolsGrid)
            }
        }

        Rectangle {
            id:emojiContainer
            width: parent.width
            height: emojiSelector.height-200
           // radius: 20
            anchors.top:emojiCategory.bottom
            anchors.topMargin: 5
            color: "#000000"//"#1a1a1a"

            EmojiGrid{
                id:peopleGrid
                anchors.fill: parent
                start: 0;
                end: 187;
            }

            EmojiGrid{
                id:natureGrid
                width:parent.width
                height:parent.height
                start: 189;
                end: 304;
            }

            EmojiGrid{
                id:placesGrid
                width:parent.width
                height:parent.height
                start: 305;
                end: 534;
            }

            EmojiGrid{
                id:objectsGrid
                width:parent.width
                height:parent.height
                start: 535;
                end: 636;
            }

            EmojiGrid{
                id:symbolsGrid
                width:parent.width
                height:parent.height
                start: 637;
                end: 845
            }
        }
	}

    function selectEmoji(emojiCode){

        //console.log("GOT "+emojiCode)
        //emojiSelected(emojiCode);

        /*if(EmojiHelper.emojiSelectCallback){
            EmojiHelper.emojiSelectCallback(emojiCode);
        }*/


        var textarea = EmojiHelper.emojiTextarea;

        var cresult = textarea.getCleanText();
        var str = cresult[0]
        var npos = cresult[1]

        var pos = str.indexOf("&quot;")
        var newPosition = textarea.lastPosition
        while(pos>-1 && pos<textarea.lastPosition) {
            textarea.lastPosition = textarea.lastPosition +5
            pos = str.indexOf("&quot;", pos+1)

        }
        pos = str.indexOf("&amp;")
        while(pos>-1 && pos<textarea.lastPosition) {
            textarea.lastPosition = textarea.lastPosition +4
            pos = str.indexOf("&amp;", pos+1)
        }
        pos = str.indexOf("&lt;")
        while(pos>-1 && pos<textarea.lastPosition) {
            textarea.lastPosition = textarea.lastPosition +3
            pos = str.indexOf("&lt;", pos+1)
        }
        pos = str.indexOf("&gt;")
        while(pos>-1 && pos<textarea.lastPosition) {
            textarea.lastPosition = textarea.lastPosition +3
            pos = str.indexOf("&gt;", pos+1)
        }
        pos = str.indexOf("<br />")
        while(pos>-1 && pos<textarea.lastPosition) {
            textarea.lastPosition = textarea.lastPosition +5
            pos = str.indexOf("<br />", pos+1)
        }

        textarea.lastPosition = textarea.lastPosition + parseInt(npos);

        var emojiImg = '<img src="/opt/waxmppplugin/bin/wazapp/UI/common/images/emoji/24/'+emojiCode+'.png" />'
        str = str.substring(0,textarea.lastPosition) + emojiImg + str.slice(textarea.lastPosition)
        textarea.text = Helpers.emojify2(str)
        textarea.cursorPosition = newPosition + 1
        textarea.forceActiveFocus();


        emojiSelector.accept();
        hideAll();
    }

}
