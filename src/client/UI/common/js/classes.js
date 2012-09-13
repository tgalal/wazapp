//.pragma library
//@@TODO GLOBIFY USAGE
function Conversation(parent,modelData) {
    var self = this;
    this.view = {};
    this.modelData = modelData || {};

    Component.call(this,"../Conversations/Conversation.qml",parent);

   // this.view.model = this.model;
   // this.model.view = this.view;
    
}





function Component(componentName,parent)
{
    var component = Qt.createComponent(componentName);

    var dynamicObject = component.createObject(parent);
    if(dynamicObject == null){
        console.log("error creating block");
        console.log(component.errorString());

        return false;
    }

   this.view=dynamicObject;

    return;
    if(component.status == Component.Ready){


    }else{
        console.log("error loading block component");
        console.log(component.errorString());
        return false;
    }

}
