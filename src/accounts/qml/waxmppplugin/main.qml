import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0

PageStackWindow {
    id: appWindow

    Component.onCompleted: {
        if(initType == 2)
        {
            editPage.phoneNumber=currPhoneNumber;
            editPage.pushName = currPushName;
        }
    }

    InfoBanner {
        id:osd_notify
        topMargin: 10
       // iconSource: "system_banner_thumbnail.png"
    }

    initialPage: initType == 2? editPage:regPage


    Connections {
            target:actor
            onStatusUpdated:{
               regLoading.state = status;
            }
            onRegistrationFailed:{
                //failPage.reason = reason;
               // appWindow.pageStack.push(failPage);
                showNotification(reason);
                regPage.showAlternatives();
                appWindow.pageStack.pop(null);

            }
            onRegistrationSuccess:{
                console.log("CAUGHT SUCCESS");
                editPage.status="Offline"
                console.log("REG SUCCESS "+phoneNumber);
                editPage.phoneNumber=phoneNumber
                editPage.pushName = phoneNumber
                //appWindow.pageStack.pop(null);
                appWindow.pageStack.push(editPage);
                showNotification("Successfully Registered!\n Close me and relaunch Wazapp to login");
            }

            onVoiceCodeRequested:{
                appWindow.pageStack.push(codeEntry);
                showNotification("Code was requested successfully. You should receive a call now.");
            }
        }


    function showNotification(text,fixed) {

        if(fixed)
            osd_notify.timerEnabled=false

        osd_notify.topMargin=100

        osd_notify.text=text
        osd_notify.show();
    }



    SelectionDialog {
        id: cc_selector
        titleText: "Country"
        selectedIndex: 61
        model: countriesModel


    }

    ListModel{
        id:countriesModel

        ListElement{name: "Afghanistan"; cc:"+93"}
        ListElement{name: "Albania"; cc:"+355"}
        ListElement{name: "Algeria"; cc:"+213"}
        ListElement{name: "Andorra"; cc:"+376"}
        ListElement{name: "Angola"; cc:"+244"}
        ListElement{name: "Anguilla"; cc:"+1"}
        ListElement{name: "Antarctica (Australian bases)"; cc:"+6721"}
        ListElement{name: "Antigua and Barbuda"; cc:"+1"}
        ListElement{name: "Argentina"; cc:"+54"}
        ListElement{name: "Armenia"; cc:"+374"}
        ListElement{name: "Aruba"; cc:"+297"}
        ListElement{name: "Ascension"; cc:"+247"}
        ListElement{name: "Australia"; cc:"+61"}
        ListElement{name: "Austria"; cc:"+43"}
        ListElement{name: "Azerbaijan"; cc:"+994"}
        ListElement{name: "Bahamas"; cc:"+1"}
        ListElement{name: "Bahrain"; cc:"+973"}
        ListElement{name: "Bangladesh"; cc:"+880"}
        ListElement{name: "Barbados"; cc:"+1"}
        ListElement{name: "Belarus"; cc:"+375"}
        ListElement{name: "Belgium"; cc:"+32"}
        ListElement{name: "Belize"; cc:"+501"}
        ListElement{name: "Benin"; cc:"+229"}
        ListElement{name: "Bermuda"; cc:"+1"}
        ListElement{name: "Bhutan"; cc:"+975"}
        ListElement{name: "Bolivia"; cc:"+591"}
        ListElement{name: "Bosnia and Herzegovina"; cc:"+387"}
        ListElement{name: "Botswana"; cc:"+267"}
        ListElement{name: "Brazil"; cc:"+55"}
        ListElement{name: "British Indian Ocean Territory"; cc:"+246"}
        ListElement{name: "British Virgin Islands"; cc:"+1"}
        ListElement{name: "Brunei"; cc:"+673"}
        ListElement{name: "Bulgaria"; cc:"+359"}
        ListElement{name: "Burkina Faso"; cc:"+226"}
        ListElement{name: "Burundi"; cc:"+257"}
        ListElement{name: "Cambodia"; cc:"+855"}
        ListElement{name: "Cameroon"; cc:"+237"}
        ListElement{name: "Canada"; cc:"+1"}
        ListElement{name: "Cape Verde"; cc:"+238"}
        ListElement{name: "Cayman Islands"; cc:"+1"}
        ListElement{name: "Central African Republic"; cc:"+236"}
        ListElement{name: "Chad"; cc:"+235"}
        ListElement{name: "Chile"; cc:"+56"}
        ListElement{name: "China"; cc:"+86"}
        ListElement{name: "Colombia"; cc:"+57"}
        ListElement{name: "Comoros"; cc:"+269"}
        ListElement{name: "Congo, Democratic Republic of the"; cc:"+243"}
        ListElement{name: "Congo, Republic of the"; cc:"+242"}
        ListElement{name: "Cook Islands"; cc:"+682"}
        ListElement{name: "Costa Rica"; cc:"+506"}
        ListElement{name: "Cote d'Ivoire"; cc:"+225"}
        ListElement{name: "Croatia"; cc:"+385"}
        ListElement{name: "Cuba"; cc:"+53"}
        ListElement{name: "Cyprus"; cc:"+357"}
        ListElement{name: "Czech Republic"; cc:"+420"}
        ListElement{name: "Denmark"; cc:"+45"}
        ListElement{name: "Djibouti"; cc:"+253"}
        ListElement{name: "Dominica"; cc:"+1"}
        ListElement{name: "Dominican Republic"; cc:"+1"}
        ListElement{name: "East Timor"; cc:"+670"}
        ListElement{name: "Ecuador"; cc:"+593"}
        ListElement{name: "Egypt"; cc:"+20"}
        ListElement{name: "El Salvador"; cc:"+503"}
        ListElement{name: "Equatorial Guinea"; cc:"+240"}
        ListElement{name: "Eritrea"; cc:"+291"}
        ListElement{name: "Estonia"; cc:"+372"}
        ListElement{name: "Ethiopia"; cc:"+251"}
        ListElement{name: "Falkland Islands"; cc:"+500"}
        ListElement{name: "Faroe Islands"; cc:"+298"}
        ListElement{name: "Fiji"; cc:"+679"}
        ListElement{name: "Finland"; cc:"+358"}
        ListElement{name: "France"; cc:"+33"}
        ListElement{name: "French Guiana"; cc:"+594"}
        ListElement{name: "French Polynesia"; cc:"+689"}
        ListElement{name: "Gabon"; cc:"+241"}
        ListElement{name: "Gambia"; cc:"+220"}
        ListElement{name: "Gaza Strip"; cc:"+970"}
        ListElement{name: "Georgia"; cc:"+995"}
        ListElement{name: "Germany"; cc:"+49"}
        ListElement{name: "Ghana"; cc:"+233"}
        ListElement{name: "Gibraltar"; cc:"+350"}
        ListElement{name: "Greece"; cc:"+30"}
        ListElement{name: "Greenland"; cc:"+299"}
        ListElement{name: "Grenada"; cc:"+1"}
        ListElement{name: "Guadeloupe"; cc:"+590"}
        ListElement{name: "Guam"; cc:"+1"}
        ListElement{name: "Guatemala"; cc:"+502"}
        ListElement{name: "Guinea"; cc:"+224"}
        ListElement{name: "Guinea-Bissau"; cc:"+245"}
        ListElement{name: "Guyana"; cc:"+592"}
        ListElement{name: "Haiti"; cc:"+509"}
        ListElement{name: "Honduras"; cc:"+504"}
        ListElement{name: "Hong Kong"; cc:"+852"}
        ListElement{name: "Hungary"; cc:"+36"}
        ListElement{name: "Iceland"; cc:"+354"}
        ListElement{name: "India"; cc:"+91"}
        ListElement{name: "Indonesia"; cc:"+62"}
        ListElement{name: "Iraq"; cc:"+964"}
        ListElement{name: "Iran"; cc:"+98"}
        ListElement{name: "Ireland (Eire)"; cc:"+353"}
        ListElement{name: "Italy"; cc:"+39"}
        ListElement{name: "Jamaica"; cc:"+1"}
        ListElement{name: "Japan"; cc:"+81"}
        ListElement{name: "Jordan"; cc:"+962"}
        ListElement{name: "Kazakhstan"; cc:"+7"}
        ListElement{name: "Kenya"; cc:"+254"}
        ListElement{name: "Kiribati"; cc:"+686"}
        ListElement{name: "Kuwait"; cc:"+965"}
        ListElement{name: "Kyrgyzstan"; cc:"+996"}
        ListElement{name: "Laos"; cc:"+856"}
        ListElement{name: "Latvia"; cc:"+371"}
        ListElement{name: "Lebanon"; cc:"+961"}
        ListElement{name: "Lesotho"; cc:"+266"}
        ListElement{name: "Liberia"; cc:"+231"}
        ListElement{name: "Libya"; cc:"+218"}
        ListElement{name: "Liechtenstein"; cc:"+423"}
        ListElement{name: "Lithuania"; cc:"+370"}
        ListElement{name: "Luxembourg"; cc:"+352"}
        ListElement{name: "Macau"; cc:"+853"}
        ListElement{name: "Macedonia, Republic of"; cc:"+389"}
        ListElement{name: "Madagascar"; cc:"+261"}
        ListElement{name: "Malawi"; cc:"+265"}
        ListElement{name: "Malaysia"; cc:"+60"}
        ListElement{name: "Maldives"; cc:"+960"}
        ListElement{name: "Mali"; cc:"+223"}
        ListElement{name: "Malta"; cc:"+356"}
        ListElement{name: "Marshall Islands"; cc:"+692"}
        ListElement{name: "Martinique"; cc:"+596"}
        ListElement{name: "Mauritania"; cc:"+222"}
        ListElement{name: "Mauritius"; cc:"+230"}
        ListElement{name: "Mayotte"; cc:"+262"}
        ListElement{name: "Mexico"; cc:"+52"}
        ListElement{name: "Micronesia, Federated States of"; cc:"+691"}
        ListElement{name: "Moldova"; cc:"+373"}
        ListElement{name: "Monaco"; cc:"+377"}
        ListElement{name: "Mongolia"; cc:"+976"}
        ListElement{name: "Montenegro"; cc:"+382"}
        ListElement{name: "Montserrat"; cc:"+1"}
        ListElement{name: "Morocco"; cc:"+212"}
        ListElement{name: "Mozambique"; cc:"+258"}
        ListElement{name: "Myanmar"; cc:"+95"}
        ListElement{name: "Namibia"; cc:"+264"}
        ListElement{name: "Nauru"; cc:"+674"}
        ListElement{name: "Netherlands"; cc:"+31"}
        ListElement{name: "Netherlands Antilles"; cc:"+599"}
        ListElement{name: "Nepal"; cc:"+977"}
        ListElement{name: "New Caledonia"; cc:"+687"}
        ListElement{name: "New Zealand"; cc:"+64"}
        ListElement{name: "Nicaragua"; cc:"+505"}
        ListElement{name: "Niger"; cc:"+227"}
        ListElement{name: "Nigeria"; cc:"+234"}
        ListElement{name: "Niue"; cc:"+683"}
        ListElement{name: "Norfolk Island"; cc:"+6723"}
        ListElement{name: "North Korea"; cc:"+850"}
        ListElement{name: "Northern Ireland 44"; cc:"+28"}
        ListElement{name: "Northern Mariana Islands"; cc:"+1"}
        ListElement{name: "Norway"; cc:"+47"}
        ListElement{name: "Oman"; cc:"+968"}
        ListElement{name: "Pakistan"; cc:"+92"}
        ListElement{name: "Palau"; cc:"+680"}
        ListElement{name: "Palestine"; cc:"+970"}
        ListElement{name: "Panama"; cc:"+507"}
        ListElement{name: "Papua New Guinea"; cc:"+675"}
        ListElement{name: "Paraguay"; cc:"+595"}
        ListElement{name: "Peru"; cc:"+51"}
        ListElement{name: "Philippines"; cc:"+63"}
        ListElement{name: "Poland"; cc:"+48"}
        ListElement{name: "Portugal"; cc:"+351"}
        ListElement{name: "Qatar"; cc:"+974"}
        ListElement{name: "Reunion"; cc:"+262"}
        ListElement{name: "Romania"; cc:"+40"}
        ListElement{name: "Russia"; cc:"+7"}
        ListElement{name: "Rwanda"; cc:"+250"}
        ListElement{name: "Saint-Barthelemy"; cc:"+590"}
        ListElement{name: "Saint Helena"; cc:"+290"}
        ListElement{name: "Saint Kitts and Nevis"; cc:"+1"}
        ListElement{name: "Saint Lucia"; cc:"+1"}
        ListElement{name: "Saint Martin (French side)"; cc:"+590"}
        ListElement{name: "Saint Pierre and Miquelon"; cc:"+508"}
        ListElement{name: "Saint Vincent and the Grenadines"; cc:"+1"}
        ListElement{name: "Samoa"; cc:"+685"}
        ListElement{name: "Sao Tome and Principe"; cc:"+239"}
        ListElement{name: "Saudi Arabia"; cc:"+966"}
        ListElement{name: "Senegal"; cc:"+221"}
        ListElement{name: "Serbia"; cc:"+381"}
        ListElement{name: "Seychelles"; cc:"+248"}
        ListElement{name: "Sierra Leone"; cc:"+232"}
        ListElement{name: "Singapore"; cc:"+65"}
        ListElement{name: "Slovakia"; cc:"+421"}
        ListElement{name: "Slovenia"; cc:"+386"}
        ListElement{name: "Solomon Islands"; cc:"+677"}
        ListElement{name: "Somalia"; cc:"+252"}
        ListElement{name: "South Africa"; cc:"+27"}
        ListElement{name: "South Korea"; cc:"+82"}
        ListElement{name: "South Sudan"; cc:"+211"}
        ListElement{name: "Spain"; cc:"+34"}
        ListElement{name: "Sri Lanka"; cc:"+94"}
        ListElement{name: "Sudan"; cc:"+249"}
        ListElement{name: "Suriname"; cc:"+597"}
        ListElement{name: "Swaziland"; cc:"+268"}
        ListElement{name: "Sweden"; cc:"+46"}
        ListElement{name: "Switzerland"; cc:"+41"}
        ListElement{name: "Syria"; cc:"+963"}
        ListElement{name: "Taiwan"; cc:"+886"}
        ListElement{name: "Tajikistan"; cc:"+992"}
        ListElement{name: "Tanzania"; cc:"+255"}
        ListElement{name: "Thailand"; cc:"+66"}
        ListElement{name: "Togo"; cc:"+228"}
        ListElement{name: "Tokelau"; cc:"+690"}
        ListElement{name: "Tonga"; cc:"+676"}
        ListElement{name: "Trinidad and Tobago"; cc:"+1"}
        ListElement{name: "Tunisia"; cc:"+216"}
        ListElement{name: "Turkey"; cc:"+90"}
        ListElement{name: "Turkmenistan"; cc:"+993"}
        ListElement{name: "Turks and Caicos Islands"; cc:"+1"}
        ListElement{name: "Tuvalu"; cc:"+688"}
        ListElement{name: "Uganda"; cc:"+256"}
        ListElement{name: "Ukraine"; cc:"+380"}
        ListElement{name: "United Arab Emirates"; cc:"+971"}
        ListElement{name: "United Kingdom"; cc:"+44"}
        ListElement{name: "United States of America"; cc:"+1"}
        ListElement{name: "Uruguay"; cc:"+598"}
        ListElement{name: "Uzbekistan"; cc:"+998"}
        ListElement{name: "Vanuatu"; cc:"+678"}
        ListElement{name: "Venezuela"; cc:"+58"}
        ListElement{name: "Vietnam"; cc:"+84"}
        ListElement{name: "U.S. Virgin Islands"; cc:"+1"}
        ListElement{name: "Wallis and Futuna"; cc:"+681"}
        ListElement{name: "West Bank"; cc:"+970"}
        ListElement{name: "Yemen"; cc:"+967"}
        ListElement{name: "Zambia"; cc:"+260"}
        ListElement{name: "Zimbabwe"; cc:"+263"}
    }



    VoiceRegistration{
        id:voiceRegPage
        onSaveAccount: {
            regPage.allFail = true
             appWindow.pageStack.push(regVoiceLoading)
            regVoiceLoading.startTimer(10000)
             actor.voiceCodeRequest(cc_val,number_val);
        }
    }


    Registration {
        id:regPage
        allFail: false
        onSaveAccount: {

            appWindow.pageStack.push(regLoading)
            regLoading.startTimer(30000);
            voiceRegPage.cc = cc_val;
            voiceRegPage.number = number_val;
             actor.registerAccount(cc_val,number_val)
             //call save function here on actor
            }
    }

    EditPage{
        id:editPage
    }

    FailPage{
        id:failPage
    }


    CodeEntry{
        id:codeEntry
        onSaveAccount: {
            appWindow.pageStack.push(codeEntryLoading);
            codeEntryLoading.startTimer(10000)
            actor.regRequest(code)
        }
    }

    LoadingPage{
        id:codeEntryLoading

        state: "reg_a"
        buttonOneText: "Cancel"

        onButtonOneClicked: console.log("cancel clicked")


        states: [
            State {
                name: "reg_a"
                PropertyChanges {
                    target: codeEntryLoading
                    operation:"Verifying your account"
                }
            }
        ]
    }

    LoadingPage{
        id:regVoiceLoading;
        state: "reg_a"
        buttonOneText: "Enter code manually"

        onButtonOneClicked: console.log("manual code entry clicked")

        states: [
            State {
                name: "reg_a"
                PropertyChanges {
                    target: regVoiceLoading
                    operation:"Sending Voice Registration Request"
                }
            }
        ]
    }

    LoadingPage{
        id:regLoading;
        state: "reg_a"
        buttonOneText: "Enter code manually"
        buttonTwoText: "Use voice request"

        onButtonOneClicked: {
            console.log("manual code entry clicked")
            actor.stopCodeRequest();
            appWindow.pageStack.push(codeEntry)
        }

        onButtonTwoClicked: {
            console.log("voice entry clicked")
            actor.stopCodeRequest();
            regPage.allFail = true

            appWindow.pageStack.push(voiceRegPage);
        }


        states: [
            State {
                name: "reg_a"
                PropertyChanges {
                    target: regLoading
                    operation:"Sending Registration Request"

                }
            },
            State {
                name: "reg_b"
                PropertyChanges {
                    target: regLoading
                    operation: "Waiting for SMS"

                }
            },
            State {
                name: "reg_c"
                PropertyChanges {
                    target: regLoading
                    operation:"Got the SMS"

                }
            },
            State {
                name: "reg_d"
                PropertyChanges {
                    target: regLoading
                    operation:"Authenticating"

                }
            },

            State {
                name: "reg_e"
                PropertyChanges {
                    target: regLoading
                    operation:"Success"

                }
            }

        ]
    }

    MainPage {
        id: mainPage
    }

    ToolBarLayout {
        id: commonTools
        visible: false
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: Qt.quit()
        }
    }

    ToolBarLayout {
        id: editTools
        visible: false
        /*ToolButton {
            text: qsTrId("Save")
            //enabled: mainPage.checkFilled()
            onClicked: mainPage.saveAccount()
        }
        ToolButton {
            text: qsTrId("Cancel")
            onClicked: Qt.quit()
        }*/
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            anchors.right: (parent === undefined) ? undefined : parent.right
            onClicked: (myMenu.status == DialogStatus.Closed) ? myMenu.open() : myMenu.close()
        }
    }

    Menu {
        id: myMenu
        visualParent: pageStack
        MenuLayout {
            MenuItem { text: qsTrId("Delete Account"); onClicked: delconfirm.open() }
        }
    }

    QueryDialog {
        id: delconfirm
        titleText: qsTrId("Confirm Delete")
        message: qsTrId("Delete account?")
        acceptButtonText: qsTrId("Delete")
        rejectButtonText: qsTrId("Cancel")
        onAccepted: actor.deleteAccount()
    }
}
