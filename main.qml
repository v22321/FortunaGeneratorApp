import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

import FortunaGenerator 1.0
import QtSensors 5.15
import QtCharts 2.15

Window {
    id: win
    visible: true

    Fortuna {
        id: generator
        sources: [
            AccelerometerEntropySource {},
            CompassEntropySource {}
            // GyroscopeEntropySource {},
            // LightEntropySource {}
        ]
    }

    Rectangle {
        id: header
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: 80
        color: "lightblue"

        Label {
            anchors {
                margins: 16
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            text: qsTr("Fortuna генератор")
            font.pixelSize: 24
        }
    }

    ProgressBar {
        id: progress
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
        }
        width: parent.width
        height: 10

        contentItem: Rectangle {
            anchors {
                left: progress.left
                bottom: progress.bottom
            }
            height: progress.height
            width: progress.width * progress.value

            color: progress.value === 0.0 ? "white" : "lightblue"
            radius: 2
        }

        property real step: 0.01

        function changeValue() {
            value += step
            if (value > 0.99 || value < 0.01) {
                step *= -1
            }
        }
        function stop() {
            value = 0
            progressTimer.running = false
        }

        Timer {
            id: progressTimer
            interval: 10
            repeat: true
            running: true
            onTriggered: progress.changeValue()
        }
    }

    Item {
        id: content
        enabled: false
        anchors {
            top: progress.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        StackView {
            id: contentView

            anchors.fill: parent
            initialItem: mainPage

            property alias sensors: generator.sources
            property string sensorsStr: generator.sourcesStr
            readonly property string emptySensors: qsTr("Нет")

            property int randomNumbersCount: 10
            property var generatedNumbersList: []

            Component.onCompleted: {
                // Add sources
                generator.sources.push(gyroscopeSource)
                generator.sources.push(lightSensorSource)

                if (generator.prepareEntropy()) {
                    console.log("Generator ready")
                    progress.stop()
                    content.enabled = true
                }
                else
                    console.warn("Generator not ready")
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
                                    contentView.push(sensorsComponent)
                                }
                            }
                        }

                        ColumnLayout {
                            id: selectedSensors
                            Layout.fillWidth: true
                            Layout.preferredHeight: 60
                            spacing: 4

                            Label {
                                text: qsTr("Выбранные сенсоры") + ": "
                                font.pixelSize: 16
                            }
                            Label {
                                text: contentView.sensorsStr
                                font.pixelSize: 14
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: "lightblue"
                        }

                        Rectangle {
                            id: generateNumber
                            Layout.fillWidth: true
                            Layout.preferredHeight: 100
                            enabled: sensorsStr !== emptySensors
                            border {
                                color: "gray"
                                width: 1
                            }
                            radius: 2

                            property string currentNumber: "-"

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

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: "lightblue"
                        }

                        Item {
                            id: selectRandomNumberCount
                            Layout.fillWidth: true
                            Layout.preferredHeight: 60
                            enabled: sensorsStr !== emptySensors

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
                                    elide: Text.ElideRight
                                    font.pixelSize: 14
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
                            enabled: sensorsStr !== emptySensors
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
                                    console.log("Generate N digits")
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
                id: sensorsComponent
                Item {
                    id: sensorsPage

                    function sensorsSelected() {
                        if (accelCheck.checked)
                        {
                            generator.addSource(accelerometer.type)
                        }
                        if (compassCheck.checked)
                        {
                            generator.addSource(compass.type)
                        }
                        if (gyroCheck.checked)
                        {
                            generator.addSource(gyroscope.type)
                        }
                        if (lightCheck.checked)
                        {
                            generator.addSource(lightSensor.type)
                        }

                        contentView.pop()
                    }

                    Accelerometer { id: accelerometer }
                    Compass { id: compass }
                    Gyroscope { id: gyroscope }
                    LightSensor { id: lightSensor }

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
                        }
                        CheckBox {
                            id: lightCheck
                            text: "Light sensor"
                            checked: true
                        }

                        Button {
                            text: qsTr("Назад")

                            onClicked: sensorsPage.sensorsSelected()
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
//                        property var generatedNumbersList: []

                        Component.onCompleted: {
                            updateNumbers()
                        }

                        function updateNumbers() {
                            console.log("Generate result")
                            contentView.generatedNumbersList = generator.generateRange(contentView.randomNumbersCount)
                            generatedNumbers = contentView.generatedNumbersList.join("\n");
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
                            text: qsTr("График")
                            onClicked: contentView.push(resultChart)
                        }
                        Button {
                            text: qsTr("Назад")
                            onClicked: contentView.pop()
                        }
                    }
                }
            }
            Component {
                id: resultChart
                Item {
                    ColumnLayout {
                        id: testLayout
                        anchors {
                            fill: parent
                            margins: 24
                        }
                        spacing: 4

                        property string generatedNumbers: "---"
                        property var generatedNumbersList: []

                        Component.onCompleted: {
                            console.warn("Start generate")
                            bar.values = generator.generateRange(100)
                            diabChartBig.update()
                            console.warn(bar.values)
                        }

                        function updateNumbers() {
                            console.log("Generate result”)
                            generatedNumbersList = generator.generateRange(contentView.randomNumbersCount)
                            generatedNumbers = generatedNumbersList.join("\n");
                        }

                        Text {
                            text: qsTr("Распределение случайных чисел")
                            font.pixelSize: 24
                        }

                        property var cats: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10" ]
                        property var vals: [1, 2, 3, 4, 5, 6, 7, 8, 9, 5000000000 ]

                        ChartView {
                            id: diabChartBig
                            title: "Overview"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 400
                            antialiasing: true
                            plotAreaColor: "gray"

                            StackedBarSeries {
                                id: mySeries
                                axisX: BarCategoryAxis { id: axis; categories: testLayout.cats }

                                BarSet { id: bar; label: "Random"; values: testLayout.vals }
                            }
                        }


                        Button {
                            text: qsTr("Назад")
                            // onClicked: contentView.pop()
                            onClicked: {
                                var cats = []
                                console.warn("Start generate")
                                bar.values = generator.generateRange(100)
                                diabChartBig.update()
                                console.warn(bar.values)

                            }
                        }
                    }
                }
            }
        }

//        AccelerometerEntropySource { id: accelerometerSource }
//        CompassEntropySource { id: compassSource }
        GyroscopeEntropySource { id: gyroscopeSource }
        LightEntropySource { id: lightSensorSource }
    }
}
