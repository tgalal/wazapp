// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import "../common"
import com.nokia.meego 1.0
import com.nokia.extras 1.0
WAPage {

    property string operation:qsTr("Initializing")
    property string subOperation:""
    property string version:waversion
    orientationLock: PageOrientation.LockPortrait

    function setCurrentOperation(op) {
		progress.visible = false
        subOperation = ""
        operation = qsTr(op)
    }

    function setSubOperation(subop) {
        subOperation = subop
    }

	function setProgressMax(val) {
		progress.maximumValue = val
	}

	function setProgress(val) {
		progress.value = val
	}

	function resetProgress() {
        //progress.visible = true
		progress.value = 0
	}

    onStatusChanged: {
      /*  if(status == PageStatus.Activating){
            appWindow.showStatusBar = false
            appWindow.showToolBar = false
        } else if(status == PageStatus.Deactivating) {
              appWindow.showStatusBar = true
              appWindow.showToolBar = true
        }*/
    }

    Image {
        id: name
        source: "../common/images/splash/wasplash90.png"
        anchors.fill: parent
        smooth: true

    }

    Column{
        width:parent.width
		spacing: 20
        y:450

        Label{
            text:operation
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            font.bold: true
            width:parent.width
        }

		ProgressBar{
			id: progress
			width: 360
            visible:false
			anchors.horizontalCenter: parent.horizontalCenter
			minimumValue: 0
			platformStyle: ProgressBarStyle {
				knownTexture: "../common/images/splashprogress.png"
			}
        }

        Label{
            text:subOperation
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            width:parent.width
        }
    }

    Label{
        text:version
        width:parent.width
        horizontalAlignment: Text.AlignHCenter
        color:"white"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
    }

}
