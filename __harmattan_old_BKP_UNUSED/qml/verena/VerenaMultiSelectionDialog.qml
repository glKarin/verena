import QtQuick 1.1
import com.nokia.meego 1.1

Item{
	id:root;
	property alias titleText:dialog.titleText;
	property alias model:dialog.model;
	property alias acceptButtonText:dialog.acceptButtonText;
	property alias rejectButtonText:dialog.rejectButtonText;
	signal hasSelectedIndies(variant arr);
	signal rejected;

	function open(){
		dialog.open();
	}

	function resetSelectedIndexes(){
		dialog.selectedIndexes = [];
	}

	MultiSelectionDialog{
		id:dialog;
		onAccepted:{
			if(selectedIndexes.length > 0){
				root.hasSelectedIndies(selectedIndexes);
			}else{
				//close();
				reject();
			}
		}
		onRejected:{
			root.rejected();
		}
	}
}
