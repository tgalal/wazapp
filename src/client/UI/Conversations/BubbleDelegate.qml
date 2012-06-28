// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import "../common/js/Global.js" as Helpers
import "Bubbles"
import com.nokia.meego 1.0

Item {

    id:delegateContainer
    width:bubbleDisplay.width
    height:bubbleDisplay.height;

    property int mediatype_id:1
    property string message;
    property string picture;
    property bool from_me;
    property bool isGroup;
    property string date;
    property string name;
    property int msg_id;
    property string state_status;
    property int bubbleColor:1
    property string thumb
    property variant media
    property variant author
    property int progress: 0

    signal optionsRequested()

    anchors.right: from_me?this.right:parent.right
    anchors.left: !from_me?this.left:parent.left
    anchors.rightMargin: 0
    anchors.leftMargin: 0

    function getBubble(){

        switch(mediatype_id){
		    case 1: return textDelegate
		    case 2: case 3: case 4: case 5: case 6: return mediaDelegate
			case 10: return textAreaDelegate
        }
    }

    Component {
       id: textDelegate

       TextBubble{
           id:textBubble
           message:Helpers.emojifyBig(Helpers.linkify(delegateContainer.message));
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

           transferState:delegateContainer.media.transfer_status == 2?"success":
                             (delegateContainer.media.transfer_status == 1?"failed":"init")

           date:Helpers.getDateText(delegateContainer.date).replace("Today", qsTr("Today")).replace("Yesterday", qsTr("Yesterday"))
           from_me:delegateContainer.from_me
           progress:delegateContainer.progress
           name: delegateContainer.name
           state_status:delegateContainer.state_status
           media: delegateContainer.media//.preview?delegateContainer.media.preview:""
           message: delegateContainer.message
           bubbleColor:delegateContainer.bubbleColor;

           onOptionsRequested: {
               delegateContainer.optionsRequested()
           }

           onClicked: {
               if(delegateContainer.media.transfer_status != 2)
                   return;

               var prefix = "";

               switch(delegateContainer.media.mediatype_id){
                   case 5:prefix = "geo:"; break;
                   default: prefix = "file:///";break;
               }
               Qt.openUrlExternally(prefix+delegateContainer.media.local_path);
           }

           onDownloadClicked: {
               if(delegateContainer.isGroup){
                   appWindow.fetchGroupMedia(delegateContainer.media.id);
               }else{
                   appWindow.fetchMedia(delegateContainer.media.id);
               }
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
