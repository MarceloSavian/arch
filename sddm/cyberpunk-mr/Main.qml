import QtQuick 2.0
import SddmComponents 2.0
import QtGraphicalEffects 1.0

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: config.BgColor

    TextConstants { id: textConstants }

    // ---------- Users (SDDM's userModel) ----------
    // A Repeater (not a ListView) so every delegate exists and itemAt() works.
    property int userIdx: 0
    Repeater {
        id: users
        model: userModel
        delegate: Item {
            visible: false
            property string uName: model.name
            property string uReal: model.realName
            property string uIcon: model.icon
        }
    }
    readonly property var cur: users.count > 0 ? users.itemAt(Math.min(userIdx, users.count - 1)) : null
    readonly property string currentUser: cur ? cur.uName : config.DefaultUser
    readonly property string currentLabel: cur ? (cur.uReal !== "" ? cur.uReal : cur.uName) : config.DefaultUser

    function pickInitialUser() {
        // last user to log in > DefaultUser > first user
        var want = (userModel.lastUser && userModel.lastUser !== "") ? userModel.lastUser : config.DefaultUser;
        for (var i = 0; i < users.count; i++)
            if (users.itemAt(i).uName === want) { userIdx = i; return; }
        userIdx = 0;
    }
    function cycleUser(step) {
        if (users.count < 2) return;
        userIdx = (userIdx + step + users.count) % users.count;
        passwordField.text = "";
        errorText.text = "";
        passwordField.forceActiveFocus();
    }

    // ---------- Background ----------
    Image {
        id: bg
        anchors.fill: parent
        source: config.Background
        fillMode: Image.PreserveAspectCrop
        smooth: true
        asynchronous: true
        cache: true
        visible: false   // drawn through the blur below
    }

    // Blur like hyprlock's background (blur_passes=2, blur_size=6)
    FastBlur {
        anchors.fill: bg
        source: bg
        radius: parseInt(config.BlurRadius)
        visible: bg.status === Image.Ready
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: parseFloat(config.DimOpacity)
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
                    // configured photo for DefaultUser; other users get their own face icon
                    source: (root.cur && root.cur.uName !== config.DefaultUser && root.cur.uIcon !== "")
                            ? root.cur.uIcon : config.Avatar
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    asynchronous: true
                    cache: true
                }
            }

            Row {
                id: userRow
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 14

                Text {
                    text: "‹"
                    visible: users.count > 1
                    color: arrowL.containsMouse ? config.AccentColor : config.MutedTextColor
                    font.family: config.FontFamily
                    font.pixelSize: 26
                    anchors.verticalCenter: parent.verticalCenter
                    MouseArea { id: arrowL; anchors.fill: parent; anchors.margins: -8; hoverEnabled: true; onClicked: root.cycleUser(-1) }
                }
                Text {
                    id: usernameText
                    text: root.currentLabel
                    color: config.TextColor
                    font.family: config.FontFamily
                    font.pixelSize: 22
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: "›"
                    visible: users.count > 1
                    color: arrowR.containsMouse ? config.AccentColor : config.MutedTextColor
                    font.family: config.FontFamily
                    font.pixelSize: 26
                    anchors.verticalCenter: parent.verticalCenter
                    MouseArea { id: arrowR; anchors.fill: parent; anchors.margins: -8; hoverEnabled: true; onClicked: root.cycleUser(1) }
                }
            }

            Text {
                text: users.count > 1 ? "Enter password  ·  ↑ ↓ to switch user" : "Enter password to unlock"
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

                Keys.onUpPressed: root.cycleUser(-1)
                Keys.onDownPressed: root.cycleUser(1)
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
        sddm.login(root.currentUser, passwordField.text, sessionBox.index);
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

    Component.onCompleted: {
        pickInitialUser();
        passwordField.forceActiveFocus();
    }
}
