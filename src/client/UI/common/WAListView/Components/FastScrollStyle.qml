// FastScrollStyle.qml
import QtQuick 1.1
import com.nokia.meego 1.0 // for Style

Style {

    // Font
    property int fontPixelSize: 68
    property bool fontBoldProperty: true

    // Color
    property color textColor: inverted?"#000":"#fff"

    property string handleImage: "image://theme/meegotouch-fast-scroll-handle"+__invertedString
    property string magnifierImage: "image://theme/meegotouch-fast-scroll-magnifier"+__invertedString
    property string railImage: "image://theme/meegotouch-fast-scroll-rail"+__invertedString
}
