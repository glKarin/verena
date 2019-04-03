import QtQuick 1.1

QtObject{
	id: root;

	// player
	property string player_verena: "Verena-player";
	property string player_external: "External-player";

	// play to
	property string play_next: "next";
	property string play_prev: "prev";

	// state
	property string state_show: "show";
	property string state_hide: "noshow";

	// player
	property int player_top_bar_height: 60;
	property int player_bottom_bar_height: 60;
	property int player_left_bar_width: 320;
	property int player_right_bar_width: 320;
	property int player_streamtype_tumbler_height: 360;

	// general
	property int page_header_view_height: 60;
	property color page_header_view_color: "pink";
	property int scheme_nav_bar_height: 50;
	property int user_avatar_image_width: 160;
	property int max_height: 854; // screen.displayHeight
	property int max_width: 480; // screen.displayWidth

	// font, based on MeeGo Harmattan
	property int pixel_micro: 10;
	property int pixel_tiny: 12;
	property int pixel_small: 16;
	property int pixel_medium: 18;
	property int pixel_large: 20;
	property int pixel_xl: 24;
	property int pixel_xxl: 32;
	property int pixel_xxxl: 36;
	property int pixel_big: 40;
	property int pixel_toobig: 48;
	property int pixel_super: 64;
}
