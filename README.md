https://www.bankrate.com/finance/credit-cards/credit-card-information-the-basics-to-know/#terms

https://www.bankrate.com/finance/credit-cards/what-is-penalty-apr/

https://www.bankrate.com/finance/credit-cards/what-is-credit-card-apr/#what-are-the-different-types-of-apr

Logic tạm thời của credit spending sẽ là:
- User không cần phải nhập APR nữa vì nó giao động trên thị trường
- Sẽ hiển thị thông báo yêu cầu người dùng cập nhật lại dư nợ của thẻ tín dụng vì đã quá hạn
- Thông báo đến hạn thanh toán thẻ tín dụng
- Thông báo nếu quá 45 ngày không thanh toán sẽ bị áp phí
- Thông báo nếu quá 60 ngày sẽ bị áp phí penalty APR

Mỗi thông báo sẽ có thêm mục cập nhật số dư để người dùng nắm được dư nợ tăng lên bao nhiêu,...

VỀ THẺ TÍN DỤNG NGÂN HÀNG:
- Trong một tháng sẽ có 

Logic:
KHÔNG CHO PHÉP TẠO CREDIT SPENDING VÀ CREDIT PAYMENT TẠI TƯƠNG LAI
Tìm earliest credit spending
Tạo persistent các payment period tính từ thời điểm earliest credit spending
Mỗi payment period object chứa:
    - @Index statementDate
    - paymentDueDate
    - enum PaymentStatus {underMinimumPaid, atLeastMinimumPaid, fullPayment}
    - List spendingTransactions
    - List paymentTransactions
Các getters:
    - get fullPaymentAmount
    - get minimumPaymentAmount

LÃI CỘNG THÊM SẼ TÍNH VÀO DƯ NỢ CỦA MÌNH!!!!!!!!!!!!!!!!!!!
