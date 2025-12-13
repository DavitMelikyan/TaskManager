import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: root
    visible: true
    width: 900
    height: 600
    minimumWidth: 400
    minimumHeight: 400
    title: "Task Manager"

    ListModel { id: taskModel }

    property string currentFilter: "All"

    function filtered(index) {
        if (currentFilter === "All") return true
        if (currentFilter === "Active" && !taskModel.get(index).completed) return true
        if (currentFilter === "Completed" && taskModel.get(index).completed) return true
        return false
    }

    StackView {
        id: stack
        anchors.fill: parent
        initialItem: mainPage
    }

    Component {
        id: mainPage

        Page {
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Button {
                        text: "All"
                        onClicked: currentFilter = "All"
                        Layout.fillWidth: true
                    }
                    Button {
                        text: "Active"
                        onClicked: currentFilter = "Active"
                        Layout.fillWidth: true
                    }
                    Button {
                        text: "Completed"
                        onClicked: currentFilter = "Completed"
                        Layout.fillWidth: true
                    }

                    Item { Layout.fillWidth: true }

                    Button {
                        text: "Add Task"
                        onClicked: stack.push(taskFormPage)
                        Layout.fillWidth: true
                    }
                }


                ListView {
                    id: lView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: taskModel
                    clip: true

                    delegate: Item {
                        width: parent.width
                        height: row.implicitHeight + 16
                        visible: filtered(index)

                        RowLayout {
                            id: row
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 10

                            CheckBox {
                                checked: completed
                                onToggled: taskModel.setProperty(index, "completed", checked)
                            }

                            Rectangle {
                                width: 12
                                height: 12
                                radius: 2
                                color: priorityColor
                                Layout.alignment: Qt.AlignVCenter
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    text: title
                                    font.bold: true
                                    font.strikeout: completed
                                    color: priorityColor
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: description ? description : ""
                                    color: priorityColor
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                    Layout.fillWidth: true
                                }
                            }

                            ColumnLayout {
                                spacing: 4
                                Layout.alignment: Qt.AlignRight
                                Layout.minimumWidth: 120

                                Text {
                                    text: dueDate
                                    font.pixelSize: 12
                                    color: priorityColor
                                    horizontalAlignment: Text.AlignRight
                                    Layout.fillWidth: true
                                }

                                RowLayout {
                                    spacing: 6
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignRight

                                    Button {
                                        text: "Edit"
                                        onClicked: stack.push(taskFormPage, {
                                            editMode: true,
                                            editIndex: index
                                        })
                                        Layout.preferredWidth: 60
                                    }

                                    Button {
                                        text: "Delete"
                                        onClicked: taskModel.remove(index)
                                        Layout.preferredWidth: 70
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: taskFormPage

        Page {
            property bool editMode: false
            property int editIndex: -1

            property string titleError: ""
            property string descError: ""
            property string dateError: ""

            property bool validForm:
                titleError === "" &&
                descError === "" &&
                dateError === "" &&
                titleField.text.length >= 3

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12

                Label {
                    text: editMode ? "Edit Task" : "New Task"
                    font.pixelSize: 20
                }

                TextField {
                    id: titleField
                    placeholderText: "Title (min 3 chars)"
                    Layout.fillWidth: true

                    onTextChanged: {
                        titleError = text.length < 3 ? "Title must be at least 3 characters" : ""
                    }
                }

                Label {
                    text: titleError
                    color: "red"
                    visible: titleError !== ""
                }

                TextArea {
                    id: descField
                    placeholderText: "Description (max 500 chars)"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    wrapMode: Text.Wrap

                    onTextChanged: {
                        descError = text.length > 500 ? "Description max 500 characters" : ""
                    }
                }

                Label {
                    text: descError
                    color: "red"
                    visible: descError !== ""
                }

                ComboBox {
                    id: priorityDropdown
                    Layout.fillWidth: true
                    model: ["Low", "Medium", "High"]
                }

                TextField {
                    id: dateField
                    placeholderText: "YYYY-MM-DD"
                    Layout.fillWidth: true

                    onTextChanged: {
                        var r = /^\d{4}-\d{2}-\d{2}$/
                        dateError = r.test(text) ? "" : "Date must be YYYY-MM-DD"
                    }
                }

                Label {
                    text: dateError
                    color: "red"
                    visible: dateError !== ""
                }

                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: 10

                    Button {
                        text: "Cancel"
                        onClicked: stack.pop()
                    }

                    Button {
                        text: "Save"
                        enabled: validForm

                        onClicked: {
                            var color =
                                priorityDropdown.currentText === "Low" ? "green" :
                                priorityDropdown.currentText === "Medium" ? "orange" :
                                "red"

                            if (editMode) {
                                taskModel.set(editIndex, {
                                    title: titleField.text,
                                    description: descField.text,
                                    completed: taskModel.get(editIndex).completed,
                                    priorityColor: color,
                                    dueDate: dateField.text
                                })
                            } else {
                                taskModel.append({
                                    title: titleField.text,
                                    description: descField.text,
                                    completed: false,
                                    priorityColor: color,
                                    dueDate: dateField.text
                                })
                            }

                            stack.pop()
                        }
                    }
                }
            }

            Component.onCompleted: {
                if (editMode) {
                    var item = taskModel.get(editIndex)
                    titleField.text = item.title
                    descField.text = item.description
                    dateField.text = item.dueDate

                    if (item.priorityColor === "green") priorityDropdown.currentIndex = 0
                    else if (item.priorityColor === "orange") priorityDropdown.currentIndex = 1
                    else priorityDropdown.currentIndex = 2
                }
            }
        }
    }
}
