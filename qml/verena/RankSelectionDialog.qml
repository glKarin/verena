import QtQuick 1.1
import com.nokia.meego 1.1

VerenaSelectionDialog{
	id:root;
	signal selectedRank(int rank);
	//property variant arr:[1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

	titleText:qsTr("Select collection rank");
	model:ListModel{id: rankmodel}
	onHasSelectedIndex:{
		root.selectedRank(rankmodel.get(i).name);
	}
	Component.onCompleted:{
		rankmodel.clear();
		var i = 1;
		while(i < 11){
			rankmodel.append({name: i});
			i++;
		}
	}
}
