// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import "../common"
import "../EmojiDialog"

WAPage {
   tools:testtools

   Column{
       anchors.centerIn: parent
       anchors.leftMargin: 10;
       anchors.rightMargin: 10;

       Label{
           width:parent.width
           text:"WATextArea:"
       }

       WATextArea{
           id:textareatest
           width:parent.width
       }

       Button{
           text:"Emoji"
           onClicked: {
               emojiDialog.openDialog(textareatest, "/home/tarek/Projects/Wazapp/wazapp/src/client/UI/common/images/emoji");
           }

       }
   }


   ToolBarLayout {
       id:testtools

       ToolIcon{
           platformIconId: "toolbar-back"
           onClicked: pageStack.pop()
       }
   }

   Emojidialog{
       id:emojiDialog
   }

}
