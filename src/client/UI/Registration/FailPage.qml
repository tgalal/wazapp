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

Page{
    property alias reason:fail_reason.text


        Item
        {
            anchors.verticalCenter: parent.verticalCenter
            width:parent.width

            Label{
                id:title
                text:qsTr("Failed:")

                platformStyle: LabelStyle {
                        textColor: "red"
                        fontPixelSize: 30

                    }
                }

            Text{
                id:fail_reason
                anchors.top:title.bottom
                anchors.topMargin: 10
                width:parent.width
                font.pointSize: 20
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere


                }
        }

}
