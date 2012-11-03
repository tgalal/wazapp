// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import "../../common"

Row{
    spacing:10

    property string image;
    property alias label: contribLabel.text;
    property alias role: contribRole.text;
    property string twitter;
    property string url;
    property string jid;
    property string github;

    function unFocus(){
        contribWazapp.pressed = false
    }

    Connections{
        target: creditsFlickable
        onMovementStarted:{
            var items = [contribWazapp, contribUrl, contribGithub, contribTwit];

            for(var i in items){
                items[i].pressed = false
            }
        }
    }

    RoundedImage{
        id:contribImg
        //fillMode: Image.PreserveAspectFit
        imgsource: "../About/"+image
        size: 130
        height:130
        width:130
    }

    Column{

        spacing:5
        Label{
            id:contribLabel
        }
        Label{
            id:contribRole
            text:"Main author"
        }
        Row{
            id:imageButtonRow
            spacing:5

            ImageButton{
                id:contribWazapp
                source:"../../common/images/icons/wazapp48.png"
                visible:jid?true:false

                onClicked: {
                    openConversation(jid)
                }
            }

            ImageButton{
                id:contribGithub
                source:"../images/icons/github.png"
                visible:github?true:false

                onClicked: Qt.openUrlExternally(github)
            }


            ImageButton{
                id:contribTwit
                source: "../images/icons/twitter.png"
                visible:twitter?true:false
                onClicked: Qt.openUrlExternally(twitter)
            }

            ImageButton{
                id:contribUrl
                source: "../images/icons/browser.png"
                visible:url?true:false;
                onClicked: Qt.openUrlExternally(url)
            }


        }
    }
}
