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
import "../common/js/settings.js" as MySettings
import "../common/js/Global.js" as Helpers
import "../common"
import "../Profile"

WAPage {
    id: root

    property bool loaded:false

    //property string contactPicture: WAConstants.CACHE_PROFILE + "/" + myAccount.split("@")[0] + ".jpg"
    property string profilePicture:currentProfilePicture?currentProfilePicture:defaultProfilePicture

    property string message: qsTr("This is a %1 version.").arg(waversiontype) + "\n" +
							 qsTr("You are trying it at your own risk.") + "\n" + 
							 qsTr("Please report any bugs to") + "\n" + "tarek@wazapp.im"


    onStatusChanged: {
        if(status == PageStatus.Activating){

            myStatus.text = Helpers.emojify2(currentStatus); //reset status to cancel unsaved modifications

            if(!loaded){
                MySettings.initialize()
                getRingtones()

                currentSelectionProfile = "PersonalRingtone"
                setRingtone(MySettings.getSetting("PersonalRingtone", "/usr/share/sounds/ring-tones/Message 1.mp3"));

                currentSelectionProfile = "GroupRingtone"
                setRingtone(MySettings.getSetting("GroupRingtone", "/usr/share/sounds/ring-tones/Message 1.mp3"));

                loaded = true

            }
        }
    }


    Component.onCompleted: {
      //  MySettings.initialize()
        //getRingtones()
    }

	Connections {
		target: appWindow

		onSetBackground: {
			var result = backgroundimg.replace("file://","")
			myBackgroundImage = result
			MySettings.setSetting("Background", result)
			backgroundSelector.subtitle = getBackgroundSubtitle()
		}

		onSetRingtone: {
			MySettings.setSetting(currentSelectionProfile, ringtonevalue)
			currentSelectionProfileValue = ringtonevalue
			if (currentSelectionProfile=="GroupRingtone") {
				setGroupRingtone(ringtonevalue)
				groupRingtone = ringtonevalue
				groupTone.subtitle = getRingtoneSubtitle(ringtonevalue)
			} else {
				setPersonalRingtone(ringtonevalue)
				personalRingtone = ringtonevalue
				personalTone.subtitle = getRingtoneSubtitle(ringtonevalue)
			}
		}
	}

	function getBackgroundSubtitle() {
		var res = MySettings.getSetting("Background", "none")
		res = res.split('/')
		res = res[res.length-1]
		res = res.charAt(0).toUpperCase() + res.slice(1);
		if (res=="None") res = qsTr("(no background)")
		return res
	}

	function getRingtoneSubtitle(ringtone) {
		var res = ringtone.split('/')
		res = res[res.length-1]
		res = res.charAt(0).toUpperCase() + res.slice(1);
		res = res.split('.')[0]
		if (res=="No sound") res = qsTr("(no sound)")
		return res
	}
    tools: ToolBarLayout {
        id: toolBar

        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }

        ButtonRow {
            style: TabButtonStyle { inverted:theme.inverted }

            TabButton {
	            iconSource: "image://theme/icon-m-toolbar-settings" + (theme.inverted ? "-white" : "")
	            tab: generalTab
	        }

		    TabButton {
		        iconSource: "image://theme/icon-m-toolbar-pages-all" + (theme.inverted ? "-white" : "") 
		        tab: appearanceTab
		    }

		    TabButton {
		        iconSource: "../common/images/notifications" + (theme.inverted ? "-white" : "") + ".png";
		        tab: notificationsTab
		    }

		    TabButton {
		        iconSource: "image://theme/icon-m-toolbar-contact" + (theme.inverted ? "-white" : "")
		        tab: profileTab
		    }

            /*TabButton {
		        iconSource: "../common/images/about" + (theme.inverted ? "-white" : "") + ".png";
		        tab: aboutTab
            }*/
		}

    }

	TextFieldStyle {
        id: myTextFieldStyle
        backgroundSelected: ""
        background: ""
		backgroundDisabled: ""
		backgroundError: ""
    }

    ButtonStyle {
        id: myButtonStyleLeft
        pressedBackground: "image://theme/color3-meegotouch-button-background-pressed-horizontal-left"
        checkedBackground: "image://theme/color3-meegotouch-button-background-selected-horizontal-left"
    }
    ButtonStyle {
        id: myButtonStyleCenter
        pressedBackground: "image://theme/color3-meegotouch-button-background-pressed-horizontal-center"
        checkedBackground: "image://theme/color3-meegotouch-button-background-selected-horizontal-center"
    }
    ButtonStyle {
        id: myButtonStyleRight
        pressedBackground: "image://theme/color3-meegotouch-button-background-pressed-horizontal-right"
        checkedBackground: "image://theme/color3-meegotouch-button-background-selected-horizontal-right"
    }

    SliderStyle {
        id: mySliderStyle
        grooveItemBackground: "image://theme/color3-meegotouch-slider-elapsed-background-horizontal"
        grooveItemElapsedBackground: "image://theme/color3-meegotouch-slider-elapsed-background-horizontal"
    }


    QueryDialog {
        property string phone_number;
        id:aboutDialog
        //anchors.fill: parent
        icon: "../common/images/icons/wazapp80.png"
        titleText: "Wazapp" //This should not be translated!
        message: qsTr("version") + " " + waversion + "\n\n" + 
                 qsTr("This is a %1 version.").arg(waversiontype) + "\n" + 
				 qsTr("You are trying it at your own risk.") + "\n" + 
				 qsTr("Please report any bugs to") + "\n" + "tarek@wazapp.im"
 
    }

	WAHeader{
        title: qsTr("Settings")
        anchors.top:parent.top
        width:parent.width
		height: 73
    }

    TabGroup {
        id: tabGroups
        currentTab: generalTab


		Item {
			id: generalTab
			anchors.top: parent.top
			anchors.topMargin: 73
			height: parent.height -73
			anchors.left: parent.left
			anchors.leftMargin: 16
			width: parent.width -32

			Flickable {
				id: flickArea1
				anchors.fill: parent
				contentWidth: width
				contentHeight: column.height + 40
				clip: true

				Column {
					id: column
					anchors { top: parent.top; left: parent.left; right: parent.right; }
					spacing: 10


					GroupSeparator {
						title: qsTr("Chats")
					}
					SwitchItem {
						title: qsTr("Enter key sends the message")
						check: sendWithEnterKey
						onCheckChanged: {
							MySettings.setSetting("SendWithEnterKey", value)
							sendWithEnterKey = value=="Yes"
						}
					}

					GroupSeparator {
						title: qsTr("Media sending")
					}
					SwitchItem {
						title: qsTr("Resize images before sending")
						check: resizeImages
						onCheckChanged: {
							MySettings.setSetting("ResizeImages", value)
							resizeImages = value=="Yes"
							setResizeImages(resizeImages)
						}
					}

					GroupSeparator {
						title: qsTr("Language")
					}
					SelectionItemTr {
					    title: qsTr("Current language")
					    model: ListModel {
							ListElement { name: "Albanian"; value: "sq" }
							ListElement { name: "Arabic"; value: "ar" }
							ListElement { name: "Basque"; value: "eu" }
							ListElement { name: "Bulgarian"; value: "bg" }
							ListElement { name: "Catalan"; value: "ca" }
							ListElement { name: "Chinese"; value: "zh" }
							ListElement { name: "Chinese (Hong Kong)"; value: "zh_HK" }
							ListElement { name: "Chinese (Taiwan)"; value: "zh_TW" }
							ListElement { name: "Croatian"; value: "hr" }
							ListElement { name: "Czech"; value: "cs" }
							ListElement { name: "Dutch"; value: "nl" }
							ListElement { name: "English"; value: "en" }
							ListElement { name: "English (United Kingdom)"; value: "en_GB" }
							ListElement { name: "English (United States)"; value: "en_US" }
							ListElement { name: "Finnish"; value: "fi" }
							ListElement { name: "French (France)"; value: "fr_FR" }
							ListElement { name: "French (Switzerland)"; value: "fr_CH" }
							ListElement { name: "German (Germany)"; value: "de_DE" }
							ListElement { name: "German (Switzerland)"; value: "de_CH" }
							ListElement { name: "Greek"; value: "el" }
							ListElement { name: "Hebrew"; value: "he" }
							ListElement { name: "Hindi"; value: "hi" }
                            ListElement { name: "Hungary"; value: "hu_HU" }
							ListElement { name: "Italian"; value: "it" }
							ListElement { name: "Macedonian"; value: "mk" }
							ListElement { name: "Malay"; value: "ms" }
							ListElement { name: "Persian"; value: "fa" }
                            ListElement { name: "Polish"; value: "pl" }
							ListElement { name: "Portuguese (Brazil)"; value: "pt_BR" }
							ListElement { name: "Portuguese (Portugal)"; value: "pt_PT" }
							ListElement { name: "Romanian"; value: "ro" }
							ListElement { name: "Russian"; value: "ru" }
							ListElement { name: "Spanish"; value: "es" }
							ListElement { name: "Spanish (Argentina)"; value: "es_AR" }
							ListElement { name: "Spanish (Mexico)"; value: "es_MX" }
							ListElement { name: "Swedish (Finland)"; value: "sv_FI" }
							ListElement { name: "Swedish (Sweden)"; value: "sv_SE" }
							ListElement { name: "Thai"; value: "th" }
							ListElement { name: "Turkish"; value: "tr" }
                            ListElement { name: "Ukrainian"; value: "uk_UA" }
                            ListElement { name: "Urdu"; value: "ur" }

							ListElement { name: "Vietnamese"; value: "vi" }
					    }
						initialValue: MySettings.getSetting("Language", "en")
					    onValueChosen: { 
							MySettings.setSetting("Language", value)
							setLanguage(value)
						}
					}
					Label {
						id: subTitle
						color: "gray"
						verticalAlignment: Text.AlignVCenter
						text: qsTr("*Restart Wazapp to apply the new language")
						font.pixelSize: 20
					}


				}

			}

			ScrollDecorator {
				flickableItem: flickArea1
			}

		}

		Item {
			id: appearanceTab
			anchors.top: parent.top
			anchors.topMargin: 73
			height: parent.height -73
			anchors.left: parent.left
			anchors.leftMargin: 16
			width: parent.width -32

			Flickable {
				id: flickArea2
				anchors.fill: parent
				contentWidth: width
				contentHeight: column2.height + 40
				clip: true

				Column {
					id: column2
					anchors { top: parent.top; left: parent.left; right: parent.right;}
					spacing: 10

					GroupSeparator {
						title: qsTr("Background")
					}

					SelectionItem {
						id: backgroundSelector
					    title: qsTr("Image")
					    subtitle: getBackgroundSubtitle()
						onClicked: pageStack.push(Qt.resolvedUrl("SetBackground.qml") );
					}

					Row {
						width: parent.width
						spacing: 16
						visible: backgroundSelector.subtitle == qsTr("(no background)") ? false : true

					Label {
							id: sliderText
						verticalAlignment: Text.AlignBottom
						text: qsTr("Opacity:")
						height: 50
					}
		            Slider {
		                id: themeslider
		                maximumValue: 10
		                minimumValue: 0
		                stepSize: 1
							width: parent.width - sliderText.paintedWidth-16
		                value: MySettings.getSetting("BackgroundOpacity", "0.5")
		                platformStyle: mySliderStyle
		                onValueChanged: {
		                    myBackgroundOpacity = value
							MySettings.setSetting("BackgroundOpacity", value)
		                }

		            }
					}

					GroupSeparator {
						title: qsTr("Appearance")
					}


					Label {
						verticalAlignment: Text.AlignBottom
						text: qsTr("Orientation:")
						height: 30
					}
					ButtonRow {
					    Button {
					        text: qsTr("Automatic")
					        checked: orientation==0
							platformStyle: myButtonStyleLeft
					        onClicked: {
								MySettings.setSetting("Orientation", "0")
					            orientation=0
					        }
					    }
					    Button {
					        text: qsTr("Portrait")
					        checked: orientation==1
							platformStyle: myButtonStyleCenter
					        onClicked: {
								MySettings.setSetting("Orientation", "1")
					            orientation=1
					        }
					    }
					    Button {
					        text: qsTr("Landscape")
					        checked: orientation==2
							platformStyle: myButtonStyleRight
					        onClicked: {
								MySettings.setSetting("Orientation", "2")
					            orientation=2
					        }
					    }
					}

					Label {
						verticalAlignment: Text.AlignBottom
						text: qsTr("Theme color:")
						height: 50
					}
					ButtonRow {
					    id: br1
					    Button {
					        text: qsTr("White")
					        checked: theme.inverted ? false : true
					        platformStyle: myButtonStyleLeft
					        onClicked: {
								MySettings.setSetting("ThemeColor", "White")
					            theme.inverted = false
					        }
					    }
					    Button {
					        text: qsTr("Black")
					        checked: theme.inverted ? true : false
					        platformStyle: myButtonStyleRight
					        onClicked: {
								MySettings.setSetting("ThemeColor", "Black")
					            theme.inverted = true
					        }
					    }
					}

					Label {
						verticalAlignment: Text.AlignBottom
						text: qsTr("Bubble color:")
						height: 50
					}
					ButtonRow {
					    id: br2
						height: 70
					    Button {
					        text: qsTr("Cyan")
					        checked: mainBubbleColor==1
							platformStyle: myButtonStyleLeft
					        onClicked: {
								MySettings.setSetting("BubbleColor", "1")
					            mainBubbleColor=1
					        }
					    }
					    Button {
					        text: qsTr("Green")
					        checked: mainBubbleColor==4
							platformStyle: myButtonStyleCenter
					        onClicked: {
								MySettings.setSetting("BubbleColor", "4")
					            mainBubbleColor=4
					        }
					    }
					    Button {
					        text: qsTr("Pink")
					        checked: mainBubbleColor==3
							platformStyle: myButtonStyleCenter
					        onClicked: {
								MySettings.setSetting("BubbleColor", "3")
					            mainBubbleColor=3
					        }
					    }
					    Button {
					        text: qsTr("Orange")
					        checked: mainBubbleColor==2
							platformStyle: myButtonStyleRight
					        onClicked: {
								MySettings.setSetting("BubbleColor", "2")
					            mainBubbleColor=2
					        }
					    }
					}

				}

			}

			ScrollDecorator {
				flickableItem: flickArea2
			}

		}




		Item {
			id: notificationsTab
			anchors.top: parent.top
			anchors.topMargin: 73
			height: parent.height -73
            anchors.left: parent.left
			anchors.leftMargin: 16
			width: parent.width -32

			Flickable {
				id: flickArea3
				anchors.fill: parent
				contentWidth: width
				contentHeight: column3.height + 40
				clip: true

				Column {
					id: column3
					anchors { top: parent.top; left: parent.left; right: parent.right;}
					spacing: 10

					GroupSeparator {
						title: qsTr("Personal messages")
					}
					SelectionItem {
						id: personalTone
					    title: qsTr("Notification tone")
					    subtitle: getRingtoneSubtitle(personalRingtone)
						onClicked: {
							currentSelectionProfile = "PersonalRingtone"
							currentSelectionProfileValue = personalRingtone
							pageStack.push(Qt.resolvedUrl("../common/MusicBrowserDialog.qml"))
						}
					}
					SwitchItem {
						title: qsTr("Vibrate")
						check: MySettings.getSetting("PersonalVibrate", "Yes")=="Yes"
						onCheckChanged: {
							MySettings.setSetting("PersonalVibrate", value)
							vibraForPersonal = value=="Yes"
							setPersonalVibrate(vibraForPersonal)
						}
					}

					GroupSeparator {
						title: qsTr("Group messages")
					}

					SelectionItem {
						id: groupTone
					    title: qsTr("Notification tone")
					    subtitle: getRingtoneSubtitle(groupRingtone)
						onClicked: {
							currentSelectionProfile = "GroupRingtone"
							currentSelectionProfileValue = groupRingtone
							pageStack.push(Qt.resolvedUrl("../common/MusicBrowserDialog.qml"))
						}
					}
					SwitchItem {
						id: groupVibra
						title: qsTr("Vibrate")
						check: MySettings.getSetting("GroupVibrate", "Yes")=="Yes"
						onCheckChanged: {
							MySettings.setSetting("GroupVibrate", value)
							vibraForGroup = value=="Yes"
							setGroupVibrate(vibraForGroup)
						}
					}

				}

			}

			ScrollDecorator {
				flickableItem: flickArea3
			}

		}

		Item {
			id: profileTab
			anchors.top: parent.top
			anchors.topMargin: 73
			height: parent.height -73
			anchors.left: parent.left
			anchors.leftMargin: 16
			width: parent.width -32

			Flickable {
				id: flickArea4
				anchors.fill: parent
				contentWidth: width 
				contentHeight: column4.height + 20
				anchors.centerIn: parent
				clip: true

				Image {
					id: bigImage
					visible: false
                    source: profilePicture
					cache: false
				}

				Column {
					id: column4
					width: parent.width
					anchors { top: parent.top; left: parent.left; right: parent.right;}
					spacing: 24

					GroupSeparator {
						title: qsTr("Profile picture")
					}

					ProfileImage {
						id: picture
						size: 340
						height: size
						width: size
                        imgsource: profilePicture
						onClicked: {
							profileUser = myAccount
							pageStack.push(setProfilePicture)
						}
						anchors.horizontalCenter: parent.horizontalCenter

                        Connections{
                            target: appWindow
                            onProfilePictureUpdated:{
                                picture.state = "";
                                appWindow.showNotification(qsTr("Profile picture updated"))
                            }

                        }
					}

					GroupSeparator {
						title: qsTr("Status")
					}

					Status {
						id: myStatus
						//height: 140
						clip: true
						width: parent.width
                        text: Helpers.emojify2(currentStatus)
					}

					GroupSeparator {
						title: qsTr("Push Name")
						height: 36
					}

					WATextArea {
						id: push_text
                        property string pushNameCached:typeof(myPushName) != "undefined"?myPushName:""
						width: parent.width
						wrapMode: TextEdit.Wrap
						textFormat: Text.PlainText
						textColor: "black"
                        text: typeof(myPushName) != "undefined"?myPushName:""
					}

					Button
					{
						platformStyle: ButtonStyle { inverted: true }
						width: 160
						height: 50
                        text: qsTr("Save")
						anchors.right: push_text.right
                        onClicked: {//no need to run only when online, since pushname is sent on connect anyway
                            var pName = push_text.text.trim()
                            if(pName.length==0) {
                                showNotification(qsTr("Push name can't be empty"));
                                push_text.text = push_text.pushNameCached
                                return
                            }

                            setMyPushName(push_text.text);
                            showNotification(qsTr("Push name updated"));
                        }
                    }
				}

			}

			ScrollDecorator {
				flickableItem: flickArea4
			}

		}



		Item {
			id: aboutTab
			anchors.top: parent.top
			anchors.topMargin: 73
			height: parent.height -73
			anchors.left: parent.left
			anchors.leftMargin: 16
			width: parent.width -32

			Flickable {
				id: flickArea6
				anchors.fill: parent
				contentWidth: width
				contentHeight: column6.height + 20
				anchors.centerIn: parent
				clip: true

				Column {
					id: column6
					width: parent.width
					anchors { top: parent.top; left: parent.left; right: parent.right;}
					spacing: 24

					GroupSeparator {
						title: qsTr("About")
					}


					Image {
						source: "../common/images/icons/wazapp256.png"
						anchors.horizontalCenter: parent.horizontalCenter
					}

					Label {
						horizontalAlignment: Text.AlignHCenter
						anchors.leftMargin: 0
						width: parent.width 
						text: "Wazapp"
					}

					Label {
						horizontalAlignment: Text.AlignHCenter
						anchors.leftMargin: 0
						width: parent.width
						text: qsTr("version") + " " + waversion
					}

					Label {
						horizontalAlignment: Text.AlignHCenter
						anchors.leftMargin: 0
						width: parent.width
						text: message
					}
					
				}

			}

			ScrollDecorator {
				flickableItem: flickArea6
			}

		}

	}

    SelectPicture {
        id:setProfilePicture
        onSelected: {
            pageStack.pop()

            runIfOnline(function(){
                picture.state = "loading"
                breathe()
                setMyProfilePicture(path)

            }, true)

        }
    }

}

