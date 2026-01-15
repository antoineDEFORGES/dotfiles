import QtQuick 2.15
import QtQuick.Controls 2.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080

    // Colors from wallust (defaults, overridden by colors.conf)
    property color backgroundColor: "#171717"
    property color foregroundColor: "#F4C1BD"
    property color accentColor: "#9F1D57"
    property color dimColor: "#3E3E3E"

    // Load colors from file
    Component.onCompleted: {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "colors.conf", false);
        xhr.send();
        if (xhr.status === 200) {
            var lines = xhr.responseText.split("\n");
            for (var i = 0; i < lines.length; i++) {
                var line = lines[i].trim();
                if (line.startsWith("background=")) backgroundColor = line.split("=")[1];
                if (line.startsWith("foreground=")) foregroundColor = line.split("=")[1];
                if (line.startsWith("accent=")) accentColor = line.split("=")[1];
                if (line.startsWith("dim=")) dimColor = line.split("=")[1];
            }
        }
    }

    // Wallpaper background
    Image {
        id: background
        anchors.fill: parent
        source: "wallpaper.jpeg"
        fillMode: Image.PreserveAspectCrop
    }

    // Dark overlay
    Rectangle {
        anchors.fill: parent
        color: backgroundColor
        opacity: 0.4
    }

    // Clock
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.15
        spacing: 0

        Text {
            id: timeText
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: 72
            font.weight: Font.Light
            color: foregroundColor
            text: Qt.formatTime(new Date(), "hh:mm")
        }

        Text {
            id: dateText
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: 16
            font.weight: Font.Light
            color: foregroundColor
            opacity: 0.7
            text: Qt.formatDate(new Date(), "dddd, MMMM d")
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            timeText.text = Qt.formatTime(new Date(), "hh:mm")
            dateText.text = Qt.formatDate(new Date(), "dddd, MMMM d")
        }
    }

    // Login form
    Column {
        id: loginForm
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 60
        spacing: 16
        width: 280

        // Username field
        Rectangle {
            width: parent.width
            height: 44
            color: backgroundColor
            opacity: 0.85
            radius: 6

            TextInput {
                id: usernameField
                anchors.fill: parent
                anchors.margins: 12
                font.pointSize: 13
                color: foregroundColor
                clip: true
                focus: true

                Text {
                    anchors.fill: parent
                    text: "username"
                    font.pointSize: 13
                    color: dimColor
                    visible: parent.text === ""
                }

                onAccepted: passwordField.focus = true
            }
        }

        // Password field
        Rectangle {
            width: parent.width
            height: 44
            color: backgroundColor
            opacity: 0.85
            radius: 6

            TextInput {
                id: passwordField
                anchors.fill: parent
                anchors.margins: 12
                font.pointSize: 13
                color: foregroundColor
                echoMode: TextInput.Password
                clip: true

                Text {
                    anchors.fill: parent
                    text: "password"
                    font.pointSize: 13
                    color: dimColor
                    visible: parent.text === ""
                }

                onAccepted: sddm.login(usernameField.text, passwordField.text, sessionSelect.currentIndex)
            }
        }

        // Login button
        Rectangle {
            width: parent.width
            height: 44
            color: accentColor
            radius: 6

            Text {
                anchors.centerIn: parent
                text: "Login"
                font.pointSize: 13
                font.weight: Font.Medium
                color: foregroundColor
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.login(usernameField.text, passwordField.text, sessionSelect.currentIndex)
            }
        }

        // Error message
        Text {
            id: errorMessage
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 11
            color: "#E14D43"
            text: ""
            visible: text !== ""
        }
    }

    // Session selector
    ComboBox {
        id: sessionSelect
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 24
        width: 180
        height: 36
        model: sessionModel
        textRole: "name"
        currentIndex: sessionModel.lastIndex

        background: Rectangle {
            color: backgroundColor
            opacity: 0.7
            radius: 4
        }

        contentItem: Text {
            text: sessionSelect.displayText
            font.pointSize: 11
            color: foregroundColor
            verticalAlignment: Text.AlignVCenter
            leftPadding: 12
        }

        popup: Popup {
            y: -implicitHeight - 4
            width: sessionSelect.width
            implicitHeight: contentItem.implicitHeight
            padding: 1

            contentItem: ListView {
                clip: true
                implicitHeight: contentHeight
                model: sessionSelect.popup.visible ? sessionSelect.delegateModel : null

                ScrollIndicator.vertical: ScrollIndicator {}
            }

            background: Rectangle {
                color: backgroundColor
                radius: 4
            }
        }

        delegate: ItemDelegate {
            width: sessionSelect.width
            height: 32

            contentItem: Text {
                text: model.name
                font.pointSize: 11
                color: foregroundColor
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                color: highlighted ? dimColor : "transparent"
            }
        }
    }

    // Power buttons
    Row {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 24
        spacing: 16

        // Reboot
        Rectangle {
            width: 36
            height: 36
            color: "transparent"
            radius: 4

            Text {
                anchors.centerIn: parent
                text: "\u21BB"
                font.pointSize: 18
                color: foregroundColor
                opacity: parent.parent.children[0] === parent ? 0.7 : 0.5
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onEntered: parent.color = dimColor
                onExited: parent.color = "transparent"
                onClicked: sddm.reboot()
            }
        }

        // Shutdown
        Rectangle {
            width: 36
            height: 36
            color: "transparent"
            radius: 4

            Text {
                anchors.centerIn: parent
                text: "\u23FB"
                font.pointSize: 18
                color: foregroundColor
                opacity: 0.7
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onEntered: parent.color = dimColor
                onExited: parent.color = "transparent"
                onClicked: sddm.powerOff()
            }
        }
    }

    // Handle login errors
    Connections {
        target: sddm
        function onLoginFailed() {
            errorMessage.text = "Login failed"
            passwordField.text = ""
            passwordField.focus = true
        }
    }
}
