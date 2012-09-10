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
import QtQuick 1.1
import com.nokia.meego 1.0

import "js/contacts.js" as ContactsManager
import "../common/js/Global.js" as Helpers
import "../common"
import "../Menu"

Item {

	anchors.fill: parent
	property bool selecting: false
	property string listdelegate: "myDelegate"

	Connections {
		target: appWindow
		onContactsAtStart: list_view1.positionViewAtBeginning()
		onContactsSetFocus: list_view1.forceActiveFocus()
	}

	function getItem(index) {
		list_view1.currentIndex = index
		return list_view1.currentItem
	}

	function isSelected(index) {
		list_view1.currentIndex = index
		return list_view1.currentItem.isSelected
	}

    function replaceText(text,str) {
        var ltext = text.toLowerCase()
        var lstr = str.toLowerCase()
        var ind = ltext.indexOf(lstr)
        var txt = text.substring(0,ind)
        text = txt + "<u><font color=#4591FF>" +
               text.slice(ind,ind+str.length)  + "</font></u>" +
               text.slice(ind+str.length,text.length);
        return text;
    }

    ListView {
        id: list_view1
		anchors.fill: parent
        clip: true
        model: contactsModel
        delegate: listdelegate=="myDelegate" ? myDelegate : selectDelegate
        spacing: 1
		cacheBuffer: 20000 // contactsModel.count * 81 --> will this work? I'll check later
		highlightFollowsCurrentItem: false
        section.property: "alphabet"
        section.criteria: ViewSection.FirstCharacter

        section.delegate: GroupSeparator {
			anchors.left: parent.left
			anchors.leftMargin: 16
			width: parent.width - 44
			height: searchFilter==="" ? 50 : 0
			title: section
		}

		Component.onCompleted: fast.listViewChanged()

        onContentYChanged:  {
            if ( list_view1.visibleArea.yPosition < 0)
            {
                if ( !searBarVisible )
                    onShowSearchBar()
            }
        }
    }

	FastScroll {
		id: fast
		listView: list_view1
		enabled: searchFilter===""
	}

    Component{
        id:myDelegate

        Contact{
            property bool filtered: model.name.match(new RegExp(searchFilter,"i")) != null
            id:contactComp
            height: filtered ? 80 : 0
			visible: height!=0
            Component.onCompleted: {
                ContactsManager.contactsViews.push(contactComp)
            }

            jid:model.jid
            picture:model.picture
            contactName: model.name
			contactShowedName: searchFilter.length>0 ? replaceText(model.name, searchFilter) : model.name
            contactStatus:model.status;
            contactNumber:model.number

			onOptionsRequested: {
				profileUser = model.jid
				contactMenu.open()
			}

            onClicked: {
				hideSearchBar()
				if(searchbar.height==71) searchInput.platformCloseSoftwareInputPanel()
			}
        }
    }

    Component{
        id:selectDelegate

        Rectangle
		{
			property variant myData: model
			property bool filtered: model.name.match(new RegExp(searchFilter,"i")) != null

			property string jid: model.jid
			property string picture: model.picture
			property string defaultPicture:"../common/images/user.png"
			property string contactPicture: !picture || picture=="none" ? defaultPicture : picture
			property string contactName: searchFilter.length>0 ? replaceText(model.name, searchFilter) : model.name
			property string contactStatus: model.status;
			property string contactNumber: model.number
			property bool isSelected: selectedContacts.indexOf(model.jid)>-1

			height: filtered ? 80 : 0
			width: appWindow.inPortrait? 480:854
			color: "transparent"
			clip: true

			Rectangle {
				anchors.fill: parent
				color: theme.inverted? "darkgray" : "lightgray"
				opacity: theme.inverted? 0.2 : 0.8
				visible: mouseArea.pressed || isSelected
			}

		    RoundedImage {
		        id: contact_picture
				x: 16
		        size:62
		        imgsource: contactPicture
		        opacity: 1
		        anchors.topMargin: -2
				y: 8
		    }

		    Column{
				y: 9
				x: 90
				width: parent.width -100
				anchors.verticalCenter: parent.verticalCenter
				Label{
					y: 2
		            text: contactName
				    font.pointSize: 18
					elide: Text.ElideRight
					width: parent.width -56
					font.bold: true
				}
				Label{
				    id: contact_status
		            text: Helpers.emojify(contactStatus)
				    font.pixelSize: 20
				    color: "gray"
					width: parent.width -56
					elide: Text.ElideRight
					height: 24
					clip: true
					visible: contactStatus!==""
			   }

		    }

			Image {
				anchors.right: parent.right
				anchors.rightMargin: 16
				anchors.verticalCenter: parent.verticalCenter
				source: "pics/done-" + (theme.inverted? "white" : "black") + ".png"
				visible: isSelected
			}

			MouseArea{
				id:mouseArea
				anchors.fill: parent
				onClicked:{
				    //console.log("CONTACT CLICKED: ");
					isSelected = !isSelected
				}
			}

		}
    }

}
