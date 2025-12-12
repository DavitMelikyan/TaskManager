import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: root
    minimumWidth: 800
    minimumHeight: 600
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
        property alias priorityValue: priorityDropdown.priorityColor
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
                model: ["Low", "Medium", "High"]
                currentIndex: 0
                font.pixelSize: 16 * root.scale

                property string priorityColor: {
                    if (currentText === "Low") return "green"
                    else if (currentText === "Medium") return "orange"
                    return "red"
                }
            }

            TextField {
                id: datePicker
                placeholderText: "Due date"
                Layout.fillWidth: true
                font.pixelSize: 16 * root.scale
            }
        }

        onAccepted: {
            if (titleText.trim() === "" || dateValue.trim() === "") return

            taskModel.append({
                title: titleText.trim(),
                completed: completedState,
                priorityColor: priorityValue,
                dueDate: dateValue.trim()
            })

            titleField.text = ""
            datePicker.text = ""
        }
    }

    Dialog {
        id: editTaskDialog
        modal: true
        title: "Edit Task"
        standardButtons: Dialog.Ok | Dialog.Cancel

        property int editIndex: -1
        property alias newTitleText: newTitleField.text
        property alias newCompletedState: newCompletedCheckbox.checked
        property alias newPriorityValue: newPriorityDropdown.priorityColor
        property alias newDateValue: newDatePicker.text

        font.pixelSize: 16 * root.scale

        ColumnLayout {
            spacing: 10
            width: parent.width

            TextField {
                id: newTitleField
                placeholderText: "Task title"
                Layout.fillWidth: true
                font.pixelSize: 16 * root.scale
            }

            CheckBox {
                id: newCompletedCheckbox
                text: "Completed"
                font.pixelSize: 16 * root.scale
            }

            ComboBox {
                id: newPriorityDropdown
                Layout.fillWidth: true
                model: ["Low", "Medium", "High"]
                currentIndex: 0
                font.pixelSize: 16 * root.scale

                property string priorityColor: {
                    if (currentText === "Low") return "green"
                    else if (currentText === "Medium") return "orange"
                    return "red"
                }
            }

            TextField {
                id: newDatePicker
                placeholderText: "Due date"
                Layout.fillWidth: true
                font.pixelSize: 16 * root.scale
            }
        }

        onAccepted: {
            if (newTitleText.trim() === "" || newDateValue.trim() === "") return

            taskModel.setProperty(editIndex, "title", newTitleText)
            taskModel.setProperty(editIndex, "completed", newCompletedState)
            taskModel.setProperty(editIndex, "priorityColor", newPriorityValue)
            taskModel.setProperty(editIndex, "dueDate", newDateValue)
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
            id: lView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: taskModel

            delegate: Item {
                visible: filtered(index)
                width: lView.width

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
                        color: priorityColor
                        font.strikeout: completed
                        font.pixelSize: 16 * root.scale
                    }

                    Text {
                        text: dueDate
                        color: priorityColor
                        horizontalAlignment: Text.AlignRight
                        font.strikeout: completed
                        font.pixelSize: 16 * root.scale
                    }

                    Button {
                        text: "Delete"
                        font.pixelSize: 14 * root.scale
                        onClicked: taskModel.remove(index)
                    }

                    Button {
                        text: "Modify"
                        font.pixelSize: 14 * root.scale
                        onClicked: {
                            editTaskDialog.editIndex = index
                            editTaskDialog.newTitleText = title
                            editTaskDialog.newCompletedState = completed
                            editTaskDialog.newDateValue = dueDate


                            editTaskDialog.open()
                        }
                    }
                }

                implicitHeight: row.implicitHeight + 20
            }
        }
    }
}
