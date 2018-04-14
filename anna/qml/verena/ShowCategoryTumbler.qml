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
		titleText:qsTr("Show Category");
		acceptButtonText :qsTr("Match");
		rejectButtonText:qsTr("Cancel");
		columns: [categorytc, genretc, areatc];
		onAccepted:{
			hasSelectedIndeies([categorytc.selectedIndex, genretc.selectedIndex, areatc.selectedIndex]);
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
			id:areatc;
			label:qsTr("Area");
			items:schemas.areaList;
			selectedIndex: 0;
		}

	}
	function getGenre(index){
		genremodel.clear();
		schemas.showCategoryMap[index].value.forEach(function(element){
			genremodel.append(element);
		});
		genretc.selectedIndex = 0;
	}

	Component.onCompleted:{
		categorymodel.clear();
		schemas.showCategoryMap.forEach(function(k){
			categorymodel.append({value: k.name});
		});
		getGenre(0);
	}
	/*
	 Component.onDestruction:{
		 console.log("destory -> tumbler dialog");
	 }
	 */
}
