import QtQuick 1.1
import com.nokia.extras 1.1

Item{
	id:root;

	signal hasSelectedIndeies(variant arr);
	function open(){
		dialog.open();
	}

    VTumblerDialog {
        id:dialog;
		titleText:qsTr("Video Category");
		acceptButtonText :qsTr("Match");
		rejectButtonText:qsTr("Cancel");
		columns: [categorytc, genretc, periodtc];
		onAccepted:{
			hasSelectedIndeies([categorytc.selectedIndex, genretc.selectedIndex, periodtc.selectedIndex]);
		}
		TumblerColumn {
			id:categorytc;
			label:qsTr("Category");
			items:ListModel{id:categorymodel}
			selectedIndex: 0;
			onSelectedIndexChanged:{
				getGenre(selectedIndex);
			}
		}

		TumblerColumn {
			id:genretc;
			label:qsTr("Genre");
			items:ListModel{id:genremodel}
			selectedIndex: 0;
			onSelectedIndexChanged:{
				if(selectedIndex === -1){
					selectedIndex = 0;
				}
			}
		}

		TumblerColumn {
			id:periodtc;
			label:qsTr("Period");
			items:schemas.periodList;
			selectedIndex: 0;
		}
	}
	function getGenre(index){
		genremodel.clear();
		schemas.videoCategoryMap[index].value.forEach(function(element){
			genremodel.append(element);
		});
		genretc.selectedIndex = 0;
	}

	Component.onCompleted:{
		categorymodel.clear();
		schemas.videoCategoryMap.forEach(function(k){
			categorymodel.append({value: k.name});
		});
		getGenre(0);
	}
}

