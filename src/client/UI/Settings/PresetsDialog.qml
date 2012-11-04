/****************************************************************************
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

SelectionDialog {
     id: singleSelectionDialog

     titleText: qsTr("Select status")
     selectedIndex: -1

     model: ListModel {
		id:presetsModel
     }

     onSelectedIndexChanged: {
	status_text.text = singleSelectionDialog.model.get(singleSelectionDialog.selectedIndex).name	
     }

     Component.onCompleted: {
	 presetsModel.append({"name": qsTr("Available")});
         presetsModel.append({"name": qsTr("Busy")});
         presetsModel.append({"name": qsTr("At school")});
         presetsModel.append({"name": qsTr("At the movies")});
         presetsModel.append({"name": qsTr("At work")});
         presetsModel.append({"name": qsTr("Battery about to die")});
         presetsModel.append({"name": qsTr("Can't talk, WhatsApp only")});
         presetsModel.append({"name": qsTr("In a meeting")});
         presetsModel.append({"name": qsTr("At the gym")});
         presetsModel.append({"name": qsTr("Sleeping")});
         presetsModel.append({"name": qsTr("Urgent calls only")});
         presetsModel.append({"name": qsTr("I love Wazapp")});
     }	
}
