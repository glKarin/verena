import com.nokia.symbian 1.1

ToolButton {
	id: root;
	property string iconId;
    property alias platformIconId: root.iconId;

	iconSource: __ConvertIconId(root.iconId);

	function __ConvertIconId(iid)
	{
		switch(iid)
		{
			// browserdialog
			case "toolbar-application-white":
			return "toolbar-search";
			case "toolbar-mediacontrol-play-white":
			return "toolbar-mediacontrol-play";
			case "toolbar-trim-white":
			return "toolbar-share";
			// detailpage
			case "toolbar-favorite-mark":
			return "toolbar-delete";
			case "toolbar-favorite-unmark":
			return "toolbar-add";
			case "toolbar-directory-move-to":
			return "toolbar-list"; // episodegridview -> add
			// downloadpage
			case "toolbar-mediacontrol-pause":
			return "toolbar-share";
			case "toolbar-cut-paste":
			return "toolbar-share";
			case "toolbar-close":
			return "toolbar-toolbar-mediacontrol-stop"; // playerpage -> next
			// listitemheader
			case "toolbar-up":
			return "toolbar-previous";
			case "toolbar-down":
			return "toolbar-next";
			// verenabrowser
			case "toolbar-tab-previous":
			return "toolbar-previous";
			case "toolbar-tab-next":
			return "toolbar-next";
			case "toolbar-stop":
			return "toolbar-mediacontrol-stop";
			case "toolbar-edit":
            return "toolbar-search";
			// verenaplayer
			case "toolbar-mediacontrol-previous":
			return "toolbar-mediacontrol-backwards";
			case "toolbar-mediacontrol-next":
			return "toolbar-mediacontrol-forward";

			default:
            return iid;
		}
	}
}
