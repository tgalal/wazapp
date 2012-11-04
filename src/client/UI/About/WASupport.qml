// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import "../common"

WAPage {
   id:root
   tools:supportTools

   state: (screen.currentOrientation == Screen.Portrait) ? "portrait" : "landscape"

   states: [
       State {
           name: "landscape"

           PropertyChanges{target:wazappIcon;  parent:landscapeRow;}
           PropertyChanges{target:supportData;  parent:landscapeRow; width:root.width - wazappIcon.width-20; x:20}

       },

       State {
           name: "portrait"
           PropertyChanges{target:wazappIcon;  parent:portraitColumn; x: root.width/2-(0.5*wazappIcon.width)}
            PropertyChanges{target:supportData;  parent:portraitColumn; width:root.width}
       }
   ]

   WAHeader{
       id:header
       height: 73
       title: "Support Wazapp"
   }

   Row{
       id:landscapeRow
       anchors.top:header.bottom
       anchors.topMargin: 30
       //anchors.verticalCenter: parent.verticalCenter
       anchors.horizontalCenter: parent.horizontalCenter

      }

   Column {
       id:portraitColumn
       width:root.width
       anchors.verticalCenter: parent.verticalCenter
       spacing: 10
       Image{
           id:wazappIcon
           //anchors.horizontalCenter: parent.horizontalCenter
           source: "../common/images/icons/wazapp128.png"
           //x: root.width/2-(0.5*wazappIcon.width)
       }

       Column{
           id:supportData
           width:root.width
           spacing:10

           Label{
               text:qsTr("Wazapp is a free open source software created entirely by the N9 Community. If you enjoy using Wazapp, you can support it by making a donation. Your donation helps maintain Wazapp and further development, as well as keeping it always a Free Software")
               width:parent.width
               horizontalAlignment: Text.AlignHCenter
           }

           Button{
               anchors.horizontalCenter: parent.horizontalCenter
               text:"Donate"
               onClicked: {
                   Qt.openUrlExternally("https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=PWX6647R3CD5L")
               }
           }

           Label{
               id:bugReportText
               width:parent.width
               horizontalAlignment: Text.AlignHCenter
               text:qsTr("Please Report any bugs to") + " <a href='http://bugs.wazapp.im'>http://bugs.wazapp.im</a>"
               onLinkActivated: Qt.openUrlExternally(link)
           }
       }
   }

   ToolBarLayout {
       id:supportTools

       ToolIcon{
           platformIconId: "toolbar-back"
           onClicked: pageStack.pop()
       }
   }

}
