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
    property string linkedin;

    function unFocus(){
        contribWazapp.pressed = false
    }


    RoundedImage{
        id:contribImg
        //fillMode: Image.PreserveAspectFit
        imgsource: "../About/"+image
        size: 120
        height:120
        width:120
    }

    Column{

        spacing:3
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
                id:contribTwit
                source: "../images/icons/twitter.png"
                visible:twitter?true:false
                onClicked: Qt.openUrlExternally(twitter)
            }


            ImageButton{
                id:contribGithub
                source:"../images/icons/github.png"
                visible:github?true:false

                onClicked: Qt.openUrlExternally(github)
            }

            ImageButton{
                id:contribLinkedin
                source:"../images/icons/linkedin.png"
                visible:linkedin?true:false

                onClicked: Qt.openUrlExternally(linkedin)
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
