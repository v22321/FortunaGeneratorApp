QT += quick

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        main.cpp

RESOURCES += qml.qrc

#QTFORTUNAGEN_CONFIG += sources
QTFORTUNAGEN_CONFIG += plugin

contains(QTFORTUNAGEN_CONFIG, plugin) {
    include(Fortuna/project/FortunaGeneratorPlugin.pri)
    DEFINES += QTFORTUNAGENERATOR_PLUGIN
}

contains(QTFORTUNAGEN_CONFIG, sources) {
    include(Fortuna/project/FortunaGenerator.pri)
    DEFINES += QTFORTUANGENERATOR_SOURCES
}

# Custom defines
!android:!ios: {
CONFIG += DESKTOP_SUPPORT
DEFINES += DESKTOP_SUPPORT
}
else: {
CONFIG += MOBILE_SUPPORT
DEFINES += MOBILE_SUPPORT
}

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
