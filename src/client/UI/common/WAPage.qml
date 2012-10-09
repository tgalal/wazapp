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
//import com.nokia.extras 1.0

Page {
   orientationLock: appWindow.orientation==2 ? PageOrientation.LockLandscape:
                appWindow.orientation==1 ? PageOrientation.LockPortrait : PageOrientation.Automatic

	Connections {
		target: appWindow
		onSetBackground: {
			var result = backgroundimg.replace("file://","")
			myBackgroundImage = result
		}
	}

    Image {
		id: background
        anchors.fill: parent
        source: myBackgroundImage!="none" ? myBackgroundImage : ""
        opacity: getOpacity(myBackgroundOpacity)
		fillMode: Image.PreserveAspectCrop
    }

	function getOpacity(value) {
		if (value=="10") return 1.0;
		else if (value=="9") return 0.9;
		else if (value=="8") return 0.8;
		else if (value=="7") return 0.7;
		else if (value=="6") return 0.6;
		else if (value=="5") return 0.5;
		else if (value=="4") return 0.4;
		else if (value=="3") return 0.3;
		else if (value=="2") return 0.2;
		else if (value=="1") return 0.1;
		else if (value=="0") return 0;

	}


}
