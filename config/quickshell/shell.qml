import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Widgets
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

    readonly property var connectedWifiNetwork: {
        const device = Networking.devices.values.find((d) => d.type === DeviceType.Wifi)
        if (!device) return null
        return device.networks.values.find((n) => n.connected) || null
    }
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
    property int bluetoothDisplayMode: 2
    property int batteryDisplayMode: 2
    property bool batteryBlinkOn: true
    property var wifiPasswordTarget: null
    property bool vpnActive: false

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

    function wifiIconFor(net) {
        if (!net) return "󰤮"

        const s = net.signalStrength
        if (s >= 80) return "󰤨"
        if (s >= 60) return "󰤥"
        if (s >= 40) return "󰤢"
        if (s >= 20) return "󰤟"
        return "󰤯"
    }

    function togglePopup(target) {
        const wasVisible = target.visible

        audioPopup.visible = false
        wifiPopup.visible = false
        bluetoothPopup.visible = false
        wallpaperPopup.visible = false

        target.visible = !wasVisible
    }

    anchors.top: true
    anchors.left: true
    anchors.right: true

    implicitHeight: 30
    color: root.colBg

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
    // IPC (bar toggle)
    // ─────────────────────────────────────────────

    IpcHandler {
        target: "bar"

        function toggle(): void {
            root.visible = !root.visible
        }
    }

    IpcHandler {
        target: "wallpaper"

        function toggle(): void {
            root.togglePopup(wallpaperPopup)
        }
    }

    IpcHandler {
        target: "airplane"

        function toggle(): void {
            const adapter = Bluetooth.defaultAdapter
            const radiosOn = (adapter && adapter.enabled) || Networking.wifiEnabled
            const turnOn = !radiosOn

            if (adapter) adapter.enabled = turnOn
            Networking.wifiEnabled = turnOn
        }
    }

    // Bluetooth defaults to off on every quickshell start
    Component.onCompleted: {
        if (Bluetooth.defaultAdapter) Bluetooth.defaultAdapter.enabled = false
    }

    Connections {
        target: Bluetooth

        function onDefaultAdapterChanged() {
            if (Bluetooth.defaultAdapter) Bluetooth.defaultAdapter.enabled = false
        }
    }

    // ─────────────────────────────────────────────
    // VPN (WireGuard)
    // ─────────────────────────────────────────────

    Process {
        id: vpnProcess

        command: ["sh", "-c", "wg show interfaces 2>/dev/null"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.vpnActive = text.trim() !== ""
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            vpnProcess.running = true
        }
    }

    // ─────────────────────────────────────────────
    // Audio Output / Input Picker
    // ─────────────────────────────────────────────

    PopupWindow {
        id: audioPopup

        anchor.item: volumeArea
        anchor.rect.x: 0
        anchor.rect.y: volumeArea.height + 8
        anchor.rect.width: volumeArea.width
        anchor.rect.height: 0
        anchor.edges: Edges.Bottom | Edges.Right
        anchor.gravity: Edges.Bottom | Edges.Left

        implicitWidth: 300
        implicitHeight: audioColumn.implicitHeight + 16

        color: "transparent"
        visible: false
        grabFocus: true

        onClosed: audioPopup.visible = false

        Rectangle {
            anchors.fill: parent

            radius: 10
            color: root.colBg
            border.color: root.colMuted
            border.width: 1

            Column {
                id: audioColumn

                anchors.fill: parent
                anchors.margins: 8

                spacing: 2

                Text {
                    text: "Output"

                    color: root.colMuted

                    bottomPadding: 4

                    font {
                        family: root.fontFamily
                        pixelSize: root.fontSize - 2
                        bold: true
                    }
                }

                Repeater {
                    model: Pipewire.nodes.values.filter(
                        (node) => node.isSink && !node.isStream
                    )

                    delegate: Rectangle {
                        id: sinkRow

                        required property var modelData

                        width: audioColumn.width
                        height: 28

                        radius: 6
                        color: sinkArea.containsMouse
                            ? Qt.rgba(root.colAccent.r, root.colAccent.g, root.colAccent.b, 0.2)
                            : "transparent"

                        MouseArea {
                            id: sinkArea

                            anchors.fill: parent
                            hoverEnabled: true

                            onClicked: {
                                Pipewire.preferredDefaultAudioSink = sinkRow.modelData
                                audioPopup.visible = false
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8

                                elide: Text.ElideRight

                                text: {
                                    const label = sinkRow.modelData.description
                                        || sinkRow.modelData.nickname
                                        || sinkRow.modelData.name
                                    const isDefault = Pipewire.defaultAudioSink !== null
                                        && Pipewire.defaultAudioSink.id === sinkRow.modelData.id
                                    return (isDefault ? "󰄬 " : "   ") + label
                                }

                                color: root.colFg

                                font {
                                    family: root.fontFamily
                                    pixelSize: root.fontSize
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    width: audioColumn.width
                    height: 1

                    color: root.colMuted
                    opacity: 0.4
                }

                Text {
                    text: "Input"

                    color: root.colMuted

                    topPadding: 8
                    bottomPadding: 4

                    font {
                        family: root.fontFamily
                        pixelSize: root.fontSize - 2
                        bold: true
                    }
                }

                Repeater {
                    model: Pipewire.nodes.values.filter(
                        (node) => (node.type & PwNodeType.Source) !== 0
                            && !node.isStream
                            && !node.name.endsWith(".monitor")
                    )

                    delegate: Rectangle {
                        id: sourceRow

                        required property var modelData

                        width: audioColumn.width
                        height: 28

                        radius: 6
                        color: sourceArea.containsMouse
                            ? Qt.rgba(root.colAccent.r, root.colAccent.g, root.colAccent.b, 0.2)
                            : "transparent"

                        MouseArea {
                            id: sourceArea

                            anchors.fill: parent
                            hoverEnabled: true

                            onClicked: {
                                Pipewire.preferredDefaultAudioSource = sourceRow.modelData
                                audioPopup.visible = false
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8

                                elide: Text.ElideRight

                                text: {
                                    const label = sourceRow.modelData.description
                                        || sourceRow.modelData.nickname
                                        || sourceRow.modelData.name
                                    const isDefault = Pipewire.defaultAudioSource !== null
                                        && Pipewire.defaultAudioSource.id === sourceRow.modelData.id
                                    return (isDefault ? "󰄬 " : "   ") + label
                                }

                                color: root.colFg

                                font {
                                    family: root.fontFamily
                                    pixelSize: root.fontSize
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ─────────────────────────────────────────────
    // Wi-Fi Network Picker
    // ─────────────────────────────────────────────

    PopupWindow {
        id: wifiPopup

        anchor.item: wifiArea
        anchor.rect.x: 0
        anchor.rect.y: wifiArea.height + 8
        anchor.rect.width: wifiArea.width
        anchor.rect.height: 0
        anchor.edges: Edges.Bottom | Edges.Right
        anchor.gravity: Edges.Bottom | Edges.Left

        implicitWidth: 300
        implicitHeight: wifiColumn.implicitHeight + 16

        color: "transparent"
        visible: false
        grabFocus: true

        onClosed: wifiPopup.visible = false

        onVisibleChanged: {
            const device = Networking.devices.values.find(
                (d) => d.type === DeviceType.Wifi
            )
            if (device) device.scannerEnabled = visible

            if (!visible) {
                root.wifiPasswordTarget = null
                wifiPasswordInput.text = ""
            }
        }

        Rectangle {
            anchors.fill: parent

            radius: 10
            color: root.colBg
            border.color: root.colMuted
            border.width: 1

            Column {
                id: wifiColumn

                anchors.fill: parent
                anchors.margins: 8

                spacing: 2

                Rectangle {
                    id: wifiToggleRow

                    width: wifiColumn.width
                    height: 28

                    radius: 6
                    color: wifiToggleArea.containsMouse
                        ? Qt.rgba(root.colAccent.r, root.colAccent.g, root.colAccent.b, 0.2)
                        : "transparent"

                    MouseArea {
                        id: wifiToggleArea

                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            Networking.wifiEnabled = !Networking.wifiEnabled
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8

                            text: "Wi-Fi: " + (Networking.wifiEnabled ? "On" : "Off")

                            color: root.colFg

                            font {
                                family: root.fontFamily
                                pixelSize: root.fontSize
                                bold: true
                            }
                        }
                    }
                }

                Rectangle {
                    width: wifiColumn.width
                    height: 1

                    color: root.colMuted
                    opacity: 0.4
                }

                Repeater {
                    model: {
                        const device = Networking.devices.values.find(
                            (d) => d.type === DeviceType.Wifi
                        )
                        if (!device) return []
                        return [...device.networks.values].sort(
                            (a, b) => b.signalStrength - a.signalStrength
                        )
                    }

                    delegate: Rectangle {
                        id: netRow

                        required property var modelData

                        width: wifiColumn.width
                        height: 28

                        radius: 6
                        color: netArea.containsMouse
                            ? Qt.rgba(root.colAccent.r, root.colAccent.g, root.colAccent.b, 0.2)
                            : "transparent"

                        MouseArea {
                            id: netArea

                            anchors.fill: parent
                            hoverEnabled: true

                            onClicked: {
                                const net = netRow.modelData

                                if (net.connected) {
                                    net.disconnect()
                                } else if (net.known || net.security === WifiSecurityType.Open) {
                                    root.wifiPasswordTarget = null
                                    net.connect()
                                } else {
                                    root.wifiPasswordTarget = net
                                    wifiPasswordInput.forceActiveFocus()
                                }
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8

                                elide: Text.ElideRight

                                text: {
                                    const net = netRow.modelData

                                    let signalIcon = "󰤟"
                                    if (net.signalStrength >= 80) signalIcon = "󰤨"
                                    else if (net.signalStrength >= 60) signalIcon = "󰤥"
                                    else if (net.signalStrength >= 40) signalIcon = "󰤢"
                                    else if (net.signalStrength >= 20) signalIcon = "󰤟"
                                    else signalIcon = "󰤯"

                                    const lock = net.security === WifiSecurityType.Open ? "" : " 󰌾"
                                    const status = net.stateChanging
                                        ? " …"
                                        : (net.connected ? " 󰄬" : "")

                                    return signalIcon + " " + net.name + lock + status
                                }

                                color: root.colFg

                                font {
                                    family: root.fontFamily
                                    pixelSize: root.fontSize
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    width: wifiColumn.width
                    height: root.wifiPasswordTarget !== null ? 1 : 0

                    visible: root.wifiPasswordTarget !== null

                    color: root.colMuted
                    opacity: 0.4
                }

                Item {
                    width: wifiColumn.width
                    height: root.wifiPasswordTarget !== null ? 32 : 0

                    visible: root.wifiPasswordTarget !== null
                    clip: true

                    Rectangle {
                        anchors.fill: parent
                        anchors.topMargin: 4

                        radius: 6
                        color: Qt.rgba(root.colFg.r, root.colFg.g, root.colFg.b, 0.08)
                        border.color: root.colMuted
                        border.width: 1

                        TextInput {
                            id: wifiPasswordInput

                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            verticalAlignment: TextInput.AlignVCenter

                            echoMode: TextInput.Password
                            color: root.colFg

                            font {
                                family: root.fontFamily
                                pixelSize: root.fontSize
                            }

                            Keys.onReturnPressed: {
                                if (root.wifiPasswordTarget) {
                                    root.wifiPasswordTarget.connectWithPsk(wifiPasswordInput.text)
                                }
                                wifiPasswordInput.text = ""
                                root.wifiPasswordTarget = null
                            }

                            Keys.onEscapePressed: {
                                wifiPasswordInput.text = ""
                                root.wifiPasswordTarget = null
                            }

                            Text {
                                visible: wifiPasswordInput.text.length === 0
                                text: "Password, then Enter"
                                color: root.colMuted

                                font {
                                    family: root.fontFamily
                                    pixelSize: root.fontSize
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ─────────────────────────────────────────────
    // Bluetooth Device Picker
    // ─────────────────────────────────────────────

    PopupWindow {
        id: bluetoothPopup

        anchor.item: bluetoothArea
        anchor.rect.x: 0
        anchor.rect.y: bluetoothArea.height + 8
        anchor.rect.width: bluetoothArea.width
        anchor.rect.height: 0
        anchor.edges: Edges.Bottom | Edges.Right
        anchor.gravity: Edges.Bottom | Edges.Left

        implicitWidth: 300
        implicitHeight: bluetoothColumn.implicitHeight + 16

        color: "transparent"
        visible: false
        grabFocus: true

        onClosed: bluetoothPopup.visible = false

        onVisibleChanged: {
            const adapter = Bluetooth.defaultAdapter
            if (adapter && adapter.enabled) adapter.discovering = visible
        }

        Connections {
            target: Bluetooth.defaultAdapter

            function onStateChanged() {
                const adapter = Bluetooth.defaultAdapter
                if (adapter
                    && adapter.state === BluetoothAdapterState.Enabled
                    && bluetoothPopup.visible) {
                    adapter.discovering = true
                }
            }
        }

        Rectangle {
            anchors.fill: parent

            radius: 10
            color: root.colBg
            border.color: root.colMuted
            border.width: 1

            Column {
                id: bluetoothColumn

                anchors.fill: parent
                anchors.margins: 8

                spacing: 2

                Rectangle {
                    id: adapterToggleRow

                    width: bluetoothColumn.width
                    height: 28

                    radius: 6
                    color: adapterToggleArea.containsMouse
                        ? Qt.rgba(root.colAccent.r, root.colAccent.g, root.colAccent.b, 0.2)
                        : "transparent"

                    MouseArea {
                        id: adapterToggleArea

                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            const adapter = Bluetooth.defaultAdapter
                            if (adapter) adapter.enabled = !adapter.enabled
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8

                            text: {
                                const adapter = Bluetooth.defaultAdapter
                                return "Bluetooth: " + (adapter && adapter.enabled ? "On" : "Off")
                            }

                            color: root.colFg

                            font {
                                family: root.fontFamily
                                pixelSize: root.fontSize
                                bold: true
                            }
                        }
                    }
                }

                Rectangle {
                    width: bluetoothColumn.width
                    height: 1

                    color: root.colMuted
                    opacity: 0.4
                }

                Repeater {
                    model: {
                        const adapter = Bluetooth.defaultAdapter
                        if (!adapter) return []
                        const macAddress = /^([0-9A-F]{2}:){5}[0-9A-F]{2}$/i
                        return [...adapter.devices.values]
                            .filter((d) => d.name && d.name.length > 0 && !macAddress.test(d.name))
                            .sort((a, b) => {
                                if (a.connected !== b.connected) return a.connected ? -1 : 1
                                if (a.paired !== b.paired) return a.paired ? -1 : 1
                                return a.name.localeCompare(b.name)
                            })
                    }

                    delegate: Rectangle {
                        id: btRow

                        required property var modelData

                        width: bluetoothColumn.width
                        height: 28

                        radius: 6
                        color: btArea.containsMouse
                            ? Qt.rgba(root.colAccent.r, root.colAccent.g, root.colAccent.b, 0.2)
                            : "transparent"

                        MouseArea {
                            id: btArea

                            anchors.fill: parent
                            hoverEnabled: true

                            onClicked: {
                                const dev = btRow.modelData
                                if (dev.connected) {
                                    dev.disconnect()
                                } else if (dev.paired) {
                                    dev.connect()
                                } else {
                                    dev.pair()
                                }
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8

                                elide: Text.ElideRight

                                text: {
                                    const dev = btRow.modelData
                                    const battery = dev.batteryAvailable
                                        ? " (" + Math.round(dev.battery * 100) + "%)"
                                        : ""

                                    let status = ""
                                    if (dev.pairing
                                        || dev.state === BluetoothDeviceState.Connecting
                                        || dev.state === BluetoothDeviceState.Disconnecting) {
                                        status = " …"
                                    } else if (dev.connected) {
                                        status = " 󰄬"
                                    } else if (!dev.paired) {
                                        status = " (tap to pair)"
                                    }

                                    return dev.name + battery + status
                                }

                                color: root.colFg

                                font {
                                    family: root.fontFamily
                                    pixelSize: root.fontSize
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ─────────────────────────────────────────────
    // Wallpaper Picker
    // ─────────────────────────────────────────────

    PanelWindow {
        id: wallpaperPopup

        property string selectedTheme: ""
        property var themes: []
        property var files: []
        property int selectedIndex: 0

        readonly property var filteredThemes: wallpaperPopup.themes.filter(
            (t) => t.toLowerCase().includes(wallpaperSearchInput.text.toLowerCase())
        )
        readonly property var filteredFiles: wallpaperPopup.files.filter(
            (f) => wallpaperPopup.basename(f).toLowerCase()
                .includes(wallpaperSearchInput.text.toLowerCase())
        )

        function basename(path) {
            return path.substring(path.lastIndexOf("/") + 1)
        }

        function openTheme(theme) {
            wallpaperPopup.selectedTheme = theme
            wallpaperPopup.selectedIndex = 0
            wallpaperSearchInput.text = ""
            wallpaperFilesProcess.command = [
                "sh", "-c",
                'find "$1" -maxdepth 1 -type f \\( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \\) | sort',
                "_",
                Quickshell.env("HOME") + "/.wallpapers/" + theme
            ]
            wallpaperFilesProcess.running = true
        }

        function backToThemes() {
            wallpaperPopup.selectedTheme = ""
            wallpaperPopup.selectedIndex = 0
            wallpaperSearchInput.text = ""
        }

        function applyWallpaper(path) {
            wallpaperSetProcess.command = ["set-wallpaper", path]
            wallpaperSetProcess.running = true
        }

        function moveSelection(delta) {
            const count = wallpaperPopup.selectedTheme === ""
                ? wallpaperPopup.filteredThemes.length
                : wallpaperPopup.filteredFiles.length

            if (count === 0) {
                wallpaperPopup.selectedIndex = 0
                return
            }

            let next = wallpaperPopup.selectedIndex + delta
            if (next < 0) next = 0
            if (next >= count) next = count - 1
            wallpaperPopup.selectedIndex = next
        }

        function activateSelection() {
            if (wallpaperPopup.selectedTheme === "") {
                const theme = wallpaperPopup.filteredThemes[wallpaperPopup.selectedIndex]
                if (theme) wallpaperPopup.openTheme(theme)
            } else {
                const file = wallpaperPopup.filteredFiles[wallpaperPopup.selectedIndex]
                if (file) wallpaperPopup.applyWallpaper(file)
            }
        }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "wallpaper-picker"

        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true

        exclusionMode: ExclusionMode.Ignore

        color: "transparent"
        visible: false

        onVisibleChanged: {
            if (visible) {
                wallpaperPopup.selectedTheme = ""
                wallpaperPopup.selectedIndex = 0
                wallpaperSearchInput.text = ""
                wallpaperThemesProcess.running = true
                Qt.callLater(() => wallpaperSearchInput.forceActiveFocus())
            }
        }

        Process {
            id: wallpaperThemesProcess

            command: [
                "sh", "-c",
                'find "$1" -mindepth 1 -maxdepth 1 -type d ! -name ".*" -printf "%f\\n" | sort',
                "_",
                Quickshell.env("HOME") + "/.wallpapers"
            ]

            stdout: StdioCollector {
                onStreamFinished: {
                    wallpaperPopup.themes = text.trim().split("\n").filter((t) => t.length > 0)
                }
            }
        }

        Process {
            id: wallpaperFilesProcess

            stdout: StdioCollector {
                onStreamFinished: {
                    wallpaperPopup.files = text.trim().split("\n").filter((f) => f.length > 0)
                }
            }
        }

        Process {
            id: wallpaperSetProcess
        }

        MouseArea {
            anchors.fill: parent

            onClicked: wallpaperPopup.visible = false

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.35)
            }
        }

        Rectangle {
            anchors.centerIn: parent

            width: 460
            height: 520

            radius: 10
            color: root.colBg
            border.color: root.colMuted
            border.width: 1

            MouseArea {
                anchors.fill: parent
                onClicked: {}
            }

            Rectangle {
                id: wallpaperHeader

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 8

                height: 28

                radius: 6
                color: headerArea.containsMouse && wallpaperPopup.selectedTheme !== ""
                    ? Qt.rgba(root.colAccent.r, root.colAccent.g, root.colAccent.b, 0.2)
                    : "transparent"

                MouseArea {
                    id: headerArea

                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: wallpaperPopup.selectedTheme !== ""

                    onClicked: {
                        wallpaperPopup.backToThemes()
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8

                        elide: Text.ElideRight

                        text: wallpaperPopup.selectedTheme === ""
                            ? "Choose a Theme"
                            : "‹ " + wallpaperPopup.selectedTheme

                        color: root.colFg

                        font {
                            family: root.fontFamily
                            pixelSize: root.fontSize
                            bold: true
                        }
                    }
                }
            }

            Rectangle {
                id: wallpaperSearchBox

                anchors.top: wallpaperHeader.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 8
                anchors.topMargin: 4

                height: 28

                radius: 6
                color: Qt.rgba(root.colFg.r, root.colFg.g, root.colFg.b, 0.08)
                border.color: root.colMuted
                border.width: 1

                TextInput {
                    id: wallpaperSearchInput

                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    verticalAlignment: TextInput.AlignVCenter

                    color: root.colFg

                    font {
                        family: root.fontFamily
                        pixelSize: root.fontSize
                    }

                    onTextChanged: {
                        wallpaperPopup.selectedIndex = 0
                    }

                    Keys.onEscapePressed: {
                        if (wallpaperSearchInput.text.length > 0) {
                            wallpaperSearchInput.text = ""
                        } else {
                            wallpaperPopup.visible = false
                        }
                    }

                    Keys.onUpPressed: (event) => {
                        wallpaperPopup.moveSelection(
                            wallpaperPopup.selectedTheme === "" ? -1 : -wallpaperGrid.columns
                        )
                        event.accepted = true
                    }

                    Keys.onDownPressed: (event) => {
                        wallpaperPopup.moveSelection(
                            wallpaperPopup.selectedTheme === "" ? 1 : wallpaperGrid.columns
                        )
                        event.accepted = true
                    }

                    Keys.onLeftPressed: (event) => {
                        if (wallpaperPopup.selectedTheme !== "") {
                            wallpaperPopup.moveSelection(-1)
                            event.accepted = true
                        }
                    }

                    Keys.onRightPressed: (event) => {
                        if (wallpaperPopup.selectedTheme !== "") {
                            wallpaperPopup.moveSelection(1)
                            event.accepted = true
                        }
                    }

                    Keys.onTabPressed: (event) => {
                        wallpaperPopup.moveSelection(1)
                        event.accepted = true
                    }

                    Keys.onBacktabPressed: (event) => {
                        wallpaperPopup.moveSelection(-1)
                        event.accepted = true
                    }

                    Keys.onReturnPressed: (event) => {
                        wallpaperPopup.activateSelection()
                        event.accepted = true
                    }

                    Keys.onEnterPressed: (event) => {
                        wallpaperPopup.activateSelection()
                        event.accepted = true
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left

                        visible: wallpaperSearchInput.text.length === 0

                        text: wallpaperPopup.selectedTheme === ""
                            ? "Search themes…"
                            : "Search wallpapers…"

                        color: root.colMuted

                        font {
                            family: root.fontFamily
                            pixelSize: root.fontSize
                        }
                    }
                }
            }

            ListView {
                anchors.top: wallpaperSearchBox.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 8
                anchors.topMargin: 4

                visible: wallpaperPopup.selectedTheme === ""
                clip: true

                spacing: 2

                model: wallpaperPopup.filteredThemes
                currentIndex: wallpaperPopup.selectedIndex

                delegate: Rectangle {
                    id: themeRow

                    required property string modelData
                    required property int index

                    width: ListView.view.width
                    height: 28

                    radius: 6
                    color: (themeArea.containsMouse || themeRow.index === wallpaperPopup.selectedIndex)
                        ? Qt.rgba(root.colAccent.r, root.colAccent.g, root.colAccent.b, 0.2)
                        : "transparent"

                    MouseArea {
                        id: themeArea

                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            wallpaperPopup.openTheme(themeRow.modelData)
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8

                            elide: Text.ElideRight

                            text: themeRow.modelData
                                .replace(/[-_]/g, " ")
                                .replace(/\b\w/g, (c) => c.toUpperCase())

                            color: root.colFg

                            font {
                                family: root.fontFamily
                                pixelSize: root.fontSize
                            }
                        }
                    }
                }
            }

            GridView {
                id: wallpaperGrid

                anchors.top: wallpaperSearchBox.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 8
                anchors.topMargin: 4

                visible: wallpaperPopup.selectedTheme !== ""
                clip: true

                cellWidth: 128
                cellHeight: 96

                readonly property int columns: Math.max(1, Math.floor(width / cellWidth))

                model: wallpaperPopup.filteredFiles
                currentIndex: wallpaperPopup.selectedIndex

                delegate: Item {
                    id: fileCell

                    required property string modelData
                    required property int index

                    width: GridView.view.cellWidth
                    height: GridView.view.cellHeight

                    ClippingRectangle {
                        anchors.fill: parent
                        anchors.margins: 4

                        radius: 6
                        color: root.colMuted

                        border.color: (fileArea.containsMouse || fileCell.index === wallpaperPopup.selectedIndex)
                            ? root.colAccent
                            : "transparent"
                        border.width: 2

                        Image {
                            anchors.fill: parent

                            source: "file://" + fileCell.modelData
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true

                            sourceSize.width: 128
                            sourceSize.height: 96
                        }
                    }

                    MouseArea {
                        id: fileArea

                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            wallpaperPopup.applyWallpaper(fileCell.modelData)
                        }
                    }
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
            visible: root.weatherTemp !== ""
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

        // Push right side to the right
        Item {
            Layout.fillWidth: true
        }

        // ─────────────────────────────────────────
        // Wi-Fi / IP Address
        // ─────────────────────────────────────────

        MouseArea {
            id: wifiArea

            Layout.preferredWidth: wifiText.implicitWidth
            Layout.preferredHeight: wifiText.implicitHeight

            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                    root.togglePopup(wifiPopup)
                } else {
                    root.wifiDisplayMode = root.cycleDisplayMode(root.wifiDisplayMode)
                }
            }

            onWheel: {
                root.showIpAddress = !root.showIpAddress
            }

            Text {
                id: wifiText

                text: {
                    const net = root.connectedWifiNetwork
                    const icon = root.showIpAddress
                        ? "󰩟"
                        : (root.vpnActive ? "󰖂" : root.wifiIconFor(net))
                    const label = root.showIpAddress
                        ? root.ipAddress
                        : (net ? net.name : "Disconnected")

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
        // Bluetooth
        // ─────────────────────────────────────────

        MouseArea {
            id: bluetoothArea

            Layout.preferredWidth: bluetoothText.implicitWidth
            Layout.preferredHeight: bluetoothText.implicitHeight

            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                    root.togglePopup(bluetoothPopup)
                } else {
                    root.bluetoothDisplayMode = root.cycleDisplayMode(root.bluetoothDisplayMode)
                }
            }

            Text {
                id: bluetoothText

                text: {
                    const adapter = Bluetooth.defaultAdapter
                    const enabled = adapter && adapter.enabled
                    const connectedCount = enabled
                        ? adapter.devices.values.filter((d) => d.connected).length
                        : 0

                    const icon = enabled ? "󰂯" : "󰂲"
                    const label = !enabled
                        ? "Off"
                        : (connectedCount > 0 ? connectedCount + " connected" : "On")

                    if (root.bluetoothDisplayMode === 0) return icon
                    if (root.bluetoothDisplayMode === 1) return label
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
            id: volumeArea

            Layout.preferredWidth: volumeText.implicitWidth
            Layout.preferredHeight: volumeText.implicitHeight

            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                    root.togglePopup(audioPopup)
                } else {
                    root.volumeDisplayMode = root.cycleDisplayMode(root.volumeDisplayMode)
                }
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
