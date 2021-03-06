<?php

class Category extends CategoryCore {

    public static function getCheckedCategories() {
        $result = array();
        if (isset($_COOKIE['categories']) && $_COOKIE['categories']) {
            $result['categories'] = array_flip(explode(',', $_COOKIE['categories']));
        }
        if (isset($_COOKIE['manufact']) && $_COOKIE['manufact']) {
            $result['manufact'] = array_flip(explode(',', $_COOKIE['manufact']));   
        }
        return $result;
    }
    
    public static function getCategoriesList($id_lang) {
        $arr = Category::getCategories($id_lang);
        $categories = array();
        $subcategories = array();

        foreach ($arr as $value) {
            foreach ($value as $key => $item) {
                $category = $item['infos'];
                if ($category['level_depth'] == 4) {
                    if (!isset($subcategories[$category['id_parent']])) {
                        $subcategories[$category['id_parent']] = array();
                    }
                    $subcategories[$category['id_parent']][$category['id_category']] = $category;
                }
            }
        }

        foreach ($arr as $value) {
            foreach ($value as $key => $item) {
                $category = $item['infos'];
                if ($category['level_depth'] == 2)
                    if (!isset($categories[$category['id_category']]))
                        $categories[$category['id_category']] = $category;
                    else
                        array_merge($categories[$category['id_category']], $category);
                    
                if ($category['level_depth'] == 3) {
                    if (!isset($categories[$category['id_parent']])) {
                        $categories[$category['id_parent']] = array('categories' => array());

                    }

                    if (isset($subcategories[$category['id_category']])) {
                        $category['categories'] = $subcategories[$category['id_category']];
                    }

                    $categories[$category['id_parent']]['categories'][$category['id_category']] = $category;

                }
            }
        }

        return $categories;
    }

    public static function getProductsList($id_lang, $page_number = 0, $nb_products = 10, $count = false, $order_by = null, $order_way = null, $beginning = false, $ending = false, Context $context = null) {
        if (!Validate::isBool($count)) {
            die(Tools::displayError());
        }

        if (!$context) {
            $context = Context::getContext();
        }
        if ($page_number < 0) {
            $page_number = 0;
        }
        if ($nb_products < 1) {
            $nb_products = 10;
        }
        if (empty($order_by) || $order_by == 'position') {
            $order_by = 'price';
        }
        if (empty($order_way)) {
            $order_way = 'DESC';
        }
        if ($order_by == 'id_product' || $order_by == 'price' || $order_by == 'date_add' || $order_by == 'date_upd') {
            $order_by_prefix = 'ps';
        } elseif ($order_by == 'name') {
            $order_by_prefix = 'pl';
        }
        if ($order_by == 'quantity') $order_by_prefix = 'stock';

        if ($order_by == 'reference') $order_by_prefix = 'p';

        if (!Validate::isOrderBy($order_by) || !Validate::isOrderWay($order_way)) {
            die(Tools::displayError());
        }

        $prefix  = _DB_PREFIX_;
        $id_shop = Context::getContext()->shop->id;
        $current_date = date('Y-m-d').' 00:00:00';
        $offset = $page_number * $nb_products;
        $limit = $nb_products;

        $filter = '';
        if (isset($_COOKIE['categories']) && $_COOKIE['categories']) {
            $filter = "AND cp.id_category IN(" . $_COOKIE['categories'] .")";
        }

        if (isset($_COOKIE['discount']) && $_COOKIE['discount'] == '1') {
            $filter .= ' AND sp.reduction > 0';
        }

        if (isset($_COOKIE['manufact']) && $_COOKIE['manufact']) {
            $filter .= " AND p.id_manufacturer IN(" . $_COOKIE['manufact'] .")";
        }
        
        if ($count) return Db::getInstance(_PS_USE_SQL_SLAVE_)->getValue("
            SELECT COUNT(DISTINCT p.id_product)
            FROM {$prefix}product AS p

            INNER JOIN {$prefix}product_shop AS ps
            ON (ps.id_product = p.id_product AND ps.id_shop = {$id_shop})

            LEFT JOIN {$prefix}category_product AS cp
            ON p.id_product = cp.id_product

            LEFT JOIN {$prefix}stock_available AS stock
            ON stock.id_product = p.id_product
                AND stock.id_product_attribute = 0
                AND stock.id_shop = {$id_shop} 
                AND stock.id_shop_group = 0

            LEFT JOIN {$prefix}specific_price AS sp
            ON p.id_product = sp.id_product
                AND ps.id_shop = sp.id_shop

            WHERE
                ps.active = 1
            AND stock.quantity > 0
            AND ps.show_price = 1
            {$filter}");

        if (strpos($order_by, '.') > 0) {
            $order_by = explode('.', $order_by);
            $order_by = pSQL($order_by[0]).'.'.pSQL($order_by[1]).'';
        }

        $sql = "
        SELECT
            p.*,
            (p.price - p.price * sp.reduction) AS price_discount,
            sp.reduction,
            ps.*,
            stock.out_of_stock,
            IFNULL (stock.quantity, 0) AS quantity,
            pl.description,
            pl.description_short,
            pl.available_now,
            pl.available_later,
            IFNULL (product_attribute_shop.id_product_attribute, 0) AS id_product_attribute,
            pl.link_rewrite,
            pl.meta_description,
            pl.meta_keywords,
            pl.meta_title,
            pl.name,
            image_shop.id_image AS id_image,
            il.legend,
            m.name AS manufacturer_name
        FROM {$prefix}product AS p

        INNER JOIN {$prefix}product_shop AS ps
        ON  ps.id_product = p.id_product
            AND ps.id_shop = {$id_shop}
            AND ps.active = 1
            AND ps.show_price = 1
        
        LEFT JOIN {$prefix}category_product AS cp
        ON p.id_product = cp.id_product

        LEFT JOIN {$prefix}specific_price AS sp
        ON p.id_product = sp.id_product
            AND ps.id_shop = sp.id_shop

        LEFT JOIN {$prefix}product_attribute_shop AS product_attribute_shop
        ON  p.id_product = product_attribute_shop.id_product
            AND product_attribute_shop.default_on = 1
            AND product_attribute_shop.id_shop={$id_shop}

        LEFT JOIN {$prefix}product_lang AS pl
        ON  p.id_product = pl.id_product
            AND pl.id_lang = {$id_lang}

        LEFT JOIN {$prefix}image_shop AS image_shop
        ON image_shop.id_product = p.id_product
            AND image_shop.cover = 1
            AND image_shop.id_shop = {$id_shop}

        LEFT JOIN {$prefix}stock_available AS stock
        ON stock.id_product = p.id_product
            AND stock.id_product_attribute = 0
            AND stock.id_shop = {$id_shop} 
            AND stock.id_shop_group = 0

        LEFT JOIN {$prefix}image_lang AS il
        ON image_shop.id_image = il.id_image
            AND il.id_lang = {$id_lang}

        LEFT JOIN {$prefix}manufacturer AS m
        ON m.id_manufacturer = p.id_manufacturer

        WHERE ps.active = 1
            AND ps.show_price = 1
            AND stock.quantity > 0
            {$filter}

        GROUP BY p.id_product

        ORDER BY {$order_by_prefix}.{$order_by} {$order_way}

        LIMIT {$offset}, {$limit}";

        $result = Db::getInstance(_PS_USE_SQL_SLAVE_)->executeS($sql);

        foreach ($result as $key => $product) {
            $result[$key]['specific_prices'] = array(
                'reduction' => $product['reduction'],
                'reduction_type' => 'percentage'
            );
            $result[$key]['price'] = isset($product['price_discount']) ? $product['price_discount'] : $product['price'];
            $result[$key]['price_without_reduction'] = $product['price'];
            $result[$key]['features'] = array();
            $result[$key]['link'] = $context->link->getProductLink(
                $product['id_product'],
                $product['link_rewrite'],
                $product['id_category_default'],
                $product['ean13']);
        }
        return $result;
    }

}