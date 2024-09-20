-- 1)	Liệt kê tên nhân viên và tên phòng ban của họ
SELECT e.name, d.department_name
FROM employees e 
JOIN departments d ON e.department_id = d.department_id ;

-- 2)	Liệt kê tên nhân viên và tên dự án mà họ tham gia
SELECT e.name, p.project_name
FROM employees e 
JOIN employee_projects ep ON e.employee_id = ep.employee_id 
JOIN projects p ON ep.project_id = p.project_id ;

-- 3)	Liệt kê tên phòng ban, tên dự án và tên nhân viên tham gia dự án đó.
SELECT d.department_name, p.project_name, e.name 
FROM departments d 
JOIN projects p ON d.department_id = p.department_id 
JOIN employee_projects ep ON ep.project_id = p.project_id 
JOIN employees e ON e.employee_id = ep.employee_id ;

-- 4)	Tính tổng lương của nhân viên tham gia từng dự án
SELECT p.project_name, sum(e.salary) as tong_luong
FROM projects p 
JOIN employee_projects ep ON p.project_id = ep.project_id 
JOIN employees e ON e.employee_id = ep.employee_id 
GROUP BY p.project_name 
;

-- 5)	Liệt kê tên nhân viên, tên quản lý của họ và tên dự án họ tham gia
SELECT e.name, m.name as manager, p.project_name
FROM employees e 
JOIN employees m ON e.manager_id = m.employee_id 
JOIN employee_projects ep ON e.employee_id = ep.employee_id 
JOIN projects p ON p.project_id = ep.project_id ;

-- 6)	Liệt kê tên phòng ban và số lượng nhân viên tham gia dự án của từng phòng ban
SELECT d.department_name, count(*) as so_nhan_vien
FROM departments d 
JOIN employees e ON d.department_id = e.department_id 
WHERE EXISTS (SELECT ep.employee_id FROM employee_projects ep WHERE ep.employee_id = e.employee_id)
GROUP BY d.department_name ;

-- 7)	Tìm tên nhân viên có lương cao nhất tham gia trong mỗi dự án
SELECT tbl.project_name, e.name, e.salary
FROM employees e JOIN employee_projects ep ON e.employee_id = ep.employee_id 
JOIN (
	SELECT ep.project_id, p.project_name, max(e.salary) as max_salary
	FROM employee_projects ep 
	JOIN employees e ON ep.employee_id = e.employee_id 
	JOIN projects p ON p.project_id = ep.project_id 
	GROUP BY ep.project_id
	) as tbl ON ep.project_id = tbl.project_id AND e.salary = tbl.max_salary
;

-- 8)	Liệt kê tên dự án và tổng số nhân viên tham gia, sắp xếp theo tổng số nhân viên giảm dần
SELECT p.project_name, count(*) as tong_nhan_vien
FROM projects p JOIN employee_projects ep ON p.project_id = ep.project_id 
GROUP BY p.project_name
ORDER BY tong_nhan_vien DESC;

-- 9)	Tính lương trung bình của nhân viên trong từng phòng ban tham gia dự án
SELECT d.department_name, AVG(e.salary) as luong_tb
FROM departments d JOIN employees e ON d.department_id = e.department_id 
GROUP BY d.department_name ;

-- 10)	Tìm tên nhân viên và dự án mà họ tham gia ít nhất một lần trong mỗi phòng ban
SELECT e.name, p.project_name, COUNT(0) so_du_an
FROM employees e 
JOIN employee_projects ep ON e.employee_id = ep.employee_id
JOIN projects p ON p.project_id = ep.project_id 
JOIN departments d ON e.department_id = d.department_id
GROUP BY e.name, p.project_name 
HAVING so_du_an > 0

-- HAVING COUNT(DISTINCT d.department_id) = (SELECT COUNT(0) FROM departments) -- TH tham gia đủ tất cả dự án
;

-- 11)	Tìm tên nhân viên và số lượng dự án mà họ tham gia nhiều nhất
SELECT e.name, count(*) as so_du_an
FROM employees e JOIN employee_projects ep ON e.employee_id = ep.employee_id
GROUP BY e.name 
HAVING so_du_an = (SELECT MAX(so_du_an) FROM (SELECT count(*) as so_du_an FROM employee_projects GROUP BY employee_id) AS tb1)
;

-- 12)	Tìm tên phòng ban và số lượng dự án mà phòng ban đó quản lý nhiều nhất
SELECT d.department_name, count(*) as so_du_an 
FROM departments d JOIN projects p ON d.department_id = p.department_id
GROUP BY department_name
HAVING so_du_an = (SELECT count(*) AS so_du_an FROM projects p GROUP BY p.department_id ORDER BY so_du_an DESC LIMIT 1);

-- 13)	Tìm tên nhân viên có lương thấp nhất trong từng dự án
SELECT tbl.project_name, e.name, e.salary
FROM employees e JOIN employee_projects ep ON e.employee_id = ep.employee_id 
JOIN (
	SELECT ep.project_id, p.project_name, min(e.salary) as min_salary
	FROM employee_projects ep JOIN employees e ON ep.employee_id = e.employee_id 
	JOIN projects p ON p.project_id = ep.project_id 
	GROUP BY ep.project_id) as tbl ON ep.project_id = tbl.project_id AND e.salary = tbl.min_salary
;

-- 14)	Liệt kê tên tất cả các dự án không có nhân viên tham gia
SELECT p.project_name
FROM projects p 
WHERE p.project_id NOT IN (SELECT ep.project_id from employee_projects ep);

-- 15)	Tìm tên nhân viên có lương cao nhất và thấp nhất trong mỗi phòng ban
SELECT d.department_name , e.name , e.salary 
FROM employees e 
JOIN (
	SELECT e.department_id, max(salary) AS max_salary, min(salary) AS min_salary
	FROM employees e
	GROUP BY department_id 
) tbl ON e.department_id = tbl.department_id AND (e.salary = tbl.max_salary OR e.salary = tbl.min_salary)
JOIN departments d ON e.department_id = d.department_id 
;

-- 16)	Tính tổng lương và số lượng nhân viên cho từng dự án trong mỗi phòng ban
SELECT d.department_name, p.project_name , count(*) AS so_nhan_vien, sum(e.salary) AS tong_luong
FROM departments d 
JOIN projects p ON d.department_id = p.project_id 
JOIN employee_projects ep ON ep.project_id = p.project_id
JOIN employees e ON e.employee_id = ep.employee_id AND e.department_id = d.department_id 
GROUP BY d.department_id, p.project_name ;

-- 17)	Tìm tên các nhân viên không tham gia bất kỳ dự án nào
SELECT e.employee_id, COUNT(ep.project_id) as so_du_an
FROM employees e 
LEFT JOIN employee_projects ep ON e.employee_id = ep.employee_id
GROUP BY e.employee_id 
HAVING so_du_an = 0;

-- 18)	Tính tổng số dự án mà mỗi phòng ban đang quản lý
SELECT d.*, COUNT(p.project_id) AS tong_du_an 
FROM departments d 
JOIN projects p ON d.department_id = p.department_id 
GROUP BY d.department_id ;

-- 19)	Tìm tên nhân viên và tên dự án mà nhân viên có lương cao nhất tham gia trong từng phòng ban
SELECT d.department_name , e.name , e.salary , p.project_name 
FROM departments d 
JOIN employees e ON e.department_id = d.department_id 
JOIN (
	SELECT d.*, MAX(e.salary) AS max_salary
	FROM departments d 
	JOIN employees e ON d.department_id = e.department_id 
	GROUP BY d.department_id 
) tbl ON d.department_id = tbl.department_id AND e.salary = tbl.max_salary
JOIN employee_projects ep ON ep.employee_id = e.employee_id 
JOIN projects p ON p.project_id = ep.project_id ;
;

-- 20)	Tính tổng lương của nhân viên trong mỗi phòng ban theo từng dự án mà không có nhân viên tham gia dự án
select d.*, SUM(e.salary) AS tong_luong
FROM departments d 
JOIN employees e ON d.department_id = e.department_id 
WHERE e.employee_id NOT IN (
	SELECT ep1.employee_id 
	FROM departments d1
	JOIN projects p1 ON d1.department_id = p1.department_id 
	JOIN employee_projects ep1 ON p1.project_id = ep1.project_id 
	WHERE d1.department_id = d.department_id )
GROUP BY d.department_id 
;
