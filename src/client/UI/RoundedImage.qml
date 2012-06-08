import QtQuick 1.1
import com.nokia.meego 1.0

Item {
    id: container

    property string imgsource
    property int size
    property bool rounded: true
	property string istate: "Loading..."
    property alias  asynchronous: image1.asynchronous

	//signal clicked
	//signal pressAndHold

    height: size
    width: size

    MaskedItem {
        id: mask
        x:0; y:0
        width: size
        height: size
        visible: rounded

        mask: Image {
            width: size
            height: size
            smooth: true
            fillMode: Image.Stretch
            source: "pics/usermask.png"
        }

        Image
        {
            id: image1
            x:0; y:0
            width: size
            height: size
            smooth: true
            fillMode: Image.PreserveAspectCrop

            source: imgsource.substr(-4)==".mp3" ? "pics/content-audio.png" :
					imgsource.substr(-4)==".m4a" ? "pics/content-audio.png" :
					imgsource.substr(-4)==".wav" ? "pics/content-audio.png" :    
					imgsource.substr(-4)==".amr" ? "pics/content-audio.png" :    
					imgsource.substr(-4)==".mp4" ? "pics/content-video.png" : 
					imgsource.substr(-4)==".3gp" ? "pics/content-video.png" :
					imgsource.substr(-4)==".avi" ? "pics/content-video.png" :
					imgsource.substr(-4)==".vcf" ? "pics/user.png" : imgsource
			onStatusChanged: {
                if (image1.status==Image.Ready) istate="Loaded!";
				if (image1.status==Image.Error) istate=imgsource;
            }
        }
    }

    Image
    {
        x:0; y:0
        width: size
        height: size
        smooth: true
        asynchronous: true
        fillMode: Image.Stretch
        source: "pics/userborder.png"
        visible: imgsource != "" && rounded
    }

    /*MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: container.clicked()
		onPressAndHold: container.pressAndHold()
    }*/

}
