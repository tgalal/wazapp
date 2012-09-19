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

import "../Contacts/js/contacts.js" as ContactsManager
import "../common/js/Global.js" as Helpers
import "../common"
import "../Contacts"

WAPage {
    id: contactsContainer

	function contactRemoved() {
		consoleDebug("CALLED CONTACT REMOVED FUNCTION")
		for (var i=0; i<list_view1.count; ++i) {
			list_view1.currentIndex = i
			list_view1.currentItem.isSelected = selectedContacts.indexOf(list_view1.currentItem.myData.jid)>-1
		}
	}

    onStatusChanged: {
        if(status == PageStatus.Activating){
			contactRemoved()
			list_view1.positionViewAtBeginning()
		}
		if(status == PageStatus.Active){
			searchbar.height = 0
		}
	}

	tools: contactsTool

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

        Rectangle
		{
			property variant myData: model
			property bool filtered: model.name.match(new RegExp(searchInput.text,"i")) != null

			property string jid: model.jid
			property string picture: model.picture
			property string defaultPicture:"../common/images/user.png"
			property string contactPicture: !picture || picture=="none" ? defaultPicture : picture
			property string contactName: searchInput.text.length>0 ? replaceText(model.name, searchInput.text) : model.name
			property string contactStatus: model.status? model.status : ""
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
				source: "images/done-" + (theme.inverted? "white" : "black") + ".png"
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

	WAHeader{
		title: qsTr("Add contacts")
		anchors.top:parent.top
		width:parent.width
		height: 73
	}

	Rectangle {
		id: searchbar
		width: parent.width
		height: -1
		anchors.top: parent.top
		anchors.topMargin: 73
		color: "transparent"
		clip: true

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
		anchors.topMargin: 73 + searchbar.height
        width:parent.width
        height:parent.height - 73 - searchbar.height
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
			cacheBuffer: 20000
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

	ToolBarLayout {
        id:contactsTool

        ToolIcon{
            platformIconId: "toolbar-back"
       		onClicked: pageStack.pop()
        }

        ToolButton
        {
			anchors.horizontalCenter: parent.horizontalCenter
			width: 300
            text: qsTr("Done")
            onClicked: {
				selectedContacts = ""
				participantsModel.clear()

				for (var i=0; i<list_view1.count; ++i) {
					list_view1.currentIndex = i
					if (list_view1.currentItem.isSelected) {
						consoleDebug("ADDING CONTACT: "+list_view1.currentItem.jid)

						selectedContacts = selectedContacts + (selectedContacts!==""? ",":"") + contactsModel.get(i).jid;
						participantsModel.append({"contactPicture":contactsModel.get(i).picture,
							"contactName":contactsModel.get(i).name,
							"contactStatus":contactsModel.get(i).status,
							"contactJid":contactsModel.get(i).jid})
					} /*else {
						for (var j=0; j<participantsModel.count; ++j) {
							if (participantsModel.get(j).contactJid==contactsModel.get(i).jid)
								participantsModel.remove(j)
						}
						var newSelectedContacts = selectedContacts
						newSelectedContacts = newSelectedContacts.replace(contactsModel.get(i).jid,"")
						newSelectedContacts = newSelectedContacts.replace(",,",",")
						selectedContacts = newSelectedContacts
					}*/
				}
				consoleDebug("PARTICIPANTS RESULT: " + selectedContacts)
				pageStack.pop()
			}
        }

    }


}
