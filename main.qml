import QtQuick 2.15
import QtQuick.Window 2.15
import CustomFortunaGenerator 1.0

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    Rectangle {
        id: testRect
        anchors.centerIn: parent
        width: 40
        height: 50
        color: "green"
    }

    Fortuna {
        id: gen
        Component.onCompleted: {
            console.log("GOOD >>>")
            console.log(gen.generate())
            console.log("GOOD <<<")
        }
    }
}
