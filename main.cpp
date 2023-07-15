#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QAccelerometer>
#include <QPluginLoader>
#include <QThread>

#include "generatorinterface.h"
#include "globaldefs.h"
//#include "entropy/sources/qsensors/accelerometerentropysource.h"
//#include "entropy/sources/freememoryentropysource.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
//    const QUrl url(QStringLiteral("qrc:/main.qml"));
//    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
//        &app, [url](QObject *obj, const QUrl &objUrl) {
//            if (!obj && url == objUrl)
//                QCoreApplication::exit(-1);
//        }, Qt::QueuedConnection);
//    engine.load(url);

    qDebug() << "\n === \n Fortuna generator start \n === \n";

    QString pluginPath = GlobalConstants::PLUGIN_NAME;
    QPluginLoader pluginLoader(pluginPath);
    auto pobj = qobject_cast<GeneratorInterface*>(pluginLoader.instance());
    if(!pobj)
    {
        // Произошла ошибка при загрузке плагина
        qDebug() << "Failed to load plugin:" << pluginLoader.errorString();
    }
    else
    {
        qInfo() << "OK!!!!!!!!";
        qInfo() << " VERY OK";
        pobj->registerMeta();
//        qmlRegisterType<GeneratorInterface>("CustomFortunaGenerator", 1, 0, "Fortuna");
        //    genManager.seed({1, 2, 3, 4, 5});

        //    /// Add sources
        QSharedPointer<QAccelerometer> accelerometer(new QAccelerometer);
        //                QSharedPointer<AccelerometerEntropySource> accelerometerSm\ource(new AccelerometerEntropySource());
        //            auto source = genManager->createTestSource();
        //            genManager->addSource(freeMemorySource);
        pobj->addSource(accelerometer);

        //        QThread::sleep(4);
        //                if (!genManager.isPoolsReady())
        //                {
        //                    qWarning() << "Failed to collect entropy";
        //                    /// TODO
        //                    // genManager.deinit();
        //                }
        //                else
        //                {
        if (pobj->prepareEntropy())
        {
            qDebug() << "Generate...";
            for (quint32 i = 1; i <= 10; ++i)
            {
                QVector<quint32> _result(i);
                QThread::msleep(100);
                pobj->fillRange(_result);
                qDebug() << _result;
            }
        }
        else
            qWarning() << "Generator not ready!";
    }


    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    engine.load(url);

    /// Fortuna generator demonstration
//    GeneratorManager genManager(100);
//    genManager.seed({1, 2, 3, 4, 5});

    /// Add sources
//    QSharedPointer<FreeMemoryEntropySource> freeMemorySource(new FreeMemoryEntropySource());
//    genManager.addSource(freeMemorySource);
//    QSharedPointer<AccelerometerEntropySource> accelerometerSource(new AccelerometerEntropySource());
//    genManager.addSource(accelerometerSource);

//    QThread::sleep(2);
//    if (!genManager.prepareEntropy())
//    {
//        qWarning() << "Failed to collect entropy";
//        /// TODO
//        // genManager.deinit();
//    }
//    else
//    {
//        qDebug() << "Generate...";
//        for (quint32 i = 1; i <= 10; ++i)
//        {
//            QVector<quint32> _result(i);
//            QThread::msleep(100);
//            genManager.fillRange(_result);
//            qDebug() << _result;
//        }
//    }

    return app.exec();
}
