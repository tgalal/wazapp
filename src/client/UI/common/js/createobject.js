function createObject(sourceFile, parentObject) {
    var component = Qt.createComponent(sourceFile);
    var guiObject = component.createObject(parentObject);

    if (guiObject == null) {
        console.log("Error creating object");
    }
    else {
        return guiObject
    }
}
