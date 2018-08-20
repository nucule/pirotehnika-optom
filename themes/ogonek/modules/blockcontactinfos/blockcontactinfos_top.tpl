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

<!-- MODULE Block contact infos -->
<section class="ps-head__contacts ps-contacts">
    <div class="ps-contacts__info">пн-пт 09:00 - 18:00 Мск</div>
    <div class="ps-contacts__phone">
        {$blockcontactinfos_phone|escape:'html':'UTF-8'}
    </div>
    <div class="ps-contacts__info">звонок бесплатный по России</div>
    {if $page_name =='index'}
    <a class="ps-contacts__button" href="/contact-us">Свяжитесь с нами</a>
    {/if}
</section>