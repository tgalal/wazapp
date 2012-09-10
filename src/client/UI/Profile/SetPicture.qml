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
// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import "../common"

WAPage {
    id:container

    tools: ToolBarLayout {
        id: toolBar
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
    }


	Rectangle {
        property bool isClicked: false
        property int count : 0
        id: imageArea
        anchors.fill: parent

        Image {
            id: image
            source: selectedPicture
            anchors.centerIn: parent
            smooth: true
            asynchronous: true
        }
        MouseArea {
            anchors.fill: parent
            property real old_x : 0
            property real old_y : 0
 
            onPressed:{
                var tmp = mapToItem(root, mouse.x, mouse.y);
                old_x = tmp.x;
                old_y = tmp.y;
            }
 
            onPositionChanged: {
                var tmp = mapToItem(root, mouse.x, mouse.y);
                var delta_x = tmp.x - old_x;
                var delta_y = tmp.y - old_y;
                imageArea.x += delta_x;
                imageArea.y += delta_y;
                old_x = tmp.x;
                old_y = tmp.y;
            }
            onPressAndHold: {
                pincharea.enabled = true
            }
        }
 
        PinchArea {
            id: pincharea
            enabled: false
            anchors.fill: parent
            pinch.target: imageArea
            property double __oldZoom
 
            onPinchStarted: {
                __oldZoom =  pinch.scale
            }
 
            onPinchUpdated: {
                imageArea.count = pinch.scale
                if(__oldZoom  < pinch.scale){
                    imageArea.height = imageArea.height + (imageArea.count * 1)
                    imageArea.width = imageArea.width + (imageArea.count * 1)
                }
                else{
                    imageArea.height = imageArea.height - (imageArea.count * 5)
                    imageArea.width = imageArea.width - (imageArea.count * 5)
                }
            }
 
            onPinchFinished: {
                imageArea.count = pinch.scale
 
                if(__oldZoom < pinch.scale){
                    imageArea.height = imageArea.height + (imageArea.count * 1)
                    imageArea.width = imageArea.width + (imageArea.count * 1)
                }
                else{
                    imageArea.height = imageArea.height - (imageArea.count * 5)
                    imageArea.width = imageArea.width - (imageArea.count * 5)
                }
                pincharea.enabled = false
            }
        }
    }


}
