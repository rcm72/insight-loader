-- Paket za delo s strankami
CREATE OR REPLACE PACKAGE neoj_pkg_customer AS
  PROCEDURE add_customer(p_name VARCHAR2);
  PROCEDURE delete_customer(p_id NUMBER);
END neoj_pkg_customer;
/

CREATE OR REPLACE PACKAGE BODY neoj_pkg_customer AS
  PROCEDURE add_customer(p_name VARCHAR2) IS
      v_customer_id NUMBER;
  BEGIN
      INSERT INTO neoj_customers(name) VALUES (p_name)
      RETURNING customer_id INTO v_customer_id;

      -- demo: ob dodajanju stranke avtomatsko ustvarimo naro�ilo
      neoj_pkg_order.create_order(v_customer_id);
  END;

  PROCEDURE delete_customer(p_id NUMBER) IS
  BEGIN
      DELETE FROM neoj_customers WHERE customer_id = p_id;
      neoj_pkg_order.cancel_order(p_id);
  END;
END neoj_pkg_customer;
/

-- Paket za delo z naročili
CREATE OR REPLACE PACKAGE neoj_pkg_order AS
  PROCEDURE create_order(p_customer_id NUMBER);
  PROCEDURE cancel_order(p_customer_id NUMBER);
END neoj_pkg_order;
/

CREATE OR REPLACE PACKAGE BODY neoj_pkg_order AS
  PROCEDURE create_order(p_customer_id NUMBER) IS
      v_order_id NUMBER;
      v_invoice_id NUMBER;
  BEGIN
      INSERT INTO neoj_orders(customer_id) VALUES (p_customer_id)
      RETURNING order_id INTO v_order_id;

      -- dodamo nekaj produktov (demo: vedno 2 izdelka)
      INSERT INTO neoj_order_items(order_id, product_id, quantity, unit_price)
      SELECT v_order_id, product_id, 1, price
        FROM (SELECT product_id, price FROM neoj_products WHERE ROWNUM <= 2);

      -- ustvarimo račun
      -- neoj_pkg_invoice.generate_invoice(v_order_id,v_invoice_id);
  END;

  PROCEDURE cancel_order(p_customer_id NUMBER) IS
  BEGIN
      UPDATE neoj_orders
         SET status = 'CANCELLED'
       WHERE customer_id = p_customer_id;
  END;
END neoj_pkg_order;
/

-- Paket za delo z računi
CREATE OR REPLACE PACKAGE neoj_pkg_invoice AS
  PROCEDURE generate_invoice(p_order_id NUMBER, p_invoice_id out number);
END neoj_pkg_invoice;
/

CREATE OR REPLACE PACKAGE BODY neoj_pkg_invoice AS
  PROCEDURE generate_invoice(p_order_id NUMBER, p_invoice_id out number) IS
      v_invoice_id NUMBER;
  BEGIN
      DBMS_OUTPUT.PUT_LINE('p_order_id: ' || p_order_id);  
      INSERT INTO neoj_invoices(order_id) VALUES (p_order_id)
      RETURNING invoice_id INTO v_invoice_id;

      -- kopiramo vse postavke iz naročila
      INSERT INTO neoj_invoice_items(invoice_id, product_id, quantity, unit_price)
      SELECT v_invoice_id, product_id, quantity, unit_price
        FROM neoj_order_items
       WHERE order_id = p_order_id;
       
    p_invoice_id:=v_invoice_id;
  EXCEPTION WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error generating invoice: ' || SQLERRM);  
      RAISE_APPLICATION_ERROR(-20001, 'Error generating invoice: ' || SQLERRM);
  END;
END neoj_pkg_invoice;
/