import QtQuick 1.1
import com.nokia.meego 1.0

Page{

    property string changes;
    property string version;
    property string summary;
    property string urgency;
    property string url;

    tools: updateTools

    WAHeader{
        id:page_header
        title: "Update"
        anchors.top:parent.top
        width:parent.width

    }

    Component.onCompleted: {




    }

    Flickable{
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top:page_header.bottom
        anchors.bottom: parent.bottom
        anchors.margins: 10
        clip: true

        contentHeight: updateDataContainer.height

        Column{
            id:updateDataContainer
            spacing:5;
            width:parent.width

            Row{
                spacing:10
                width:parent.width

                Label{
                    text: "Latest Version:"
                    font.bold: true
                }

                Label{
                    text: version
                    font.italic: true
                }
            }

            Row{
                spacing:10
                width:parent.width

                Label{
                    text: "Urgency:"
                    font.bold: true
                }

                Label{
                    text: urgency
                    font.italic: true
                }
            }


            Label{
                id:summary_label
                text: "Summary:"
                font.bold: true
            }

            Label{
                width:parent.width //- summary_label.width
              //  font.italic: true
                wrapMode: Text.WordWrap
                text:summary
            }




                Label{
                    id:changes_label
                    text: "Changes:"
                    font.bold: true
                }

                Label{
                    width:parent.width// - summary_label.width
                    //font.italic: true
                    wrapMode: Text.WordWrap
                    text:changes

                }
        }

    }

    ToolBarLayout {
        id: updateTools

        ToolIcon {
            iconId: "toolbar-back";
            onClicked: { appWindow.pageStack.pop() }
       }

        ToolButton {
            text: qsTrId("Update")
            anchors.centerIn: parent
            onClicked: {
                Qt.openUrlExternally(url);
                appWindow.pageStack.pop()
            }
        }


    }
}
