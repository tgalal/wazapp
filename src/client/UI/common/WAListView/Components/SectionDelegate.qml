// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import "../../../common"
Item{
     id:sectionDelegateRoot
     property string currSection;
     property bool renderSection:true;


     Loader{
         id:delegateLoader
         sourceComponent: renderSection?sectionDelegateComponent:noSectionDelegateComponent
     }


    Component {
        id:sectionDelegateComponent
        GroupSeparator {
                    id:sectionDelegate
                    width: sectionDelegateRoot.width
                    height: sectionDelegateRoot.height
                    title: sectionDelegateRoot.currSection
                }
    }

    Component{
        id:noSectionDelegateComponent
        Item{}
    }

}
