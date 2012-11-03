// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0

import "Components"
import "../../common"
import "js/walistview.js" as WAlvhelper


Rectangle {
    id:walistviewroot
    property ListModel model;
    property string defaultPicture;
    property bool multiSelectMode:false
    property bool allowSelect:true
    property bool allowRemove:false
    property bool allowFastScroll:true
    property bool useRoundedImages:true
    property string emptyLabelText:qsTr("No data")

    property int _removedCount:0;

    signal removed(int index)
    state: model?"loaded":"loading"
    signal selected(variant selectedItem)

    /**********************/

    states: [

        State {
            name: "loading"
            PropertyChanges {
                target: busyIndicator
                visible:true
            }

            PropertyChanges {
                target: walistview
                visible:false
            }
        },
        State {
            name: "loaded"
            PropertyChanges {
                target: busyIndicator
                visible:false
            }

            PropertyChanges {
                target: walistview
                visible: model.count - _removedCount > 0
            }

            PropertyChanges {
                target: emptyLabel
                visible:model.count - _removedCount == 0
            }
        }
    ]

    function reset(){
        _removedCount=0
        //WAlvhelper.items = new Array()
        resetSelections()
        positionViewAtBeginning()

    }

    function positionViewAtBeginning (){
        walistview.item.positionViewAtBeginning()
         consoleDebug("Positioned to beginning!")
    }

    function resetSelections(){

        var selected = getSelected()
        for (var i=0; i<selected.length; i++){

            unSelect(selected[i].selectedIndex)
        }

         WAlvhelper.selectedIndices = new Array()
    }

    function getItems(){
        return WAlvhelper.items
    }


    function select(ind){
        consoleDebug("In selector")
        if(isSelected())
            return

        consoleDebug("SELECTING "+ind)
        WAlvhelper.selectedIndices.push(ind)

        if(ind < WAlvhelper.items.length)
            WAlvhelper.items[ind].isSelected = true

    }

    function unSelect(ind){

        var tmpind = WAlvhelper.selectedIndices.indexOf(ind)
        if(tmpind >= 0) {
            consoleDebug("SPLICED! "+tmpind)
            WAlvhelper.selectedIndices.splice(tmpind,1)
        }
        consoleDebug(ind+":::::>>>>>"+WAlvhelper.items.length)
        if(ind < WAlvhelper.items.length) {
            consoleDebug("CHANGE!")
            WAlvhelper.items[ind].isSelected = false

         }
    }

    function isSelected(ind){
        //return  WAlvhelper.items[ind].isSelected
        return (WAlvhelper.selectedIndices.indexOf(ind) >= 0)
    }

    function getSelected(){
       //return WAlvhelper.selectedItems;
        var selectedItems = new Array();
        for(var i=0; i<WAlvhelper.items.length; i++) {
            if(WAlvhelper.items[i].isSelected)
                selectedItems.push({selectedIndex:i, data:WAlvhelper.items[i].modelData})
        }

        return selectedItems;
    }

    anchors.top: parent.top
    //anchors.topMargin: 73 + searchbar.height
    width:parent.width
    height:parent.height - 73 //- searchbar.height
    color: "transparent"
    clip: true


    Loader{
       id:walistview
       sourceComponent: allowFastScroll?listviewfast:listviewsimple
        anchors.fill: parent
    }


    Component{
        id:listviewsimple
        ListViewSimple {
            model: walistviewroot.model
            delegate:listDelegate
            anchors.fill: parent
        }
    }

    Component{
        id:listviewfast
        ListViewFast {
             model:walistviewroot.model
             delegate: listDelegate
             anchors.fill: parent
        }
    }

    BusyIndicator {
        id: busyIndicator
        platformStyle: BusyIndicatorStyle { size: "large";}
        anchors.centerIn: parent
        visible:false
        running: visible
    }

    Label {
        id:emptyLabel
        anchors.centerIn: parent
        text:emptyLabelText
        visible:false
    }

    Component{
        id:listDelegate

        Rectangle
        {
            id:item

            Component.onCompleted: {
                    WAlvhelper.items.push(item)
                    item.isSelected = walistviewroot.isSelected(index);
            }

           /* Connections{
                target: walistviewroot
                onItemClicked:{
                    console.log("INSIDE CONNECTION")
                    console.log(clickedIndex)
                    if(clickedIndex == index){isSelected = walistviewroot.isSelected(index);}

                }
            }*/

            property variant modelData: model
            //property bool filtered: model.name.match(new RegExp(searchInput.text,"i")) != null

            property string itemName: model.name
            //property string showContactName: searchInput.text.length>0 ? replaceText(model.name, searchInput.text) : model.name
            property string itemPicture: model.picture || defaultPicture
            property string itemDescription:model.description || ""

            property bool isSelected
            property bool isRemoved
            property bool render:!model.norender || model.norender == false;

            //height: filtered ? 80 : 0
            height:!render || isRemoved?0:80
            visible:!isRemoved
            width: parent.width
            color: "transparent"
            clip: true

            Rectangle {
                anchors.fill: parent
                color: theme.inverted? "darkgray" : "lightgray"
                opacity: theme.inverted? 0.2 : 0.8
                visible: allowSelect?(mouseArea.pressed || isSelected):false
            }

            Loader{
               sourceComponent: useRoundedImages?item_picture_rounded:item_picture_rect
            }

            Component{
                id:item_picture_rect
                Image {
                    id: item_picture
                    x: 16

                    width: 62
                    height: 62
                    source: itemPicture
                    anchors.topMargin: -2
                    y: 8
                }

            }

            Component{
                id:item_picture_rounded

                RoundedImage {
                    id: item_picture
                    x: 16
                    size:62
                    imgsource: itemPicture
                    anchors.topMargin: -2
                    y: 8
                }

            }

            Column{
                y: 2
                x: 90
                width: parent.width -100
                anchors.verticalCenter: parent.verticalCenter
                Label{
                    y: 2
                    text: itemName
                    font.pointSize: 18
                    elide: Text.ElideRight
                    width: parent.width -56
                    font.bold: true
                }
            }

            Item {
                id: removeButton
                width:100
                height:parent.height
                anchors.right: parent.right
                //anchors.rightMargin: 5
                visible: !item.isSelected && allowRemove && !(model.noremove && model.noremove==true)


                BorderImage {

                    anchors.centerIn: parent
                    width: 42
                    height: 42
                    z:1


                    source: "image://theme/meegotouch-sheet-button-"+(theme.inverted?"inverted-":"")+
                            "background" + (rmArea.pressed? "-pressed" : "")
                    border { left: 22; right: 22; bottom: 22; top: 22; }
                    Image {
                        y: 2
                        source: "image://theme/icon-m-toolbar-cancle"+(theme.inverted?"-white":"")
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                }


                MouseArea {
                    id: rmArea
                    anchors.fill: parent
                    onClicked: {
                       item.isSelected = false
                       item.isRemoved = true
                        _removedCount++
                       removed(index)
                    }
                    z: 2
                }
            }



            Image {
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                source: "../images/done-" + (theme.inverted? "white" : "black") + ".png"
                visible: allowSelect?isSelected:false
            }

            MouseArea{
                id:mouseArea
                anchors.fill: parent
                anchors.right:removeButton.left
                anchors.rightMargin: 10
                onClicked:{
                    if(!allowSelect)
                        return
                    consoleDebug("Clicked")

                    if(!multiSelectMode)
                        walistviewroot.selected(model)
                    else{
                        if(!walistviewroot.isSelected(index))
                            select(index)
                        else
                            unSelect(index)
                    }
                }
            }

        }
    }

}
