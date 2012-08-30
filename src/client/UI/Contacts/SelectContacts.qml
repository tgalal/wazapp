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

import "../common"
import "../Contacts"

WAPage {
    id: contactsContainer

	property int total: 0
	property string selectedContacts: ""

    onStatusChanged: {
        if(status == PageStatus.Activating){
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

			property string contactName: model.name
			property string showContactName: searchInput.text.length>0 ? replaceText(model.name, searchInput.text) : model.name
			property string picture: model.picture !== "" ? model.picture : "../common/images/user.png"

			property bool isSelected: selectedContacts.indexOf(contactName)>-1

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
		        imgsource: picture=="icon-m-content-voicemail" ? "../common/images/user.png" : picture 
		        anchors.topMargin: -2
				y: 8
		    }

		    Column{
				y: 2
				x: 90
				width: parent.width -100
				anchors.verticalCenter: parent.verticalCenter
				Label{
					y: 2
		            text: showContactName
				    font.pointSize: 18
					elide: Text.ElideRight
					width: parent.width -56
					font.bold: true
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
					consoleDebug("SELECTED OLD:" +selectedContacts)
				    if (isSelected) {
						consoleDebug("REMOVING "+contactName)
						var newc = selectedContacts
						newc = newc.replace(contactName,"")
						newc = newc.replace(",,",",")
						selectedContacts = newc
						total = total -1
					} else {
						selectedContacts = selectedContacts + (selectedContacts!==""? ",":"") + contactName;
						total = total +1
					}
					consoleDebug("SELECTED NEW:" +selectedContacts)
				}
			}

		}
    }

	WAHeader{
		title: qsTr("Select contacts")
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
            model: phoneContactsModel
            delegate: myDelegate
            spacing: 1
			cacheBuffer: 30000
			highlightFollowsCurrentItem: false

            section.property: "displayLabel"
            section.criteria: ViewSection.FirstCharacter

            section.delegate: GroupSeparator {
				anchors.left: parent.left
				anchors.leftMargin: 16
				width: parent.width - 44
				height: searchInput.text==="" ? 50 : 0
				title: section
			}

			Component.onCompleted: fast.listViewChanged()
			onCountChanged: fast.listViewChanged()

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
			id: selbutton
			anchors.horizontalCenter: parent.horizontalCenter
			width: 280
            text: total==list_view1.count ? qsTr("Unselect all") : qsTr("Select all")
			visible: list_view1.count>0
            onClicked: {
				selectedContacts = ""
				if (selbutton.text==qsTr("Select all")) {
					total = list_view1.count
					for (var i=0; i<list_view1.count; ++i) {
						list_view1.currentIndex = i
						//list_view1.currentItem.isSelected = true
						selectedContacts = selectedContacts + (selectedContacts!==""? ",":"") + list_view1.currentItem.contactName;
					}
				} else {
					selectedContacts = ""
					total = 0
				}
			}
        }

        ToolIcon {
            id: doneButton
            platformIconId: "toolbar-done"
            enabled: total>0
            opacity: enabled? 1.0 : 0.5
            onClicked: {
				var selected = ""
				for (var i=0; i<list_view1.count; ++i) {
					list_view1.currentIndex = i
					if (list_view1.currentItem.isSelected) {
		                selected = selected + (selected!==""? ",":"") + list_view1.currentItem.myData.numbers
					}
				}
				//consoleDebug("SELECTED CONTACTS:" + selected);
				pageStack.replace(loadingPage);
				appWindow.refreshContacts(selected)
			}
        }

    }


}
