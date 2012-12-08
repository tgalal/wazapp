.pragma library

var popup = null;

function findRootItem(item, objectName)
{
    var next = item;
    
    var rootItemName = "windowContent";
    if (typeof(objectName) != 'undefined') {
        rootItemName = objectName;
    }

    if (next) {
        while (next.parent) {
            next = next.parent;

            if (rootItemName == next.objectName) {
                break;
            }
        }
    }

    return next;
}

function init(item)
{
    if (popup != null)
        return true;

    var root = findRootItem(item);

    // create root popup
    var component = Qt.createComponent("../WAMagnifier.qml");
    //var component = Qt.createComponent("/usr/lib/qt4/imports/com/nokia/meego/Magnifier.qml");

    // due the pragma we cannot access Component.Ready
    if (component)
        popup = component.createObject(root);

    if (popup)
        popup.__rootElement = root;

    return popup != null;
}

/*
  Open a shared magnifier for a given input item.

  input item will be used as a sourceItem for the shader
  effect
*/
function open(input, inverted)
{
    if (!input)
        return false;

    if (!init(input))
        return false;

    popup.sourceItem = input;
    popup.active = true;
    popup.inverted = inverted
    return true;
}

/*
  Check if the shared magnifier is opened
*/
function isOpened()
{
    return (popup && popup.active);
}

/*
  Close and destroy the magnifier.
*/
function close()
{
    if (popup){
        popup.active = false;
        popup.destroy();
        popup = null;
    }
}

