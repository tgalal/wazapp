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

WAPage {
    id: contactsContainer

	state:"no_data"

	property alias indicator_state:wa_notifier.state

	states: [
		State {
			name: "no_data"
			PropertyChanges {
				target: no_data
				visible:true
			}
		}
	]

    onStatusChanged: {
        if(status == PageStatus.Activating){
			list_view1.positionViewAtBeginning()
		}
	}

    ListModel{
        id:contactsModel
    }


     function pushContacts(contacts)
     {
       // console.log("AHOM"+contacts)
        ContactsManager.populateContacts(contacts);
     }

    function getOrCreateContact(c){

        console.log("get or create contact called");
        var jid=c.jid;

        console.log("entering search loop");

        for(var i=0;i<ContactsManager.contactsViews.length; i++){

            var cView = ContactsManager.contactsViews[i];
            if(cView.jid == jid)
                return cView;
        }

        //contact not found, create
        var contact = new ContactsManager.Contact(c.jid);

        contactsModel.append(contact);

        return ContactsManager.contactsViews[ContactsManager.contactsViews.length-1];

    }

    function hideSearchBar() {
        searchbar.h1 = 71
        searchbar.h2 = 0
        searchbar.height = 0
        searchInput.enabled = false
        sbutton.enabled = false
        searchInput.text = ""
        searchInput.focus = false
		list_view1.forceActiveFocus()
        timer.stop()
    }

    function showSearchBar() {
        searchbar.h1 = 0
        searchbar.h2 = 71
        searchbar.height = 71
        searchInput.enabled = true
        sbutton.enabled = true
        searchInput.text = ""
        searchInput.focus = false
        list_view1.forceActiveFocus()
        timer.start()
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


    Timer {
        id: timer
        interval: 5000
        onTriggered: {
            if (searchInput.text==="") hideSearchBar()
        }
    }

    Component{
        id:myDelegate

        Contact{
            property bool filtered: model.name.match(new RegExp(searchInput.text,"i")) != null
            id:contactComp
            height: filtered ? 80 : 0
			visible: height!=0
            Component.onCompleted: {
                ContactsManager.contactsViews.push(contactComp)
            }

            jid:model.jid
            picture:model.picture
            contactName:model.name;
            contactStatus:model.status;

            onClicked: {
				hideSearchBar()
				if(searchbar.height==71) searchInput.platformCloseSoftwareInputPanel()
			}
        }
    }

    WANotify{
		anchors.top: parent.top
        id:wa_notifier
    }

	Rectangle {
		id: searchbar
		width: parent.width
		height: 0
		anchors.top: parent.top
		anchors.topMargin: wa_notifier.height
		color: "transparent"

		property int h1
		property int h2

		Rectangle {

			id: srect
			anchors.fill: searchbar
			anchors.leftMargin: 12
			anchors.rightMargin: 12
			anchors.top: searchbar.top
			anchors.topMargin: searchbar.height - 62
			anchors.bottomMargin: 2
			color: "transparent"

			TextField {
			    id: searchInput
			    inputMethodHints: Qt.ImhNoPredictiveText
			    placeholderText: qsTr("Quick search")
			    anchors.top: srect.top
			    anchors.left: srect.left
			    width: parent.width
			    enabled: false
			    onTextChanged: timer.restart()
			}

			Image {
			    id: sbutton
			    smooth: true
			    anchors.top: srect.top
			    anchors.topMargin: 1
			    anchors.right: srect.right
			    anchors.rightMargin: 4
			    height: 52
			    width: 52
			    enabled: false
			    source: searchInput.text==="" ? "image://theme/icon-m-common-search" : "image://theme/icon-m-input-clear"
			    MouseArea {
			        anchors.fill: parent
			        onClicked: {
			            searchInput.text = ""
			            searchInput.forceActiveFocus()
			        }
			    }
			}

		}

		onHeightChanged: SequentialAnimation {
			PropertyAction { target: searchbar; property: "height"; value: searchbar.h1 }
			NumberAnimation { target: searchbar; property: "height"; to: searchbar.h2; duration: 300; easing.type: Easing.InOutQuad }
		}

        states: [
            State {
                name: 'hidden'; when: searchbar.height == 0
                PropertyChanges { target: searchbar; opacity: 0; }
            },
            State {
                name: 'showed'; when: searchbar.height == 71
                PropertyChanges { target: searchbar; opacity: 1; }
            }
        ]
        transitions: Transition {
            NumberAnimation { properties: "opacity"; easing.type: Easing.InOutQuad; duration: 300 }
        }


	}

    Rectangle {
        anchors.top: parent.top
		anchors.topMargin: wa_notifier.height + searchbar.height
        width:parent.width
        height:parent.height - wa_notifier.height - searchbar.height
		color: "transparent"
		clip: true

        Item{
        	anchors.fill: parent
            visible:false;
            id:no_data

            Label{
                anchors.centerIn: parent;
                text: qsTr("No contacts yet. Try to resync")
                font.pointSize: 20
                width:parent.width
                horizontalAlignment: Text.AlignHCenter
            }
        }

        ListView {
            id: list_view1
			anchors.fill: parent
            clip: true
            model: contactsModel
            delegate: myDelegate
            spacing: 1
			cacheBuffer: 10000
			highlightFollowsCurrentItem: false
            section.property: "alphabet"
            section.criteria: ViewSection.FirstCharacter

            section.delegate: GroupSeparator {
				anchors.left: parent.left
				anchors.leftMargin: 16
				width: parent.width - 44
				height: searchInput.text==="" ? 50 : 0
				title: section
			}

			Component.onCompleted: fast.listViewChanged()

            onContentYChanged:  {
                if ( list_view1.visibleArea.yPosition < 0)
                {
                    if ( searchbar.height==0 )
                        showSearchBar()
                }
            }
        }

		FastScroll {
			id: fast
			listView: list_view1
			enabled: searchInput.text===""
		}

    }


}
