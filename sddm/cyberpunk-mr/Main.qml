import QtQuick 2.0
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: config.BgColor

    TextConstants { id: textConstants }

    // ---------- Background ----------
    Image {
        id: bg
        anchors.fill: parent
        source: config.Background
        fillMode: Image.PreserveAspectCrop
        smooth: true
        asynchronous: true
        cache: true
        visible: status === Image.Ready
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: parseFloat(config.DimOpacity)
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#80000000" }
            GradientStop { position: 0.45; color: "transparent" }
            GradientStop { position: 1.0; color: "#80000000" }
        }
    }

    // ---------- Top-right clock ----------
    Column {
        id: clockBox
        visible: config.ShowClock === "true"
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 40
        spacing: 4

        Text {
            id: clockTime
            anchors.right: parent.right
            color: config.TextColor
            font.family: config.FontFamily
            font.pixelSize: 56
            font.bold: true
        }
        Text {
            id: clockDate
            anchors.right: parent.right
            color: config.TextColor
            opacity: 0.7
            font.family: config.FontFamily
            font.pixelSize: 16
        }

        function refresh() {
            var fmt = config.ClockFormat24h === "true" ? "HH:mm" : "h:mm AP";
            clockTime.text = Qt.formatDateTime(new Date(), fmt);
            clockDate.text = Qt.formatDateTime(new Date(), "dddd, MMMM d");
        }
        Component.onCompleted: refresh()
        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clockBox.refresh()
        }
    }

    // ---------- Centered login card ----------
    Rectangle {
        id: card
        anchors.centerIn: parent
        width: 380
        height: cardCol.height + 48
        radius: 18
        color: Qt.rgba(0.10, 0.11, 0.15, 0.78)
        border.color: config.BorderColor
        border.width: 1

        Column {
            id: cardCol
            anchors.centerIn: parent
            width: parent.width - 48
            spacing: 18

            Item {
                id: avatarSlot
                visible: config.ShowAvatar === "true"
                width: parseInt(config.AvatarSize)
                height: width
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "transparent"
                    border.color: config.AccentColor
                    border.width: 2
                }

                Image {
                    anchors.fill: parent
                    anchors.margins: 4
                    source: config.Avatar
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    asynchronous: true
                    cache: true
                }
            }

            Text {
                id: usernameText
                text: {
                    if (userModel.lastUser && userModel.lastUser !== "")
                        return userModel.lastUser;
                    return config.DefaultUser;
                }
                color: config.TextColor
                font.family: config.FontFamily
                font.pixelSize: 22
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "Enter password to unlock"
                color: config.MutedTextColor
                font.family: config.FontFamily
                font.pixelSize: 12
                anchors.horizontalCenter: parent.horizontalCenter
            }

            PasswordBox {
                id: passwordField
                width: parent.width
                height: 44
                radius: 12
                color: config.SurfaceColor
                borderColor: "#383050"
                focusColor: config.AccentColor
                hoverColor: config.AccentColor
                textColor: config.TextColor
                font.family: config.FontFamily
                font.pixelSize: parseInt(config.FontSize)
                tooltipBG: config.SurfaceColor
                tooltipFG: config.TextColor
                tooltipText: textConstants.capslockWarning
                focus: true

                Keys.onReturnPressed: doLogin()
                Keys.onEnterPressed: doLogin()
            }

            Text {
                id: errorText
                text: ""
                color: config.ErrorColor
                font.family: config.FontFamily
                font.pixelSize: 12
                anchors.horizontalCenter: parent.horizontalCenter
                visible: text !== ""
            }
        }
    }

    // ---------- Bottom-right power buttons ----------
    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 40
        spacing: 12

        PowerButton { glyph: "⏻"; enabled: sddm.canPowerOff; onTriggered: sddm.powerOff() }
        PowerButton { glyph: "↻"; enabled: sddm.canReboot;   onTriggered: sddm.reboot() }
        PowerButton { glyph: "☾"; enabled: sddm.canSuspend;  onTriggered: sddm.suspend() }
    }

    // ---------- Bottom-left session selector ----------
    Row {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 40
        spacing: 8

        Text {
            text: "Session:"
            color: config.MutedTextColor
            font.family: config.FontFamily
            font.pixelSize: 12
            anchors.verticalCenter: parent.verticalCenter
        }

        ComboBox {
            id: sessionBox
            width: 180
            height: 28
            model: sessionModel
            index: sessionModel.lastIndex
            color: config.SurfaceColor
            borderColor: "#383050"
            focusColor: config.AccentColor
            hoverColor: config.AccentColor
            textColor: config.TextColor
            font.family: config.FontFamily
            font.pixelSize: 12
            arrowIcon: ""
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // ---------- Login plumbing ----------
    function doLogin() {
        errorText.text = "";
        sddm.login(usernameText.text, passwordField.text, sessionBox.index);
    }

    Connections {
        target: sddm
        onLoginFailed: {
            errorText.text = "Login failed";
            passwordField.text = "";
            passwordField.focus = true;
        }
        onLoginSucceeded: {}
    }

    Component.onCompleted: passwordField.forceActiveFocus()
}
