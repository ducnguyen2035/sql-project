-- yêu cầu user id
exec dbo.usp_User_Update
	@User_ID=null
--user id không tồn tại
exec dbo.usp_User_Update
	@User_ID='204'
-- id number phải có đúng 12 số
exec dbo.usp_User_Update
	@User_ID='203',
	@ID_number='5678910111211'-- dư 1 số
exec dbo.usp_User_Update
	@User_ID='203',
	@ID_number='56789101112'-- thiếu 1 số
--id number được dùng bởi user khác
exec dbo.usp_User_Update
	@User_ID='203',
	@ID_number='001098002222' -- dùng bởi user id 102
--phone number không bắt đầu bằng số 0
exec dbo.usp_User_Update
	@User_ID='203',
	@Phone_number='1123456789'
-- phone number khác 10 chữ số
exec dbo.usp_User_Update
	@User_ID='203',
	@Phone_number='012345678910'-- nhiều hơn 10 số
exec dbo.usp_User_Update
	@User_ID='203',
	@Phone_number='012345678'-- ít hơn 10 số
--phone number tồn tại ký tự khác chữ số
exec dbo.usp_User_Update
	@User_ID='203',
	@Phone_number='0123456s89'
--phone number được dùng bởi người khác
exec dbo.usp_User_Update
	@User_ID='203',
	@Phone_number='0909456789'--dùng bới user id 104
-- email thiếu @
exec dbo.usp_User_Update
	@User_ID='203',
	@Email='applegmail.com'
--email có khoảng trắng
exec dbo.usp_User_Update
	@User_ID='203',
	@Email='app le@gmail.com'
--email được dùng bởi người khác
exec dbo.usp_User_Update
	@User_ID='203',
	@Email='phamthid@shop.com'
-- full name có tồn tại ký tự khác chữ cái trong tên
exec dbo.usp_User_Update
	@User_ID='203',
	@Full_name='Doan Kieu D6'
-- full name có khoảng trắng trước hoặc sau
exec dbo.usp_User_Update
	@User_ID='203',
	@Full_name='Doan Kieu D '-- có khoảng trắng ở sau
-- full name có khoảng trắng trước 
exec dbo.usp_User_Update
	@User_ID='203',
	@Full_name=' Doan Kieu D'-- có khoảng trắng ở trước
-- full name có khoảng trắng ở giữa
exec dbo.usp_User_Update
	@User_ID='203',
	@Full_name='Doan  Kieu D'
-- gender không hợp lệ
exec dbo.usp_User_Update
	@User_ID='203',
	@Gender='Femal'
--birthday trong tương lai
exec dbo.usp_User_Update
	@User_ID='203',
	@Birthday='2070-1-1'
--birthday không nằm trong khoảng hợp lệ
exec dbo.usp_User_Update
	@User_ID='203',
	@Birthday='1800-1-1'
-- account status không hợp lệ
exec dbo.usp_User_Update
	@User_ID='203',
	@Account_status='restricte'