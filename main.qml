import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import CustomFortunaGenerator 1.0
import QtSensors 5.15

Window {
    id: win
//    width: 640
//    height: 480
    visible: true

    Fortuna {
        id: generator
    }

    Rectangle {
        id: header
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: 100
        color: "lightblue"

        Label {
            anchors {
                margins: 24
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            text: qsTr("Fortuna генератор")
            font.pixelSize: 24
        }
    }

    Item {
        id: content
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        StackView {
            id: contentView

            anchors.fill: parent
            initialItem: mainPage

            property var sensors: []
            property string sensorStr
            property int randomNumbersCount: 10

            Component.onCompleted: {
                generator.addSource(accelerometer.type)
                contentView.sensors.push(accelerometer.type)

                generator.addSource(compass.type)
                contentView.sensors.push(compass.type)

                generator.addSource(gyroscope.type)
                contentView.sensors.push(gyroscope.type)

                generator.addSource(lightSensor.type)
                contentView.sensors.push(lightSensor.type)

                sensorStr = contentView.sensors.join(", ")

                if (generator.prepareEntropy())
                    console.log("Generator ready")
                else
                    console.warn("Generator not ready")
            }

            onCurrentItemChanged: {
                console.log("Current page changed")
                if (contentView.sensors.length == 0)
                    sensorStr = qsTr("Нет")
                else
                    sensorStr = contentView.sensors.join(", ")
            }

            Component {
                id: mainPage
                Item {
                    ColumnLayout {
                        anchors {
                            fill: parent
                            margins: 24
                        }
                        spacing: 4

                        Rectangle {
                            id: selectSensorsDelegate
                            Layout.fillWidth: true
                            Layout.preferredHeight: 100
                            border {
                                color: "gray"
                                width: 1
                            }
                            radius: 2

                            ItemDelegate {
                                anchors.fill: parent
                                Label {
                                    anchors {
                                        margins: 24
                                        left: parent.left
                                        verticalCenter: parent.verticalCenter
                                    }
                                    text: qsTr("Выбрать сенсоры")
                                    font.pixelSize: 16
                                }

                                onClicked: {
                                    console.log("Select sensors >>>")
                                    generator.clearSources()
                                    contentView.sensors = []
                                    contentView.push(sensorsPage)
                                }
                            }
                        }

                        ColumnLayout {
                            id: selectedSensors
                            Layout.fillWidth: true
                            Layout.preferredHeight: 100
                            spacing: 4

                            Label {
                                text: qsTr("Выбранные сенсоры") + ": "
                                font.pixelSize: 16
                            }
                            Label {
                                text: contentView.sensorStr
                                font.pixelSize: 14
                            }
                        }

                        Rectangle {
                            id: generateNumber
                            Layout.fillWidth: true
                            Layout.preferredHeight: 100
                            enabled: sensorStr !== qsTr("Нет")
                            border {
                                color: "gray"
                                width: 1
                            }
                            radius: 2

                            property string currentNumber: "---"

                            ItemDelegate {
                                anchors.fill: parent
                                ColumnLayout {
                                    id: generateNumberContent
                                    anchors.fill: parent
                                    spacing: 4

                                    Label {
                                        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                                        Layout.margins: 8
                                        text: qsTr("Сгенерировать рандомное число")
                                        font.pixelSize: 16
                                    }

                                    Label {
                                        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                                        Layout.margins: 8
                                        text: generateNumber.currentNumber
                                        font.bold: true
                                        font.pixelSize: 14
                                    }
                                }

                                onClicked: {
                                    generateNumber.currentNumber = generator.generate().toString()
                                }
                            }
                        }

                        Item {
                            id: selectRandomNumberCount
                            Layout.fillWidth: true
                            Layout.preferredHeight: 100
                            enabled: sensorStr !== qsTr("Нет")

                            RowLayout {
                                id: selectRandomNumberContent
                                anchors.fill: parent
                                anchors.margins: 4
                                spacing: 8

                                Label {
                                    id: selectRandomNumberText
                                    Layout.maximumWidth: 200
                                    Layout.minimumWidth: 200
                                    Layout.preferredWidth: 200
                                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                    text: qsTr("Укажите количество чисел")
                                    font.pixelSize: 16
                                }

                                SpinBox {
                                    id: selectRandomNumber
                                    value: 10
                                    from: 1
                                    to: 25
                                    visible: true
                                }
                            }
                        }

                        Rectangle {
                            id: generateNumbers
                            Layout.fillWidth: true
                            Layout.preferredHeight: 100
                            enabled: sensorStr !== qsTr("Нет")
                            border {
                                color: "gray"
                                width: 1
                            }
                            radius: 2

                            ItemDelegate {
                                id: generateNumbersDelegate
                                anchors.fill: parent

                                Label {
                                    id: generateNumbersText
                                    anchors {
                                        margins: 24
                                        left: parent.left
                                        verticalCenter: parent.verticalCenter
                                    }
                                    text: qsTr("Сгенерировать числа")
                                    font.pixelSize: 16
                                }

                                onClicked: {
                                    console.log("Generate N digits >>>")
                                    console.log(selectRandomNumber.value)
                                    contentView.randomNumbersCount = selectRandomNumber.value
                                    contentView.push(resultPage)
//                                    console.log(generator.generateRange(selectRandomNumber.value))
                                }
                            }
                        }
                    }
                }
            }

            Component {
                id: sensorsPage
                Item {

                    ColumnLayout {
                        anchors {
                            fill: parent
                            margins: 24
                        }
                        spacing: 4

                        Text {
                            Layout.fillWidth: true
                            text: qsTr("Выберите сенсоры")
                            font.pixelSize: 20
                        }

                        CheckBox {
                            id: accelCheck
                            text: "Accelerometer"
                            checked: true
                        }
                        CheckBox {
                            id: compassCheck
                            text: "Compass"
                            checked: true
                        }
                        CheckBox {
                            id: gyroCheck
                            text: "Gyroscope"
                            checked: true

//                            onCheckedChanged: {
//                                if (checked)
//                                    contentView.sensors.push(gyroscope.type)
//                                else
//                                {
//                                    var index = contentView.sensors.indexOf(gyroscope.type)
//                                    if (index !== -1) {
//                                        contentView.sensors.splice(index, 1)
//                                    }
//                                }
//                                console.warn(contentView.sensors)
//                            }
                        }
                        CheckBox {
                            id: lightCheck
                            text: "Light sensor"
                            checked: true

//                            onCheckedChanged: {
//                                if (checked)
//                                    contentView.sensors.push(lightSensor.type)
//                                else
//                                {
//                                    var index = contentView.sensors.indexOf(lightSensor.type)
//                                    if (index !== -1) {
//                                        contentView.sensors.splice(index, 1)
//                                    }
//                                }

//                                console.warn(contentView.sensors)
//                            }
                        }

                        Button {
                            text: qsTr("Назад")

                            onClicked: {
                                if (accelCheck.checked)
                                {
                                    generator.addSource(accelerometer.type)
                                    contentView.sensors.push(accelerometer.type)
                                }
                                if (compassCheck.checked)
                                {
                                    generator.addSource(compass.type)
                                    contentView.sensors.push(compass.type)
                                }
                                if (gyroCheck.checked)
                                {
                                    generator.addSource(gyroscope.type)
                                    contentView.sensors.push(gyroscope.type)
                                }
                                if (lightCheck.checked)
                                {
                                    generator.addSource(lightSensor.type)
                                    contentView.sensors.push(lightSensor.type)
                                }
                                contentView.pop()
                            }
                        }
                    }
                }
            }

            Component {
                id: resultPage
                Item {

                    ColumnLayout {
                        anchors {
                            fill: parent
                            margins: 24
                        }
                        spacing: 4

                        property string generatedNumbers: "---"
                        property var generatedNumbersList: []

                        Component.onCompleted: {
                            updateNumbers()
                        }

                        function updateNumbers() {
                            console.log("Generate result")
                            generatedNumbersList = generator.generateRange(contentView.randomNumbersCount)
                            generatedNumbers = generatedNumbersList.join("\n");
                        }

                        Text {
                            text: qsTr("Результат генерации")
                            font.pixelSize: 24
                        }

                        TextEdit {
                            text: parent.generatedNumbers
                            width: parent.width
                            readOnly: true
                            font.bold: true
                            selectByMouse: true
                        }

                        Button {
                            text: qsTr("Обновить")
                            onClicked: parent.updateNumbers()
                        }
                        Button {
                            text: qsTr("Назад")
                            onClicked: contentView.pop()
                        }
                    }
                }
            }
        }

        Accelerometer { id: accelerometer }
        Compass { id: compass }
        Gyroscope { id: gyroscope }
        LightSensor { id: lightSensor }
    }
}
