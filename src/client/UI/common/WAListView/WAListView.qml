/***************************************************************************
**
** Copyright (c) 2012, Tarek Galal <tarek@wazapp.im>
**
** This file is part of Wazapp, an IM application for Meego Harmattan
** platform that allows communication with Whatsapp users.
**
** Wazapp is free software: you can redistribute it and/or modify it under
** the terms of the GNU General Public License as published by the
** Free Software Foundation, either version 2 of the License, or
** (at your option) any later version.
**
** Wazapp is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
** See the GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with Wazapp. If not, see http://www.gnu.org/licenses/.
**
****************************************************************************/


/*** WAListView **
  *
  * A customizable listview component
  * Features:
  *     -Fast section scrolling
  *     -Single-selection
  *     -Multi-selection
  *     -Squircle masks for images
  *     -Removing items
  *     -Loading indicator (states: loading,loaded)
  *
  * Current Limitations:
  *     -allowRemove is currently not compatible with fastscroll
  *     -can't use allowRemove and selection(multi/single) at same time
  * TODO:
  *     -Make allowRemove compatible with fastscroll
  *     -Add filtering textinput
  *     -Make use of itemDescription
  *     -Specifiable model properties to use
**/

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
        if(isSelected())
            return

        WAlvhelper.selectedIndices.push(ind)

        if(ind < WAlvhelper.items.length)
            WAlvhelper.items[ind].isSelected = true

    }

    function unSelect(ind){

        var tmpind = WAlvhelper.selectedIndices.indexOf(ind)
        if(tmpind >= 0) {
            WAlvhelper.selectedIndices.splice(tmpind,1)
        }

        if(ind < WAlvhelper.items.length) {
            WAlvhelper.items[ind].isSelected = false

         }
    }

    function isSelected(ind){
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
                width:42
                height:42
                anchors.right: parent.right
                anchors.rightMargin: 10
                visible: !item.isSelected && allowRemove && !(model.noremove && model.noremove==true)
                anchors.verticalCenter: parent.verticalCenter



                BorderImage {

                   anchors.fill: parent
                   height:parent.height

                    source: "image://theme/meegotouch-sheet-button-"+(theme.inverted?"inverted-":"")+
                            "background" + (rmArea.pressed? "-pressed" : "")
                    border { left: 22; right: 22; bottom: 22; top: 22; }
                    ImageButton{
                        id:rmArea
                        source: "image://theme/icon-m-toolbar-cancle"+(theme.inverted?"-white":"")
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: {
                           item.isSelected = false
                           item.isRemoved = true
                            _removedCount++
                           removed(index)
                        }
                    }
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
                anchors.left:parent.left
                anchors.top:parent.top
                anchors.bottom: parent.bottom
                anchors.right:removeButton.left
                anchors.rightMargin: 10
                onClicked:{
                    if(!allowSelect)
                        return

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
