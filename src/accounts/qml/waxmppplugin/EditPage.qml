import QtQuick 1.1
import com.nokia.meego 1.0

Page{
    property string phoneNumber;
    property string pushName;
    property string status:"Offline"

    tools:editTools
    anchors.margins: 5

    Column{
       anchors.fill: parent
       spacing:10

    WAHeader{
        width:parent.width
    }

   Label{
       id:userId
       width:parent.width
       text:"This Wazapp account is connected to "+phoneNumber
       wrapMode: Text.WrapAtWordBoundaryOrAnywhere
   }

   Label
   {
       id:currStatus
       //text:"Current status: "+status
   }


    LabeledField{
        id:push_field
        label: "Your push name"
        width:parent.width
        value: pushName?pushName:"";
    }

    Button{
        text:"Save"
        onClicked: {
            if(push_field.value.trim() == ""){
                showNotification("Push name cannot be left empty")
            }
            else{
                actor.savePushName(push_field.value)
                showNotification("Push name saved");

            }
        }
    }
}
}
