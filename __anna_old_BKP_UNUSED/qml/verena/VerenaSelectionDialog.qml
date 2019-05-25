import QtQuick 1.1
import com.nokia.symbian 1.1

Item{
	id:root;
	property alias titleText:dialog.titleText;
	property alias model:dialog.model;
	signal hasSelectedIndex(int i);

	function open(){
		dialog.open();
    }
	SelectionDialog{
		id:dialog;
        delegate:            Component {
                id: defaultDelegate

                MenuItem {
                    platformInverted: root.platformInverted
                    text: model.name
                    //privateSelectionIndicator: selectedIndex == index

                    onClicked: {
                        selectedIndex = index
                        root.accept()
                    }

                    Keys.onPressed: {
                        if (event.key == Qt.Key_Up || event.key == Qt.Key_Down)
                            scrollBar.flash()
                    }
                }
            }
		onAccepted:{
			if(selectedIndex !== -1){
				root.hasSelectedIndex(selectedIndex);
			}else{
				//close();
				reject();
			}
		}
        onStatusChanged: {
            if (status === DialogStatus.Closed)
                app.forceActiveFocus();
        }
	}
}
