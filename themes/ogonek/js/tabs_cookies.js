(function(jQuery) {
jQuery(function() {

	function createCookie(name,value,days) {
		if (days) {
			var date = new Date();
			date.setTime(date.getTime()+(days*24*60*60*1000));
			var expires = "; expires="+date.toGMTString();
		}
		else var expires = "";
		document.cookie = name+"="+value+expires+"; path=/";
	}
	function readCookie(name) {
		var nameEQ = name + "=";
		var ca = document.cookie.split(';');
		for(var i=0;i < ca.length;i++) {
			var c = ca[i];
			while (c.charAt(0)==' ') c = c.substring(1,c.length);
			if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
		}
		return null;
	}
	function eraseCookie(name) {
		createCookie(name,"",-1);
	}

	jQuery('ul.tabs').each(function(i) {
		var cookie = readCookie('tabCookie'+i);
		if (cookie) jQuery(this).find('li').eq(cookie).addClass('current').siblings().removeClass('current')
			.parents('div.section').find('div.box').hide().eq(cookie).show();
	})

	jQuery('ul.tabs').on('click', 'li:not(.current)', function() {
		jQuery(this).addClass('current').siblings().removeClass('current')
			.parents('div.section').find('div.box').eq(jQuery(this).index()).fadeIn(150).siblings('div.box').hide();
		var ulIndex = jQuery('ul.tabs').index(jQuery(this).parents('ul.tabs'));
		eraseCookie('tabCookie'+ulIndex);
		createCookie('tabCookie'+ulIndex, jQuery(this).index(), 365);
	})

})
})(jQuery)