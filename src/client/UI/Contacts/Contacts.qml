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
import "../common/WAListView/Components"
import "../common"
import "../Menu"

WAPage {
    id: contactsContainer

	//state:"no_data"

	property alias indicator_state:wa_notifier.state

	/*states: [
		State {
			name: "no_data"
			PropertyChanges {
				target: no_data
				visible:true
			}
		}
	]*/

    onStatusChanged: {
        if(status == PageStatus.Activating){
			//list_view1.positionViewAtBeginning()
		}
	}

    function pushContacts(contacts)
    {
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

        //contactsModel.append(contact);

        return ContactsManager.contactsViews[ContactsManager.contactsViews.length-1];

    }
	
    Item { id: dummy }

    function hideSearchBar() {
        searchbar.height = 0
        searchInput.enabled = false
        sbutton.enabled = false
        searchInput.text = ""
        searchInput.platformCloseSoftwareInputPanel()
		searchInput.enabled = false
        timer.stop()
    }
    function showSearchBar() {
        searchbar.height = 71
        searchInput.enabled = true
        sbutton.enabled = true
        searchInput.text = ""
        searchInput.enabled = true
        dummy.focus = true
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
            id: contactComp
            height: model.iscontact =="yes" && filtered ? 80 : 0
			visible: height!=0
            Component.onCompleted: {
                ContactsManager.contactsViews.push(contactComp)
            }

            jid: model.jid
            contactPicture: model.picture?model.picture:defaultProfilePicture
            contactName: model.name
			contactShowedName: searchInput.text.length>0 ? replaceText(model.name, searchInput.text) : model.name
            contactStatus: model.status? model.status : ""
            contactNumber: model.number
			//isNew: model.newContact

			//isVisible: ((y >= ListView.view.contentY+100 && y <= ListView.view.contentBottom-100) ||
            //           (y+height >= ListView.view.contentY+100 && y+height <= ListView.view.contentBottom-100))

			onOptionsRequested: {
                contactMenu.selectedJid = jid
                consoleDebug(contactMenu.selectedJid)

				contactMenu.open()
			}

            onClicked: {
				hideSearchBar()
				if(searchbar.height==71) searchInput.platformCloseSoftwareInputPanel()
			}
        }
    }

	WAHeader{
		id: header
        title: qsTr("Contacts")
        anchors.top:parent.top
        width:parent.width
		height: 73
    }

	Image {
		id: refreshPics
		anchors.right: header.right
		anchors.rightMargin: 16
		anchors.verticalCenter: header.verticalCenter 
		source: "../common/images/refresh.png"
        visible:false//for now
		MouseArea {
			anchors.fill: parent
			onClicked: {
				refreshPics.visible = false
				getPictures()
			}
		}
	}

    BusyIndicator {
		anchors.right: header.right
		anchors.rightMargin: 16
		anchors.verticalCenter: header.verticalCenter 
        platformStyle: BusyIndicatorStyle { size: "medium";}
        visible: !refreshPics.visible
        running: visible
    }

	Connections {
		target: appWindow
		onGetPicturesFinished: {
			refreshPics.visible = true
		}	
	}

    WANotify{
		anchors.top: header.bottom
        id:wa_notifier
    }

	Rectangle {
		id: searchbar
		width: parent.width
		height: 0
		anchors.top: header.bottom
		anchors.topMargin: wa_notifier.height
		color: "transparent"
		clip: true

		Rectangle {

			id: srect
			anchors.fill: searchbar
			anchors.leftMargin: 12
			anchors.rightMargin: 12
			anchors.top: searchbar.top
			anchors.topMargin: searchbar.height - 62
			anchors.bottomMargin: 2
			color: "transparent"
            opacity: searchbar.height==0 ? 0 : 1

            Behavior on opacity { NumberAnimation { duration: 400 } }

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

        Behavior on height { NumberAnimation { duration: 200 } }

	}

    Rectangle {
        anchors.top: header.bottom
		anchors.topMargin: wa_notifier.height + searchbar.height
        width:parent.width
        height:parent.height - wa_notifier.height - searchbar.height - header.height
		color: "transparent"
		clip: true

        Item{
        	anchors.fill: parent
            visible: list_view1.count==0
            id: no_data

            Label{
                anchors.centerIn: parent;
                text: qsTr("No contacts yet. Try to resync")
                font.pointSize: 26
                width:parent.width
                horizontalAlignment: Text.AlignHCenter
				color: "gray"
            }
        }

        ListView {
            id: list_view1
			anchors.fill: parent
            clip: true
            model: contactsModel
            delegate: myDelegate
            spacing: 1
			cacheBuffer: 30000 // contactsModel.count * 81 --> this should work too.
			highlightFollowsCurrentItem: false
            section.property: "name"
            section.criteria: ViewSection.FirstCharacter

            /*section.delegate: GroupSeparator {
				anchors.left: parent.left
				anchors.leftMargin: 16
                width: parent.width - 44
                visible: fast.sectionExists(section)
                height: visible && searchInput.text==="" ? 50 : 0
				title: section
            }*/

            section.delegate: SectionDelegate{
                anchors.left: parent.left
                anchors.leftMargin: 16
                width:parent.width-44
                renderSection: fast.sectionExists(section) && searchInput.text===""
                height:renderSection?50:0
                currSection: section
            }

			Component.onCompleted: fast.listViewChanged()

			property real contentBottom: contentY + height

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

	Menu {
	id: contactMenu
    property string selectedJid;

		MenuLayout {
			WAMenuItem {
				height: 80
                text: blockedContacts.indexOf(contactMenu.selectedJid)==-1? qsTr("Block contact") : qsTr("Unblock contact")
				onClicked: { 
                    if (blockedContacts.indexOf(contactMenu.selectedJid)==-1)
                        blockContact(contactMenu.selectedJid)
					else
                        unblockContact(contactMenu.selectedJid)
				}
			}
			WAMenuItem {
				height: 80
				//singleItem: true
				text: qsTr("View contact profile")
				onClicked: { 

                    var c = getOrCreateContact({"jid":contactMenu.selectedJid});
                    if(c){
                        c.openProfile();
                    }

				}
			}
			/*WAMenuItem {
				height: 80
				//singleItem: true
				text: qsTr("Delete contact")
				onClicked: {
					removeContactConfirm.open()
				}
			}*/
		}
	}

    function getAuthor(inputText) {
        var resp = inputText;
        for(var i =0; i<contactsModel.count; i++)
        {
            if(resp == contactsModel.get(i).jid) {
                resp = contactsModel.get(i).name;
				break;
			}
        }
        return resp
    }

    QueryDialog {
        id: removeContactConfirm
        property string selectedJid;
        titleText: qsTr("Confirm delete")
        message: qsTr("Are you sure you want to delete %1?").arg(getAuthor(removeContactConfirm.selectedJid))
        acceptButtonText: qsTr("Yes")
        rejectButtonText: qsTr("No")
        onAccepted: removeSingleContact(removeContactConfirm.selectedJid)
    }


}
