// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import "../../../common"

Item {
    property alias model:walistview.model
    property alias delegate:walistview.delegate

    function positionViewAtBeginning (){
        walistview.positionViewAtBeginning()
    }

    anchors.fill: parent
    ListView {

        id: walistview
        anchors.fill: parent
        clip: true
        spacing: 1
        cacheBuffer: 30000
        highlightFollowsCurrentItem: false

        section.property: "name"
        section.criteria: ViewSection.FirstCharacter

        section.delegate: GroupSeparator {
            anchors.left: parent.left
            anchors.leftMargin: 16
            width: parent.width - 44
            height: 50//searchInput.text==="" ? 50 : 0
            title: section
        }

        Component.onCompleted: {  fast.listViewChanged();}
        onCountChanged: { fast.listViewChanged();

        }

    }

    FastScroll {
        id: fast
        listView: walistview
        enabled: allowFastScroll
        visible: allowFastScroll

        //enabled: searchInput.text===""
    }
}

