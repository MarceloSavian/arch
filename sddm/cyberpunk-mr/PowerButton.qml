import QtQuick 2.0

Rectangle {
    id: btn
    property string glyph: ""
    property bool enabled: true
    signal triggered()

    width: 40
    height: 40
    radius: 20
    color: hov.containsMouse ? config.SurfaceHoverColor : config.SurfaceColor
    border.color: hov.containsMouse ? config.AccentColor : "transparent"
    border.width: 1
    opacity: enabled ? 1.0 : 0.35

    Behavior on color { ColorAnimation { duration: 120 } }

    Text {
        anchors.centerIn: parent
        text: btn.glyph
        color: config.AccentColor
        font.family: config.FontFamily
        font.pixelSize: 18
    }

    MouseArea {
        id: hov
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: btn.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: if (btn.enabled) btn.triggered()
    }
}
