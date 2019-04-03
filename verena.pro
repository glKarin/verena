# Add more folders to ship with the application, here

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
symbian:TARGET.CAPABILITY += NetworkServices

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
DEFINES += VHARMATTAN
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
src/vdeveloper.cpp \
src/vstd.cpp

DEFINES += _KARIN_MM_EXTENSIONS

contains(DEFINES, _KARIN_MM_EXTENSIONS) {
INCLUDEPATH += qtm
HEADERS += \
qtm/qdeclarativemediabase_p.h \
qtm/qdeclarativevideo_p.h \
qtm/qdeclarativemediametadata_p.h \
qtm/qpaintervideosurface_p.h

SOURCES += \
qtm/qdeclarativemediabase.cpp \
qtm/qdeclarativevideo.cpp \
qtm/qpaintervideosurface.cpp
}

simulator{
DEFINES += VDEBUG
DEFINES += VDEBUG _S_TEST

TARGET.CAPABILITY += NetworkServices
vendorinfo = "%{\"Karin\"}" ":\"Karin\""
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

LIBS *= -lapparc -lws32 -lapgrfx
RESOURCES += verena.qrc

my_deployment.pkg_prerules += vendorinfo
DEPLOYMENT += my_deployment
VERSION = 0.9.051
# Symbian have a different syntax
#DEFINES -= VER=\\\"$$VERSION\\\"
DEFINES += VER=\"$$VERSION\"

folder_01.source = qml/verena_symbian
folder_01.target = qml
DEPLOYMENTFOLDERS = folder_01
}

symbian {
DEFINES += _SYMBIAN _S_TEST

TARGET.CAPABILITY += NetworkServices
vendorinfo = "%{\"Karin\"}" ":\"Karin\""
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

LIBS *= -lapparc -lws32 -lapgrfx
RESOURCES += verena.qrc

my_deployment.pkg_prerules += vendorinfo
DEPLOYMENT += my_deployment
VERSION = 0.9.05
# Symbian have a different syntax
#DEFINES -= VER=\\\"$$VERSION\\\"
DEFINES += VER=\"$$VERSION\"

folder_01.source = qml/verena_symbian
folder_01.target = qml
DEPLOYMENTFOLDERS = folder_01
}

contains(MEEGO_EDITION,harmattan){
# DEFINES += VDEBUG
DEFINES += VHAS_MAEMO_MEEGOTOUCH_INTERFACES_DEV _HARMATTAN
OBJECTS_DIR = .obj
MOC_DIR = .moc

CONFIG += qdeclarative-boostable
CONFIG += videosuiteinterface-maemo-meegotouch  #video suite
CONFIG += meegotouch
splash.files = res/verena_splash.png
splash.path = /opt/verena/res
INSTALLS += splash
#CONFIG += debug_and_release

translation.files = i18n/verena.zh_CN.ts i18n/verena.zh_CN.qm
translation.path = /opt/verena/i18n
INSTALLS += translation

OTHER_FILES += \
qtc_packaging/debian_harmattan/rules \
qtc_packaging/debian_harmattan/README \
qtc_packaging/debian_harmattan/manifest.aegis \
qtc_packaging/debian_harmattan/copyright \
qtc_packaging/debian_harmattan/control \
qtc_packaging/debian_harmattan/compat \
qtc_packaging/debian_harmattan/changelog

folder_01.source = qml/verena
folder_01.target = qml
DEPLOYMENTFOLDERS = folder_01
}

folder_js.source = qml/js
folder_js.target = qml
folder_img.source = qml/image
folder_img.target = qml
DEPLOYMENTFOLDERS += folder_js folder_img

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

contains(MEEGO_EDITION,harmattan){
icon.files = verena.png
icon.path = /usr/share/icons/hicolor/80x80/apps
INSTALLS += icon
}

