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
property color colAccent: "#A4595B"
property color colRed: "#e06c75"

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
            root.colAccent = parsed.colors.color4
            root.colRed = parsed.colors.color1

            console.log("Pywal colors loaded:")
            console.log("Background:", root.colBg)
            console.log("Foreground:", root.colFg)
            console.log("Muted:", root.colMuted)
            console.log("Accent:", root.colAccent)
            console.log("Red:", root.colRed)

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
    property string weatherTemp: ""
    property string weatherCondition: ""
    property string weatherIcon: "󰖕"

    // Display state
    property bool showIpAddress: false
    property bool showFullDate: false
    // Display mode: 0 = icon only, 1 = label only, 2 = icon + label
    property int weatherDisplayMode: 2
    property int wifiDisplayMode: 2
    property int volumeDisplayMode: 2
    property int batteryDisplayMode: 2
    property bool batteryBlinkOn: true

    function weatherIconFor(condition) {
        const c = condition.toLowerCase()

        if (c.includes("thunder")) return "󰖓"
        if (c.includes("sleet")) return "󰙿"
        if (c.includes("blizzard") || c.includes("snow")) return "󰖘"
        if (c.includes("ice pellets") || c.includes("hail")) return "󰖒"
        if (c.includes("drizzle") || c.includes("rain")) return "󰖗"
        if (c.includes("fog") || c.includes("mist") || c.includes("haze")) return "󰖑"
        if (c.includes("partly cloudy")) return "󰖕"
        if (c.includes("overcast") || c.includes("cloud")) return "󰖐"
        if (c.includes("clear") || c.includes("sunny")) return "󰖙"

        return "󰖕"
    }

    function cycleDisplayMode(mode) {
        return (mode + 1) % 3
    }

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
    // Weather
    // ─────────────────────────────────────────────

    Process {
        id: weatherProcess

        command: [
            "sh",
            "-c",
            "curl -s --max-time 5 'wttr.in/?format=%C|%t&u'"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split("|")

                if (parts.length === 2 && parts[0] !== "") {
                    root.weatherCondition = parts[0].trim()
                    root.weatherTemp = parts[1].trim().replace(/^\+/, "")
                    root.weatherIcon = root.weatherIconFor(root.weatherCondition)
                }
            }
        }
    }

    Timer {
        interval: 900000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            weatherProcess.running = true
        }
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

                color: root.colAccent

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

        // Push right side to the right
        Item {
            Layout.fillWidth: true
        }

        // ─────────────────────────────────────────
        // Weather
        // ─────────────────────────────────────────

        MouseArea {
            Layout.preferredWidth: weatherText.implicitWidth
            Layout.preferredHeight: weatherText.implicitHeight

            visible: root.weatherTemp !== ""

            acceptedButtons: Qt.LeftButton

            onClicked: {
                root.weatherDisplayMode = root.cycleDisplayMode(root.weatherDisplayMode)
            }

            Text {
                id: weatherText

                text: {
                    if (root.weatherDisplayMode === 0) return root.weatherIcon
                    if (root.weatherDisplayMode === 1) return root.weatherTemp
                    return root.weatherIcon + " " + root.weatherTemp
                }

                color: root.colAccent

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
            visible: root.weatherTemp !== ""
        }

        // ─────────────────────────────────────────
        // Wi-Fi / IP Address
        // ─────────────────────────────────────────

        MouseArea {
            Layout.preferredWidth: wifiText.implicitWidth
            Layout.preferredHeight: wifiText.implicitHeight

            acceptedButtons: Qt.LeftButton

            onClicked: {
                root.wifiDisplayMode = root.cycleDisplayMode(root.wifiDisplayMode)
            }

            onWheel: {
                root.showIpAddress = !root.showIpAddress
            }

            Text {
                id: wifiText

                text: {
                    const icon = root.showIpAddress ? "󰩟" : "󰤨"
                    const label = root.showIpAddress ? root.ipAddress : root.wifiName

                    if (root.wifiDisplayMode === 0) return icon
                    if (root.wifiDisplayMode === 1) return label
                    return icon + " " + label
                }

                color: root.colAccent

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
                root.volumeDisplayMode = root.cycleDisplayMode(root.volumeDisplayMode)
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

                text: {
                    if (root.volumeDisplayMode === 0) return "󰕾"
                    if (root.volumeDisplayMode === 1) return root.volumePercent + "%"
                    return "󰕾 " + root.volumePercent + "%"
                }

                color: root.colAccent

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

        Timer {
            id: batteryBlinkTimer

            interval: 500
            repeat: true
            running: root.hasBattery && root.batteryPercent < 5 && !root.batteryCharging

            onRunningChanged: {
                if (!running) {
                    root.batteryBlinkOn = true
                }
            }

            onTriggered: {
                root.batteryBlinkOn = !root.batteryBlinkOn
            }
        }

        MouseArea {
            Layout.preferredWidth: batteryText.implicitWidth
            Layout.preferredHeight: batteryText.implicitHeight

            visible: root.hasBattery

            acceptedButtons: Qt.LeftButton

            onClicked: {
                root.batteryDisplayMode = root.cycleDisplayMode(root.batteryDisplayMode)
            }

            Text {
                id: batteryText

                opacity: root.hasBattery && root.batteryPercent < 5 && !root.batteryCharging && !root.batteryBlinkOn
                    ? 0
                    : 1

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
                    if (root.batteryDisplayMode === 0) return icon
                    const label = root.batteryPercent + "%"
                    if (root.batteryDisplayMode === 1) return label
                    return icon + " " + label
                }

                color: root.batteryPercent <= 20 && !root.batteryCharging
                    ? root.colRed
                    : root.colAccent

                font {
                    family: root.fontFamily
                    pixelSize: root.fontSize
                    bold: true
                }
            }
        }
    }

    // ─────────────────────────────────────────────
    // Focused Window Title (centered)
    // ─────────────────────────────────────────────

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        width: Math.min(implicitWidth, 600)

        horizontalAlignment: Text.AlignHCenter

        text: root.focusedWindowTitle

        color: root.colFg

        elide: Text.ElideRight

        font {
            family: root.fontFamily
            pixelSize: root.fontSize
        }
    }
}
