-- Vstavimo nekaj produktov
INSERT INTO neoj_products(name, description, price) VALUES ('Prenosnik', '14-inch laptop', 899.99);
INSERT INTO neoj_products(name, description, price) VALUES ('Miška', 'Wireless mouse', 24.50);
INSERT INTO neoj_products(name, description, price) VALUES ('Tipkovnica', 'Mechanical keyboard', 75.00);


-- Dodajmo stranko in avtomatsko ustvarimo naročilo + račun
BEGIN
  neoj_pkg_customer.add_customer('Janez Novak');
END;
/

