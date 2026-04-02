-- Janez Novak naj ima 3 naročila
BEGIN
  neoj_pkg_order.create_order(1); -- customer_id = 1
  neoj_pkg_order.create_order(1);
END;
/

-- Ana Kovač naj ima 2 naročili
BEGIN
  neoj_pkg_order.create_order(2);
END;
/

-- Peter Horvat naj ima 3 naročila
BEGIN
  neoj_pkg_order.create_order(3);
  neoj_pkg_order.create_order(3);
END;
/

-- Maja Zupan ostane samo z 1 naročilom

-- Luka Marinšek dobi še 2 dodatni naročili
BEGIN
  neoj_pkg_order.create_order(5);
  neoj_pkg_order.create_order(5);
END;
/
