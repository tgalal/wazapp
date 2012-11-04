import QtQuick 1.1
import com.nokia.meego 1.0
import QtMobility.location 1.2
import "../common"

/*!
 * @brief Includes sample code for QtMobility Location and Map demo
 * Show map with current position displaying coordinates.
 */

WAPage {
    id: mainPage
    property string latitudeStr: qsTr("Resolving...")
    property string longitudeStr: qsTr("Resolving...")
    property  bool resolved: false
    property Coordinate currentCoord

    tools: statusTools

    Component.onDestruction: positionSource.stop();

    Connections {
        target: Qt.application
        onActiveChanged: {
            if (Qt.application.active)
                positionSource.start();
            else
                positionSource.stop();
        }
    }

	WAHeader{
        title: qsTr("Send location")
        anchors.top:parent.top
        width:parent.width
		height: 73
    }


    //! Container for map element
    Rectangle {
        id : mapview
        anchors.top: parent.top
        anchors.topMargin: 73
        height: parent.height -73
		width: parent.width

        //! Map element centered with current position
        Map {
            id: map
            plugin : Plugin {
                        name : "nokia";

                        //! Location requires usage of app_id and token parameters.
                        //! Values below are for testing purposes only, please obtain real values.
                        //! Go to https://api.developer.nokia.com/ovi-api/ui/registration?action=list.
                        parameters: [
                            PluginParameter { name: "app_id"; value: "TkC5-XNRXMDAOgcbpP4X" },
                            PluginParameter { name: "token"; value: "L7R-fqk_5JgvdwjoTEmQhw" }
                       ]
                    }
            anchors.fill: parent
            size { width: parent.width; height: parent.height }
            center: positionSource.position.coordinate
            mapType: Map.StreetMap
            zoomLevel: 14

            //! Icon to display the current position
            MapImage {
                id: mapPlacer
                source: "../common/images/located.png"
                coordinate: positionSource.position.coordinate

                /*!
                 * We want that bottom middle edge of icon points to the location, so using offset parameter
                 * to change the on-screen position from coordinate. Values are calculated based on icon size,
                 * in our case icon is 48x48.
                 */
                offset.x: -24
                offset.y: -48
            }
        }

        //! Panning and pinch implementation on the maps
        /*PinchArea {
            id: pincharea

            //! Holds previous zoom level value
            property double __oldZoom

            anchors.fill: parent

            //! Calculate zoom level
            function calcZoomDelta(zoom, percent) {
                return zoom + Math.log(percent)/Math.log(2)
            }

            //! Save previous zoom level when pinch gesture started
            onPinchStarted: {
                __oldZoom = map.zoomLevel
            }

            //! Update map's zoom level when pinch is updating
            onPinchUpdated: {
                map.zoomLevel = calcZoomDelta(__oldZoom, pinch.scale)
            }

            //! Update map's zoom level when pinch is finished
            onPinchFinished: {
                map.zoomLevel = calcZoomDelta(__oldZoom, pinch.scale)
            }
        }*/

        //! Map's mouse area for implementation of panning in the map and zoom on double click
        /*MouseArea {
            id: mousearea

            //! Property used to indicate if panning the map
            property bool __isPanning: false

            //! Last pressed X and Y position
            property int __lastX: -1
            property int __lastY: -1

            anchors.fill : parent

            //! When pressed, indicate that panning has been started and update saved X and Y values
            onPressed: {
                __isPanning = true
                __lastX = mouse.x
                __lastY = mouse.y
            }

            //! When released, indicate that panning has finished
            onReleased: {
                __isPanning = false
            }

            //! Move the map when panning
            onPositionChanged: {
                if (__isPanning) {
                    var dx = mouse.x - __lastX
                    var dy = mouse.y - __lastY
                    map.pan(-dx, -dy)
                    __lastX = mouse.x
                    __lastY = mouse.y
                }
            }

            //! When canceled, indicate that panning has finished
            onCanceled: {
                __isPanning = false;
            }

            //! Zoom one level when double clicked
            onDoubleClicked: {
                map.center = map.toCoordinate(Qt.point(__lastX,__lastY))
                map.zoomLevel += 1
            }
        }*/
    }

    //! Source for retrieving the positioning information
    PositionSource {
        id: positionSource

        //! Desired interval between updates in milliseconds
        updateInterval: 10000
        active: true

        //! When position changed, update the location strings
        onPositionChanged: {
            updateGeoInfo()
        }
    }

    function updateGeoInfo() {
        currentCoord = positionSource.position.coordinate
        latitudeStr = currentCoord.latitude
        longitudeStr = currentCoord.longitude

        resolved = true;
    }

    Column {
        anchors { bottom: parent.bottom; bottomMargin: 16; left: parent.left; leftMargin: 16; right: parent.right; rightMargin: 16 }
        spacing: 8

        Rectangle {
            id: longRect
            color: "gray"
	    opacity: 0.75
            height: 36
            width: parent.width
	    radius: height/2
            Label {
                id: longLabel
                anchors { left: parent.left; leftMargin: 8; right: parent.right; rightMargin: 8; bottom: parent.bottom; bottomMargin: 4; top: parent.top; topMargin: 4 }
                font { family: "Nokia Pure Text"; weight: Font.Light; pixelSize: 22 }

                text: qsTr("Longitude:") + " " + longitudeStr //+ "."
            }
        }

        Rectangle {
            id: latRect
            color: "gray"
	    opacity: 0.75
            height: 36
            width: parent.width
	    radius: height/2
            Label {
                id: latLabel
                anchors { left: parent.left; leftMargin: 8; right: parent.right; rightMargin: 8; bottom: parent.bottom; bottomMargin: 4; top: parent.top; topMargin: 4 }
                font { family: "Nokia Pure Text"; weight: Font.Light; pixelSize: 22 }

                text: qsTr("Latitude:") + " " + latitudeStr //+ "."
            }
        }
    }

	ToolBarLayout {
        id:statusTools

        ToolIcon{
            platformIconId: "toolbar-back"
       		onClicked: pageStack.pop()
        }

        ToolButton
        {
			anchors.horizontalCenter: parent.horizontalCenter
			width: 300
            text: qsTr("Send")
            onClicked: {
				sendLocation(currentJid,latitudeStr,longitudeStr,appWindow.inPortrait?"true":"false")
				pageStack.pop()
			}
            enabled:resolved
        }
       
    }

}

