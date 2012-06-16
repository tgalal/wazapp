import QtQuick 1.1
import com.nokia.meego 1.0
import "/usr/lib/qt4/imports/com/nokia/meego/UIConstants.js" as UI


Item {
    id: root

    // Common API
    property string text
    signal clicked
    property alias pressed: mouseArea.pressed
	property bool singleItem: false

    // platformStyle API
    property Style platformStyle: MenuItemStyle{}
    property alias style: root.platformStyle // Deprecated

    width: parent ? parent.width: 0
    height: ( root.platformStyle.height == 0 ) ?
            root.platformStyle.topMargin + menuText.paintedHeight + root.platformStyle.bottomMargin :
            root.platformStyle.topMargin + root.platformStyle.height + root.platformStyle.bottomMargin
/*
    Rectangle {
       id: backgroundRec
       // ToDo: remove hardcoded values
       color: pressed ? "darkgray" : "transparent"
       anchors.fill : root
       opacity : 0.5
    }
*/
    BorderImage {
       id: backgroundImage
       // ToDo: remove hardcoded values
       source:  singleItem ? (pressed ? "image://theme/meegotouch-list-"+(theme.inverted?"inverted-":"")+"background-pressed" : 
				"image://theme/meegotouch-list-"+(theme.inverted?"inverted-":"")+"background")
              : root.parent.children[0] == root ? 
				(pressed ? "image://theme/meegotouch-list-"+(theme.inverted?"inverted-":"")+"background-pressed-vertical-top" : 
				"image://theme/meegotouch-list-"+(theme.inverted?"inverted-":"")+"background-vertical-top")
              : root.parent.children[root.parent.children.length-1] == root ? 
				(pressed ? "image://theme/meegotouch-list-"+(theme.inverted?"inverted-":"")+"background-pressed-vertical-bottom" : 
				"image://theme/meegotouch-list-"+(theme.inverted?"inverted-":"")+"background-vertical-bottom")
              : (pressed ? "image://theme/meegotouch-list-"+(theme.inverted?"inverted-":"")+"background-pressed-vertical-center" : 
				"image://theme/meegotouch-list-"+(theme.inverted?"inverted-":"")+"background-vertical-center")
       anchors.fill : root
       border { left: 22; top: 22;
                right: 22; bottom: 22 }
    }

    Text {
        id: menuText
        text: parent.text
        elide: Text.ElideRight
        font.family : root.platformStyle.fontFamily
        font.pixelSize : root.platformStyle.fontPixelSize
        font.weight: root.platformStyle.fontWeight
        color: root.platformStyle.textColor

        anchors.topMargin : root.platformStyle.topMargin
        anchors.bottomMargin : root.platformStyle.bottomMargin
        anchors.leftMargin : root.platformStyle.leftMargin
        anchors.rightMargin : root.platformStyle.rightMargin

        anchors.top : root.platformStyle.centered ? undefined : root.top
        anchors.bottom : root.platformStyle.centered ? undefined : root.bottom
        anchors.left : root.left
        anchors.right : root.right
//        anchors.centerIn : parent.centerIn
        anchors.verticalCenter : root.platformStyle.centered ? parent.verticalCenter : undefined
  }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: { if (parent.enabled) parent.clicked();}
    }

    onClicked: if (parent) parent.closeLayout();
}

