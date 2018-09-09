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
{extends file="helpers/list/list_header.tpl"}
{block name=override_header}
{if isset($show_filter) && $show_filter}
<div class="panel">
	<h3><i class="icon-cogs"></i> {l s='Filters'}</h3>
	<div class="filter-stock">
		<form id="stock_instant_state" method="get" class="form-horizontal">
			<input type="hidden" name="controller" value="AdminStockInstantState" />
			<input type="hidden" name="token" value="{$token|escape:'html':'UTF-8'}" />
			{if count($stock_instant_state_warehouses) > 0}
				<div id="stock_instant_state_form_warehouse" class="form-group">
					<label for="id_warehouse" class="control-label col-lg-1">{'По складу:'}</label>
					<div class="col-lg-3">
						<select id="id_warehouse" name="id_warehouse" onchange="$('#stock_instant_state').submit();">
							{foreach from=$stock_instant_state_warehouses key=k item=i}
								<option {if $i.id_warehouse == $stock_instant_state_cur_warehouse} selected="selected"{/if} value="{$i.id_warehouse}">{$i.name}</option>
							{/foreach}
						</select>
					</div>
				</div>
			{/if}
			<div id="stock_instant_state_form_manufacturers" class="form-group">
				<label for="id_manufacturer" class="control-label col-lg-1">{'По Т.Марке:'}</label>
				<div class="col-lg-3">
					<select id="id_manufacturer" name="id_manufacturer" onchange="$('#stock_instant_state').submit();">
						{foreach from=$stock_instant_state_manufacturers key=k item=i}
							<option {if $i.id_manufacturer == $stock_instant_state_cur_manufacturer} selected="selected"{/if} value="{$i.id_manufacturer}">{$i.name}</option>
						{/foreach}
					</select>
				</div>
			</div>
			<div id="stock_instant_state_form_categories" class="form-group">
				<label for="id_category" class="control-label col-lg-1">{'По категории:'}</label>
				<div class="col-lg-3">
					<select id="id_category" name="id_category" onchange="$('#stock_instant_state').submit();">
						{foreach from=$stock_instant_state_categories key=k item=i}
							<option {if $i.id_category == $stock_instant_state_cur_category} selected="selected"{/if} value="{$i.id_category}">{$i.name}</option>
						{/foreach}
					</select>
				</div>
			</div>
			<div id="stock_instant_state_form_manufacturers" class="form-group">
				<label for="summa_physical" class="control-label col-lg-1">{'Физически:'}</label>
				<div class="col-lg-2">
					<input type="text" style="width: 200px; text-align:right" name="summa_physical" id="summa_physical" value="{displayPrice price=$summa_physical currency=$currency->id}"/>
				</div>
				<label for="summa_usable" class="control-label col-lg-1">{'Доступно:'}</label>
				<div class="col-lg-2">
					<input type="text" style="width: 200px; text-align:right" name="summa_usable" id="summa_usable"  value="{displayPrice price=$summa_usable currency=$currency->id}"/>
				</div>
				<label for="summa_rest" class="control-label col-lg-1">{'Свободно:'}</label>
				<div class="col-lg-2">
					<input type="text" style="width: 200px; text-align:right" name="summa_rest" id="summa_rest"  value="{displayPrice price=$summa_rest currency=$currency->id}"/>
				</div>
				<label for="summa_bron" class="control-label col-lg-1">{'В брони:'}</label>
				<div class="col-lg-2">
					<input type="text" style="width: 200px; text-align:right" name="summa_bron" id="summa_bron"  value="{displayPrice price=$summa_bron currency=$currency->id}"/>
				</div>
				<label for="summa_razn" class="control-label col-lg-1">{'Потеряно:'}</label>
				<div class="col-lg-2">
					<input type="text" style="width: 200px; text-align:right" name="summa_razn" id="summa_razn"  value="{displayPrice price=$summa_razn currency=$currency->id}"/>
				</div>
			</div>
<!-- 			<div>
				<input type="button" id="stock_av_sync" name="stock_av_sync" onclick="$('#stock_instant_state').submit();" value=" Пересчитать свободные остатки ">
			</div>
 -->			
		
		</form>
	</div>
</div>
{/if}
{/block}