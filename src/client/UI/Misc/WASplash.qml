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
        subOperation = ""
        operation = qsTr(op)
    }

    function setSubOperation(subop) {
        subOperation = subop
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
        y:450

        Label{
            text:operation
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            font.bold: true
            width:parent.width
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
