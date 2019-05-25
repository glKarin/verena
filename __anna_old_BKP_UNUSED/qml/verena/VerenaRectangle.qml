import QtQuick 1.1

Item{
	id:root;

	width:parent.width;
	property int theight:100;
	property bool fullShow:height === theight;
	state:"show";
	states:[
		State{
			name:"show";
			PropertyChanges {
				target: root;
				height:theight;
			}
		}
		,
		State{
			name:"noshow";
			PropertyChanges {
				target: root;
				height:0;
			}
		}
	]
	transitions: [
		Transition {
            from:"noshow";
            to:"show";
			NumberAnimation{
				target:root;
				property:"height";
                easing.type:Easing.OutExpo;
				duration:400;
			}
		}
        ,
        Transition {
            from:"show";
            to:"noshow";
            NumberAnimation{
                target:root;
                property:"height";
                easing.type:Easing.InExpo;
                duration:400;
            }
        }
	]

}
