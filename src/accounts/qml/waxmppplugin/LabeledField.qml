import QtQuick 1.1
import com.nokia.meego 1.0

Item {
    id:container
    property alias label:lf_label.text
    property alias value:lf_value.text
    property string input_size:"wide" //wide, medium, small
    property alias inputMethodHints:lf_value.inputMethodHints
    property alias enabled:lf_value.enabled

    height:lf_label.height + lf_value.height

    Column{
        id:lf_holder
        spacing:2
        width:parent.width

        Label{
            id:lf_label
            width:parent.width
        }

        TextField{
            id:lf_value
            width:input_size =="wide"?parent.width:input_size=="medium"?parent.width/2:parent.width/4;


        }
    }

}
