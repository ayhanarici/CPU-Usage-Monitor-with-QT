import QtQml 2.13
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick 2.2

CircularGauge {
    id: circularGauge
    value: 0
    minimumValue: 0
    maximumValue: 100
    tickmarksVisible: true
    style: CircularGaugeStyle {
        tickmarkInset: toPixels(0.04)
        minorTickmarkInset: tickmarkInset
        labelStepSize: 20
        labelInset: toPixels(0.23)
        property real xCenter: outerRadius
        property real yCenter: outerRadius
        property real needleLength: outerRadius - tickmarkInset * 1.15
        property real needleTipWidth: toPixels(0.02)
        property real needleBaseWidth: toPixels(0.06)
        property bool halfGauge: false
        function toPixels(percentage) {
            return percentage * outerRadius;
        }
        function degToRad(degrees) {
            return degrees * (Math.PI / 180);
        }
        function radToDeg(radians) {
            return radians * (180 / Math.PI);
        }
        function paintBackground(ctx) {
            if (halfGauge) {
                ctx.beginPath();
                ctx.rect(0, 0, ctx.canvas.width, ctx.canvas.height / 2);
                ctx.clip();
            }

            ctx.beginPath();
            ctx.fillStyle = "#242428";
            ctx.ellipse(0, 0, ctx.canvas.width, ctx.canvas.height);
            ctx.fill();

            ctx.beginPath();
            ctx.lineWidth = tickmarkInset;
            ctx.strokeStyle = "black";
            ctx.arc(xCenter, yCenter, outerRadius - ctx.lineWidth / 2, outerRadius - ctx.lineWidth / 2, 0, Math.PI * 2);
            ctx.stroke();

            ctx.beginPath();
            ctx.lineWidth = tickmarkInset / 2;
            ctx.strokeStyle = "#222";
            ctx.arc(xCenter, yCenter, outerRadius - ctx.lineWidth / 2, outerRadius - ctx.lineWidth / 2, 0, Math.PI * 2);
            ctx.stroke();

            ctx.beginPath();
            var gradient = ctx.createRadialGradient(xCenter, yCenter, outerRadius * 0.8, xCenter, yCenter, outerRadius);
            gradient.addColorStop(0, Qt.rgba(1, 1, 1, 0));
            gradient.addColorStop(0.7, Qt.rgba(1, 1, 1, 0.13));
            gradient.addColorStop(1, Qt.rgba(1, 1, 1, 1));
            ctx.fillStyle = gradient;
            ctx.arc(xCenter, yCenter, outerRadius - tickmarkInset, outerRadius - tickmarkInset, 0, Math.PI * 2);
            ctx.fill();
        }
        function degreesToRadians(degrees) {
            return degrees * (Math.PI / 180);
        }
        background: Canvas {
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                paintBackground(ctx);
                ctx.beginPath();
                ctx.strokeStyle = "#EA2027";
                ctx.lineWidth = outerRadius * 0.02;
                ctx.arc(outerRadius, outerRadius, outerRadius - ctx.lineWidth*2.5,degreesToRadians(valueToAngle(70) - 90), degreesToRadians(valueToAngle(100) - 90));
                ctx.stroke();
            }
            Text {
                id: cpuText
                font.pixelSize: toPixels(0.3)
                text: kphInt
                color: "white"
                horizontalAlignment: Text.AlignRight
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.verticalCenter
                anchors.topMargin: toPixels(0.1)
                readonly property int kphInt: control.value
            }
            Text {
                text: "CPU Usage %"
                color: "white"
                font.pixelSize: toPixels(0.09)
                anchors.top: cpuText.bottom
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    
        needle: Canvas {
            implicitWidth: needleBaseWidth
            implicitHeight: needleLength
            property real xCenter: width / 2
            property real yCenter: height / 2

            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                ctx.beginPath();
                ctx.moveTo(xCenter, height);
                ctx.lineTo(xCenter - needleBaseWidth / 2, height - needleBaseWidth / 2);
                ctx.lineTo(xCenter - needleTipWidth / 2, 0);
                ctx.lineTo(xCenter, yCenter - needleLength);
                ctx.lineTo(xCenter, 0);
                ctx.closePath();
                ctx.fillStyle = Qt.rgba(0.66, 0, 0, 0.66);
                ctx.fill();

                ctx.beginPath();
                ctx.moveTo(xCenter, height)
                ctx.lineTo(width, height - needleBaseWidth / 2);
                ctx.lineTo(xCenter + needleTipWidth / 2, 0);
                ctx.lineTo(xCenter, 0);
                ctx.closePath();
                ctx.fillStyle = Qt.lighter(Qt.rgba(0.66, 0, 0, 0.66));
                ctx.fill();
            }
        }
        foreground: Item {
            Rectangle {
                width: outerRadius * 0.2
                height: width
                radius: width / 2
                color: "#1d1d1d"
                anchors.centerIn: parent
            }
        }
      
        tickmark: Rectangle {
            visible: styleData.value < 70 || styleData.value % 10 == 0
            implicitWidth: outerRadius * 0.02
            antialiasing: true
            implicitHeight: outerRadius * 0.06
            color: styleData.value >= 70 ? "#EA2027" : "#e5e5e5"
        }
        tickmarkLabel:  Text {
            font.pixelSize: Math.max(6, outerRadius * 0.1)
            text: styleData.value
            color: styleData.value >= 70 ? "#EA2027" : "#e5e5e5"
            antialiasing: true
        }
    }
    Connections{
        target: connector
        onValueChanged: circularGauge.value = value
    }
}