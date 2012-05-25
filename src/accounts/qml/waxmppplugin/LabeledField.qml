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

Item {
    id:container
    property alias label:lf_label.text
    property alias value:lf_value.text
    property string input_size:"wide" //wide, medium, small
    property alias inputMethodHints:lf_value.inputMethodHints
    property alias enabled:lf_value.enabled

    height:lf_label.height + lf_value.height

    Column{
        id:lf_holder
        spacing:2
        width:parent.width

        Label{
            id:lf_label
            width:parent.width
        }

        TextField{
            id:lf_value
            width:input_size =="wide"?parent.width:input_size=="medium"?parent.width/2:parent.width/4;


        }
    }

}
