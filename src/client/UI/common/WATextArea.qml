import QtQuick 1.1
import com.nokia.meego 1.0
import "." 1.0
import Qt.labs.components 1.0
import "/usr/lib/qt4/imports/com/nokia/meego/UIConstants.js" as UI
import "/usr/lib/qt4/imports/com/nokia/meego/EditBubble.js" as Popup
import "/usr/lib/qt4/imports/com/nokia/meego/Magnifier.js" as MagnifierPopup
import "/usr/lib/qt4/imports/com/nokia/meego/SelectionHandles.js" as SelectionHandles
import "js/WATextAreaHelper.js" as WATextAreaHelper
import "js/Global.js" as Helpers

FocusScope {
    id: root

    signal textPasted
    signal enterKeyClicked
    signal inputPanelChanged
    property int lastPosition:0
    property alias textColor: textEdit.color

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

    property QtObject platformStyle: TextFieldStyle {}
    property alias style: root.platformStyle

    property alias platformPreedit: inputMethodObserver.preedit

    //force a western numeric input panel even when vkb is set to arabic
    property alias platformWesternNumericInputEnforced: textEdit.westernNumericInputEnforced
    property bool platformSelectable: true

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
        if (res.indexOf("-qt-paragraph-type:empty;") != -1)
	    res = res.replace("text-indent:0px;\"><br />","text-indent:0px;\">")
        while(res.indexOf("<br />")>-1) res = res.replace("<br />", "wazappLineBreak");
        res = res.replace(/<[^>]*>?/g, "").replace(repl,"");
        res = res.replace(/^\s+/,"");
        while(res.indexOf("wazappLineBreak")>-1) res = res.replace("wazappLineBreak", "<br />");
        return [res, result[1]];

    }
    
    function insert(object) {
	var text = root.text
	consoleDebug("insert()")
	consoleDebug(text)
	var richText = text.split("</head>")[1].split("</body>")[0]
	if (richText.indexOf("-qt-paragraph-type:empty;") != -1)
	    richText = richText.replace("text-indent:0px;\"><br />","text-indent:0px;\">")
	richText = richText.replace(/\<p[^\>]*\>/g, "").replace(/<\/p>/g, "")
	richText = richText.replace(/\<body[^\>]*\>\n/g, "")
	richText = richText.replace(/\n/g, "<br />")
	
	consoleDebug(richText.length)
	
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
        platformCloseSoftwareInputPanel()
    }

    function platformCloseSoftwareInputPanel() {
        inputContext.simulateSipClose();
        textEdit.closeSoftwareInputPanel();
    }

    function openSoftwareInputPanel() {
        platformOpenSoftwareInputPanel()
    }

    function platformOpenSoftwareInputPanel() {
        inputContext.simulateSipOpen();
        textEdit.openSoftwareInputPanel();
    }

    Connections {
        target: platformWindow

        onActiveChanged: {
            if(platformWindow.active) {
                if (__hadFocusBeforeMinimization) {                                                                                                         
                    __hadFocusBeforeMinimization = false                                                                                                      
                    if (root.parent)                                                                                                                          
                        root.focus = true                                                                                                                     
                    else                                                                                                                                      
                        textInput.focus = true                                                                                                                
                }
                if (!readOnly) {
                    if (activeFocus) {
                        platformOpenSoftwareInputPanel();
                        repositionTimer.running = true;
                    }
                }
            } else {
                if (activeFocus) {
                    platformCloseSoftwareInputPanel();
                    Popup.close(textEdit);
                    SelectionHandles.close(textEdit);

                    __hadFocusBeforeMinimization = true                                                                                                                                                                                           
                    if (root.parent)                                                                                     
                        root.parent.focus = true                                           
                    else                                                                       
                        textInput.focus = false
                }
            }
        }

        onAnimatingChanged: {
            if (!platformWindow.animating && root.activeFocus) {
                WATextAreaHelper.repositionFlickable(contentMovingAnimation);
            }
        }
    }

    // private
    property int __preeditDisabledMask: Qt.ImhHiddenText|                       
                                        Qt.ImhNoPredictiveText|                
                                        Qt.ImhDigitsOnly|                      
                                        Qt.ImhFormattedNumbersOnly|             
                                        Qt.ImhDialableCharactersOnly|           
                                        Qt.ImhEmailCharactersOnly|              
                                        Qt.ImhUrlCharactersOnly 
    
    property bool __hadFocusBeforeMinimization: false
    
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
            SelectionHandles.close(textEdit);
            MagnifierPopup.close(); 
        }
    }

    BorderImage {
        id: background
	source: errorHighlight?
                platformStyle.backgroundError:
            readOnly?
                platformStyle.backgroundDisabled:
            textEdit.activeFocus? 
                platformStyle.backgroundSelected:
                platformStyle.background

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

        font: root.platformStyle.textFont
        color: "gray"
        elide: Text.ElideRight

        // opacity for default state
        opacity:  1.0

        states: [
            State {
                name: "unfocused"
                // memory allocation optimization: cursorPosition is checked to minimize displayText evaluations
                when: !root.activeFocus && textEdit.cursorPosition == 0 && !textEdit.text && prompt.text && !textEdit.inputMethodComposing
                PropertyChanges { target: prompt; opacity: 1.0; }
            },
            State {
                name: "focused"
                // memory allocation optimization: cursorPosition is checked to minimize displayText evaluations
                when: root.activeFocus && textEdit.cursorPosition == 0 && !textEdit.text && prompt.text && !textEdit.inputMethodComposing
                PropertyChanges { target: prompt; opacity: 0.6; }
            }
        ]

        transitions: [
            Transition {
                from: "unfocused"; to: "focused";
                reversible: true
                SequentialAnimation {
                    PauseAnimation { duration: 60 }
                    NumberAnimation { target: prompt; properties: "opacity"; duration: 150 }
                }
            },
            Transition {
                from: "focused"; to: "";
                reversible: true
                SequentialAnimation {
                    PauseAnimation { duration:  60 }
                    NumberAnimation { target: prompt; properties: "opacity"; duration: 100 }
                }
            }
        ]
    }

    MouseArea {
        enabled: !textEdit.activeFocus
        z: enabled?1:0
        anchors.fill: parent
        anchors.margins: UI.TOUCH_EXPANSION_MARGIN
        onClicked: {
            if (!textEdit.activeFocus) {
                textEdit.forceActiveFocus();

                // activate to preedit and/or move the cursor
                var preeditDisabled = root.inputMethodHints &                   
                                      root.__preeditDisabledMask
                var injectionSucceeded = false;
                var mappedMousePos = mapToItem(textEdit, mouseX, mouseY);
                var newCursorPosition = textEdit.positionAt(mappedMousePos.x, mappedMousePos.y, TextInput.CursorOnCharacter);
                if (!preeditDisabled) {
                    var beforeText = root.text;
                    if (!WATextAreaHelper.atSpace(newCursorPosition, beforeText)
                        && newCursorPosition != beforeText.length
                        && !(newCursorPosition == 0 || WATextAreaHelper.atSpace(newCursorPosition - 1, beforeText))) {

                        injectionSucceeded = WATextAreaHelper.injectWordToPreedit(newCursorPosition, beforeText);
                    }
                }
                if (!injectionSucceeded) {
                    textEdit.cursorPosition=newCursorPosition;
                }
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

        // this properties are evaluated by the input method framework
        property bool westernNumericInputEnforced: false
        property bool suppressInputMethod: !activeFocusOnPress

        onWesternNumericInputEnforcedChanged: {
            inputContext.update();
        }

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

        function updateMagnifierPosition(posX, posY) {
            var yAdjustment = 0
            var magnifier = MagnifierPopup.popup;
            var cursorHeight = textEdit.positionToRectangle(0,0).height;
            var mappedPos =  mapToItem(magnifier.parent, posX - magnifier.width / 2,
                                       posY - magnifier.height / 2 - cursorHeight - 70);

            magnifier.xCenter = mapToItem(magnifier.sourceItem, posX, 0).x;
            magnifier.x = mappedPos.x;
            if (-root.mapFromItem(magnifier.__rootElement, 0,0).y - posY < (magnifier.height / 1.5)) {
                yAdjustment = Math.max(0,(magnifier.height / 1.5) + root.mapFromItem(magnifier.__rootElement, 0,0).y - posY);
            } else {
                yAdjustment = 0;
            }
            magnifier.yCenter = mapToItem(magnifier.sourceItem, 0, posY - cursorHeight + 50).y
            magnifier.y = mappedPos.y + yAdjustment;
        }

        Component.onDestruction: {
            Popup.close(textEdit);
            SelectionHandles.close(textEdit);
        }

        onTextChanged: {
            if(root.activeFocus) {
                WATextAreaHelper.repositionFlickable(contentMovingAnimation);
            }

            if (textEdit.preedit == "" && Popup.isOpened(textEdit) && !Popup.isChangingInput())
                Popup.close(textEdit);
            if (SelectionHandles.isOpened(textEdit) && textEdit.selectedText == "")
                SelectionHandles.close(textEdit);
        }

        Connections {
            target: WATextAreaHelper.findFlickable(root.parent)

            onContentYChanged: if (root.activeFocus) WATextAreaHelper.filteredInputContextUpdate();
            onContentXChanged: if (root.activeFocus) WATextAreaHelper.filteredInputContextUpdate();
            onMovementEnded: inputContext.update();
        }

        Connections {
            target: inputContext

            onSoftwareInputPanelVisibleChanged: {
                inputPanelChanged()
                if (activeFocus)
                    WATextAreaHelper.repositionFlickable(contentMovingAnimation);
            }

            onSoftwareInputPanelRectChanged: {
                inputPanelChanged()
                if (activeFocus)
                    WATextAreaHelper.repositionFlickable(contentMovingAnimation);
            }
        }

        onCursorPositionChanged: {
            if(!MagnifierPopup.isOpened() && activeFocus) {
                WATextAreaHelper.repositionFlickable(contentMovingAnimation)
            }

           if (MagnifierPopup.isOpened()) {
               if (Popup.isOpened(textEdit)) {
                   Popup.close(textEdit);
               }
               if (SelectionHandles.isOpened(textEdit)) {
                   SelectionHandles.close(textEdit);
               }
           } else if (!mouseFilter.attemptToActivate ||
                textEdit.cursorPosition == textEdit.text.length) {
                if ( Popup.isOpened(textEdit) ) {
                    Popup.close(textEdit);
                    Popup.open(textEdit,
                           textEdit.positionToRectangle(textEdit.cursorPosition));
                }
            }
        }

        onSelectedTextChanged: {
            if ( !platformSelectable )
                textEdit.deselect(); // enforce deselection in all cases we didn't think of

            if (Popup.isOpened(textEdit) && !Popup.isChangingInput()) {
                Popup.close(textEdit);
            }
            if (SelectionHandles.isOpened(textEdit)) {
                SelectionHandles.close(textEdit);
            }
        }

        InputMethodObserver {
            id: inputMethodObserver

            onPreeditChanged: {
                if (Popup.isOpened(textEdit) && !Popup.isChangingInput()) {
                    Popup.close(textEdit);
                }
                if (SelectionHandles.isOpened(textEdit)) {
                    SelectionHandles.close(textEdit);
                }
            }

        }

        Timer {
            id: repositionTimer
            interval: 350
            onTriggered: WATextAreaHelper.repositionFlickable(contentMovingAnimation)
        }

        PropertyAnimation {
            id: contentMovingAnimation
            property: "contentY"
            duration: 200
            easing.type: Easing.InOutCubic
        }

        MouseFilter {
            id: mouseFilter
            anchors.fill: parent
            anchors.leftMargin:  UI.TOUCH_EXPANSION_MARGIN - UI.PADDING_XLARGE
            anchors.rightMargin:  UI.TOUCH_EXPANSION_MARGIN - UI.PADDING_MEDIUM
            anchors.topMargin: UI.TOUCH_EXPANSION_MARGIN - (UI.FIELD_DEFAULT_HEIGHT - font.pixelSize) / 2
            anchors.bottomMargin:  UI.TOUCH_EXPANSION_MARGIN - (UI.FIELD_DEFAULT_HEIGHT - font.pixelSize) / 2

            property bool attemptToActivate: false
            property bool pressOnPreedit

            property variant editBubblePosition: null

            onPressed: {
                var mousePosition = textEdit.positionAt(mouse.x,mouse.y,TextEdit.CursorOnCharacter);
                pressOnPreedit = textEdit.cursorPosition==mousePosition
                var preeditDisabled = root.inputMethodHints &                  
                                      root.__preeditDisabledMask

                attemptToActivate = !pressOnPreedit && !root.readOnly && !preeditDisabled && root.activeFocus &&
                                    !(mousePosition == 0 || WATextAreaHelper.atSpace(mousePosition - 1, root.text) || WATextAreaHelper.atSpace(mousePosition, root.text));
                mouse.filtered = true;
            }

            onHorizontalDrag: {
                // possible pre-edit word have to be committed before selection
                if (root.activeFocus || root.readOnly) {
                    inputContext.reset()
                    if ( platformSelectable )
                        parent.selectByMouse = true
                    attemptToActivate = false
                }
            }

            onPressAndHold:{
                // possible pre-edit word have to be commited before showing the magnifier
                if ((root.text != "" || inputMethodObserver.preedit != "") && root.activeFocus) {
                    textEdit.color = "gray"
                    inputContext.reset()
                    attemptToActivate = false
                    parent.selectByMouse = false
                    MagnifierPopup.open(root);
                    var magnifier = MagnifierPopup.popup;
                    parent.cursorPosition = parent.positionAt(mouse.x,mouse.y)
                    parent.updateMagnifierPosition(mouse.x,mouse.y)
                    root.z = Number.MAX_VALUE
                }
            }

            onReleased:{  
                textEdit.color = theme.inverted ? "white" : "black"
      
                if (MagnifierPopup.isOpened()) {
                    MagnifierPopup.close();
                    WATextAreaHelper.repositionFlickable(contentMovingAnimation);
                }

                if (attemptToActivate)
                    inputContext.reset();

                var newCursorPosition = textEdit.positionAt(mouse.x,mouse.y,TextEdit.CursorOnCharacter);
                if (textEdit.preedit.length == 0)                   
                    editBubblePosition = textEdit.positionToRectangle(newCursorPosition);

                if (attemptToActivate) {
                    var beforeText = textEdit.text;

                    textEdit.cursorPosition = newCursorPosition;
                    var injectionSucceeded = false;

                    if (!WATextAreaHelper.atSpace(newCursorPosition, beforeText)
                             && newCursorPosition != beforeText.length) {
                        injectionSucceeded = WATextAreaHelper.injectWordToPreedit(newCursorPosition, beforeText);
                    }
                    if (injectionSucceeded) {
                        mouse.filtered=true;
                        if (textEdit.preedit.length >=1 && textEdit.preedit.length <= 4)
                            editBubblePosition = textEdit.positionToRectangle(textEdit.cursorPosition);
                    } else {
                        textEdit.text=beforeText;
                        textEdit.cursorPosition=newCursorPosition;
                    }
                    attemptToActivate = false;
                } else if (!parent.selectByMouse) {
                    if (!pressOnPreedit) inputContext.reset();
                    textEdit.cursorPosition = textEdit.positionAt(mouse.x,mouse.y,TextEdit.CursorOnCharacter);
                }
                parent.selectByMouse = false;
            }
            onFinished: {
                if (root.activeFocus && platformEnableEditBubble) {
                    if (textEdit.preedit.length == 0)
                        editBubblePosition = textEdit.positionToRectangle(textEdit.cursorPosition);
                    if (editBubblePosition != null) {
                        Popup.open(textEdit,editBubblePosition);
                        editBubblePosition = null;
                    }
                    if (textEdit.selectedText != "")
                        SelectionHandles.open(textEdit);
                }
            }
            onMousePositionChanged: {
               if (MagnifierPopup.isOpened() && !parent.selectByMouse) {
                    var pos = textEdit.positionAt (mouse.x,mouse.y)
                    parent.cursorPosition = pos
                    parent.updateMagnifierPosition(mouse.x,mouse.y);
                }
            }
            onDoubleClicked: {
                // possible pre-edit word have to be committed before selection
                inputContext.reset()
                if ( platformSelectable )
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
