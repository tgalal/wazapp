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

       contentHeight:header.height + creditsContainer.height+10

       WAHeader{
           id:header
           height:73
           title:qsTr("Wazapp Champions")
       }

       Column{
           id:creditsContainer
           anchors.top:header.bottom
           anchors.topMargin: 10
           anchors.left:parent.left
           anchors.right: parent.right
           spacing:15


           GroupSeparator{
                color:"#27a01b"
                title:qsTr("Upstream Author")
           }

           CreditItem{
               id:tgalalCredit
               image: "images/contribs/tarek.png"
               label: "Tarek Galal (tgalal)"
               role: qsTr("Official author, Wazapp creator")
               twitter: "http://twitter.com/tgalal"
               url: "http://posts.tgalal.com"
               github: "https://github.com/tgalal"
               linkedin: "http://www.linkedin.com/profile/view?id=45300606"
           }

           GroupSeparator{
                color:"#27a01b"
                title:qsTr("Major Contributors")
           }

           CreditItem{
               image: "images/contribs/matias.png"
               label: "Matias Perez (Cepiperez)"
               role: qsTr("UI Champion")
               twitter: "http://twitter.com/negrocepi"
           }

           CreditItem{
               image: "images/contribs/bojan.png"
               label: "Bojan Komljenovic (Knobtviker)"
               role: qsTr("Developer")
               twitter: "http://twitter.com/knobtviker"
           }

           CreditItem{
               image: "images/contribs/andrey.png"
               label: "Andrey Kozhevnikov (Coderus)"
               role: qsTr("Developer")
               twitter: "http://twitter.com/iCODeRUS"
           }

           GroupSeparator{
                color:"#27a01b"
                title:qsTr("Thanks to")
           }

           CreditItem{
               image: "images/contribs/fabian.png"
               label: "Fabian Sauter (brkn)"
               role: qsTr("Developer, Wiki Creator")
               url: "http://wiki.maemo.org/Wazapp"
               twitter: "http://twitter.com/binbrkn"
           }

           CreditItem{
               image: "images/contribs/andreas.png"
               label: "Andreas Adler (The Best Isaac)"
               role: qsTr("Icons Artist")
               url: "http://talk.maemo.org/member.php?u=59328"
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
