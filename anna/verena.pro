# Add more folders to ship with the application, here
folder_01.source = qml/verena
folder_01.target = qml
DEPLOYMENTFOLDERS = folder_01

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

symbian:TARGET.UID3 = 0xE0629D0E

# Smart Installer package's UID
# This UID is from the protected range and therefore the package will
# fail to install if self-signed. By default qmake uses the unprotected
# range value if unprotected UID is defined for the application and
# 0x2002CCCF value if protected UID is given to the application
#symbian:DEPLOYMENT.installer_header = 0x2002CCCF

# Allow network access on Symbian
symbian {
    TARGET.CAPABILITY += NetworkServices

    vendorinfo += "%{\"Karin\"}" ":\"Karin\""
}

# If your application uses the Qt Mobility libraries, uncomment the following
# lines and add the respective components to the MOBILITY variable.
# CONFIG += mobility
# MOBILITY +=

# Speed up launching on MeeGo/Harmattan when using applauncherd daemon
TEMPLATE = app
TARGET = verena
DEPENDPATH += . qmlapplicationviewer src
INCLUDEPATH += . src
QT += declarative network sql webkit
DEFINES += VHARMATTAN _S_TEST #VDEBUG
CONFIG += mobility
MOBILITY += multimedia systeminfo

# Add dependency to Symbian components
# CONFIG += qt-components

# The .cpp file which was generated for your project. Feel free to hack it.
HEADERS += src/vdeveloper.h\
src/vnetworkmanager.h\
src/vvideoplayer.h\
src/vdownloadmanager.h\
src/vdownloadtask.h\
src/vverenadatabase.h\
src/vstd.h\
src/vdeclarativewebview.h\
src/vut.h
SOURCES += main.cpp\
src/vnetworkmanager.cpp\
src/vvideoplayer.cpp\
src/vdownloadmanager.cpp\
src/vdownloadtask.cpp\
src/vutility.cpp\
src/vverenadatabase.cpp\
src/vdeclarativewebview.cpp\
src/vdeveloper.cpp

#splash.files = res/verena_splash.png
#splash.path = res
folder_js.source = qml/js
folder_js.target = qml
folder_img.source = qml/image
folder_img.target = qml
DEPLOYMENTFOLDERS += folder_js folder_img
#INSTALLS += splash
#CONFIG += debug_and_release

    CONFIG += qt-components
    CONFIG += localize_deployment

#    TARGET.UID3 = 0x2006622C
    TARGET.CAPABILITY *= \
        NetworkServices \
        ReadUserData \
        WriteUserData \
        SwEvent\
LocalServices\
UserEnvironment

    TARGET.EPOCHEAPSIZE = 0x40000 0x4000000

simulator{
DEFINES += _SIMULATOR VDEBUG
}
symbian{
DEFINES += _SYMBIAN
    LIBS *= -lapparc -lws32 -lapgrfx
}

RESOURCES += verena.qrc
TRANSLATIONS += i18n/verena.zh_CN.ts

    vendorinfo = "%{\"Karin\"}" ":\"Karin\""
    my_deployment.pkg_prerules += vendorinfo
    DEPLOYMENT += my_deployment
VERSION = 0.7.91
    # Symbian have a different syntax
    #DEFINES -= VER=\\\"$$VERSION\\\"
    DEFINES += VER=\"$$VERSION\"
#translation.files = i18n/verena.zh_CN.qm #i18n/verena.zh_CN.ts
#translation.path = i18n
#INSTALLS += translation
# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

OTHER_FILES += \
    qtc_packaging/debian_harmattan/rules \
    qtc_packaging/debian_harmattan/README \
    qtc_packaging/debian_harmattan/manifest.aegis \
    qtc_packaging/debian_harmattan/copyright \
    qtc_packaging/debian_harmattan/control \
    qtc_packaging/debian_harmattan/compat \
    qtc_packaging/debian_harmattan/changelog

contains(MEEGO_EDITION,harmattan) {
    icon.files = verena.png
    icon.path = /usr/share/icons/hicolor/80x80/apps
    INSTALLS += icon
}
