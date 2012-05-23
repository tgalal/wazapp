// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0

PageStackWindow{
    showStatusBar: true
    initialPage: splashPage

    Page{
        id:splashPage
        Image {
            id: splashImage
            source: "pics/wasplash.png"
            width: parent.width
            height: parent.height
        }
    }
}


