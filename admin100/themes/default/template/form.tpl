{*
* 2007-2016 PrestaShop
*
* NOTICE OF LICENSE
*
* This source file is subject to the Academic Free License (AFL 3.0)
* that is bundled with this package in the file LICENSE.txt.
* It is also available through the world-wide-web at this URL:
* http://opensource.org/licenses/afl-3.0.php
* If you did not receive a copy of the license and are unable to
* obtain it through the world-wide-web, please send an email
* to license@prestashop.com so we can send you a copy immediately.
*
* DISCLAIMER
*
* Do not edit or add to this file if you wish to upgrade PrestaShop to newer
* versions in the future. If you wish to customize PrestaShop for your
* needs please refer to http://www.prestashop.com for more information.
*
*  @author PrestaShop SA <contact@prestashop.com>
*  @copyright  2007-2016 PrestaShop SA
*  @license    http://opensource.org/licenses/afl-3.0.php  Academic Free License (AFL 3.0)
*  International Registered Trademark & Property of PrestaShop SA
*}
<style type="text/css">
.table .colored tr, .table .colored {
      background-color:#9999ff;
  }
</style>
<script type="text/javascript">
	var id_cart = {$cart->id|intval};
	var id_customer = 0;
	var show_filter = 0;
	var	paym_sum = 0;
	var	paym_zak = '';
	var iall = 0;
	var rest_sum_rasp = 0.00;
	var tek_zak_sum_rasp = 0.00;
	var tek_zak_sum_rasp_id = 0;
	var tek_zak_sum_rasp_id_cust = 0;
	var admin_order_tab_link = "{$link->getAdminLink('AdminOrders')|addslashes}";
	var admin_my_payments_tab_link = "{$link->getAdminLink('AdminMy_Payments')|addslashes}";
	var changed_shipping_price = false;
	var shipping_price_selected_carrier = '';
	var current_index = '{$current|escape:'html':'UTF-8'}&token={$token|escape:'html':'UTF-8'}';
	var admin_cart_link = '{$link->getAdminLink('AdminCarts')|addslashes}';
	var cart_quantity = new Array();
	var currencies = new Array();
	var my_orders = new Array();
	var my_payms = new Array();
	var paymentsArray = new Array();
	var id_currency = '';
	var id_lang = '';
	//var txt_show_carts = '{l s='Show carts and orders for this customer.' js=1}';
	//var txt_hide_carts = '{l s='Hide carts and orders for this customer.' js=1}';
	var defaults_order_state = new Array();
	var customization_errors = false;
	var pic_dir = '{$pic_dir}';
	var currency_format = 5;
	var currency_sign = '';
	var currency_blank = false;
	var priceDisplayPrecision = {$smarty.const._PS_PRICE_DISPLAY_PRECISION_|intval};

	{foreach from=$defaults_order_state key='module' item='id_order_state'}
		defaults_order_state['{$module}'] = '{$id_order_state}';
	{/foreach}

	// Init all events

	$(document).ready(function() {

	
	
		$('.datepicker').datetimepicker({
				prevText: '',
				nextText: '',
				dateFormat: 'yy-mm-dd',
				// Define a custom regional settings in order to use PrestaShop translation tools
				currentText: '{l s='Now' js=1}',
				closeText: '{l s='Done' js=1}',
				ampm: false,
				amNames: ['AM', 'A'],
				pmNames: ['PM', 'P'],
				timeFormat: 'hh:mm:ss tt',
				timeSuffix: '',
				timeOnlyTitle: '{l s='Choose Time' js=1}',
				timeText: '{l s='Time' js=1}',
				hourText: '{l s='Hour' js=1}',
				minuteText: '{l s='Minute' js=1}'
			});
	
	
		$('#customer').typeWatch({
			captureLength: 3,
			highlight: true,
			wait: 100,
			callback: function(){ searchCustomers("searchCustomers"); }
			});
		$('#product').typeWatch({
			captureLength: 1,
			highlight: true,
			wait: 750,
			callback: function(){ searchProducts(); }
		});
		$('#payment_module_name').change(function() {
			var id_order_state = defaults_order_state[this.value];
			if (typeof(id_order_state) == 'undefined')
				id_order_state = defaults_order_state['other'];
			$('#id_order_state').val(id_order_state);
		});
		$("#id_address_delivery").change(function() {
			updateAddresses();
		});
		$("#id_address_invoice").change(function() {
			updateAddresses();
		});
		$('#id_currency').change(function() {
			updateCurrency();
		});
		$('#id_lang').change(function(){
			updateLang();
		});
		$('#delivery_option,#carrier_recycled_package,#order_gift,#gift_message').change(function() {
			updateDeliveryOption();
		});
		$('#shipping_price').change(function() {
			if ($(this).val() != shipping_price_selected_carrier)
				changed_shipping_price = true;
		});

		$('#payment_module_name').change();
		$.ajaxSetup({ type:"post" });
		$("#voucher").autocomplete('{$link->getAdminLink('AdminCartRules')|addslashes}', {
					minChars: 3,
					max: 15,
					width: 250,
					selectFirst: false,
					scroll: false,
					dataType: "json",
					formatItem: function(data, i, max, value, term) {
						return value;
					},
					parse: function(data) {
						if (!data.found)
							$('#vouchers_err').html('{l s='No voucher was found'}').show();
						else
							$('#vouchers_err').hide();
						var mytab = new Array();
						for (var i = 0; i < data.vouchers.length; i++)
							mytab[mytab.length] = { data: data.vouchers[i], value: data.vouchers[i].name + (data.vouchers[i].code.length > 0 ? ' - ' + data.vouchers[i].code : '')};
						return mytab;
					},
					extraParams: {
						ajax: "1",
						token: "{getAdminToken tab='AdminCartRules'}",
						tab: "AdminCartRules",
						action: "searchCartRuleVouchers"
					}
				}
			)
			.result(function(event, data, formatted) {
				$('#voucher').val(data.name);
				add_cart_rule(data.id_cart_rule);
			});
		{if $cart->id}
			setupCustomer({$cart->id_customer|intval});
			useCart('{$cart->id|intval}');
		{/if}

		$('.delete_product').live('click', function(e) {
			e.preventDefault();
			var to_delete = $(this).attr('rel').split('_');
			deleteProduct(to_delete[1], to_delete[2], to_delete[3]);
		});
		$('.delete_discount').live('click', function(e) {
			e.preventDefault();
			deleteVoucher($(this).attr('rel'));
		});
		$('.use_cart').live('click', function(e) {
			e.preventDefault();
			useCart($(this).attr('rel'));
			return false;
		});

		$('input:radio[name="free_shipping"]').on('change',function() {
			var free_shipping = $('input[name=free_shipping]:checked').val();
			$.ajax({
				type:"POST",
				url: "{$link->getAdminLink('AdminCarts')|addslashes}",
				async: true,
				dataType: "json",
				data : {
					ajax: "1",
					token: "{getAdminToken tab='AdminCarts'}",
					tab: "AdminCarts",
					action: "updateFreeShipping",
					id_cart: id_cart,
					id_customer: id_customer,
					'free_shipping': free_shipping
					},
				success : function(res)
				{
					displaySummary(res);
				}
			});
		});

		$('.duplicate_order').live('click', function(e) {
			e.preventDefault();
			duplicateOrder($(this).attr('rel'));
		});
		$('.cart_quantity').live('change', function(e) {
			e.preventDefault();
			if ($(this).val() != cart_quantity[$(this).attr('rel')])
			{
				var product = $(this).attr('rel').split('_');
				updateQty(product[0], product[1], product[2], $(this).val() - cart_quantity[$(this).attr('rel')]);
			}
		});
		$('.increaseqty_product, .decreaseqty_product').live('click', function(e) {
			e.preventDefault();
			var product = $(this).attr('rel').split('_');
			var sign = '';
			if ($(this).hasClass('decreaseqty_product'))
				sign = '-';
			updateQty(product[0], product[1],product[2], sign+1);
		});
		$('#id_product').live('keydown', function(e) {
			$(this).click();
			return true;
		});
		$('#id_product, .id_product_attribute').live('change', function(e) {
			e.preventDefault();
			displayQtyInStock(this.id);
		});
		$('#id_product, .id_product_attribute').live('keydown', function(e) {
			$(this).change();
			return true;
		});
		$('.product_unit_price').live('change', function(e) {
			e.preventDefault();
			var product = $(this).attr('rel').split('_');
			updateProductPrice(product[0], product[1], $(this).val());
		});
		$('#order_message').live('change', function(e) {
			e.preventDefault();
			$.ajax({
				type:"POST",
				url: "{$link->getAdminLink('AdminCarts')|addslashes}",
				async: true,
				dataType: "json",
				data : {
					ajax: "1",
					token: "{getAdminToken tab='AdminCarts'}",
					tab: "AdminCarts",
					action: "updateOrderMessage",
					id_cart: id_cart,
					id_customer: id_customer,
					message: $(this).val()
					},
				success : function(res)
				{
					displaySummary(res);
				}
			});
		});
		resetBind();

		$('#cur_order').focus();

		$('#submitAddProduct').on('click',function(){
			addProduct();
		});

		$('#submit_this_order_sum').on('click',function(){
			if (!confirm('Вы уверены?'))
			return false;
			$('#summa_all').val(tek_zak_sum_rasp.toFixed(2));
			$('#summa_no').val(tek_zak_sum_rasp.toFixed(2));
			$('#summa_no_2').html(tek_zak_sum_rasp.toFixed(2));
			$('#summa_no_2_2').html(tek_zak_sum_rasp.toFixed(2));
			$('#id_customer').val(tek_zak_sum_rasp_id_cust);
			$('#rsps'+tek_zak_sum_rasp_id).val(tek_zak_sum_rasp.toFixed(2));
			$('#submitSavePayment').click();
		});

		$('#submitSavePayment').on('click',function(){
			var new_sum = parseFloat($('#summa_all').val());
			var sum_yes = parseFloat($('#summa_yes').val());
			var new_zak = $('#cur_order').val();
			new_zak = new_zak.trim();
			var new_cust = $('#id_customer').val();
			var go = true;
            
			if ((new_sum == 0) && (new_zak.length == 0) && (new_cust == 0))
			{
				jAlert('Необходимо заполнить хотя бы одно из полей: № заказа, Покупатель или Сумма оплаты!');
				go = false;
			}
			if (new_sum < sum_yes)
			{
				jAlert('The amount of payment may not be less than the distributed!');
				go = false;
			}
			if (go)
			{
				saveMyPayment($('#id_my_payments').val(), new_zak, new_cust, $('#date_payment').val(), $('#id_my_payments_tip').val(), $('#id_my_payments_vid option:selected').val(), $('#id_my_payments_spos option:selected').val(), $('#id_my_payments_kas option:selected').val(), parseFloat($('#summa_all').val()), $('#prim').val());
			}
		});

		$('#mytest').on('click',function(){
//			$('#prim').val('8765865876');
//			$('#customer_part').find('.setup-customer').trigger( "click" );
//			$('#to_rasp').removeClass('hide');
//			preparePaymentArray();
		});
		$('#id_my_payments_vid').on('change',function(){
			if ($('#id_my_payments_vid option:selected').val() < 3) {
				$('#to_rasp').removeClass('hide');
			} else {
				$('#to_rasp').addClass('hide');
			}	
		});
		

	function saveMyPayment(id_new_payment, new_order, id_new_customer, date_payment, id_new_payments_tip, id_new_payment_vid, id_new_payment_spos, id_new_payment_kas, new_summa_all, new_prim)
	{
	var testrasp = preparePaymentArray();
	if (testrasp == 2) {
		jAlert('Невозможно распределить на заказ больше чем сумма к оплате!');
		return false;
	}
	if (testrasp == 1) {
		jAlert('Слишком большая сумма разнесенных оплат!');
		return false;
	}
	var dataps = JSON.stringify(paymentsArray);
//	jAlert(dataps);
	$.ajax({
			type:"POST",
			url: admin_my_payments_tab_link,
			async: true,
			dataType: "json",
			data : {
				ajax: "1",
				token: "{getAdminToken tab='AdminMy_Payments'}",
				action: "SavePayment",
				id_payment: id_new_payment,
				nomOrder: new_order,
				id_customer: id_new_customer,
				date_payment: date_payment,
				id_my_payments_tip: id_new_payments_tip,
				id_my_payments_vid: id_new_payment_vid,
				id_my_payments_spos: id_new_payment_spos,
				id_my_payments_kas: id_new_payment_kas,
				summa_all: new_summa_all,
				prim: new_prim,
				dataps: dataps,
			},
			success : function(res)
			{
				if(res.found)
				{
//					jAlert('вернолось');
					my_orders = res.orders;
					my_payms = res.payments;
					paym_zak = $('#cur_order').val();
					paym_zak = paym_zak.trim();
					paym_sum = res.sumno;
					$('#id_my_payments').val(res.newpid);
					$('#summa_yes').val(res.sumyes.toFixed(2));
					$('#summa_no').val(res.sumno.toFixed(2));
					$('#summa_no_2').html(res.sumno.toFixed(2));
					$('#summa_no_2_2').html(res.sumno.toFixed(2));
					refreshMyList();
					var tek_vid = parseInt($('#id_my_payments_vid option:selected').val());
					if (tek_vid < 3) $('#to_rasp').removeClass('hide');
					jAlert('Успешно сохранено!');
					my_init();
				}
			},
			error : function(XMLHttpRequest, textStatus, errorThrown) {
				jAlert("Не возможно сохранить.\n" + XMLHttpRequest.responseText);
			}
		});
	}


		
		
		$('#product').bind('keypress', function(e) {
			var code = (e.keyCode ? e.keyCode : e.which);
			if(code == 13)
			{
				e.stopPropagation();
				e.preventDefault();
				if ($('#submitAddProduct').length)
					addProduct();
			}
		});

		$('#send_email_to_customer').on('click',function(){
			sendMailToCustomer();
			return false;
		});

//		$('#products_found').hide();
//		$('#carts').hide();

		$('#customer_part').on('click','button.setup-customer',function(e){
			e.preventDefault();
//			$('#to_rasp').removeClass('hide');
			chooseCustomer($(this));
		});


	function chooseCustomer(mcont)
	{
//			setupCustomer(mcont.data('customer'));
//			my_search(2);
			$('#id_customer').val(mcont.data('customer'));
			mcont.removeClass('setup-customer').addClass('change-customer').html('<i class="icon-refresh"></i>&nbsp;{l s="Изменить"}').blur();
			mcont.closest('.customerCard').addClass('selected-customer');
			$('.selected-customer .panel-heading').prepend('<i class="icon-ok text-success"></i>');
			$('.customerCard').not('.selected-customer').remove();
			$('#search-customer-form-group').hide();
			refreshMyList();
	}
	
		$('#customer_part').on('click','button.change-customer',function(e){
			e.preventDefault();
			$('#id_customer').val(0);
			$('#search-customer-form-group').show();
			refreshMyList();
			$(this).blur();
			$(this).removeClass('change-customer').addClass('setup-customer').html('<i class="icon-arrow-right"></i>&nbsp;{l s="Выбрать"}').blur();
			$(this).closest('.selected-customer').addClass('customerCard');
		});
		
		$('#showsum').on('click',function(){
			show_filter = 1;
			rest_sum_rasp = parseFloat($('#summa_no').val());
			$('#summa_no_2_2').html(rest_sum_rasp.toFixed(2));
			$('#summa_no_2').html(rest_sum_rasp.toFixed(2));
			$('#summa_no_2_old').val(rest_sum_rasp.toFixed(2));
			paym_sum = parseFloat($('#summa_no').val());
			refreshMyList();
		});
	
		$('#showzak').on('click',function(){
			show_filter = 2;
			rest_sum_rasp = parseFloat($('#summa_no').val());
			$('#summa_no_2_2').html(rest_sum_rasp.toFixed(2));
			$('#summa_no_2').html(rest_sum_rasp.toFixed(2));
			$('#summa_no_2_old').val(rest_sum_rasp.toFixed(2));
			paym_zak = $('#cur_order').val();
			refreshMyList();
		});
	
		$('#showall').on('click',function(){
			show_filter = 0;
			rest_sum_rasp = parseFloat($('#summa_no').val());
			$('#summa_no_2_2').html(rest_sum_rasp.toFixed(2));
			$('#summa_no_2').html(rest_sum_rasp.toFixed(2));
			$('#summa_no_2_old').val(rest_sum_rasp.toFixed(2));
			refreshMyList();
		});

		$('#rasp1').on('click',function(){
			var not_by_chek = true;
			var all_sum_rasp = parseFloat($('#summa_no').val());
			rest_sum_rasp = parseFloat($('#summa_no').val());
			var tek_sum_rasp = 0;
			var tek_null = 0;
			for (var i = 1; i < iall; i++) {
				var tek_zak_sum = parseFloat($('#rspsum'+i).val());
				if (($('#rspch'+i).prop('checked')) || (not_by_chek)) {
					if (tek_zak_sum > rest_sum_rasp) {
						tek_sum_rasp = rest_sum_rasp;
					} else {
						tek_sum_rasp = tek_zak_sum;
					}
					rest_sum_rasp -= tek_sum_rasp.toFixed(2);
					$('#rsps'+i).val(tek_sum_rasp.toFixed(2));
				} else {
					$('#rsps'+i).val(tek_null.toFixed(2));
				}	
			}
//			rest_sum_rasp = rest_sum_rasp + 100;
			$('#summa_no_2_2').html(rest_sum_rasp.toFixed(2));
			$('#summa_no_2').html(rest_sum_rasp.toFixed(2));
			$('#summa_no_old').val(rest_sum_rasp.toFixed(2));

		});
	
		$('#raspotm').on('click',function(){
			var not_by_chek = false;
			var all_sum_rasp = parseFloat($('#summa_no').val());
			rest_sum_rasp = parseFloat($('#summa_no').val());
			var tek_sum_rasp = 0;
			var tek_null = 0;
			for (var i = 1; i < iall; i++) {
				var tek_zak_sum = parseFloat($('#rspsum'+i).val());
				if ($('#rspch'+i).prop('checked') || not_by_chek ) {
					if (tek_zak_sum > rest_sum_rasp) {
						tek_sum_rasp = rest_sum_rasp;
					} else {
						tek_sum_rasp = tek_zak_sum;
					}
					rest_sum_rasp -= tek_sum_rasp.toFixed(2);
					$('#rsps'+i).val(tek_sum_rasp.toFixed(2));
				} else {
					$('#rsps'+i).val(tek_null.toFixed(2));
				}	
			}
			$('#summa_no_2_2').html(rest_sum_rasp.toFixed(2));
			$('#summa_no_2').html(rest_sum_rasp.toFixed(2));
			$('#summa_no_old').val(rest_sum_rasp.toFixed(2));

		});
	
		$('#raspclear').on('click',function(){
			rest_sum_rasp = parseFloat($('#summa_no').val());
			var tek_null = 0;
			for (var i = 1; i < iall; i++) {
				$('#rsps'+i).val(tek_null.toFixed(2));
				$('#rspch'+i).removeAttr("checked");
			}
			$('#summa_no_2_2').html(rest_sum_rasp.toFixed(2));
			$('#summa_no_2').html(rest_sum_rasp.toFixed(2));
			$('#summa_no_old').val(rest_sum_rasp.toFixed(2));

		});
	
		$('#raspprim').on('click',function(){
			var all_sum_rasp = parseFloat($('#summa_no').val());
			rest_sum_rasp = parseFloat($('#summa_no').val());
			var tek_sum_rasp = 0;
			var tek_null = 0;
			var start = 0;
			for (var i = 1; i < iall; i++) {
				var tek_zak_sum = parseFloat($('#rspsum'+i).val());
				var tek_hand_sum = parseFloat($('#rsps'+i).val());
				if (tek_hand_sum > 0) {
					start = 1;
				}	
				if (start == 1) {
					if ((tek_hand_sum > 0) || (rest_sum_rasp > 0)) {
						if (tek_hand_sum > tek_zak_sum) {
							tek_hand_sum = tek_zak_sum;
						}
						if (tek_hand_sum > rest_sum_rasp) {
							tek_sum_rasp = rest_sum_rasp;
						} else {
							if (tek_hand_sum > 0) {
								tek_sum_rasp = tek_hand_sum;
							} else {
								if (rest_sum_rasp > tek_zak_sum) {
									tek_sum_rasp = tek_zak_sum;
								} else {
									tek_sum_rasp = rest_sum_rasp;
								}
							}
						}
						rest_sum_rasp -= tek_sum_rasp.toFixed(2);
						$('#rsps'+i).val(tek_sum_rasp.toFixed(2));
					} else {
						$('#rsps'+i).val(tek_null.toFixed(2));
					}	
				}	
			}
//			rest_sum_rasp = rest_sum_rasp + 100;
			$('#summa_no_2_2').html(rest_sum_rasp.toFixed(2));
			$('#summa_no_2').html(rest_sum_rasp.toFixed(2));
			$('#summa_no_old').val(rest_sum_rasp.toFixed(2));

		});

	$('#summa_all').unbind('keyup').keyup(function() {
		var pr_char = $(this).val();
		if (pr_char.charAt(pr_char.length-1) == '.') {
			return true;
		}
		if (pr_char.charAt(pr_char.length-1) == ',') {
			$($(this)).val(parseInt($(this).val())+'.');
			return true;
		}
		var sum_yes = parseFloat($('#summa_yes').val());
		var new_no = parseFloat($(this).val()) - sum_yes;
		$('#summa_no').val(new_no.toFixed(2));
		$('#summa_no_2').html(new_no.toFixed(2));
		$('#summa_no_2_2').html(new_no.toFixed(2));
	});

		function preparePaymentArray(){
			var teks = 0;
			for (var i = 1; i < iall; i++) {
				var sumz = parseFloat($('#rspsum'+i).val());
				var sumop = parseFloat($('#rsps'+i).val());
				teks += sumop;
				if ((sumop > sumz) && (sumop > 0)) {
					return 2;
				}	
			}
			var rest_sum = parseFloat($('#summa_no').val());
			if (rest_sum < teks) return 1;
			var idmp = parseInt($('#id_my_payments').val());
			var mps = $('#id_my_payments_spos option:selected').text();
			var mpk = $('#id_my_payments_kas option:selected').text();
			var tek_null = 0;
			paymentsArray.length = 0;
			for (var i = 1; i < iall; i++) {
				var tek_hand_sum = parseFloat($('#rsps'+i).val());
				if (tek_hand_sum > 0){
					var oid = $('#tdi'+i).text();
					var orfr = $('#tdr'+i).text();
					paymentsArray[tek_null] = [idmp,mps.trim(),orfr,tek_hand_sum,mpk.trim(),oid];
					tek_null++;
				}
			}
//			jAlert(paymentsArray);
			return 0;
		}
	
	
	
	// первая обработка load (init)
	my_init();

	});
	function refreshMyList()
	{
					var html_carts = '';
					var html_orders = '';
					var delta = 0;
					var i = 1;
					// текущий покупатель 
					var tek_customer = parseInt($('#id_customer').val());
					var tek_order = $('#cur_order').val();
					var issetorder = false;
					var setordersum = 0;
					var tek_sum_no = parseFloat($('#summa_all').val());
					$.each(my_payms, function() {
						html_carts += '<tr>';
						html_carts += '<td><input type="hidden" id="idmps'+i+'" value="'+this.id_order_payment+'"></td>';
						html_carts += '<td id="tdo'+i+'" class="hidden">'+this.id_order+'</td>';
						html_carts += '<td>'+this.order_number+'</td>';
						html_carts += '<td>'+this.id_customer+'</td>';
						html_carts += '<td>'+parseFloat(this.total_paid).toFixed(2)+'</td>';
						html_carts += '<td id="tdam'+i+'">'+parseFloat(this.amount).toFixed(2)+'</td>';
						html_carts += '<td><button type="button" id="mudal" onclick="deleteMyP('+i+')">Удалить</button></td>';
						html_carts += '</tr>';
						i++;
					});
					i = 1;
					$.each(my_orders, function() {
						if ((tek_customer == 0) || ((tek_customer > 0) && ((tek_customer == this.id_customer) || (tek_order == this.order_number))))  {
							delta = paym_sum - this.creditdig;
							if ((show_filter == 0) || ((show_filter == 1) && (Math.abs(delta) < 10)) || ((show_filter == 2) && (	paym_zak == this.order_number))) {
								html_orders += '<tr>';
								html_orders += '<td id="tdi'+i+'">'+this.id_order+'</td>';
								html_orders += '<td>'+this.date_add+'</td>';
								if (paym_zak == this.order_number) {
									issetorder = true;
									setordersum = parseFloat(this.credit);
									tek_zak_sum_rasp = parseFloat(this.credit);
									tek_zak_sum_rasp_id = i;
									tek_zak_sum_rasp_id_cust = parseInt(this.id_customer);
									html_orders += '<td id="tdr'+i+'" style="background: #9999ff">'+this.order_number+'</td>';
								} else {
									html_orders += '<td id="tdr'+i+'">'+this.order_number+'</td>';
								}	
								html_orders += '<td>'+this.id_customer+'</span></td>';
								html_orders += '<td>'+parseFloat(this.total_paid).toFixed(2)+'</td>';
								html_orders += '<td>'+parseFloat(this.total_paid_real).toFixed(2)+'</td>';
								if (Math.abs(delta) < 10) {
									html_orders += '<td style="background: #2299ff">'+parseFloat(this.credit).toFixed(2)+'</td>';
								} else {
									html_orders += '<td>'+parseFloat(this.credit).toFixed(2)+'</td>';
								}	
								html_orders += '<td><input type="hidden" id="rspsum'+i+'" value="'+this.creditdig+'"></td>';
								html_orders += '<td><input type="checkbox" id="rspch'+i+'"></td>';
								html_orders += '<td><input type="text" id="rsps'+i+'" value="0.00"></td>';
								html_orders += '</tr>';
								i++;
							} 
							iall = i;
						}	
					});
///										jAlert('Работает');

					if ((rest_sum_rasp > 0) || (rest_sum_rasp + tek_sum_no == 0)) {
						$('#showsum').removeClass('hide');
						$('#showzak').removeClass('hide');
						$('#showall').removeClass('hide');
						$('#rasp1').removeClass('hide');
						$('#raspotm').removeClass('hide');
						$('#raspclear').removeClass('hide');
						$('#raspprim').removeClass('hide');
						$('#nonOrderedCarts table tbody').html(html_orders);
					} else {
						$('#showsum').addClass('hide');
						$('#showzak').addClass('hide');
						$('#showall').addClass('hide');
						$('#rasp1').addClass('hide');
						$('#raspotm').addClass('hide');
						$('#raspclear').addClass('hide');
						$('#raspprim').addClass('hide');
						$('#nonOrderedCarts table tbody').html('');
						$('#hrefrasp').click();
					}
					$('#lastOrders table tbody').html(html_carts);
					if (tek_order.length > 0) {
						if (issetorder == true) {
							$('#this_order_sum').html('Сумма к оплате по данному заказу : '+setordersum+' руб.');
							if ((setordersum > 0) && (tek_sum_no == 0)) {
								$('#submit_this_order_sum').removeClass('hide');
							} else {
								$('#submit_this_order_sum').addClass('hide');
							}
						} else {
							$('#this_order_sum').html('Такого заказа нет!');
							$('#submit_this_order_sum').addClass('hide');
						}
						$('#div_this_order').removeClass('hide');
					}	
	}
		function validateNonEmpty(inputField) {
			if (parseFloat($('#summa_all').val()) < parseFloat($('#summa_yes').val())) {
				jAlert('Сумма не может быть меньше чем уже распределенная по заказам!');
//				$('#summa_yes').style.backgroundColor = '#FF0000';
				$('#summa_all').focus();
				return false;
			} else {
				return true;
			}	
		}

	function deleteMyP(e)
	{
	if (!confirm('Вы уверены?'))
	return false;
	$.ajax({
			type:"POST",
			url: admin_my_payments_tab_link,
			async: true,
			dataType: "json",
			data : {
				ajax: "1",
				token: "{getAdminToken tab='AdminMy_Payments'}",
				action: "DeleteRaspPayment",
				id_payment: parseInt($('#idmps'+e).val()),
				paymAmount: $('#tdam'+e).html(),
				nomOrder: $('#tdo'+e).html(),
				id_my_payments: parseInt($('#id_my_payments').val()),
				tek_order: $('#cur_order').val(),
				summa_all: parseFloat($('#summa_all').val()),
			},
			success : function(res)
			{
				if(res.found)
				{
//					jAlert('вернолось');
					my_orders = res.orders;
					my_payms = res.payments;
					paym_zak = $('#cur_order').val();
					paym_zak = paym_zak.trim();
					paym_sum = res.sumno;
					$('#id_my_payments').val(res.newpid);
					$('#summa_yes').val(res.sumyes.toFixed(2));
					$('#summa_no').val(res.sumno.toFixed(2));
					$('#summa_no_2').html(res.sumno.toFixed(2));
					$('#summa_no_2_2').html(res.sumno.toFixed(2));
					refreshMyList();
					var tek_vid = parseInt($('#id_my_payments_vid option:selected').val());
					if (tek_vid < 3) $('#to_rasp').removeClass('hide');
					$('#submitSavePayment').click();
				}
			},
			error : function(XMLHttpRequest, textStatus, errorThrown) {
				jAlert("Не возможно сохранить.\n" + XMLHttpRequest.responseText);
			}
		});
	}
		

	function resetBind()
	{
		$('.fancybox').fancybox({
			'type': 'iframe',
			'width': '90%',
			'height': '90%',
		});

		$('.fancybox_customer').fancybox({
			'type': 'iframe',
			'width': '90%',
			'height': '90%',
			'afterClose' : function () {
				searchCustomers("searchCustomers");
			}
		});
		/*$("#new_address").fancybox({
			onClosed: useCart(id_cart)
		});*/
	}

	function add_cart_rule(id_cart_rule)
	{
		$.ajax({
			type:"POST",
			url: "{$link->getAdminLink('AdminCarts')|addslashes}",
			async: true,
			dataType: "json",
			data : {
				ajax: "1",
				token: "{getAdminToken tab='AdminCarts'}",
				tab: "AdminCarts",
				action: "addVoucher",
				id_cart_rule: id_cart_rule,
				id_cart: id_cart,
				id_customer: id_customer
				},
			success : function(res)
			{
				displaySummary(res);
				$('#voucher').val('');
				var errors = '';
				if (res.errors.length > 0)
				{
					$.each(res.errors, function() {
						errors += this+'<br/>';
					});
					$('#vouchers_err').html(errors).show();
				}
				else
					$('#vouchers_err').hide();
			}
		});
	}

	function updateProductPrice(id_product, id_product_attribute, new_price)
	{
		$.ajax({
			type:"POST",
			url: "{$link->getAdminLink('AdminCarts')|addslashes}",
			async: true,
			dataType: "json",
			data : {
				ajax: "1",
				token: "{getAdminToken tab='AdminCarts'}",
				tab: "AdminCarts",
				action: "updateProductPrice",
				id_cart: id_cart,
				id_product: id_product,
				id_product_attribute: id_product_attribute,
				id_customer: id_customer,
				price: new Number(new_price.replace(",",".")).toFixed(4).toString()
				},
			success : function(res)
			{
				displaySummary(res);
			}
		});
	}

	function displayQtyInStock(id)
	{
		var id_product = $('#id_product').val();
		if ($('#ipa_' + id_product + ' option').length)
			var id_product_attribute = $('#ipa_' + id_product).val();
		else
			var id_product_attribute = 0;

		$('#qty_in_stock').html(stock[id_product][id_product_attribute]);
	}

	function duplicateOrder(id_order)
	{
		$.ajax({
			type:"POST",
			url: "{$link->getAdminLink('AdminCarts')|addslashes}",
			async: true,
			dataType: "json",
			data : {
				ajax: "1",
				token: "{getAdminToken tab='AdminCarts'}",
				tab: "AdminCarts",
				action: "duplicateOrder",
				id_order: id_order,
				id_customer: id_customer
				},
			success : function(res)
			{
				id_cart = res.cart.id;
				$('#id_cart').val(id_cart);
				displaySummary(res);
			}
		});
	}

	function useCart(id_new_cart)
	{
		id_cart = id_new_cart;
		$('#id_cart').val(id_cart);
		$('#id_cart').val(id_cart);
		$.ajax({
			type:"POST",
			url: "{$link->getAdminLink('AdminCarts')|addslashes}",
			async: false,
			dataType: "json",
			data : {
				ajax: "1",
				token: "{getAdminToken tab='AdminCarts'}",
				tab: "AdminCarts",
				action: "getSummary",
				id_cart: id_cart,
				id_customer: id_customer
				},
			success : function(res)
			{
				displaySummary(res);
			}
		});
	}

	function getSummary()
	{
		useCart(id_cart);
	}

	function deleteVoucher(id_cart_rule)
	{
		$.ajax({
			type:"POST",
			url: "{$link->getAdminLink('AdminCarts')|addslashes}",
			async: true,
			dataType: "json",
			data : {
				ajax: "1",
				token: "{getAdminToken tab='AdminCarts'}",
				tab: "AdminCarts",
				action: "deleteVoucher",
				id_cart_rule: id_cart_rule,
				id_cart: id_cart,
				id_customer: id_customer
				},
			success : function(res)
			{
				displaySummary(res);
			}
		});
	}

	function deleteProduct(id_product, id_product_attribute, id_customization)
	{
		$.ajax({
			type:"POST",
			url: "{$link->getAdminLink('AdminCarts')|addslashes}",
			async: true,
			dataType: "json",
			data : {
				ajax: "1",
				token: "{getAdminToken tab='AdminCarts'}",
				tab: "AdminCarts",
				action: "deleteProduct",
				id_product: id_product,
				id_product_attribute: id_product_attribute,
				id_customization: id_customization,
				id_cart: id_cart,
				id_customer: id_customer
				},
			success : function(res)
			{
				displaySummary(res);
			}
		});
	}

	function searchCustomers(func_search)
	{
		$.ajax({
			type:"POST",
			url : "{$link->getAdminLink('AdminCustomers')}",
			async: false,
			dataType: "json",
			data : {
				ajax: "1",
				tab: "AdminCustomers",
				action: func_search ,
				customer_search: $('#customer').val()},
			success : function(res)
			{
				if(res.found)
				{
					var html = '';
					$.each(res.customers, function() {
						html += '<div class="customerCard col-lg-4">';
						html += '<div class="panel">';
						html += '<div class="panel-heading">'+this.firstname+' '+this.lastname;
						html += '<span class="pull-right">'+this.id_customer+'</span></div>';
						html += '<span>'+this.email+'</span><br/>';
						html += '<span class="text-muted">'+((this.birthday != '0000-00-00') ? this.birthday : '')+'</span><br/>';
						html += '<div class="panel-footer">';
						html += '<a href="{$link->getAdminLink('AdminCustomers')}&id_customer='+this.id_customer+'&viewcustomer&liteDisplaying=1" class="btn btn-default fancybox"><i class="icon-search"></i> {l s='Details'}</a>';
						html += '<button type="button" data-customer="'+this.id_customer+'" class="setup-customer btn btn-default pull-right"><i class="icon-arrow-right"></i> {l s='Выбрать'}</button>';
						html += '</div>';
						html += '</div>';
						html += '</div>';

					});
				}
				else
					html = '<div class="alert alert-warning">{l s='No customers found'}</div>';
				$('#customers').html(html);
				resetBind();
			}
		});
	}

	// первая обработка load (init)
	function my_init()
	{
		// если tek_new=0 то новый платеж
		var tek_new = parseInt($('#id_my_payments').val());
		// приход / расход
		var tek_tip = parseInt($('#id_my_payments_tip').val());
		// вид поступления или расхода
		var tek_vid = parseInt($('#id_my_payments_vid option:selected').val());
		// текущий покупатель 
		var tek_customer = parseInt($('#id_customer').val());
		// текущий заказ 
		var tek_order = $('#cur_order').val();
		rest_sum_rasp = parseFloat($('#summa_no').val());
		paym_sum = parseFloat($('#summa_no').val());
		paym_zak = $('#cur_order').val();
		
		if ((tek_tip == 1) && (tek_new > 0)) {
			my_search(tek_new, tek_order);
		}	
		if (tek_customer == 0) {
			
		} else {
			$('#customer').val(tek_customer);
			searchCustomers("searchCustomersById");
			$('#customer').val('');
		// нажатие на кнопку Choose
			$('#customer_part').find('.setup-customer').trigger( "click" );
		}
	}

	function setupCustomer(idCustomer)
	{
		$('#carts').show();
//		$('#products_part').show();
//		$('#vouchers_part').show();
//		$('#address_part').show();
//		$('#carriers_part').show();
//		$('#summary_part').show();
		var address_link = $('#new_address').attr('href');
		id_customer = idCustomer;
		id_cart = 0;
		$('#new_address').attr('href', address_link.replace(/id_customer=[0-9]+/, 'id_customer='+id_customer));
		$.ajax({
			type:"POST",
			url : "{$link->getAdminLink('AdminCarts')|addslashes}",
			async: false,
			dataType: "json",
			data : {
				ajax: "1",
				token: "{getAdminToken tab='AdminCarts'}",
				tab: "AdminCarts",
				action: "searchCarts",
				id_customer: id_customer,
				id_cart: id_cart
			},
			success : function(res)
			{
				if(res.found)
				{
					my_orders = res.orders;
					my_payms = res.payments;
					refreshMyList();
				}
			}
		});
	}

	function my_search(idPayment, nomOrder)
	{
//		$('#carts').show();
//		var address_link = $('#new_address').attr('href');
//		id_customer = idCustomer;
//		id_cart = 0;
//		$('#new_address').attr('href', address_link.replace(/id_customer=[0-9]+/, 'id_customer='+id_customer));
//		jAlert('my_search');
		$.ajax({
			type:"POST",
			url : "{$link->getAdminLink('AdminMy_payments')|addslashes}",
			async: false,
			dataType: "json",
			data : {
				ajax: "1",
				token: "{getAdminToken tab='AdminMy_Payments'}",
				tab: "AdminMy_Payments",
				action: "findAllNotAmountOrders",
				id_payment: idPayment,
				nomOrder: nomOrder,
			},
			success : function(res)
			{
				
				if(res.found)
				{
//					jAlert('my_search - found');
				
					my_orders = res.orders;
					my_payms = res.payments;
					refreshMyList();
				}
//				displaySummary(res);
//				resetBind();
			}
		});
		// вид поступления или расхода
		var tek_vid = parseInt($('#id_my_payments_vid option:selected').val());
		if (tek_vid < 3) $('#to_rasp').removeClass('hide');
	}


	
	function updateDeliveryOptionList(delivery_option_list)
	{
		var html = '';
		if (delivery_option_list.length > 0)
		{
			$.each(delivery_option_list, function() {
				html += '<option value="'+this.key+'" '+(($('#delivery_option').val() == this.key) ? 'selected="selected"' : '')+'>'+this.name+'</option>';
			});
			$('#carrier_form').show();
			$('#delivery_option').html(html);
			$('#carriers_err').hide();
			$("button[name=\"submitAddOrder\"]").removeAttr("disabled");
		}
		else
		{
			$('#carrier_form').hide();
			$('#carriers_err').show().html('{l s='No carrier can be applied to this order'}');
			$("button[name=\"submitAddOrder\"]").attr("disabled", "disabled");
		}
	}

	function searchProducts()
	{
//		$('#products_part').show();
		$.ajax({
			type:"POST",
			url: "{$link->getAdminLink('AdminOrders')|addslashes}",
			async: true,
			dataType: "json",
			data : {
				ajax: "1",
				token: "{$token|escape:'html':'UTF-8'}",
				tab: "AdminOrders",
				action: "searchProducts",
				id_cart: id_cart,
				id_customer: id_customer,
				id_currency: id_currency,
				product_search: $('#product').val()},
			success : function(res)
			{
				var products_found = '';
				var attributes_html = '';
				var customization_html = '';
				stock = {};

				if(res.found)
				{
					if (!customization_errors)
						$('#products_err').addClass('hide');
					else
						customization_errors = false;
					$('#products_found').show();
					products_found += '<label class="control-label col-lg-3">{l s='Product'}</label><div class="col-lg-6"><select id="id_product" onclick="display_product_attributes();display_product_customizations();"></div>';
					attributes_html += '<label class="control-label col-lg-3">{l s='Combination'}</label><div class="col-lg-6">';
					$.each(res.products, function() {
						products_found += '<option '+(this.combinations.length > 0 ? 'rel="'+this.qty_in_stock+'"' : '')+' value="'+this.id_product+'">'+this.name+(this.combinations.length == 0 ? ' - '+this.formatted_price : '')+'</option>';
						attributes_html += '<select class="id_product_attribute" id="ipa_'+this.id_product+'" style="display:none;">';
						var id_product = this.id_product;
						stock[id_product] = new Array();
						if (this.customizable == '1' || this.customizable == '2')
						{
							customization_html += '<div class="bootstrap"><div class="panel"><div class="panel-heading">{l s='Customization'}</div><form id="customization_'+id_product+'" class="id_customization" method="post" enctype="multipart/form-data" action="'+admin_cart_link+'" style="display:none;">';
							customization_html += '<input type="hidden" name="id_product" value="'+id_product+'" />';
							customization_html += '<input type="hidden" name="id_cart" value="'+id_cart+'" />';
							customization_html += '<input type="hidden" name="action" value="updateCustomizationFields" />';
							customization_html += '<input type="hidden" name="id_customer" value="'+id_customer+'" />';
							customization_html += '<input type="hidden" name="ajax" value="1" />';
							$.each(this.customization_fields, function() {
								class_customization_field = "";
								if (this.required == 1){ class_customization_field = 'required' };
								customization_html += '<div class="form-group"><label class="control-label col-lg-3 ' + class_customization_field + '" for="customization_'+id_product+'_'+this.id_customization_field+'">';
								customization_html += this.name+'</label><div class="col-lg-9">';
								if (this.type == 0)
									customization_html += '<input class="form-control customization_field" type="file" name="customization_'+id_product+'_'+this.id_customization_field+'" id="customization_'+id_product+'_'+this.id_customization_field+'">';
								else if (this.type == 1)
									customization_html += '<input class="form-control customization_field" type="text" name="customization_'+id_product+'_'+this.id_customization_field+'" id="customization_'+id_product+'_'+this.id_customization_field+'">';
								customization_html += '</div></div>';
							});
							customization_html += '</form></div></div>';
						}

						$.each(this.combinations, function() {
							attributes_html += '<option rel="'+this.qty_in_stock+'" '+(this.default_on == 1 ? 'selected="selected"' : '')+' value="'+this.id_product_attribute+'">'+this.attributes+' - '+this.formatted_price+'</option>';
							stock[id_product][this.id_product_attribute] = this.qty_in_stock;
						});

						stock[this.id_product][0] = this.stock[0];
						attributes_html += '</select>';
					});
					products_found += '</select></div>';
					$('#products_found #product_list').html(products_found);
					$('#products_found #attributes_list').html(attributes_html);
					$('link[rel="stylesheet"]').each(function (i, element) {
						sheet = $(element).clone();
						$('#products_found #customization_list').contents().find('head').append(sheet);
					});
					$('#products_found #customization_list').contents().find('body').html(customization_html);
					display_product_attributes();
					display_product_customizations();
					$('#id_product').change();
				}
				else
				{
					$('#products_found').hide();
					$('#products_err').html('{l s='No products found'}');
					$('#products_err').removeClass('hide');
				}
				resetBind();
			}
		});
	}

	function display_product_customizations()
	{
		if ($('#products_found #customization_list').contents().find('#customization_'+$('#id_product option:selected').val()).children().length === 0)
			$('#customization_list').hide();
		else
		{
			$('#customization_list').show();
			$('#products_found #customization_list').contents().find('.id_customization').hide();
			$('#products_found #customization_list').contents().find('#customization_'+$('#id_product option:selected').val()).show();
//			$('#products_found #customization_list').css('height',$('#products_found #customization_list').contents().find('#customization_'+$('#id_product option:selected').val()).height()+95+'px');
		}
	}

	function display_product_attributes()
	{
		if ($('#ipa_'+$('#id_product option:selected').val()+' option').length === 0)
			$('#attributes_list').hide();
		else
		{
			$('#attributes_list').show();
			$('.id_product_attribute').hide();
			$('#ipa_'+$('#id_product option:selected').val()).show();
		}
	}

	function updateCartProducts(products, gifts, id_address_delivery)
	{
		var cart_content = '';
		$.each(products, function() {
			var id_product = Number(this.id_product);
			var id_product_attribute = Number(this.id_product_attribute);
			cart_quantity[Number(this.id_product)+'_'+Number(this.id_product_attribute)+'_'+Number(this.id_customization)] = this.cart_quantity;
			cart_content += '<tr><td><img src="'+this.image_link+'" title="'+this.name+'" /></td><td>'+this.name+'<br />'+this.attributes_small+'</td><td>'+this.reference+'</td><td><input type="text" rel="'+this.id_product+'_'+this.id_product_attribute+'" class="product_unit_price" value="' + this.numeric_price + '" /></td><td>';
			cart_content += (!this.id_customization ? '<div class="input-group fixed-width-md"><div class="input-group-btn"><a href="#" class="btn btn-default increaseqty_product" rel="'+this.id_product+'_'+this.id_product_attribute+'_'+(this.id_customization ? this.id_customization : 0)+'" ><i class="icon-caret-up"></i></a><a href="#" class="btn btn-default decreaseqty_product" rel="'+this.id_product+'_'+this.id_product_attribute+'_'+(this.id_customization ? this.id_customization : 0)+'"><i class="icon-caret-down"></i></a></div>' : '');
			cart_content += (!this.id_customization ? '<input type="text" rel="'+this.id_product+'_'+this.id_product_attribute+'_'+(this.id_customization ? this.id_customization : 0)+'" class="cart_quantity" value="'+this.cart_quantity+'" />' : '');
			cart_content += (!this.id_customization ? '<div class="input-group-btn"><a href="#" class="delete_product btn btn-default" rel="delete_'+this.id_product+'_'+this.id_product_attribute+'_'+(this.id_customization ? this.id_customization : 0)+'" ><i class="icon-remove text-danger"></i></a></div></div>' : '');
			cart_content += '</td><td>' + formatCurrency(this.numeric_total, currency_format, currency_sign, currency_blank) + '</td></tr>';

			if (this.id_customization && this.id_customization != 0)
			{
				$.each(this.customized_datas[this.id_product][this.id_product_attribute][id_address_delivery], function() {
					var customized_desc = '';
					if (typeof this.datas[1] !== 'undefined' && this.datas[1].length)
					{
						$.each(this.datas[1],function() {
							customized_desc += this.name + ': ' + this.value + '<br />';
							id_customization = this.id_customization;
						});
					}
					if (typeof this.datas[0] !== 'undefined' && this.datas[0].length)
					{
						$.each(this.datas[0],function() {
							customized_desc += this.name + ': <img src="' + pic_dir + this.value + '_small" /><br />';
							id_customization = this.id_customization;
						});
					}
					cart_content += '<tr><td></td><td>'+customized_desc+'</td><td></td><td></td><td>';
					cart_content += '<div class="input-group fixed-width-md"><div class="input-group-btn"><a href="#" class="btn btn-default increaseqty_product" rel="'+id_product+'_'+id_product_attribute+'_'+id_customization+'" ><i class="icon-caret-up"></i></a><a href="#" class="btn btn-default decreaseqty_product" rel="'+id_product+'_'+id_product_attribute+'_'+id_customization+'"><i class="icon-caret-down"></i></a></div>';
					cart_content += '<input type="text" rel="'+id_product+'_'+id_product_attribute+'_'+id_customization +'" class="cart_quantity" value="'+this.quantity+'" />';
					cart_content += '<div class="input-group-btn"><a href="#" class="delete_product btn btn-default" rel="delete_'+id_product+'_'+id_product_attribute+'_'+id_customization+'" ><i class="icon-remove"></i></a></div></div>';
					cart_content += '</td><td></td></tr>';
				});
			}
		});

		$.each(gifts, function() {
			cart_content += '<tr><td><img src="'+this.image_link+'" title="'+this.name+'" /></td><td>'+this.name+'<br />'+this.attributes_small+'</td><td>'+this.reference+'</td>';
			cart_content += '<td>{l s='Gift'}</td><td>'+this.cart_quantity+'</td><td>{l s='Gift'}</td></tr>';
		});
		$('#customer_cart tbody').html(cart_content);
	}

	function updateCartVouchers(vouchers)
	{
		var vouchers_html = '';
		if (typeof(vouchers) == 'object')
			$.each(vouchers, function(){
				if (parseFloat(this.value_real) === 0 && parseInt(this.free_shipping) === 1)
					var value = '{l s='Free shipping'}';
				else
					var value = this.value_real;

				vouchers_html += '<tr><td>'+this.name+'</td><td>'+this.description+'</td><td>'+value+'</td><td class="text-right"><a href="#" class="btn btn-default delete_discount" rel="'+this.id_discount+'"><i class="icon-remove text-danger"></i>&nbsp;{l s='Delete'}</a></td></tr>';
			});
		$('#voucher_list tbody').html($.trim(vouchers_html));
		if ($('#voucher_list tbody').html().length == 0)
			$('#voucher_list').hide();
		else
			$('#voucher_list').show();
	}

	function updateCartPaymentList(payment_list)
	{
		$('#payment_list').html(payment_list);
	}

	function fixPriceFormat(price)
	{
		if(price.indexOf(',') > 0 && price.indexOf('.') > 0) // if contains , and .
			if(price.indexOf(',') < price.indexOf('.')) // if , is before .
				price = price.replace(',','');  // remove ,
		price = price.replace(' ',''); // remove any spaces
		price = price.replace(',','.'); // remove , if price did not cotain both , and .
		return price;
	}

	function displaySummary(jsonSummary)
	{
		currency_format = jsonSummary.currency.format;
		currency_sign = jsonSummary.currency.sign;
		currency_blank = jsonSummary.currency.blank;
		priceDisplayPrecision = jsonSummary.currency.decimals ? 2 : 0;

		updateCartProducts(jsonSummary.summary.products, jsonSummary.summary.gift_products, jsonSummary.cart.id_address_delivery);
		updateCartVouchers(jsonSummary.summary.discounts);
		updateAddressesList(jsonSummary.addresses, jsonSummary.cart.id_address_delivery, jsonSummary.cart.id_address_invoice);

		if (!jsonSummary.summary.products.length || !jsonSummary.addresses.length || !jsonSummary.delivery_option_list)
			$('#carriers_part,#summary_part').hide();
		else
			$('#carriers_part,#summary_part').show();

		updateDeliveryOptionList(jsonSummary.delivery_option_list);

		if (jsonSummary.cart.gift == 1)
			$('#order_gift').attr('checked', true);
		else
			$('#carrier_gift').removeAttr('checked');
		if (jsonSummary.cart.recyclable == 1)
			$('#carrier_recycled_package').attr('checked', true);
		else
			$('#carrier_recycled_package').removeAttr('checked');
		if (jsonSummary.free_shipping == 1)
			$('#free_shipping').attr('checked', true);
		else
			$('#free_shipping_off').attr('checked', true);

		$('#gift_message').html(jsonSummary.cart.gift_message);
		if (!changed_shipping_price)
			$('#shipping_price').html('<b>' + formatCurrency(parseFloat(jsonSummary.summary.total_shipping), currency_format, currency_sign, currency_blank) + '</b>');
		shipping_price_selected_carrier = jsonSummary.summary.total_shipping;

		$('#total_vouchers').html(formatCurrency(parseFloat(jsonSummary.summary.total_discounts_tax_exc), currency_format, currency_sign, currency_blank));
		$('#total_shipping').html(formatCurrency(parseFloat(jsonSummary.summary.total_shipping_tax_exc), currency_format, currency_sign, currency_blank));
		$('#total_taxes').html(formatCurrency(parseFloat(jsonSummary.summary.total_tax), currency_format, currency_sign, currency_blank));
		$('#total_without_taxes').html(formatCurrency(parseFloat(jsonSummary.summary.total_price_without_tax), currency_format, currency_sign, currency_blank));
		$('#total_with_taxes').html(formatCurrency(parseFloat(jsonSummary.summary.total_price), currency_format, currency_sign, currency_blank));
		$('#total_products').html(formatCurrency(parseFloat(jsonSummary.summary.total_products), currency_format, currency_sign, currency_blank));
		id_currency = jsonSummary.cart.id_currency;
		$('#id_currency option').removeAttr('selected');
		$('#id_currency option[value="'+id_currency+'"]').attr('selected', true);
		id_lang = jsonSummary.cart.id_lang;
		$('#id_lang option').removeAttr('selected');
		$('#id_lang option[value="'+id_lang+'"]').attr('selected', true);
		$('#send_email_to_customer').attr('rel', jsonSummary.link_order);
		$('#go_order_process').attr('href', jsonSummary.link_order);
		$('#order_message').val(jsonSummary.order_message);
		resetBind();
	}

	function updateQty(id_product, id_product_attribute, id_customization, qty)
	{
		$.ajax({
			type:"POST",
			url: "{$link->getAdminLink('AdminMy_Payments')|addslashes}",
			async: true,
			dataType: "json",
			data : {
				ajax: "1",
				action: "updateQty",
				id_product: id_product,
				id_product_attribute: id_product_attribute,
				id_customization: id_customization,
				qty: qty,
				id_customer: id_customer,
				id_cart: id_cart,
			},
			success : function(res)
			{
				displaySummary(res);
				var errors = '';
				if (res.errors.length)
				{
					$.each(res.errors, function() {
						errors += this + '<br />';
					});
					$('#products_err').removeClass('hide');
				}
				else
					$('#products_err').addClass('hide');
				$('#products_err').html(errors);
			}
		});
	}

	function resetShippingPrice()
	{
		$('#shipping_price').val(shipping_price_selected_carrier);
		changed_shipping_price = false;
	}

	function addProduct()
	{
		var id_product = $('#id_product option:selected').val();
		$('#products_found #customization_list').contents().find('#customization_'+id_product).submit();

		addProductProcess();
	}

	//Called from form_customization_feedback.tpl
	function customizationProductListener()
	{
		//refresh form customization
		searchProducts();

	}

	function addProductProcess()
	{
		if (customization_errors) {
			$('#products_err').removeClass('hide');
		} else {
			$('#products_err').addClass('hide');
			updateQty($('#id_product').val(), $('#ipa_'+$('#id_product').val()+' option:selected').val(), 0, $('#qty').val());
		}
	}

	function updateCurrency()
	{
		$.ajax({
			type:"POST",
			url: "{$link->getAdminLink('AdminCarts')|addslashes}",
			async: true,
			dataType: "json",
			data : {
				ajax: "1",
				token: "{getAdminToken tab='AdminCarts'}",
				tab: "AdminCarts",
				action: "updateCurrency",
				id_currency: $('#id_currency option:selected').val(),
				id_customer: id_customer,
				id_cart: id_cart
				},
			success : function(res)
			{
					displaySummary(res);
			}
		});
	}

	function updateLang()
	{
		$.ajax({
			type:"POST",
			url: "{$link->getAdminLink('AdminCarts')|addslashes}",
			async: true,
			dataType: "json",
			data : {
				ajax: "1",
				token: "{getAdminToken tab='AdminCarts'}",
				tab: "admincarts",
				action: "updateLang",
				id_lang: $('#id_lang option:selected').val(),
				id_customer: id_customer,
				id_cart: id_cart
				},
			success : function(res)
			{
					displaySummary(res);
			}
		});
	}

	function updateDeliveryOption()
	{
		$.ajax({
			type:"POST",
			url: "{$link->getAdminLink('AdminCarts')|addslashes}",
			async: true,
			dataType: "json",
			data : {
				ajax: "1",
				token: "{getAdminToken tab='AdminCarts'}",
				tab: "AdminCarts",
				action: "updateDeliveryOption",
				delivery_option: $('#delivery_option option:selected').val(),
				gift: $('#order_gift').is(':checked')?1:0,
				gift_message: $('#gift_message').val(),
				recyclable: $('#carrier_recycled_package').is(':checked')?1:0,
				id_customer: id_customer,
				id_cart: id_cart
				},
			success : function(res)
			{
				displaySummary(res);
			}
		});
	}

	function sendMailToCustomer()
	{
		$.ajax({
			type:"POST",
			url: "{$link->getAdminLink('AdminOrders')|addslashes}",
			async: true,
			dataType: "json",
			data : {
				ajax: "1",
				token: "{getAdminToken tab='AdminOrders'}",
				tab: "AdminOrders",
				action: "sendMailValidateOrder",
				id_customer: id_customer,
				id_cart: id_cart
				},
			success : function(res)
			{
				if (res.errors)
					$('#send_email_feedback').removeClass('hide').removeClass('alert-success').addClass('alert-danger');
				else
					$('#send_email_feedback').removeClass('hide').removeClass('alert-danger').addClass('alert-success');
				$('#send_email_feedback').html(res.result);
			}
		});
	}

	function updateAddressesList(addresses, id_address_delivery, id_address_invoice)
	{
		var addresses_delivery_options = '';
		var addresses_invoice_options = '';
		var address_invoice_detail = '';
		var address_delivery_detail = '';
		var delivery_address_edit_link = '';
		var invoice_address_edit_link = '';

		$.each(addresses, function() {
			if (this.id_address == id_address_invoice)
			{
				address_invoice_detail = this.formated_address;
				invoice_address_edit_link = "{$link->getAdminLink('AdminAddresses')}&id_address="+this.id_address+"&updateaddress&realedit=1&liteDisplaying=1&submitFormAjax=1#";
			}

			if(this.id_address == id_address_delivery)
			{
				address_delivery_detail = this.formated_address;
				delivery_address_edit_link = "{$link->getAdminLink('AdminAddresses')}&id_address="+this.id_address+"&updateaddress&realedit=1&liteDisplaying=1&submitFormAjax=1#";
			}

			addresses_delivery_options += '<option value="'+this.id_address+'" '+(this.id_address == id_address_delivery ? 'selected="selected"' : '')+'>'+this.alias+'</option>';
			addresses_invoice_options += '<option value="'+this.id_address+'" '+(this.id_address == id_address_invoice ? 'selected="selected"' : '')+'>'+this.alias+'</option>';
		});
		if (addresses.length == 0)
		{
			$('#addresses_err').show().html('{l s='You must add at least one address to process the order.'}');
			$('#address_delivery, #address_invoice').hide();
		}
		else
		{
			$('#addresses_err').hide();
			$('#address_delivery, #address_invoice').show();
		}

		$('#id_address_delivery').html(addresses_delivery_options);
		$('#id_address_invoice').html(addresses_invoice_options);
		$('#address_delivery_detail').html(address_delivery_detail);
		$('#address_invoice_detail').html(address_invoice_detail);
		$('#edit_delivery_address').attr('href', delivery_address_edit_link);
		$('#edit_invoice_address').attr('href', invoice_address_edit_link);
	}

	function updateAddresses()
	{
		$.ajax({
			type:"POST",
			url: "{$link->getAdminLink('AdminCarts')|addslashes}",
			async: true,
			dataType: "json",
			data : {
				ajax: "1",
				token: "{getAdminToken tab='AdminCarts'}",
				tab: "AdminCarts",
				action: "updateAddresses",
				id_customer: id_customer,
				id_cart: id_cart,
				id_address_delivery: $('#id_address_delivery option:selected').val(),
				id_address_invoice: $('#id_address_invoice option:selected').val()
				},
			success : function(res)
			{
				updateDeliveryOption();
			}
		});
	}
</script>
<div class="leadin">{block name="leadin"}{/block}</div>
	<div class="panel form-horizontal" id="customer_part">
		<div class="panel-heading">
			<i class="icon-user"></i>
			{if ($my_tip_amount == 1)}
				{l s='Приход'}
			{else}	
				{l s='Расход'}
			{/if}
		</div>
  
		<div id="payment-information-form-group" class="form-group">
			<input type="hidden" id="id_my_payments" name="id_my_payments" value="{$my_payment}" />
			<input type="hidden" id="id_my_payments_tip" name="id_my_payments_vid" value="{$my_tip_amount}" />
			<input type="hidden" id="id_customer" name="id_customer" value="{$currentCust}" />
<!-- Дата оплаты -->
			<label class="control-label col-lg-3">
				<div class="row">
				<span title="" data-toggle="tooltip" class="label-tooltip" data-original-title="{l s='Search for an existing customer by typing the first letters of his/her name.'}">
					{l s='Дата оплаты'}
				</span>
			</div>
			</label>
			<div class="col-lg-9">
				<input type="text" id="date_payment" name="date_payment" class="datepicker col-lg-3" value="{$date_payment}" />
			</div>
<!-- Вид оплаты -->
			<div {if ($my_paym_filt > 0)} class="hidden"{/if}>
				<label class="control-label col-lg-3">
					<span title="" data-toggle="tooltip" class="label-tooltip" data-original-title="{l s='Search for an existing customer by typing the first letters of his/her name.'}">
						{l s='Вид оплаты'}
					</span>
				</label>
				<div class="col-lg-9"> 
					<select id="id_my_payments_vid" class="chosen form-control" name="id_my_payments_vid">
					{foreach from=$mpv_array item=my_vid}
						<option  value="{$my_vid['id_my_payments_vid']|intval}"
							{if isset($currentVid) && $my_vid['id_my_payments_vid'] == $currentVid} 
								selected="selected" 
							{/if}
							{if ((($my_tip_amount == 2) && ($my_vid['id_my_payments_vid'] < 5)) || (($my_tip_amount == 1) && ($my_vid['id_my_payments_vid'] > 4)))} 
								class="hidden" 
							{/if}
							>
							{$my_vid['name']|escape}
						</option>
					{/foreach}
					</select>
				</div>
			</div>
<!-- Способ оплаты -->
			<label class="control-label col-lg-3">
				<span title="" data-toggle="tooltip" class="label-tooltip" data-original-title="{l s='Search for an existing customer by typing the first letters of his/her name.'}">
					{l s='Способ оплаты'}
				</span>
			</label>
			<div class="col-lg-9">
				<select id="id_my_payments_spos" class="chosen form-control" name="id_my_payments_spos">
				{foreach from=$mps_array item=my_spos}
					<option  value="{$my_spos['id_my_payments_spos']|intval}"
						{if isset($currentSpos) && $my_spos['id_my_payments_spos'] == $currentSpos} 
							selected="selected" 
						{/if}
						>
						{$my_spos['name']|escape}
					</option>
				{/foreach}
				</select>
			</div>
			
<!-- Касса -->
			<label class="control-label col-lg-3">
				<span title="" data-toggle="tooltip" class="label-tooltip" data-original-title="{l s='Search for an existing customer by typing the first letters of his/her name.'}">
					{l s='Получатель'}
				</span>
			</label>
			<div class="col-lg-9">
				<select id="id_my_payments_kas" class="chosen form-control" name="id_my_payments_kas">
				{foreach from=$mpk_array item=my_kas}
					<option  value="{$my_kas['id_my_payments_kas']|intval}"
						{if isset($currentKas) && $my_kas['id_my_payments_kas'] == $currentKas} 
							selected="selected" 
						{/if}
						>
						{$my_kas['name']|escape}
					</option>
				{/foreach}
				</select>
			</div>

<!-- Заказ -->
			<label class="control-label col-lg-3">
				<span title="" data-toggle="tooltip" class="label-tooltip" data-original-title="{l s='Search for an existing customer by typing the first letters of his/her name.'}">
					{l s='Заказ'}
				</span>
			</label>
			<div class="col-lg-9">
				<input type="text" id="cur_order" name="cur_order" value="{$currentOrder}" />
			</div>
			<div class="form-group hide" id="div_this_order">
				<div class="col-lg-3 col-lg-offset-3">
					<i id="this_order_sum">Сумма к оплате по данному заказу - 0.00 руб.</i>
				</div>
				<div class="col-lg-2 col-lg-offset">
					<button type="button" class="btn btn-default" id="submit_this_order_sum" />
					<i class="icon-ok text-success"></i>
					{l s='Оплатить полностью этот заказ'}
				</div>
			</div>
<!-- Сумма -->
			<label class="control-label col-lg-3">
				<span title="" data-toggle="tooltip" class="label-tooltip" data-original-title="{l s='Search for an existing customer by typing the first letters of his/her name.'}">
					{l s='Сумма оплаты'}
				</span>
			</label>
			<div class="col-lg-9">
				<input type="text" id="summa_all" name="summa_all" value="{$currentSum}" onblur="validateNonEmpty(this)"/>
				<input type="hidden" id="summa_all_old" name="summa_all" value="{$currentSum}" />
			</div>
<!-- Сумма распределенная-->
			<label class="control-label col-lg-3">
				<span title="" data-toggle="tooltip" class="label-tooltip" data-original-title="{l s='Search for an existing customer by typing the first letters of his/her name.'}">
					{l s='Сумма распределенная'}
				</span>
			</label>
			<div class="col-lg-9">
				<input type="text" id="summa_yes" name="summa_yes" value="{$currentSumYes}"  disabled="disabled"/>
			</div>
<!-- Сумма не распределенная-->
			<label class="control-label col-lg-3">
				<span title="" data-toggle="tooltip" class="label-tooltip" data-original-title="{l s='Search for an existing customer by typing the first letters of his/her name.'}">
					{l s='Сумма к распределению'}
				</span>
			</label>
			<div class="col-lg-9">
				<input type="text" id="summa_no" name="summa_no" value="{$currentSumNo}"  disabled="disabled"/>
			</div>
		</div>
<!-- покупатель -->		
			<div id="search-customer-form-group" class="form-group">
				<label class="control-label col-lg-3">
					<span title="" data-toggle="tooltip" class="label-tooltip" data-original-title="{l s='Search for an existing customer by typing the first letters of his/her name.'}">
						{l s='Поиск покупателя'}
					</span>
				</label>
				<div class="col-lg-9">
					<div class="row">
						<div class="col-lg-6">
							<div class="input-group">
								<input type="text" id="customer" value="" />
								<span class="input-group-addon">
									<i class="icon-search"></i>
								</span>
							</div>
						</div>
						<div class="col-lg-6 hidden">
							<span class="form-control-static">{l s='Or'}&nbsp;</span>
							<a class="fancybox_customer btn btn-default" href="{$link->getAdminLink('AdminCustomers')|escape:'html':'UTF-8'}&amp;addcustomer&amp;liteDisplaying=1&amp;submitFormAjax=1#">
								<i class="icon-plus-sign-alt"></i>
								{l s='Add new customer'}
							</a>
						</div>
					</div>
				</div>
			</div>
			<div class="row">
				<div id="customers"></div>
			</div>			
<!-- Примечание -->
			<label class="control-label col-lg-3">
				<span title="" data-toggle="tooltip" class="label-tooltip" data-original-title="{l s='Search for an existing customer by typing the first letters of his/her name.'}">
					{l s='Примечания'}
				</span>
			</label>
			<div class="col-lg-9">
				<textarea name="prim" id="prim" class=""  maxlength="500">{$currentPrim|escape:'html':'UTF-8'}</textarea>
			</div>
			<hr>
			<div class="form-group">
				<div class="col-lg-3 col-lg-offset-3">
					<button type="button" class="btn btn-primary" id="submitSavePayment" />
					<i class="icon-ok text-success"></i>
					{l s='Save'}
				</div>
				<div id="products_err" class="hide alert alert-danger"></div>
			</div>
<!-- 			<div class="form-group">
				<div class="col-lg-9 col-lg-offset-10">
						<button type="button" class="btn btn-default" id="mytest2" onclick="var my=window.open('form_zavkaf.php'); my.print(); var my2=window.open('form_zavkaf.php'); my2.print(); "/>
						<i class="icon-ok text-success"></i>
						{l s='My Test'}
				</div>
				<div id="products_err" class="hide alert alert-danger"></div>
			</div>
 -->
			<div id="to_rasp" class="hide">

			<div id="carts">
				<button type="button" id="show_old_carts" class="btn btn-default pull-right" data-toggle="collapse" data-target="#old_carts_orders">
					<i class="icon-caret-down"></i>
				</button>

				<ul id="old_carts_orders_navtab" class="nav nav-tabs">
					<li class="active">
						<a href="#nonOrderedCarts" data-toggle="tab" id="hrefost">
							{l s='Сумма, оставшаяся к распределению'}
							<i>&nbsp;&nbsp;-&nbsp;&nbsp;</i>
							<i id="summa_no_2">{$currentSumNo}</i>
						</a>
					</li>
					<li>
						<a href="#lastOrders" data-toggle="tab" id="hrefrasp">
							{l s='Разнесено по заказам'}
							<i>&nbsp;&nbsp;-&nbsp;&nbsp;</i>
							<i id="summa_yes_2">{$currentSumYes}</i>
						</a>
					</li>
				</ul>
				<div id="old_carts_orders" class="tab-content panel collapse in">
					<div id="nonOrderedCarts" class="tab-pane active">
						<i>{l s='Неоплаченные заказы'}</i>
						<i id="summa_no_2_2" class="pull-right"style="background: #ffcabd">{$currentSumNo}</i>
						<i class="pull-right">&nbsp;&nbsp;-&nbsp;&nbsp;</i>
						<i class="pull-right">{l s='Сумма, оставшаяся к распределению'}</i>
						<br>
						<div class="pull-left">
								<button type="button" class="label-tooltip" id="showsum" title="" data-toggle="tooltip" data-original-title="{l s='Отображает в таблице ниже только те заказы, сумма к оплате которых отличается от суммы к распределению не более чем на 10 рублей.'}" />
								<i class="icon-ok text-success"></i>
								{l s='Показать с похожими суммами'}
								<button type="button" class="label-tooltip" id="showzak" title="" data-toggle="tooltip" data-original-title="{l s='Отображает в таблице ниже только тот заказ, номер которого указан в поле Заказ.'}" />
								<i class="icon-ok text-success"></i>
								{l s='Показать только указанный заказ'}
								<button type="button" class="label-tooltip" id="showall"  title="" data-toggle="tooltip" data-original-title="{l s='Отображает в таблице ниже все заказы.'}"/>
								<i class="icon-ok text-success"></i>
								{l s='Показать все'}

						</div>
						<br>
				<input type="hidden" id="summa_no_old" name="summa_no" value="{$currentSumNo}"  disabled="disabled"/>
						<br>
						<br>
						<div class="pull-right">
								<button type="button" class="label-tooltip" id="rasp1"  title="" data-toggle="tooltip" data-original-title="{l s='Распределяет сумму, оставшуюся к распределению, начиная с первого по порядку заказа в таблице ниже. Не забудьте сохранить изменения!'}"/>
								<i class="icon-ok text-success"></i>
								{l s='Распределить по порядку'}
								<button type="button" class="label-tooltip" id="raspotm"  title="" data-toggle="tooltip" data-original-title="{l s='Распределяет сумму, оставшуюся к распределению, среди отмеченных галочками товаров в таблице ниже. Не забудьте сохранить изменения!'}"/>
								<i class="icon-ok text-success"></i>
								{l s='Распределить по отмеченным'}
								<button type="button" class="label-tooltip" id="raspprim"  title="" data-toggle="tooltip" data-original-title="{l s='Распределяет сумму, оставшуюся к распределению, начиная с того заказа в таблице ниже, в поле которого вы ввели сумму с клавиатуры. Не забудьте сохранить изменения!'}"/>
								<i class="icon-ok text-success"></i>
								{l s='Распределить в ручную'}
								<button type="button" class="label-tooltip" id="raspclear" title="" data-toggle="tooltip" data-original-title="{l s='Обнуляет все суммы в полях для распределения в таблице ниже.'}"/>
								<i class="icon-ok text-success"></i>
								{l s='Очистить'}
						</div>
						<table class="table">
							<thead>
								<tr>
									<th><span class="title_box">{l s='ID'}</span></th>
									<th><span class="title_box">{l s='Дата'}</span></th>
									<th><span class="title_box">{l s='Заказ'}</span></th>
									<th><span class="title_box">{l s='Покупатель'}</span></th>
									<th><span class="title_box">{l s='Сумма оплаты'}</span></th>
									<th><span class="title_box">{l s='Оплачено'}</span></th>
									<th><span class="title_box">{l s='К оплате'}</span></th>
									<th></th>
									<th></th>
									<th><span class="title_box">{l s='Распределить'}</span></th>
								</tr>
							</thead>
							<tbody>
							</tbody>
						</table>
					</div>
					<div id="lastOrders" class="tab-pane">
						<i>{l s='distributed payments'}</i>
						<table class="table">
							<thead>
								<tr>
									<th></th>
									<th><span class="title_box">{l s='Заказ'}</span></th>
									<th><span class="title_box">{l s='Покупатель'}</span></th>
									<th><span class="title_box">{l s='Сумма заказа'}</span></th>
									<th><span class="title_box">{l s='Оплата'}</span></th>
									<th><span class="title_box">{l s='Action 1'}</span></th>
								</tr>
							</thead>
							<tbody>
							</tbody>
						</table>
					</div>
				</div>
			</div>
		</div>
<!-- 					<div class="panel-footer">
						<button type="submit" value="1"	
							id="{if isset($fieldset['form']['submit']['id'])}
									{$fieldset['form']['submit']['id']}
								{else}
									{$table}_form_submit_btn
								{/if}
								{if $smarty.capture.form_submit_btn > 1}_{($smarty.capture.form_submit_btn - 1)|intval}{/if}" 
							name="{if isset($fieldset['form']['submit']['name'])}
									{$fieldset['form']['submit']['name']}
								{else}
									{$submit_action}
								{/if}
								{if isset($fieldset['form']['submit']['stay']) && $fieldset['form']['submit']['stay']}
									AndStay
								{/if}" 
							class="{if isset($fieldset['form']['submit']['class'])}
										{$fieldset['form']['submit']['class']}
									{else}
										btn btn-default pull-right
									{/if}">
							<i class="{if isset($fieldset['form']['submit']['icon'])}
										{$fieldset['form']['submit']['icon']}
									{else}
										process-icon-save
									{/if}">
							</i>
							{$fieldset['form']['submit']['title']}
						</button>
						<a href="{$back_url|escape:'html':'UTF-8'}" class="btn btn-default" onclick="window.history.back();">
							<i class="process-icon-cancel"></i> {l s='Cancel'}
						</a>
					</div>
 -->		
	</div>
<!-- Здесь конец ******************************************************************************************************************
 -->
<form class="form-horizontal hidden" action="{$link->getAdminLink('AdminMy_Payments')|escape:'html':'UTF-8'}&amp;submitAdd{$tabl|escape:'html':'UTF-8'}=1" method="post" autocomplete="off">
	<div class="panel" id="products_part" >
		<div class="panel-heading">
			<i class="icon-shopping-cart"></i>
			{l s='Cart'}
		</div>
		<div class="form-group">
			<label class="control-label col-lg-3">
				<span title="" data-toggle="tooltip" class="label-tooltip" data-original-title="{l s='Search for an existing product by typing the first letters of its name.'}">
					{l s='Search for a product'}
				</span>
			</label>
			<div class="col-lg-9">
				<input type="hidden" value="" id="id_cart" name="id_cart" />
				<div class="input-group">
					<input type="text" id="product" value="" />
					<span class="input-group-addon">
						<i class="icon-search"></i>
					</span>
				</div>
			</div>
		</div>

		<div id="products_found">
			<hr/>
			<div id="product_list" class="form-group"></div>
			<div id="attributes_list" class="form-group"></div>
			<!-- @TODO: please be kind refacto -->
			<div class="form-group">
				<div class="col-lg-9 col-lg-offset-3">
					<iframe id="customization_list" seamless>
						<html>
						<head>
							{if isset($css_files_orders)}
								{foreach from=$css_files_orders key=css_uri item=media}
								{/foreach}
							{/if}
						</head>
						<body>
						</body>
						</html>
					</iframe>
				</div>
			</div>
			<div class="form-group">
				<label class="control-label col-lg-3" for="qty">{l s='Quantity'}</label>
				<div class="col-lg-9">
					<input type="text" name="qty" id="qty" class="form-control fixed-width-sm" value="1" />
					<p class="help-block">{l s='In stock'} <span id="qty_in_stock"></span></p>
				</div>
			</div>

			<div class="form-group">
				<div class="col-lg-9 col-lg-offset-3">
					<button type="button" class="btn btn-default" id="submitAddProduct" />
					<i class="icon-ok text-success"></i>
					{l s='Add to cart'}
				</div>
			</div>
				<div class="form-group">
					<div class="col-lg-9 col-lg-offset-3">
						<button >
							<i class="icon-check"></i>
							{l s='Create the order'}
						</button>
					</div>
				</div>
		</div>

		<div id="products_err" class="hide alert alert-danger"></div>

		<hr/>

		<div class="row">
			<div class="col-lg-12">
				<table class="table1" id="customer_cart">
					<thead>
						<tr>
							<th><span class="title_box">{l s='Product'}</span></th>
							<th><span class="title_box">{l s='Description'}</span></th>
							<th><span class="title_box">{l s='Reference'}</span></th>
							<th><span class="title_box">{l s='Unit price'}</span></th>
							<th><span class="title_box">{l s='Quantity'}</span></th>
							<th><span class="title_box">{l s='Price'}</span></th>
						</tr>
					</thead>
					<tbody>
					</tbody>
				</table>
			</div>
		</div>

		<div class="form-group">
			<div class="col-lg-9 col-lg-offset-3">
				<div class="alert alert-warning">{l s='The prices are without taxes.'}</div>
			</div>
		</div>

		<div class="form-group">
			<label class="control-label col-lg-3" for="id_currency">
				{l s='Currency'}
			</label>
			<script type="text/javascript">
				{foreach from=$currencies item='currency'}
					currencies['{$currency.id_currency}'] = '{$currency.sign}';
				{/foreach}
			</script>
			<div class="col-lg-9">
				<select id="id_currency" name="id_currency">
					{foreach from=$currencies item='currency'}
						<option rel="{$currency.iso_code}" value="{$currency.id_currency}">{$currency.name}</option>
					{/foreach}
				</select>
			</div>
		</div>
		<div class="form-group">
			<label class="control-label col-lg-3" for="id_lang">
				{l s='Language'}
			</label>
			<div class="col-lg-9">
				<select id="id_lang" name="id_lang">
					{foreach from=$langs item='lang'}
						<option value="{$lang.id_lang}">{$lang.name}</option>
					{/foreach}
				</select>
			</div>
		</div>
	</div>

	<div class="panel" id="vouchers_part" style="display:none;">
		<div class="panel-heading">
			<i class="icon-ticket"></i>
			{l s='Vouchers'}
		</div>
		<div class="form-group">
			<label class="control-label col-lg-3">
				{l s='Search for a voucher'}
			</label>
			<div class="col-lg-9">
				<div class="row">
					<div class="col-lg-6">
						<div class="input-group">
							<input type="text" id="voucher" value="" />
							<div class="input-group-addon">
								<i class="icon-search"></i>
							</div>
						</div>
					</div>
					<div class="col-lg-6">
						<span class="form-control-static">{l s='Or'}&nbsp;</span>
						<a class="fancybox btn btn-default" href="{$link->getAdminLink('AdminCartRules')|escape:'html':'UTF-8'}&amp;addcart_rule&amp;liteDisplaying=1&amp;submitFormAjax=1#">
							<i class="icon-plus-sign-alt"></i>
							{l s='Add new voucher'}
						</a>
					</div>
				</div>
			</div>
		</div>
		<div class="row">
			<table class="table1" id="voucher_list">
				<thead>
					<tr>
						<th><span class="title_box">{l s='Name'}</span></th>
						<th><span class="title_box">{l s='Description'}</span></th>
						<th><span class="title_box">{l s='Value'}</span></th>
						<th></th>
					</tr>
				</thead>
				<tbody>
				</tbody>
			</table>
		</div>
		<div id="vouchers_err" class="alert alert-warning" style="display:none;"></div>
	</div>

	<div class="panel" id="address_part" style="display:none;">
		<div class="panel-heading">
			<i class="icon-envelope"></i>
			{l s='Addresses'}
		</div>
		<div id="addresses_err" class="alert alert-warning" style="display:none;"></div>

		<div class="row">
			<div id="address_delivery" class="col-lg-6">
				<h4>
					<i class="icon-truck"></i>
					{l s='Delivery'}
				</h4>
				<div class="row-margin-bottom">
					<select id="id_address_delivery" name="id_address_delivery"></select>
				</div>
			</div>
			<div id="address_invoice" class="col-lg-6">
				<h4>
					<i class="icon-file-text"></i>
					{l s='Invoice'}
				</h4>
				<div class="row-margin-bottom">
					<select id="id_address_invoice" name="id_address_invoice"></select>
				</div>
				<div class="well">
					<a href="" id="edit_invoice_address" class="btn btn-default pull-right fancybox"><i class="icon-pencil"></i> {l s='Edit'}</a>
					<div id="address_invoice_detail"></div>
				</div>
			</div>
		</div>
		<div class="row">
			<div class="col-lg-12">
				<a class="fancybox btn btn-default" id="new_address" href="{$link->getAdminLink('AdminAddresses')|escape:'html':'UTF-8'}&amp;addaddress&amp;id_customer=42&amp;liteDisplaying=1&amp;submitFormAjax=1#">
					<i class="icon-plus-sign-alt"></i>
					{l s='Add a new address'}
				</a>
			</div>
		</div>
	</div>
	<div class="panel" id="carriers_part" style="display:none;">
		<div class="panel-heading">
			<i class="icon-truck"></i>
			{l s='Shipping'}
		</div>
		<div id="carriers_err" style="display:none;" class="alert alert-warning"></div>
		<div id="carrier_form">
			<div class="form-group">
				<label class="control-label col-lg-3">
					{l s='Delivery option'}
				</label>
				<div class="col-lg-9">
					<select name="delivery_option" id="delivery_option">
					</select>
				</div>
			</div>
			<div class="form-group">
				<label class="control-label col-lg-3" for="shipping_price">
					{l s='Shipping price (Tax incl.)'}
				</label>
				<div class="col-lg-9">
					<p id="shipping_price" class="form-control-static" name="shipping_price"></p>
				</div>
			</div>
			<div class="form-group">
				<label class="control-label col-lg-3" for="free_shipping">
					{l s='Free shipping'}
				</label>
				<div class="input-group col-lg-9 fixed-width-lg">
					<span class="switch prestashop-switch">
						<input type="radio" name="free_shipping" id="free_shipping" value="1">
						<label for="free_shipping" class="radioCheck">
							{l s='yes'}
						</label>
						<input type="radio" name="free_shipping" id="free_shipping_off" value="0" checked="checked">
						<label for="free_shipping_off" class="radioCheck">
							{l s='No'}
						</label>
						<a class="slide-button btn"></a>
					</span>
				</div>
			</div>

			{if $recyclable_pack}
			<div class="form-group">
				<div class="checkbox col-lg-9 col-offset-3">
					<label for="carrier_recycled_package">
						<input type="checkbox" name="carrier_recycled_package" value="1" id="carrier_recycled_package" />
						{l s='Recycled package'}
					</label>
				</div>
			</div>
			{/if}

			{if $gift_wrapping}
			<div class="form-group">
				<div class="checkbox col-lg-9 col-offset-3">
					<label for="order_gift">
						<input type="checkbox" name="order_gift" id="order_gift" value="1" />
						{l s='Gift'}
					</label>
				</div>
			</div>
			<div class="form-group">
				<label class="control-label col-lg-3" for="gift_message">{l s='Gift message'}</label>
				<div class="col-lg-9">
					<textarea id="gift_message" class="form-control" cols="40" rows="4"></textarea>
				</div>
			</div>
			{/if}
		</div>
	</div>
	<div class="panel" id="summary_part" style="display:none;">
		<div class="panel-heading">
			<i class="icon-align-justify"></i>
			{l s='Summary'}
		</div>

		<div id="send_email_feedback" class="hide alert"></div>

		<div id="cart_summary" class="panel row-margin-bottom text-center">
			<div class="row">
				<div class="col-lg-2">
					<div class="data-focus">
						<span>{l s='Total products'}</span><br/>
						<span id="total_products" class="size_l text-success"></span>
					</div>
				</div>
				<div class="col-lg-2">
					<div class="data-focus">
						<span>{l s='Total vouchers (Tax excl.)'}</span><br/>
						<span id="total_vouchers" class="size_l text-danger"></span>
					</div>
				</div>
				<div class="col-lg-2">
					<div class="data-focus">
						<span>{l s='Total shipping (Tax excl.)'}</span><br/>
						<span id="total_shipping" class="size_l"></span>
					</div>
				</div>
				<div class="col-lg-2">
					<div class="data-focus">
						<span>{l s='Total taxes'}</span><br/>
						<span id="total_taxes" class="size_l"></span>
					</div>
				</div>
				<div class="col-lg-2">
					<div class="data-focus">
						<span>{l s='Total (Tax excl.)'}</span><br/>
						<span id="total_without_taxes" class="size_l"></span>
					</div>
				</div>
				<div class="col-lg-2">
					<div class="data-focus data-focus-primary">
						<span>{l s='Total (Tax incl.)'}</span><br/>
						<span id="total_with_taxes" class="size_l"></span>
					</div>
				</div>
			</div>
		</div>

		<div class="row">
			<div class="order_message_right col-lg-12">
				<div class="form-group">
					<label class="control-label col-lg-3" for="order_message">{l s='Order message'}</label>
					<div class="col-lg-6">
						<textarea name="order_message" id="order_message" rows="3" cols="45"></textarea>
					</div>
				</div>
				<div class="form-group">
					{if !$PS_CATALOG_MODE}
					<div class="col-lg-9 col-lg-offset-3">
						<a href="javascript:void(0);" id="send_email_to_customer" class="btn btn-default">
							<i class="icon-credit-card"></i>
							{l s='Send an email to the customer with the link to process the payment.'}
						</a>
						<a id="go_order_process" href="" class="btn btn-link _blank">
							{l s='Go on payment page to process the payment.'}
							<i class="icon-external-link"></i>
						</a>
					</div>
					{/if}
				</div>
				<div class="form-group">
					<label class="control-label col-lg-3">{l s='Payment'}</label>
					<div class="col-lg-9">
						<select name="payment_module_name" id="payment_module_name">
							{if !$PS_CATALOG_MODE}
							{foreach from=$payment_modules item='module'}
								<option value="{$module->name}" {if isset($smarty.post.payment_module_name) && $module->name == $smarty.post.payment_module_name}selected="selected"{/if}>{$module->displayName}</option>
							{/foreach}
							{else}
								<option value="boorder">{l s='Back office order'}</option>
							{/if}
						</select>
					</div>
				</div>
				<div class="form-group">
					<label class="control-label col-lg-3">{l s='Order status'}</label>
					<div class="col-lg-9">
						<select name="id_order_state" id="id_order_state">
							{foreach from=$order_states item='order_state'}
								<option value="{$order_state.id_order_state}" {if isset($smarty.post.id_order_state) && $order_state.id_order_state == $smarty.post.id_order_state}selected="selected"{/if}>{$order_state.name}</option>
							{/foreach}
						</select>
					</div>
				</div>
				<div class="form-group">
					<div class="col-lg-9 col-lg-offset-3">
						<button type="submit" name="submitAddOrder" class="btn btn-default" />
							<i class="icon-check"></i>
							{l s='Create the order'}
						</button>
					</div>
				</div>
			</div>
		</div>
	</div>
</form>

<div id="loader_container">
	<div id="loader"></div>
</div>
