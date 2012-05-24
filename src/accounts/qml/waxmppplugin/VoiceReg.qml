import QtQuick 1.1
import com.nokia.meego 1.0

Page{
    property string phoneNumber;

    //tools:editTools



    Column{
       anchors.fill: parent
       spacing:10

    WAHeader{
        width:parent.width
    }


   Label{
       text:"Click the next button to send the registration code to"
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
