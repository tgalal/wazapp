// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import "../common"
import "Components"

WAPage {
   id:creditsRoot
   tools:creditsTools

   Flickable{

       id:creditsFlickable
       anchors.fill: parent
       anchors.leftMargin: 2
       anchors.rightMargin: 10

       contentHeight:header.height + creditsContainer.height

       WAHeader{
           id:header
           height:73
           title:"Wazapp Champions"
       }

       Column{
           id:creditsContainer
           anchors.top:header.bottom
           anchors.left:parent.left
           anchors.right: parent.right
           spacing:5


           GroupSeparator{
                color:"#27a01b"
                title:qsTr("Upstream Author")
           }

           CreditItem{
               id:tgalalCredit
               image: "images/contribs/tarek.png"
               label: "Tarek Galal (tgalal)"
               role: qsTr("Official author, Wazapp creator")
               twitter: "@tgalal"
               url: "http://www.wazapp.im"
               jid:"4915225256022@s.whatsapp.net"
               github: "https://github.com/tgalal"
           }

           GroupSeparator{
                color:"#27a01b"
                title:qsTr("Major Contributors")
           }

           CreditItem{
               image: "images/contribs/matias.png"
               label: "Matias Perez (Cepiperez)"
               role: qsTr("UI Champion")
               twitter: "@tgalal"
               url: "http://www.wazapp.im"
           }

           CreditItem{
               image: "images/contribs/bojan.png"
               label: "Bojan Komljenovic (Knobtviker)"
               role: qsTr("Developer")
               twitter: "@tgalal"
               url: "http://www.wazapp.im"
           }

           CreditItem{
               image: "images/contribs/andrey.png"
               label: "Andrey Kozhevnikov (Coderus)"
               role: qsTr("Developer")
               twitter: "@tgalal"
               url: "http://www.wazapp.im"
           }

       }
   }


   ToolBarLayout {
       id:creditsTools

       ToolIcon{
           platformIconId: "toolbar-back"
           onClicked: pageStack.pop()
       }
   }

}
