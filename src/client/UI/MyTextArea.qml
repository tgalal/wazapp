import QtQuick 1.1
import com.nokia.meego 1.0
import "." 1.0
import Qt.labs.components 1.0
import "/usr/lib/qt4/imports/com/nokia/meego/UIConstants.js" as UI
import "/usr/lib/qt4/imports/com/nokia/meego/EditBubble.js" as Popup
import "/usr/lib/qt4/imports/com/nokia/meego/TextAreaHelper.js" as TextAreaHelper
import "/usr/lib/qt4/imports/com/nokia/meego/Magnifier.js" as MagnifierPopup

FocusScope {
    id: root

    // Common public API
    property alias text: textEdit.text
    property alias placeholderText: prompt.text

    property alias font: textEdit.font
    property alias cursorPosition: textEdit.cursorPosition
    property alias readOnly: textEdit.readOnly

    property alias horizontalAlignment: textEdit.horizontalAlignment
    property alias verticalAlignment: textEdit.verticalAlignment

    property alias selectedText: textEdit.selectedText
    property alias selectionStart: textEdit.selectionStart
    property alias selectionEnd: textEdit.selectionEnd

    property alias wrapMode: textEdit.wrapMode
    property alias textFormat: textEdit.textFormat
    // Property enableSoftwareInputPanel is DEPRECATED
    property alias enableSoftwareInputPanel: textEdit.activeFocusOnPress

    property alias inputMethodHints: textEdit.inputMethodHints

    property bool errorHighlight: false

    property Item platformSipAttributes

    property bool platformEnableEditBubble: true

    property Item platformStyle: TextAreaStyle {}
    property alias style: root.platformStyle

    property alias platformPreedit: inputMethodObserver.preedit

	platformSipAttributes: SipAttributes { 
		actionKeyEnabled: cleanText(chat_text.text).trim()!=""
		actionKeyIcon: "image://theme/icon-m-toolbar-send-chat-white"
		actionKeyLabel: ""
	}
    Keys.onEnterPressed: input_button_holder.send_button.clicked()
    Keys.onReturnPressed: input_button_holder.send_button.clicked()

    onPlatformSipAttributesChanged: {
        platformSipAttributes.registerInputElement(textEdit)
    }

    function copy() {
        textEdit.copy()
    }

    function paste() {
        textEdit.paste()
    }

    function cut() {
        textEdit.cut()
    }

    // ensure propagation of forceActiveFocus
    function forceActiveFocus() {
        textEdit.forceActiveFocus()
    }

    function select(start, end) {
        textEdit.select(start, end)
    }

    function selectAll() {
        textEdit.selectAll()
    }

    function selectWord() {
        textEdit.selectWord()
    }

    function positionAt(x, y) {
        var p = mapToItem(textEdit, x, y);
        return textEdit.positionAt(p.x, p.y)
    }

    function positionToRectangle(pos) {
        var rect = textEdit.positionToRectangle(pos)
        var point = mapFromItem(textEdit, rect.x, rect.y)
        rect.x = point.x; rect.y = point.y
        return rect;
    }

    function closeSoftwareInputPanel() {
        console.log("TextArea's function closeSoftwareInputPanel is deprecated. Use function platformCloseSoftwareInputPanel instead.")
        platformCloseSoftwareInputPanel()
    }

    function platformCloseSoftwareInputPanel() {
        inputContext.simulateSipClose();
        textEdit.closeSoftwareInputPanel();
    }

    function openSoftwareInputPanel() {
        console.log("TextArea's function openSoftwareInputPanel is deprecated. Use function platformOpenSoftwareInputPanel instead.")
        platformOpenSoftwareInputPanel()
    }

    function platformOpenSoftwareInputPanel() {
        inputContext.simulateSipOpen();
        textEdit.openSoftwareInputPanel();
    }

    implicitWidth: platformStyle.defaultWidth
    implicitHeight: Math.max (UI.FIELD_DEFAULT_HEIGHT,
                              textEdit.height + (UI.FIELD_DEFAULT_HEIGHT - font.pixelSize))

    onActiveFocusChanged: {
        if (activeFocus &&
            !readOnly) {
            platformOpenSoftwareInputPanel();
            repositionTimer.running = true;
        } else if (!activeFocus) {
            if (!readOnly)
                platformCloseSoftwareInputPanel();

            Popup.close(textEdit);
        }
    }

    BorderImage {
        id: background
        source: {
            if(root.errorHighlight) return root.platformStyle.backgroundError
            else if(root.readOnly) return root.platformStyle.backgroundDisabled
            else if(textEdit.activeFocus) return root.platformStyle.backgroundSelected
            else return root.platformStyle.background
        }
        anchors.fill: parent
        border.left: root.platformStyle.backgroundCornerMargin; border.top: root.platformStyle.backgroundCornerMargin
        border.right: root.platformStyle.backgroundCornerMargin; border.bottom: root.platformStyle.backgroundCornerMargin
    }

    Text {
        id: prompt

        anchors.fill: parent
        anchors.leftMargin: UI.PADDING_XLARGE
        anchors.rightMargin: UI.PADDING_XLARGE
        anchors.topMargin: (UI.FIELD_DEFAULT_HEIGHT - font.pixelSize) / 2
        anchors.bottomMargin: (UI.FIELD_DEFAULT_HEIGHT - font.pixelSize) / 2

        // memory allocation optimization: cursorPosition is checked to minimize displayText evaluations
        //visible: !textEdit.text && prompt.text && !textEdit.inputMethodComposing
        font: root.platformStyle.textFont
        color: "gray"
        elide: Text.ElideRight
    }

    MouseArea {
        enabled: !textEdit.activeFocus
        z: enabled?1:0
        anchors.fill: parent
        anchors.margins: UI.TOUCH_EXPANSION_MARGIN
        onClicked: {
            if (!textEdit.activeFocus) {
                textEdit.forceActiveFocus();
            }
        }
    }

    TextEdit {
        id: textEdit

        // Exposed for the edit bubble
        property alias preedit: inputMethodObserver.preedit
        property alias preeditCursorPosition: inputMethodObserver.preeditCursorPosition

        x: UI.PADDING_XLARGE
        y: (UI.FIELD_DEFAULT_HEIGHT - font.pixelSize) / 2
        width: parent.width - UI.PADDING_XLARGE * 2

        font: root.platformStyle.textFont
        color: theme.inverted ? "white" : "black"
        selectByMouse: true
        selectedTextColor: root.platformStyle.selectedTextColor
        selectionColor: root.platformStyle.selectionColor
        mouseSelectionMode: TextInput.SelectWords
        wrapMode: TextEdit.Wrap
        persistentSelection: false
        focus: true

        function updateMagnifierPosition() {
            var magnifier = MagnifierPopup.popup;
            var mappedPos =  mapToItem(magnifier.parent, positionToRectangle(cursorPosition).x - magnifier.width / 2,
                                       positionToRectangle(cursorPosition).y - magnifier.height / 2 - 70);

            magnifier.xCenter = positionToRectangle(cursorPosition).x / root.width;
            magnifier.x = mappedPos.x;
            if (-root.mapFromItem(magnifier.__rootElement(), 0,0).y - positionToRectangle(cursorPosition).y < (magnifier.height / 1.5)) {
                magnifier.yAdjustment = Math.max(0,(magnifier.height / 1.5) + root.mapFromItem(magnifier.__rootElement(), 0,0).y - positionToRectangle(cursorPosition).y);
            } else {
                magnifier.yAdjustment = 0;
            }
            magnifier.yCenter = 1.0 - ((50 + (positionToRectangle(cursorPosition).y)) / root.height);
            magnifier.y = mappedPos.y + magnifier.yAdjustment;
        }

        Component.onDestruction: {
            Popup.close(textEdit);
        }

        onTextChanged: {
            if(root.activeFocus) {
                TextAreaHelper.repositionFlickable(contentMovingAnimation);
            }

            if (textEdit.preedit == "" && Popup.isOpened(textEdit) && !Popup.isChangingInput())
                Popup.close(textEdit);
        }

        Connections {
            target: TextAreaHelper.findFlickable(root.parent)

            onContentYChanged: if (root.activeFocus) TextAreaHelper.filteredInputContextUpdate();
            onContentXChanged: if (root.activeFocus) TextAreaHelper.filteredInputContextUpdate();
            onMovementEnded: inputContext.update();
        }

        Connections {
            target: platformWindow

            onAnimatingChanged: {
                if (!platformWindow.animating && root.activeFocus)
                    TextAreaHelper.repositionFlickable(contentMovingAnimation);
            }
        }

        Connections {
            target: inputContext

            onSoftwareInputPanelVisibleChanged: {
                if (activeFocus)
                    TextAreaHelper.repositionFlickable(contentMovingAnimation);
            }

            onSoftwareInputPanelRectChanged: {
                if (activeFocus)
                    TextAreaHelper.repositionFlickable(contentMovingAnimation);
            }
        }

        onCursorPositionChanged: {
            if (MagnifierPopup.isOpened()) {
                updateMagnifierPosition();
            } else if(activeFocus) {
                TextAreaHelper.repositionFlickable(contentMovingAnimation)
            }

            if (Popup.isOpened(textEdit)) {
                Popup.close(textEdit);
                Popup.open(textEdit);
            }
        }

        onSelectedTextChanged: {
            if (Popup.isOpened(textEdit) && !Popup.isChangingInput()) {
                Popup.close(textEdit);
            }
        }

        InputMethodObserver {
            id: inputMethodObserver

            onPreeditChanged: {
                if (Popup.isOpened(textEdit) && !Popup.isChangingInput()) {
                    Popup.close(textEdit);
                }
            }

        }

        Timer {
            id: repositionTimer
            interval: 350
            onTriggered: TextAreaHelper.repositionFlickable(contentMovingAnimation)
        }

        PropertyAnimation {
            id: contentMovingAnimation
            property: "contentY"
            duration: 200
            easing.type: Easing.InOutCubic
        }

        MouseFilter {
            anchors.fill: parent
            anchors.leftMargin:  UI.TOUCH_EXPANSION_MARGIN - UI.PADDING_XLARGE
            anchors.rightMargin:  UI.TOUCH_EXPANSION_MARGIN - UI.PADDING_MEDIUM
            anchors.topMargin: UI.TOUCH_EXPANSION_MARGIN - (UI.FIELD_DEFAULT_HEIGHT - font.pixelSize) / 2
            anchors.bottomMargin:  UI.TOUCH_EXPANSION_MARGIN - (UI.FIELD_DEFAULT_HEIGHT - font.pixelSize) / 2
            property bool attemptToActivate: false
            property bool pressOnPreedit

            onPressed: {
                /*var mousePosition = textEdit.positionAt(mouse.x,mouse.y,TextEdit.CursorOnCharacter);
                pressOnPreedit = textEdit.cursorPosition==mousePosition
                var preeditDisabled = (
                        root.inputMethodHints&
                        (
                                Qt.ImhHiddenText|
                                Qt.ImhNoPredictiveText|
                                Qt.ImhDigitsOnly|
                                Qt.ImhFormattedNumbersOnly|
                                Qt.ImhDialableCharactersOnly|
                                Qt.ImhEmailCharactersOnly|
                                Qt.ImhUrlCharactersOnly
                )
                );
                attemptToActivate = !pressOnPreedit && !root.readOnly && !preeditDisabled && root.activeFocus && !(mousePosition == 0 || TextAreaHelper.atSpace(mousePosition - 1));
                mouse.filtered = true;*/
				inputContext.reset()
                parent.selectByMouse = true
                attemptToActivate = false
            }

            onHorizontalDrag: {
                // possible pre-edit word have to be committed before selection
                if (root.activeFocus || root.readOnly) {
                    inputContext.reset()
                    parent.selectByMouse = true
                    attemptToActivate = false
                }
            }

            /*onPressAndHold:{
                // possible pre-edit word have to be commited before showing the magnifier
                if ((root.text != "" || inputMethodObserver.preedit != "") && root.activeFocus) {
                    inputContext.reset()
                    attemptToActivate = false
                    parent.selectByMouse = false
                    MagnifierPopup.open(root);
                    var magnifier = MagnifierPopup.popup;
                    parent.updateMagnifierPosition()
                    parent.cursorPosition = textEdit.positionAt(mouse.x, mouse.y)
                    root.z = Number.MAX_VALUE
                }
            }*/

            onReleased:{
                if (MagnifierPopup.isOpened()) {
                    MagnifierPopup.close();
                    TextAreaHelper.repositionFlickable(contentMovingAnimation);
                }

                if (attemptToActivate) {
                    inputContext.reset();
                    var beforeText = textEdit.text;

                    var newCursorPosition = textEdit.positionAt(mouse.x,mouse.y,TextInput.CursorOnCharacter);
                    var injectionSucceeded = false;

                    if (!TextAreaHelper.atSpace(newCursorPosition)
                             && !(newCursorPosition == textEdit.text.length && TextAreaHelper.atSpace(newCursorPosition-1))
                             && newCursorPosition != textEdit.text.length) {
                        var preeditStart = TextAreaHelper.previousWordStart(newCursorPosition);
                        var preeditEnd = TextAreaHelper.nextWordEnd(newCursorPosition);

                        // copy word to preedit text
                        var preeditText = textEdit.text.substring(preeditStart,preeditEnd);

                        // inject preedit
                        textEdit.cursorPosition = preeditStart;

                        var eventCursorPosition = newCursorPosition-preeditStart;
                        injectionSucceeded = inputContext.setPreeditText(preeditText, eventCursorPosition, 0, preeditText.length);
                    }
                    if (injectionSucceeded) {
                        mouse.filtered=true;
                    } else {
                        textEdit.text=beforeText;
                        textEdit.cursorPosition=newCursorPosition;
                    }
                    attemptToActivate = false;
                } else if (!parent.selectByMouse) {
                    if (!pressOnPreedit) inputContext.reset();
                    textEdit.cursorPosition = textEdit.positionAt(mouse.x,mouse.y,TextInput.CursorOnCharacter);
                }
                //parent.selectByMouse = false;
            }
            onFinished: {
                if (root.activeFocus && platformEnableEditBubble)
                    Popup.open(textEdit);
            }
            onMousePositionChanged: {
               //if (MagnifierPopup.isOpened() && !parent.selectByMouse) {
                    var pos = textEdit.positionAt (mouse.x,mouse.y)
                    var posNextLine = textEdit.positionAt (mouse.x, mouse.y + 1)
                    var posPrevLine = textEdit.positionAt (mouse.x, mouse.y - 1)
                    if (!(Math.abs(posNextLine - pos) > 1 || Math.abs(posPrevLine - pos) > 1)) {
                        parent.cursorPosition = pos
                    }
                //}
            }
            onDoubleClicked: {
                // possible pre-edit word have to be committed before selection
                inputContext.reset()
                parent.selectByMouse = true
                attemptToActivate = false
            }
        }
    }



    InverseMouseArea {
        anchors.fill: parent
        anchors.margins: UI.TOUCH_EXPANSION_MARGIN
        enabled: root.activeFocus

        onClickedOutside: {
            if (Popup.isOpened(textEdit) && ((mouseX > Popup.geometry().left && mouseX < Popup.geometry().right) &&
                                           (mouseY > Popup.geometry().top && mouseY < Popup.geometry().bottom))) {
                return;
            }

            root.parent.focus = true;
        }
    }
}
