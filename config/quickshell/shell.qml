import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    // ─────────────────────────────────────────────
    // Theme
    // ─────────────────────────────────────────────


property color colBg: "#101b27"
property color colFg: "#c3c6c9"
property color colMuted: "#5f6975"
property color colCyan: "#91807E"
property color colBlue: "#A4595B"
property color colYellow: "#BD3B3C"

property var walColors: ({})

FileView {
    id: walColorsFile

    path: Quickshell.env("HOME") + "/.cache/wal/colors.json"

    watchChanges: true

    onLoaded: {
        try {
            const parsed = JSON.parse(text())

            root.walColors = parsed

            root.colBg = parsed.special.background
            root.colFg = parsed.special.foreground
            root.colMuted = parsed.colors.color8
            root.colCyan = parsed.colors.color6
            root.colBlue = parsed.colors.color4
            root.colYellow = parsed.colors.color3

            console.log("Pywal colors loaded:")
            console.log("Background:", root.colBg)
            console.log("Foreground:", root.colFg)
            console.log("Muted:", root.colMuted)
            console.log("Cyan:", root.colCyan)
            console.log("Blue:", root.colBlue)
            console.log("Yellow:", root.colYellow)

        } catch (error) {
            console.log("Failed to load Pywal colors:", error)
        }
    }
}   

property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 14

    // ─────────────────────────────────────────────
    // System data
    // ─────────────────────────────────────────────

    property string wifiName: "Disconnected"
    property string ipAddress: "Unknown"
    property int volumePercent: 0
    property int batteryPercent: 0
    property bool batteryCharging: false
    property bool hasBattery: false
    property string focusedWindowTitle: "Desktop"

    // Display state
    property bool showIpAddress: false
    property bool showFullDate: false

    anchors.top: true
    anchors.left: true
    anchors.right: true

    implicitHeight: 30
    color: root.colBg

    // ─────────────────────────────────────────────
    // Wi-Fi Name
    // ─────────────────────────────────────────────

    Process {
        id: wifiProcess

        command: [
            "sh",
            "-c",
            "nmcli -t -f active,ssid dev wifi | awk -F: '$1==\"yes\" {print $2; exit}'"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.wifiName = text.trim() || "Disconnected"
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            wifiProcess.running = true
        }
    }

    // ─────────────────────────────────────────────
    // IP Address
    // ─────────────────────────────────────────────

    Process {
        id: ipProcess

        command: [
            "sh",
            "-c",
            "ip -4 route get 1.1.1.1 | awk '{for(i=1;i<=NF;i++) if ($i==\"src\") print $(i+1)}'"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.ipAddress = text.trim() || "Unknown"
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            ipProcess.running = true
        }
    }

    // ─────────────────────────────────────────────
    // Network Manager TUI
    // ─────────────────────────────────────────────

    Process {
        id: nmtuiProcess

        command: [
            "kitty",
            "--class",
            "nmtui",
            "-e",
            "nmtui"
        ]
    }

    // ─────────────────────────────────────────────
    // Volume
    // ─────────────────────────────────────────────

    Process {
        id: volumeProcess

        command: [
            "sh",
            "-c",
            "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}'"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.volumePercent = parseInt(text.trim()) || 0
            }
        }
    }

    Process {
        id: volumeChangeProcess
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            volumeProcess.running = true
        }
    }

    // ─────────────────────────────────────────────
    // Battery
    // ─────────────────────────────────────────────

    Process {
        id: batteryProcess

        command: [
            "sh",
            "-c",
            "cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1; cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -1"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.trim().split("\n")
                root.hasBattery = lines[0] !== "" && !isNaN(parseInt(lines[0]))
                root.batteryPercent = parseInt(lines[0]) || 0
                root.batteryCharging = lines[1] === "Charging" || lines[1] === "Full"
            }
        }
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            batteryProcess.running = true
        }
    }

    // ─────────────────────────────────────────────
    // HyprPWCenter
    // ─────────────────────────────────────────────

    Process {
        id: volumeMixerProcess

        command: [
            "hyprpwcenter"
        ]
    }

    // ─────────────────────────────────────────────
    // Focused Window
    // ─────────────────────────────────────────────

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name === "activewindow") {
                let data = event.data.split(",")

                if (data.length >= 2) {
                    root.focusedWindowTitle = data.slice(1).join(",")
                }
            }
        }
    }

    // ─────────────────────────────────────────────
    // Layout
    // ─────────────────────────────────────────────

    RowLayout {
        anchors.fill: parent

        anchors.leftMargin: 10
        anchors.rightMargin: 10

        spacing: 8

        // ─────────────────────────────────────────
        // Time
        // ─────────────────────────────────────────

        MouseArea {
            Layout.preferredWidth: clockText.implicitWidth
            Layout.preferredHeight: clockText.implicitHeight

            acceptedButtons: Qt.NoButton

            onWheel: {
                root.showFullDate = !root.showFullDate
            }

            Text {
                id: clockText

                color: root.colBlue

                font {
                    family: root.fontFamily
                    pixelSize: root.fontSize
                    bold: true
                }

                text: root.showFullDate
                    ? Qt.formatDateTime(
                        new Date(),
                        "dddd, MMMM dd - h:mm AP"
                    )
                    : Qt.formatDateTime(
                        new Date(),
                        "h:mm AP"
                    )

                Timer {
                    interval: 1000
                    running: true
                    repeat: true

                    onTriggered: {
                        clockText.text = root.showFullDate
                            ? Qt.formatDateTime(
                                new Date(),
                                "dddd, MMMM dd - h:mm AP"
                            )
                            : Qt.formatDateTime(
                                new Date(),
                                "h:mm AP"
                            )
                    }
                }
            }
        }

        Rectangle {
            width: 1
            height: 16

            color: root.colMuted
        }

        // ─────────────────────────────────────────
        // Focused Window Title
        // ─────────────────────────────────────────

        Text {
            text: root.focusedWindowTitle

            color: root.colFg

            elide: Text.ElideRight

            Layout.maximumWidth: 600

            font {
                family: root.fontFamily
                pixelSize: root.fontSize
            }
        }

        // Push right side to the right
        Item {
            Layout.fillWidth: true
        }

        // ─────────────────────────────────────────
        // Wi-Fi / IP Address
        // ─────────────────────────────────────────

        MouseArea {
            Layout.preferredWidth: wifiText.implicitWidth
            Layout.preferredHeight: wifiText.implicitHeight

            acceptedButtons: Qt.LeftButton

            onClicked: {
                nmtuiProcess.running = true
            }

            onWheel: {
                root.showIpAddress = !root.showIpAddress
            }

            Text {
                id: wifiText

                text: root.showIpAddress
                    ? "󰩟 " + root.ipAddress
                    : "󰤨 " + root.wifiName

                color: root.colCyan

                font {
                    family: root.fontFamily
                    pixelSize: root.fontSize
                    bold: true
                }
            }
        }

        Rectangle {
            width: 1
            height: 16

            color: root.colMuted
        }

        // ─────────────────────────────────────────
        // Volume
        // ─────────────────────────────────────────

        MouseArea {
            Layout.preferredWidth: volumeText.implicitWidth
            Layout.preferredHeight: volumeText.implicitHeight

            acceptedButtons: Qt.LeftButton

            onClicked: {
                volumeMixerProcess.running = true
            }

            onWheel: (wheel) => {
                if (wheel.angleDelta.y > 0) {
                    volumeChangeProcess.command = [
                        "wpctl",
                        "set-volume",
                        "@DEFAULT_AUDIO_SINK@",
                        "5%+"
                    ]
                } else {
                    volumeChangeProcess.command = [
                        "wpctl",
                        "set-volume",
                        "@DEFAULT_AUDIO_SINK@",
                        "5%-"
                    ]
                }

                volumeChangeProcess.running = true
                volumeProcess.running = true
            }

            Text {
                id: volumeText

                text: "󰕾 " + root.volumePercent + "%"

                color: root.colYellow

                font {
                    family: root.fontFamily
                    pixelSize: root.fontSize
                    bold: true
                }
            }
        }

        // ─────────────────────────────────────────
        // Battery
        // ─────────────────────────────────────────

        Rectangle {
            width: 1
            height: 16

            color: root.colMuted
            visible: root.hasBattery
        }

        Text {
            id: batteryText

            visible: root.hasBattery

            text: {
                let icon
                if (root.batteryCharging) {
                    icon = "󰂄"
                } else if (root.batteryPercent >= 90) {
                    icon = "󰁹"
                } else if (root.batteryPercent >= 80) {
                    icon = "󰂂"
                } else if (root.batteryPercent >= 70) {
                    icon = "󰂁"
                } else if (root.batteryPercent >= 60) {
                    icon = "󰂀"
                } else if (root.batteryPercent >= 50) {
                    icon = "󰁿"
                } else if (root.batteryPercent >= 40) {
                    icon = "󰁾"
                } else if (root.batteryPercent >= 30) {
                    icon = "󰁽"
                } else if (root.batteryPercent >= 20) {
                    icon = "󰁼"
                } else if (root.batteryPercent >= 10) {
                    icon = "󰁻"
                } else {
                    icon = "󰂎"
                }
                return icon + " " + root.batteryPercent + "%"
            }

            color: root.batteryPercent <= 20 && !root.batteryCharging
                ? root.colBlue
                : root.colFg

            font {
                family: root.fontFamily
                pixelSize: root.fontSize
                bold: true
            }
        }
    }
}
