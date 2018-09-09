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
<script type="text/javascript">
$(document).ready(function() {
	var my_newcolor = '#fc0707';
	var my_oldcolor = '#2eacce';
	detect_state_group();
	
	$('#but_selectOrderGroup1').unbind('click').click(function(e) {
			$('input[name="orderFilter_order_state_groups"]').val('');
			$('#submitFilterButtonorder').trigger('click');orderFilter_is_payed
	});
	$('#but_selectOrderGroup2').unbind('click').click(function(e) {
			$('input[name="orderFilter_order_state_groups"]').val($('#but_selectOrderGroup2').val());
			$('#submitFilterButtonorder').trigger('click');
	});
	$('#but_selectOrderGroup3').unbind('click').click(function(e) {
			$('input[name="orderFilter_order_state_groups"]').val($('#but_selectOrderGroup3').val());
			$('#submitFilterButtonorder').trigger('click');
	});
	$('#but_selectOrderGroup4').unbind('click').click(function(e) {
			$('input[name="orderFilter_order_state_groups"]').val($('#but_selectOrderGroup4').val());
			$('#submitFilterButtonorder').trigger('click');
	});
	$('#but_selectOrderGroup5').unbind('click').click(function(e) {
			$('input[name="orderFilter_order_state_groups"]').val($('#but_selectOrderGroup5').val());
			$('#submitFilterButtonorder').trigger('click');
	});
	$('#but_selectOrderGroup6').unbind('click').click(function(e) {
			$('input[name="orderFilter_order_state_groups"]').val($('#but_selectOrderGroup6').val());
			$('#submitFilterButtonorder').trigger('click');
	});
	$('#but_selectOrderGroup7').unbind('click').click(function(e) {
			$('input[name="orderFilter_order_state_groups"]').val($('#rest_order_statuses_groups').val());
			$('#submitFilterButtonorder').trigger('click');
	});

	$('#but_selectPayedOrder').unbind('click').click(function(e) {
			$('input[name="orderFilter_is_payed"]').val('');
			$('#submitFilterButtonorder').trigger('click');
	});
	$('#but_selectPayedOrder0').unbind('click').click(function(e) {
			$('input[name="orderFilter_is_payed"]').val($('#but_selectPayedOrder0').val());
			$('#submitFilterButtonorder').trigger('click');
	});
	$('#but_selectPayedOrder1').unbind('click').click(function(e) {
			$('input[name="orderFilter_is_payed"]').val($('#but_selectPayedOrder1').val());
			$('#submitFilterButtonorder').trigger('click');
	});
	$('#but_selectPayedOrder2').unbind('click').click(function(e) {
			$('input[name="orderFilter_is_payed"]').val($('#but_selectPayedOrder2').val());
			$('#submitFilterButtonorder').trigger('click');
	});

	
	function detect_state_group() {
		var tek_state_group = $('input[name="orderFilter_order_state_groups"]').val();
//		jAlert(tek_state_group);
		var is_found = 0;
		for(i = 1; i < 7; i++) {
			if ($('#but_selectOrderGroup'+i).val() == tek_state_group ) {
				$('#but_selectOrderGroup'+i).css('backgroundColor', my_newcolor);
				is_found = 1;
			}	
		}
		if (is_found == 0) {
			$('#rest_order_statuses_groups').val(tek_state_group);
			$('#but_selectOrderGroup7').css('backgroundColor', my_newcolor);
		}
	};

	
});	
</script>

<div class="panel kpi-container">
	<div class="row">
		<table class="table">
			<tbody>
				<tr>
					<td>
						<button id="but_selectOrderGroup1" value="" class="btn btn-primary" type="submit" name="submitFilter">
							{l s='Все'}
						</button>
						&nbsp;-&nbsp;{$order_counts[0]}
					</td>
					{assign var=i value=1}
					{foreach from=$order_statuses_groups item=group}
						{if ($i++ < 6)}
							<td>
								<button id="but_selectOrderGroup{$i}" value="{$group.id_order_state_group}" class="btn btn-primary" type="submit" name="submitAddPayment">
									{$group.group_name}
								</button>
								&nbsp;-&nbsp;{$order_counts[$i-1]}
							</td>
						{/if}	
					{/foreach}
					{if ($i > 6)}
						<td>
							<select id="rest_order_statuses_groups" class="edit_payment_transaction_id" />
							{assign var=i2 value=1}
							{foreach from=$order_statuses_groups item=group}
								{if ($i2++ > 5)}
									<option value="{$group.id_order_state_group}">{$group.group_name}</option>
								{/if}	
							{/foreach}
							</select>
						</td>
						<td>
							<button id="but_selectOrderGroup7" class="btn btn-primary" type="submit" name="submitAddPayment">
								{l s='Выбранная'}
							</button>
						</td>
					{/if}	
				</tr>
			</tbody>
		</table>
	</div>
	<div class="row hidden">
 		<table class="table">
			<tbody>
				<tr>
					<td>
						<button id="but_selectPayedOrder" value="5" class="btn btn-primary" type="submit">
							{l s='Все'}
						</button>
					</td>
					<td>
						<button id="but_selectPayedOrder0" value="0" class="btn btn-primary" type="submit">
							{l s='Оплаченные'}
						</button>
					</td>
					<td>
						<button id="but_selectPayedOrder1" value="1" class="btn btn-primary" type="submit">
							{l s='Частично оплаченные'}
						</button>
					</td>
					<td>
						<button id="but_selectPayedOrder2" value="2" class="btn btn-primary" type="submit">
							{l s='Без оплаты'}
						</button>
					</td>
				</tr>
			</tbody>
		</table>
		</div>
</div>
