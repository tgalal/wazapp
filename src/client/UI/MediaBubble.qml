// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0

SpeechBubble {

    id:mediaBubble



    property string thumb;
    property int progress:0
    property variant media;

    property string transferState;

	property bool loaded: false

    signal downloadClicked()
    signal uploadClicked()

    function progressUpdated(progress){
        progressBar.value=progress
    }




    Component.onCompleted: {
        var thumb = ""
		loaded = true
        if(!media.preview){
            switch(media.mediatype_id){
                case 2:thumb = "pics/content-image.png"; break;
                case 3:thumb = "pics/content-audio.png";break;
                case 4:thumb = "pics/content-video.png";break;
            }
        }
        else if(media.mediatype_id == 2){
            thumb = media.transfer_status == 2?media.preview:("data:image/jpg;base64," + media.preview)
        }

        msg_image = thumb
    }


//download,open,retry

	childrenWidth: realContainer.width

    bubbleContent: Rectangle {

        id:realContainer
        width: state=="success" ? openButton.paintedWidth : 180
        height: state=="success" ? 32 : 60
        color:"transparent"
		anchors.left: parent.left
		anchors.leftMargin: (appWindow.inPortrait?480:854) -(openButton.visible?openButton.paintedWidth:180) - 86
       // height:parent.height
        state:(mediaBubble.progress > 0 && mediaBubble.progress < 100)?"inprogress": mediaBubble.transferState
		
        states: [

            State {
                name: "init"
                PropertyChanges {
                    target: progressBar
                    visible:true
                }

                PropertyChanges {
                    target: operationButton
                    visible:!delegateContainer.from_me
                    enabled:true
                    text:delegateContainer.from_me? qsTr("Send"):qsTr("Download")
                }
            },


            State {
                name: "success"
                PropertyChanges {
                    target: progressBar
                    visible: false
                }

                PropertyChanges {
                    target: openButton
                    visible:true
                }

                PropertyChanges {
                    target: operationButton
                    visible:false
                }

            },

            State {
                name: "inprogress"

                PropertyChanges {
                    target: progressBar
                    visible:true
                }

                PropertyChanges{
                    target: operationButton
                    enabled:false
                    visible:true
                    text:delegateContainer.from_me? qsTr("Sending"):qsTr("Downloading")
                }


            },

            State {
                name: "failed"
                PropertyChanges {
                    target: progressBar
                    visible:false
                }
                PropertyChanges {
                    target: operationButton
                    visible:true
                    enabled:true
                    text: qsTr("Retry")
                }
            }

        ]

        Item{
            id:buttonsHolder

            width: openButton.visible? openButton.paintedWidth : 180
            height:openButton.height
            anchors.verticalCenter: msg_image.verticalCenter
            anchors.right: msg_image.left
            anchors.rightMargin: 10

            Label {
                id: openButton
                visible: state=="success"
                width: appWindow.inPortrait ? 480 : 854
				font.family: "Nokia Pure Light"
				font.weight: Font.Light
				font.pixelSize: 23
				color: from_me? "black" : "white"
                text: qsTr("Multimedia message")
				onVisibleChanged: {
					//if (state!="success") return;
					//fromMediaDownloaded = true
					//listSizeNum = listSizeNum-28
					//fromMediaDownloaded = false
				}
            }

            Button {
                id: operationButton
                visible:false

                width: parent.width
                height: 38
                font.pixelSize: 20
                text: qsTr("Download")

                onClicked: {
                     operationButton.enabled=false
                    operationButton.text= qsTr("Initializing")

                    if(delegateContainer.from_me)
                        uploadClicked()
                    else
                        downloadClicked()


                }


            }

        }

        ProgressBar {
            id: progressBar
            minimumValue: 0
            maximumValue: 100
            value:progress
            width: parent.width-20
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top:buttonsHolder.bottom
            anchors.topMargin: 10
			visible: state!="success"

        }

    }

}
