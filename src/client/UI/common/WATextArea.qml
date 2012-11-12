import QtQuick 1.1
import com.nokia.meego 1.0
import "." 1.0
import Qt.labs.components 1.0
import "/usr/lib/qt4/imports/com/nokia/meego/UIConstants.js" as UI
import "/usr/lib/qt4/imports/com/nokia/meego/EditBubble.js" as Popup
import "/usr/lib/qt4/imports/com/nokia/meego/TextAreaHelper.js" as TextAreaHelper
import "js/Global.js" as Helpers

FocusScope {
    id: root

    signal textPasted
    signal enterKeyClicked
    signal inputPanelChanged
    property int lastPosition:0

    // Common public API
    property alias text: textEdit.text
    property alias placeholderText: prompt.text
    property alias textColor: textEdit.color

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

    onPlatformSipAttributesChanged: {
        platformSipAttributes.registerInputElement(textEdit)
    }

    function _getCleanText() {
        var repl = "p, li { white-space: pre-wrap; }";
        var res = root.text
        var result = Helpers.getCode(res);
        res = result[0]
        var pos = result[1]
        res = res.replace(/<[^>]*>?/g, "").replace(repl,"");
        res = res.replace(/^\s+/,"");
        return [res, pos];
    }

    function getCleanText(){

        var repl = "p, li { white-space: pre-wrap; }";
        var res = root.text
        var result = Helpers.getCode(res);
        res = result[0]
        res = res.replace("text-indent:0px;\"><br />","text-indent:0px;\">")
        while(res.indexOf("<br />")>-1) res = res.replace("<br />", "wazappLineBreak");
        res = res.replace(/<[^>]*>?/g, "").replace(repl,"");
        res = res.replace(/^\s+/,"");
        while(res.indexOf("wazappLineBreak")>-1) res = res.replace("wazappLineBreak", "<br />");
        return [res, count()];

    }
    
    function insert(object) {
	var text = root.text
	var richText = text.split("</head>")[1].split("</body>")[0]
	richText = richText.replace(/\<p[^\>]*\>/g, "").replace(/<\/p>/g, "")
	richText = richText.replace(/\<body[^\>]*\>\n/g, "")
	richText = richText.replace(/\n/g, "<br />")
	
	var listText = []
	for(var i =0; i<richText.length; i++)
	{
	    if (richText[i] == "<")
	    {
		var j =  richText.indexOf(">", i+1)
		listText.push(richText.substring(i, j+1))
		i = j
	    }
	    else if (richText[i] == "&")
	    {
		var j =  richText.indexOf(";", i+1)
		listText.push(richText.substring(i, j+1))
		i = j
	    }
	    else
		listText.push(richText[i])
	}
	listText.splice(root.cursorPosition,0,object)
	var result = listText.join("")
	
	root.lastPosition = root.cursorPosition
	root.text = result
	root.cursorPosition = root.lastPosition + 1
    }

    function copy() {
        textEdit.copy()
    }

    function paste() {
        textEdit.paste()
        textPasted()
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
        onVisibleChanged: {
            if (prompt.visible) platformCloseSoftwareInputPanel()
            else platformOpenSoftwareInputPanel()
        }
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

        Keys.onEnterPressed: { enterKeyClicked() }
        Keys.onReturnPressed: { enterKeyClicked() }


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
                inputPanelChanged()
                if (activeFocus)
                    TextAreaHelper.repositionFlickable(contentMovingAnimation);
            }

            onSoftwareInputPanelRectChanged: {
                inputPanelChanged()
                if (activeFocus)
                    TextAreaHelper.repositionFlickable(contentMovingAnimation);
            }
        }

        onCursorPositionChanged: {
            if(activeFocus) {
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


            onReleased:{

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
                    Popup.open(textEdit, textEdit.cursorPosition);
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
