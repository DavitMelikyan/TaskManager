import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: root
    width: 800
    height: 600
    visible: true

    property string currentFilter: "All"
    property real scale: width / 800

    ListModel { id: taskModel }

    function filtered(index) {
        if (currentFilter === "All") return true
        if (currentFilter === "Active" && !taskModel.get(index).completed) return true
        if (currentFilter === "Completed" && taskModel.get(index).completed) return true
        return false
    }

    function totalCount() { return taskModel.count }
    function completedCount() {
        var c = 0
        for (var i = 0; i < taskModel.count; ++i) if (taskModel.get(i).completed) ++c
        return c
    }
    function remainingCount() { return totalCount() - completedCount() }

    Dialog {
        id: addTaskDialog
        modal: true
        title: "Create New Task"
        standardButtons: Dialog.Ok | Dialog.Cancel

        property alias titleText: titleField.text
        property alias completedState: completedCheckbox.checked
        property alias priorityValue: priorityDropdown.currentText
        property alias dateValue: datePicker.text

        font.pixelSize: 16 * root.scale

        contentItem: ColumnLayout {
            spacing: 10
            width: parent.width

            TextField {
                id: titleField
                placeholderText: "Task title"
                Layout.fillWidth: true
                font.pixelSize: 16 * root.scale
            }

            CheckBox {
                id: completedCheckbox
                text: "Completed"
                font.pixelSize: 16 * root.scale
            }

            ComboBox {
                id: priorityDropdown
                Layout.fillWidth: true
                model: ["red", "yellow", "green", "blue"]
                currentIndex: 0
                font.pixelSize: 16 * root.scale
            }

            TextField {
                id: datePicker
                placeholderText: "Due date (DD-MM-YYYY)"
                Layout.fillWidth: true
                font.pixelSize: 16 * root.scale
            }
        }

        onAccepted: {
            if (titleText.trim().length === 0) return

            taskModel.append({
                title: titleText,
                completed: completedState,
                priorityColor: priorityValue,
                dueDate: dateValue
            })

            titleField.text = ""
            datePicker.text = ""
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        RowLayout {
            spacing: 10
            Layout.fillWidth: true

            Button {
                text: "All"
                onClicked: currentFilter = "All"
                font.pixelSize: 16 * root.scale
            }
            Button {
                text: "Active"
                onClicked: currentFilter = "Active"
                font.pixelSize: 16 * root.scale
            }
            Button {
                text: "Completed"
                onClicked: currentFilter = "Completed"
                font.pixelSize: 16 * root.scale
            }

            Button {
                text: "Add Task"
                onClicked: addTaskDialog.open()
                font.pixelSize: 16 * root.scale
            }

            Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                text: `Total: ${totalCount()} | Completed: ${completedCount()} | Remaining: ${remainingCount()}`
                color: "dark green"
                font.pixelSize: 16 * root.scale
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: taskModel

            delegate: Item {
                visible: filtered(index)
                width: ListView.view.width

                RowLayout {
                    id: row
                    Layout.fillWidth: true
                    anchors.margins: 10
                    spacing: 10

                    CheckBox {
                        checked: completed
                        onCheckedChanged: taskModel.setProperty(index, "completed", checked)
                        font.pixelSize: 16 * root.scale
                    }

                    Rectangle {
                        width: 12 * root.scale
                        height: 12 * root.scale
                        color: priorityColor
                        radius: 2
                    }

                    Text {
                        text: title
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        color: "light blue"
                        font.pixelSize: 16 * root.scale
                    }

                    Text {
                        text: dueDate
                        color: "light blue"
                        horizontalAlignment: Text.AlignRight
                        font.pixelSize: 16 * root.scale
                    }

                    Button {
                        text: "Delete"
                        font.pixelSize: 14 * root.scale
                        onClicked: taskModel.remove(index)
                    }
                }

                implicitHeight: row.implicitHeight + 20
            }
        }
    }
}
