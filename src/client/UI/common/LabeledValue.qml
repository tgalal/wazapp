import QtQuick 1.1
import com.nokia.meego 1.0

Row {
    id: labeledValueContainer
    width:parent.width - 10
    height:Math.max(l.height, v.height)

    property alias label: l.text
    property alias value: v.text

    Label{
        id:l
        width:labeledValueContainer.width/2
    }

    Label{
        id:v
        width:labeledValueContainer.width/2
    }


}
