## Checkpoint logic:
- Tạo một list các checkpoint object
- Vẫn generate ra các statement như bình thường, check start date có trùng với checkpoint hay không
- Nếu trùng với checkpoint thì chỉnh sửa giá trị balanceAtEndDate của previousStatement của statement đó
  - Trong đó, nếu checkpointWithInterest == true thì vẫn cứ để giá trị interest là 0.
  - Kiểm tra cả biến bool checkpointWithInterest để xác định xem statement sau có phải charge thêm interest hay không 
-   

## Add thêm một tính năng để người dùng lựa chọn 1 payment có phải là full payment không
  - bool isFullPayment
  - Chỉ thay đổi đc nếu là lastest payment trong kỳ
  - Chỉ có thể tick nếu payment amount lớn hơn balanceToPay (không tính interest, vì giá trị interest chỉ là giá trị tham khảo)
  - Khi có fullpayment trong kỳ, ta sẽ xác định được kỳ đó đã được thanh toán full, không xác định bằng việc tính toán nữa
- Bằng các cách trên, ta có thể loại bỏ việc yêu cầu người dùng phải nhập chính xác từng ly từng tí
