var emojiSelectCallback;
var emojiTextarea;

var emoji = new Array();
var emoji_landscape = new Array();


function addEmoji(code, path){
    var component = Qt.createComponent("../Components/Emoji.qml");

    var dynamicObject = component.createObject(emojiGrid.contentItem);
    if(dynamicObject == null){
        console.log("error creating block");
        console.log(component.errorString());

        return false;
    }

    dynamicObject.code = code;
    dynamicObject.emojiPath = path;
    dynamicObject.selected.connect(selectEmoji)
    //dynamicObject.anchors.top = emojiGrid.top
    //dynamicObject.anchors.left = emojiGrid.left
    //dynamicObject.x = emoji.x;
    //dynamicObject.y = emoji.y;


    return dynamicObject;

}
