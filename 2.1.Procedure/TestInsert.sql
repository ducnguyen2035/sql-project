--trả về lỗi require id number
exec dbo.usp_User_Insert   
    @Phone_number ='0123456789',
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
--trả về lỗi id number đã tồn tại
exec dbo.usp_User_Insert
	@ID_number ='001099001111',--trùng với user id 101
    @Phone_number ='0123456789',
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
--trả về lỗi phải đủ 12 chữ số
exec dbo.usp_User_Insert
	@ID_number ='01234567891011',-- thừa 1 chữ số
    @Phone_number ='0123456789',
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
exec dbo.usp_User_Insert
	@ID_number ='01234567891',-- thiếu 1 chữ số
    @Phone_number ='0123456789',
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
--trả về lỗi yêu cầu phone number
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
--trả về lỗi phone number đã tồn tại
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='0123456789',--trung voi user id 101
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
--trả về lỗi phone number không bắt đầu bằng số 0
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='01234567891',
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
---trả về lỗi phone number không có đúng 10 chữ số
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='012345678910',-- dư 2 chữ số
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='012345678',-- thiếu 1 chữ số
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
-- trả về lỗi phone number chứa ký tự không phải chữ số
exec dbo.usp_User_Insert
    @ID_number ='012345678910',
    @Phone_number ='012a456789',-- chứa ký tự không phải chữ số
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
--trả về lỗi yêu cầu email
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='0123456789',
    @Email =null,
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
--trả về lỗi email đã tồn tại
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='0123456789',
    @Email ='nguyenvana@gmail.com',--trùng với email user id 101
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
--trả về lỗi email cần phải có dấu @
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='0123456789',
    @Email ='abchcmut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
-- trả về lỗi email không được tồn tại dấu cách
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='0123456789',
    @Email ='abc@hc mut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
-- trả về lỗi yêu cầu full name
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='0123456789',
    @Email ='abc@hcmut.edu.vn',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
-- trả về lỗi full name tồn tại khoảng trắng ở đầu hoặc cuối
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='0123456789',
    @Email ='abc@hcmut.edu.vn',
    @Full_name =' Dang Kieu D',--khoảng trắng ở đầu
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='0123456789',
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D   ',--khoảng trắng ở cuối
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
-- trả về lỗi full name tồn tại nhiều khoảng trắng ở giữa
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='0123456789',
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang   Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
--trả về lỗi full name tồn tại ký tự không phải chữ cái
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='0123456789',
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D6',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'
-- trả về lỗi giới tính không hợp lệ
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='0123456789',
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Mal',
    @Birthday ='1975-4-30',
    @Account_status ='active'
-- trả về lỗi birthday ko thể thuộc về tương lai
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='0123456789',
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='2026-1-1',
    @Account_status ='active'
-- trả về lỗi tuổi không thuộc khoảng hợp lệ
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='0123456789',
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1800-4-30',
    @Account_status ='active'
-- trả về lỗi account status không hợp lệ
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='0123456789',
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='activ'
-- insert thành công
exec dbo.usp_User_Insert
	@ID_number ='012345678910',
    @Phone_number ='0123456789',
    @Email ='abc@hcmut.edu.vn',
    @Full_name ='Dang Kieu D',
    @Gender ='Male',
    @Birthday ='1975-4-30',
    @Account_status ='active'