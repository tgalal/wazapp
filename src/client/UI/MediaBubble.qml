// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0

SpeechBubble {

    id:mediaBubble



    property string thumb;
    property int progress:0
    property variant media;

    property string transferState;

    signal downloadClicked()
    signal uploadClicked()

    function progressUpdated(progress){
        progressBar.value=progress
    }




    Component.onCompleted: {
        var thumb = ""

        if(!media.preview){
            switch(media.mediatype_id){
                case 2:thumb = "pics/content-video.png"; break;
                case 3:thumb = "pics/content-audio.png";break;
                case 4:thumb = "pics/content-location.png";break;
            }
        }
        else if(media.mediatype_id == 2){
            thumb = media.transfer_status == 2?media.preview:("data:image/jpg;base64," + media.preview)
        }

        msg_image.imgsource = thumb
    }


//download,open,retry


    bubbleContent:Rectangle{

            id:realContainer
            width:300
            height:80
            color:"transparent"
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
                        text:delegateContainer.from_me?"Send":"Download"
                    }
                },


                State {
                    name: "success"
                    PropertyChanges {
                        target: progressBar
                        visible:false
                    }

                    PropertyChanges {
                        target: openButton
                        visible:true
                    }

                    PropertyChanges {
                        target: operationButton
                        visible:false
                    }

                    PropertyChanges {
                        target: realContainer
                        height:69
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
                        text:delegateContainer.from_me?"Sending":"Downloading"
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
                        text:"Retry"
                    }
                }

            ]

            RoundedImage {
                    id: msg_image
                    width: 75
                    size: 69
                    //imgsource: thumb;
                    anchors.left: parent.left
                }

                Item{
                    id:buttonsHolder


                    width:200
                    height:openButton.height
                    anchors.verticalCenter: msg_image.verticalCenter
                    anchors.left: msg_image.right
                    anchors.leftMargin: 3

                    Button {
                        id: openButton
                        visible:false

                        width: parent.width
                        //height: parent.height
                        font.pixelSize: 25

                        text: "Open"
                        onClicked: {
                            Qt.openUrlExternally("file:///"+media.local_path)

                        }
                    }

                    Button {
                        id: operationButton
                        visible:false

                        width: parent.width
                       // height: parent.height
                        font.pixelSize: 25
                        text: "Download"



                        onClicked: {
                             operationButton.enabled=false
                            operationButton.text="Initializing"

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
                    anchors.top:msg_image.bottom
                    anchors.topMargin: 5

                }

    }

}
