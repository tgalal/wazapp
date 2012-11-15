// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import "../common/js/Global.js" as Helpers
import "Bubbles"
import com.nokia.meego 1.0

Item {

    id:delegateContainer
    width:bubbleDisplay.width
    height:bubbleDisplay.height;

	property string jid;
    property int mediatype_id:1
    property string message;
    property string picture;
    property int from_me;
    property bool isGroup;
    property string date;
    property string name;
    property int msg_id;
    property string state_status;
    property int bubbleColor:1
    property string thumb
    property variant media
    property string media_path
    property variant author
    property int progress: 0

    signal optionsRequested()

    anchors.right: from_me==1?this.right:parent.right
    anchors.left: from_me!=1?this.left:parent.left
    anchors.rightMargin: 0
    anchors.leftMargin: 0

	Connections {
		target: conversation_view
		onTextHeightChanged: {
			if(mediatype_id==10) bubbleDisplay.height = currentTextHeight
		}
	}

	Connections {
		target: appWindow

		onMessageSent: {
			if (ujid==jid && msg_id==mid)
				state_status = isGroup ? "delivered" : "pending"
		}

		onMessageDelivered: {
			if (ujid==jid && msg_id==mid)
				state_status = "delivered"
		}

	}

    function getBubble(){

		if (from_me==20 || from_me==21 || from_me==22 || from_me==23) 
			return notificationDelegate
		else {
		    switch(mediatype_id){
				case 1: return textDelegate
				case 2: case 3: case 4: case 5: case 6: return mediaDelegate
		        //case 10: return textInputComponent
		    }
		}
    }

	function decodeText(text) {
		var res = text;
		res = Helpers.linkify(res);
		res = Helpers.emojifyBig(res);
		while(res.indexOf("\n")>-1) res = res.replace("\n", "<br />");
		return res;
	}


	Component {
		id: notificationDelegate

		TextBubble{
			id:notificationBubble
			message:Helpers.emojify(delegateContainer.message)
			name:delegateContainer.name
			from_me:delegateContainer.from_me
			date:Helpers.getDateText(delegateContainer.date).replace("Today", qsTr("Today")).replace("Yesterday", qsTr("Yesterday"))
		}
    }

    Component {
       id: textDelegate

       TextBubble{
           id:textBubble
           message:decodeText(delegateContainer.message);
           date:Helpers.getDateText(delegateContainer.date).replace("Today", qsTr("Today")).replace("Yesterday", qsTr("Yesterday"))
           from_me:delegateContainer.from_me
           name:delegateContainer.name
           state_status:delegateContainer.state_status
           bubbleColor: delegateContainer.bubbleColor;

           onOptionsRequested: {
               delegateContainer.optionsRequested()
           }

  		}
    }

    Component {
		id: mediaDelegate

		MediaBubble{

			id:mediaBubble

			transferState: delegateContainer.media.transfer_status == 2?"success":
						     (delegateContainer.media.transfer_status == 1?"failed":"init")

			date:Helpers.getDateText(delegateContainer.date).replace("Today", qsTr("Today")).replace("Yesterday", qsTr("Yesterday"))
			from_me:delegateContainer.from_me
			progress:delegateContainer.progress
			name: delegateContainer.name
			state_status:delegateContainer.state_status
			media: delegateContainer.media
            localPath: delegateContainer.media.local_path?delegateContainer.media.local_path:elegateContainer.media_path
			message: delegateContainer.message
			bubbleColor:delegateContainer.bubbleColor;
            mediaSize: delegateContainer.media.size?delegateContainer.media.size:0

			Connections {
				target: appWindow

				onMediaTransferProgressUpdated: {
					if (media.id == mid) {
						//consoleDebug("MESSAGE PROGRESS BUBBLE " + media.id + " - " + mprogress)
						progress = mprogress
					}
				}

				onMediaTransferSuccess: {
					if (media.id == mid) {
						consoleDebug("MESSAGE SENT! BUBBLE " + media.id + " - " + filepath)
						transferState = 2
						localPath = filepath
						delegateContainer.media_path = filepath
						transferState = "success"
						progress = 0
					}
				}

				onMediaTransferError: {
					if (media.id == mid) {
						consoleDebug("MESSAGE ERROR BUBBLE " + media.id)
						media.transfer_status = 1
						transferState = "failed"
						progress = 0
					}
				}

			}

			onOptionsRequested: {
		   		delegateContainer.optionsRequested()
			}

			onClicked: {
		   		if(from_me==0 && transferState!="success")
		   			return;

		   		var prefix = "";

	   			switch(delegateContainer.media.mediatype_id) {
					case 5:prefix = "geo:"; break;
					default: prefix = "file://"; break;
		   		}

				consoleDebug("OPENING: " + prefix + decodeURIComponent(localPath))
				Qt.openUrlExternally( prefix + decodeURIComponent(localPath) );
			}

			onUploadClicked: {
	   			if(delegateContainer.isGroup)
			   		appWindow.uploadGroupMedia(delegateContainer.media.id);
		   		else
					appWindow.uploadMedia(delegateContainer.media.id);
			}

			onDownloadClicked: {
		   		if(delegateContainer.isGroup)
			   		appWindow.fetchGroupMedia(delegateContainer.media.id);
		   		else
					appWindow.fetchMedia(delegateContainer.media.id);
			}

		}
    }

    Loader {
      id: bubbleDisplay
      sourceComponent: getBubble()
     // width:bubbleDisplay.children[0].width
      //height:bubbleDisplay.children[0].height
    }
}
