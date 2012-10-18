// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
Rectangle {
   id: emojiDelegate
   property string code
   property string emojiPath;
   width: emojiWidth -1
   height: emojiHeight -1
   property bool  spawned: false
   property bool landscape: false
   visible:landscape && screen.currentOrientation == Screen.Landscape || !landscape &&  screen.currentOrientation == Screen.Portrait


   signal selected(string code);

   Behavior on y {
       enabled:spawned && visible
       SpringAnimation{ spring: 2; damping: 0.2 }
   }

   Rectangle {
       anchors.fill: parent
       color:mousearea.pressed ? "#218ade":"#3c3c3b"
   }
   Image {
       id:emojiImage
       source: emojiPath?"../"+emojiPath:""
       anchors.horizontalCenter: parent.horizontalCenter
       anchors.verticalCenter: parent.verticalCenter
       width: 32
       height: 32
   }
   MouseArea {
       id: mousearea
       anchors.fill: parent
       onClicked: {
           //selectEmoji(emojiDelegate.codeS)
           selected(code)
       }
   }
}
