.pragma library

function makeid(l)
{
    var text = "";
    var possible = "abcdefghijklmnopqrstuvwxyz";

    for( var i=0; i < l; i++ )
        text += possible.charAt(Math.floor(Math.random() * possible.length));

    return text;
}
