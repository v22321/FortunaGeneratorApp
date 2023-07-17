#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QAccelerometer>
#include <QPluginLoader>
#include <QThread>

#if defined (QTFORTUNAGENERATOR_PLUGIN)
#include "generatorinterface.h"
#include "globaldefs.h"
#elif defined (QTFORTUANGENERATOR_SOURCES)
#include "generatormanager.h"
#endif

//#include "entropy/sources/qsensors/accelerometerentropysource.h"
//#include "entropy/sources/freememoryentropysource.h"

/// Fortuna generator demonstration
int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    qDebug() << "\n === \n Fortuna generator start \n === \n";

    QSharedPointer<GeneratorInterface> generator;

#if defined (QTFORTUNAGENERATOR_PLUGIN)
    QString pluginPath = GlobalConstants::PLUGIN_NAME;
    QPluginLoader pluginLoader(pluginPath);
    generator = QSharedPointer<GeneratorInterface>(qobject_cast<GeneratorInterface*>(pluginLoader.instance()));
    if (!generator)
    {
        // Произошла ошибка при загрузке плагина
        qDebug() << "Failed to load plugin:" << pluginLoader.errorString();
        return 0;
    }
#elif defined (QTFORTUANGENERATOR_SOURCES) // QTFORTUNAGENERATOR_PLUGIN
    generator = QSharedPointer<GeneratorManager>(new GeneratorManager());
#endif

    generator->registerFortunaGenerator();
    /// Add sources
//    QSharedPointer<QAccelerometer> accelerometer(new QAccelerometer);
//    // QSharedPointer<AccelerometerEntropySource> accelerometerSm\ource(new AccelerometerEntropySource());
//    // auto source = genManager->createTestSource();
//    // genManager->addSource(source);
//    generator->addSource(accelerometer);
//    QThread::sleep(10);

//    if (generator->prepareEntropy())
//    {
//        qDebug() << "Generator ready!";
//        qDebug() << "Generate...";
//        for (quint32 i = 1; i <= 10; ++i)
//        {
//            QVector<quint32> _result(i);
//            QThread::msleep(100);
//            generator->fillRange(_result);
//            qDebug() << _result;
//        }
//    }
//    else
//        qWarning() << "Generator not ready!";


    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    engine.load(url);


    return app.exec();
}
