WorkerScript.onMessage=function(msg) {

    var model = msg.model;
    var data = msg.data
    console.log("Worker live")
    for(var i=0; i<data.length; i++){
        model.append(data[i])
    }
    model.sync()
    WorkerScript.sendMessage({"result":"OK"})

}
