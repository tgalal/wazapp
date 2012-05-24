// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

Rectangle {
    width: parent.width
    height:top_margin.height+bottom_margin.height+1;
    color:"transparent"
    property alias top_margin:top_margin.height
    property alias bottom_margin:bottom_margin.height

    Column
    {
        anchors.fill: parent;
        Rectangle{
            id:top_margin
            width:parent.width
            color:"transparent"
        }


        Rectangle{
            width:parent.width
            height:1
            color:"white"
        }

        Rectangle{
            id:bottom_margin
            width:parent.width
            color:"transparent"
        }
    }
}
