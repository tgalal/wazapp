import QtQuick 1.1
import com.nokia.meego 1.0

Page{
    property alias reason:fail_reason.text


        Item
        {
            anchors.verticalCenter: parent.verticalCenter
            width:parent.width

            Label{
                id:title
                text:"Failed:"

                platformStyle: LabelStyle {
                        textColor: "red"
                        fontPixelSize: 30

                    }
                }

            Text{
                id:fail_reason
                anchors.top:title.bottom
                anchors.topMargin: 10
                width:parent.width
                font.pointSize: 20
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere


                }
        }

}
