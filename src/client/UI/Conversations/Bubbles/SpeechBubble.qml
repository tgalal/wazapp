// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import "../../common/js/Global.js" as Helpers

Rectangle {
	id: bubble

    property string picture;

    property bool from_me;
    property string date;
    property string name;
    property int msg_id;
    property string state_status;
    property variant media;
	property int childrenWidth

    property int bubbleColor;

    property alias bubbleContent:bubbleContent.children

    state: state_status;

	signal optionsRequested();
    signal clicked();

	width: appWindow.inPortrait ? 480 : 854
	height: bubbleContent.children[0].height + (mediatype_id==1?msg_date.height:0) + 
			(sender_name.text!=""?sender_name.height:0) + (from_me?28:30) ;
	color: "transparent"

    function xgetBubbleColor(user) {
		var color = -1
         /*UNCOMMENTME
		if (groupMembers.count==0) {
			groupMembers.insert(groupMembers.count, {"name":user})
			color = 1
		} else {
			for(var i =0; i<groupMembers.count; i++)
			{
				if(user == groupMembers.get(i).name) {
				    color = i+1;
					break;
				}
			}
			if (color==-1) {
				groupMembers.insert(groupMembers.count, {"name":user})
				color = groupMembers.count
			}
        }*/
		return parseInt(color);
	}


    function getBubbleBorderImageSource(){
        var imageSrc = "../images/bubbles/";
        imageSrc += from_me?"outgoing":"incoming";
        imageSrc += bubbleColor+"-";
        imageSrc += mArea.pressed? "pressed" : "normal";
        imageSrc += ".png";

        console.log(imageSrc);
        return imageSrc;
    }


	BorderImage {
		anchors.top: parent.top
		anchors.topMargin: from_me ? 8 : 0
		anchors.left: parent.left
		anchors.leftMargin: from_me ? 10 : parent.width-width-10
		width: Math.max(childrenWidth, msg_date.paintedWidth+(from_me?28:0), sender_name.paintedWidth) +26
		height: parent.height + (from_me ? 2 : 0)

        source: getBubbleBorderImageSource();

		border { left: 22; right: 22; bottom: 22; top: 22; }

		opacity:theme.inverted?0.8:1

		MouseArea{
			id: mArea
			anchors.fill: parent
			onClicked: {
                bubble.clicked();
			}
			onPressAndHold:{
				console.log("pressed and held!")
				//if (mediatype_id==1) optionsRequested();
				optionsRequested();
			}
		}

	}

	Image {
        id: status
        visible: from_me
        anchors.left: msg_date.left
        anchors.leftMargin: msg_date.paintedWidth + 12
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12
		height: 16; width: 16
        source: state_status!="" ? "../images/indicators/" + state_status + ".png" : ""
		smooth: true
    }

	Label{
	    id: sender_name
		y: 18
	    width: parent.width-100
	    color: "white"
	    text: name
	    font.pixelSize: 20
	    font.bold: true
	    anchors.left: parent.left
		anchors.leftMargin: from_me ? (20+(mediatype_id==1?0:66)) : (80-(mediatype_id==1?0:66))
		horizontalAlignment: Text.AlignRight
		visible: name!=""
	}

	Item{
        id: bubbleContent
		anchors.top: parent.top
		anchors.topMargin: from_me ? 16 : sender_name.text=="" ? 18 : 48
		height: bubbleContent.children[0].height
	}
	
	Label {
	    id: msg_date
		anchors.top: bubbleContent.bottom
		anchors.topMargin: mediatype_id==1? 4 : (mediatype_id==1?-20:-18)
	    text: date
	    color: from_me ? "black" : "white"
	    anchors.left: parent.left
		anchors.leftMargin: from_me ? (20+(mediatype_id==1?0:66)) : (80-(mediatype_id==1?0:66))
		width: parent.width -100
	    font.pixelSize: 16
	    font.weight: Font.Light
		horizontalAlignment: from_me? Text.AlignLeft : Text.AlignRight
		opacity: from_me && !theme.inverted? 0.5 : 0.7
	}


}
