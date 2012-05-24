import QtQuick 1.1
import com.nokia.meego 1.0


PageStackWindow{
    initialPage: main


Page {

    id:main

    WAHeader{
        width:parent.width
    }

    Label{

        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        text:"You can only have 1 wazapp account at a time"
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        width:parent.width

    }
}

}
