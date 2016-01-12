require 'test_helper'

class FirstdataIpgTest < Test::Unit::TestCase
  def setup
    @gateway = FirstdataIpgGateway.new fixtures(:firstdata_ipg)
    @credit_card = credit_card
    @amount = 10.0

    @options = {
      # order_id: '1',
      # billing_address: address,
      currency: 978, # 978 for EUR
      # description: 'Store Purchase'
    }
  end

  def test_successful_purchase
    @gateway.expects(:ssl_post).returns(successful_purchase_response)

    response = @gateway.purchase(@amount, @credit_card, @options)
    assert_success response

    assert_equal 'A-bc2abed6-09c1-462d-a9da-30ac6043b99b', response.authorization
    assert response.test?
  end

  def test_failed_purchase
    @gateway.expects(:ssl_post).returns(failed_purchase_response)

    response = @gateway.purchase(@amount, @credit_card, @options)
    assert_failure response
    assert_equal Gateway::STANDARD_ERROR_CODE[:card_declined], response.error_code
  end

  def test_successful_authorize
  end

  def test_failed_authorize
  end

  def test_successful_capture
  end

  def test_failed_capture
  end

  def test_successful_refund
  end

  def test_failed_refund
  end

  def test_successful_void
  end

  def test_failed_void
  end

  def test_successful_verify
  end

  def test_successful_verify_with_failed_void
  end

  def test_failed_verify
  end

  def test_scrub
    assert @gateway.supports_scrubbing?
    assert_equal @gateway.scrub(pre_scrubbed), post_scrubbed
  end

  private

  def pre_scrubbed
    %q(
      opening connection to test.ipg-online.com:443...
      opened
      starting SSL for test.ipg-online.com:443...
      SSL established
      <- "POST /ipgapi/services HTTP/1.1\r\nContent-Type: text/xml\r\nAuthorization: Basic V1MxMjkwMDAwMDA2NzA0Ll8uMTpOTVM5eTFmOXFF\r\nAccept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3\r\nAccept: */*\r\nUser-Agent: Ruby\r\nConnection: close\r\nHost: test.ipg-online.com\r\nContent-Length: 760\r\n\r\n"
      <- "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n  <soap:Body>\n    <ipgapi:IPGApiOrderRequest xmlns:v1=\"http://ipg-online.com/ipgapi/schemas/v1\" xmlns:ipgapi=\"http://ipg-online.com/ipgapi/schemas/ipgapi\">\n<v1:Transaction>\n  <v1:CreditCardTxType>\n    <v1:Type>sale</v1:Type>\n  </v1:CreditCardTxType>\n  <v1:CreditCardData>\n    <v1:CardNumber>5500000000000004</v1:CardNumber>\n    <v1:ExpMonth>09</v1:ExpMonth>\n    <v1:ExpYear>17</v1:ExpYear>\n    <v1:CardCodeValue>123</v1:CardCodeValue>\n  </v1:CreditCardData>\n  <v1:Payment>\n    <v1:ChargeTotal>10.00</v1:ChargeTotal>\n    <v1:Currency>978</v1:Currency>\n  </v1:Payment>\n</v1:Transaction>\n    </ipgapi:IPGApiOrderRequest>\n  </soap:Body>\n</soap:Envelope>\n"
      -> "HTTP/1.1 200 OK\r\n"
      -> "Date: Fri, 29 Jan 2016 05:48:05 GMT\r\n"
      -> "Server: Apache\r\n"
      -> "Set-Cookie: JSESSIONIDSSO=3F4961ACF0C8DB8BA3515D92B192DA93; Path=/; Secure\r\n"
      -> "Set-Cookie: JSESSIONID=1859600187770E8A4235C5380D137CC4.ipg_api_2; Path=/ipgapi; Secure; HttpOnly\r\n"
      -> "Accept: text/xml, text/html, image/gif, image/jpeg, *; q=.2, */*; q=.2\r\n"
      -> "SOAPAction: \"\"\r\n"
      -> "Content-Length: 1621\r\n"
      -> "Connection: close\r\n"
      -> "Content-Type: text/xml;charset=utf-8\r\n"
      -> "\r\n"
      reading 1621 bytes...
      -> ""
      -> "<SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\"><SOAP-ENV:Header/><SOAP-ENV:Body><ipgapi:IPGApiOrderResponse xmlns:ipgapi=\"http://ipg-online.com/ipgapi/schemas/ipgapi\" xmlns:a1=\"http://ipg-online.com/ipgapi/schemas/a1\" xmlns:pay_1_0_0=\"http://api.clickandbuy.com/webservices/pay_1_0_0/\" xmlns:v1=\"http://ipg-online.com/ipgapi/schemas/v1\"><ipgapi:ApprovalCode>Y:SM2713:0016860979:PPXM:9427138169</ipgapi:ApprovalCode><ipgapi:AVSResponse>PPX</ipgapi:AVSResponse><ipgapi:Brand>MASTERCARD</ipgapi:Brand><ipgapi:CommercialServiceProvider>TELECASH</ipgapi:CommercialServiceProvider><ipgapi:OrderId>A-774bd35a-8c39-4be6-9433-75affbc7e203</ipgapi:OrderId><ipgapi:IpgTransactionId>16860979</ipgapi:IpgTransactionId><ipgapi:PaymentType>CREDITCARD</ipgapi:PaymentType><ipgapi:ProcessorApprovalCode>SM2713</ipgapi:ProcessorApprovalCode><ipgapi:ProcessorReceiptNumber>8169</ipgapi:ProcessorReceiptNumber><ipgapi:ProcessorCCVResponse>M</ipgapi:ProcessorCCVResponse><ipgapi:ProcessorReferenceNumber>882713</ipgapi:ProcessorReferenceNumber><ipgapi:ProcessorResponseCode>00</ipgapi:ProcessorResponseCode><ipgapi:ProcessorResponseMessage>Function performed error-free</ipgapi:ProcessorResponseMessage><ipgapi:ProcessorTraceNumber>942713</ipgapi:ProcessorTraceNumber><ipgapi:TDate>1454046486</ipgapi:TDate><ipgapi:TDateFormatted>2016.01.29 06:48:06 (CET)</ipgapi:TDateFormatted><ipgapi:TerminalID>54000015</ipgapi:TerminalID><ipgapi:TransactionResult>APPROVED</ipgapi:TransactionResult><ipgapi:TransactionTime>1454046486</ipgapi:TransactionTime></ipgapi:IPGApiOrderResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>"
      read 1621 bytes
      Conn close
    )
  end

  def post_scrubbed
    %q(
      opening connection to test.ipg-online.com:443...
      opened
      starting SSL for test.ipg-online.com:443...
      SSL established
      <- "POST /ipgapi/services HTTP/1.1\r\nContent-Type: text/xml\r\nAuthorization: Basic [FILTERED]\r\nAccept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3\r\nAccept: */*\r\nUser-Agent: Ruby\r\nConnection: close\r\nHost: test.ipg-online.com\r\nContent-Length: 760\r\n\r\n"
      <- "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n  <soap:Body>\n    <ipgapi:IPGApiOrderRequest xmlns:v1=\"http://ipg-online.com/ipgapi/schemas/v1\" xmlns:ipgapi=\"http://ipg-online.com/ipgapi/schemas/ipgapi\">\n<v1:Transaction>\n  <v1:CreditCardTxType>\n    <v1:Type>sale</v1:Type>\n  </v1:CreditCardTxType>\n  <v1:CreditCardData>\n    <v1:CardNumber>[FILTERED]</v1:CardNumber>\n    <v1:ExpMonth>09</v1:ExpMonth>\n    <v1:ExpYear>17</v1:ExpYear>\n    <v1:CardCodeValue>[FILTERED]</v1:CardCodeValue>\n  </v1:CreditCardData>\n  <v1:Payment>\n    <v1:ChargeTotal>10.00</v1:ChargeTotal>\n    <v1:Currency>978</v1:Currency>\n  </v1:Payment>\n</v1:Transaction>\n    </ipgapi:IPGApiOrderRequest>\n  </soap:Body>\n</soap:Envelope>\n"
      -> "HTTP/1.1 200 OK\r\n"
      -> "Date: Fri, 29 Jan 2016 05:48:05 GMT\r\n"
      -> "Server: Apache\r\n"
      -> "Set-Cookie: JSESSIONIDSSO=3F4961ACF0C8DB8BA3515D92B192DA93; Path=/; Secure\r\n"
      -> "Set-Cookie: JSESSIONID=1859600187770E8A4235C5380D137CC4.ipg_api_2; Path=/ipgapi; Secure; HttpOnly\r\n"
      -> "Accept: text/xml, text/html, image/gif, image/jpeg, *; q=.2, */*; q=.2\r\n"
      -> "SOAPAction: \"\"\r\n"
      -> "Content-Length: 1621\r\n"
      -> "Connection: close\r\n"
      -> "Content-Type: text/xml;charset=utf-8\r\n"
      -> "\r\n"
      reading 1621 bytes...
      -> ""
      -> "<SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\"><SOAP-ENV:Header/><SOAP-ENV:Body><ipgapi:IPGApiOrderResponse xmlns:ipgapi=\"http://ipg-online.com/ipgapi/schemas/ipgapi\" xmlns:a1=\"http://ipg-online.com/ipgapi/schemas/a1\" xmlns:pay_1_0_0=\"http://api.clickandbuy.com/webservices/pay_1_0_0/\" xmlns:v1=\"http://ipg-online.com/ipgapi/schemas/v1\"><ipgapi:ApprovalCode>Y:SM2713:0016860979:PPXM:9427138169</ipgapi:ApprovalCode><ipgapi:AVSResponse>PPX</ipgapi:AVSResponse><ipgapi:Brand>MASTERCARD</ipgapi:Brand><ipgapi:CommercialServiceProvider>TELECASH</ipgapi:CommercialServiceProvider><ipgapi:OrderId>A-774bd35a-8c39-4be6-9433-75affbc7e203</ipgapi:OrderId><ipgapi:IpgTransactionId>16860979</ipgapi:IpgTransactionId><ipgapi:PaymentType>CREDITCARD</ipgapi:PaymentType><ipgapi:ProcessorApprovalCode>SM2713</ipgapi:ProcessorApprovalCode><ipgapi:ProcessorReceiptNumber>8169</ipgapi:ProcessorReceiptNumber><ipgapi:ProcessorCCVResponse>M</ipgapi:ProcessorCCVResponse><ipgapi:ProcessorReferenceNumber>882713</ipgapi:ProcessorReferenceNumber><ipgapi:ProcessorResponseCode>00</ipgapi:ProcessorResponseCode><ipgapi:ProcessorResponseMessage>Function performed error-free</ipgapi:ProcessorResponseMessage><ipgapi:ProcessorTraceNumber>942713</ipgapi:ProcessorTraceNumber><ipgapi:TDate>1454046486</ipgapi:TDate><ipgapi:TDateFormatted>2016.01.29 06:48:06 (CET)</ipgapi:TDateFormatted><ipgapi:TerminalID>54000015</ipgapi:TerminalID><ipgapi:TransactionResult>APPROVED</ipgapi:TransactionResult><ipgapi:TransactionTime>1454046486</ipgapi:TransactionTime></ipgapi:IPGApiOrderResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>"
      read 1621 bytes
      Conn close
    )
  end

  def successful_purchase_response
    %(<SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\"><SOAP-ENV:Header/><SOAP-ENV:Body><ipgapi:IPGApiOrderResponse xmlns:ipgapi=\"http://ipg-online.com/ipgapi/schemas/ipgapi\" xmlns:a1=\"http://ipg-online.com/ipgapi/schemas/a1\" xmlns:pay_1_0_0=\"http://api.clickandbuy.com/webservices/pay_1_0_0/\" xmlns:v1=\"http://ipg-online.com/ipgapi/schemas/v1\"><ipgapi:ApprovalCode>Y:SM2507:0016929932:PPXM:9725077748</ipgapi:ApprovalCode><ipgapi:AVSResponse>PPX</ipgapi:AVSResponse><ipgapi:Brand>MASTERCARD</ipgapi:Brand><ipgapi:CommercialServiceProvider>TELECASH</ipgapi:CommercialServiceProvider><ipgapi:OrderId>A-bc2abed6-09c1-462d-a9da-30ac6043b99b</ipgapi:OrderId><ipgapi:IpgTransactionId>16929932</ipgapi:IpgTransactionId><ipgapi:PaymentType>CREDITCARD</ipgapi:PaymentType><ipgapi:ProcessorApprovalCode>SM2507</ipgapi:ProcessorApprovalCode><ipgapi:ProcessorReceiptNumber>7748</ipgapi:ProcessorReceiptNumber><ipgapi:ProcessorCCVResponse>M</ipgapi:ProcessorCCVResponse><ipgapi:ProcessorReferenceNumber>882507</ipgapi:ProcessorReferenceNumber><ipgapi:ProcessorResponseCode>00</ipgapi:ProcessorResponseCode><ipgapi:ProcessorResponseMessage>Function performed error-free</ipgapi:ProcessorResponseMessage><ipgapi:ProcessorTraceNumber>972507</ipgapi:ProcessorTraceNumber><ipgapi:TDate>1454565706</ipgapi:TDate><ipgapi:TDateFormatted>2016.02.04 07:01:46 (CET)</ipgapi:TDateFormatted><ipgapi:TerminalID>54000015</ipgapi:TerminalID><ipgapi:TransactionResult>APPROVED</ipgapi:TransactionResult><ipgapi:TransactionTime>1454565706</ipgapi:TransactionTime></ipgapi:IPGApiOrderResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>)
  end

  def failed_purchase_response
    %(<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Header/><SOAP-ENV:Body><SOAP-ENV:Fault><faultcode>SOAP-ENV:Client</faultcode><faultstring xml:lang="en">ProcessingException</faultstring><detail><ipgapi:IPGApiOrderResponse xmlns:ipgapi="http://ipg-online.com/ipgapi/schemas/ipgapi" xmlns:a1="http://ipg-online.com/ipgapi/schemas/a1" xmlns:pay_1_0_0="http://api.clickandbuy.com/webservices/pay_1_0_0/" xmlns:v1="http://ipg-online.com/ipgapi/schemas/v1"><ipgapi:ApprovalCode>N:-2303:Invalid credit card number</ipgapi:ApprovalCode><ipgapi:Brand>VISA</ipgapi:Brand><ipgapi:CommercialServiceProvider>TELECASH</ipgapi:CommercialServiceProvider><ipgapi:ErrorMessage>SGS-002303: Invalid credit card number</ipgapi:ErrorMessage><ipgapi:OrderId>A-f8288370-2da5-4f54-829b-3279b76ef9d6</ipgapi:OrderId><ipgapi:IpgTransactionId>16930150</ipgapi:IpgTransactionId><ipgapi:PaymentType>CREDITCARD</ipgapi:PaymentType><ipgapi:TDate>1454568203</ipgapi:TDate><ipgapi:TDateFormatted>2016.02.04 07:43:23 (CET)</ipgapi:TDateFormatted><ipgapi:TransactionResult>FAILED</ipgapi:TransactionResult><ipgapi:TransactionTime>1454568203</ipgapi:TransactionTime></ipgapi:IPGApiOrderResponse></detail></SOAP-ENV:Fault></SOAP-ENV:Body></SOAP-ENV:Envelope>)
  end

  def successful_authorize_response
    %(<SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\"><SOAP-ENV:Header/><SOAP-ENV:Body><ipgapi:IPGApiOrderResponse xmlns:ipgapi=\"http://ipg-online.com/ipgapi/schemas/ipgapi\" xmlns:a1=\"http://ipg-online.com/ipgapi/schemas/a1\" xmlns:pay_1_0_0=\"http://api.clickandbuy.com/webservices/pay_1_0_0/\" xmlns:v1=\"http://ipg-online.com/ipgapi/schemas/v1\"><ipgapi:ApprovalCode>Y:SM2555:0016930152:PPXM:9725557793</ipgapi:ApprovalCode><ipgapi:AVSResponse>PPX</ipgapi:AVSResponse><ipgapi:Brand>MASTERCARD</ipgapi:Brand><ipgapi:CommercialServiceProvider>TELECASH</ipgapi:CommercialServiceProvider><ipgapi:OrderId>A-b273ee9e-52eb-462d-9c41-59c03257ea79</ipgapi:OrderId><ipgapi:IpgTransactionId>16930152</ipgapi:IpgTransactionId><ipgapi:PaymentType>CREDITCARD</ipgapi:PaymentType><ipgapi:ProcessorApprovalCode>SM2555</ipgapi:ProcessorApprovalCode><ipgapi:ProcessorReceiptNumber>7793</ipgapi:ProcessorReceiptNumber><ipgapi:ProcessorCCVResponse>M</ipgapi:ProcessorCCVResponse><ipgapi:ProcessorReferenceNumber>882555</ipgapi:ProcessorReferenceNumber><ipgapi:ProcessorResponseCode>00</ipgapi:ProcessorResponseCode><ipgapi:ProcessorResponseMessage>Function performed error-free</ipgapi:ProcessorResponseMessage><ipgapi:ProcessorTraceNumber>972555</ipgapi:ProcessorTraceNumber><ipgapi:ReferencedTDate>1454568267</ipgapi:ReferencedTDate><ipgapi:TDate>1454568270</ipgapi:TDate><ipgapi:TDateFormatted>2016.02.04 07:44:30 (CET)</ipgapi:TDateFormatted><ipgapi:TerminalID>54000015</ipgapi:TerminalID><ipgapi:TransactionResult>APPROVED</ipgapi:TransactionResult><ipgapi:TransactionTime>1454568270</ipgapi:TransactionTime></ipgapi:IPGApiOrderResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>)
  end

  def failed_authorize_response
  end

  def successful_capture_response
    %(<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Header/><SOAP-ENV:Body><ipgapi:IPGApiOrderResponse xmlns:ipgapi="http://ipg-online.com/ipgapi/schemas/ipgapi" xmlns:a1="http://ipg-online.com/ipgapi/schemas/a1" xmlns:pay_1_0_0="http://api.clickandbuy.com/webservices/pay_1_0_0/" xmlns:v1="http://ipg-online.com/ipgapi/schemas/v1"><ipgapi:ApprovalCode>Y:SM2555:0016930152:PPXM:9725557793</ipgapi:ApprovalCode><ipgapi:AVSResponse>PPX</ipgapi:AVSResponse><ipgapi:Brand>MASTERCARD</ipgapi:Brand><ipgapi:CommercialServiceProvider>TELECASH</ipgapi:CommercialServiceProvider><ipgapi:OrderId>A-b273ee9e-52eb-462d-9c41-59c03257ea79</ipgapi:OrderId><ipgapi:IpgTransactionId>16930152</ipgapi:IpgTransactionId><ipgapi:PaymentType>CREDITCARD</ipgapi:PaymentType><ipgapi:ProcessorApprovalCode>SM2555</ipgapi:ProcessorApprovalCode><ipgapi:ProcessorReceiptNumber>7793</ipgapi:ProcessorReceiptNumber><ipgapi:ProcessorCCVResponse>M</ipgapi:ProcessorCCVResponse><ipgapi:ProcessorReferenceNumber>882555</ipgapi:ProcessorReferenceNumber><ipgapi:ProcessorResponseCode>00</ipgapi:ProcessorResponseCode><ipgapi:ProcessorResponseMessage>Function performed error-free</ipgapi:ProcessorResponseMessage><ipgapi:ProcessorTraceNumber>972555</ipgapi:ProcessorTraceNumber><ipgapi:ReferencedTDate>1454568267</ipgapi:ReferencedTDate><ipgapi:TDate>1454568270</ipgapi:TDate><ipgapi:TDateFormatted>2016.02.04 07:44:30 (CET)</ipgapi:TDateFormatted><ipgapi:TerminalID>54000015</ipgapi:TerminalID><ipgapi:TransactionResult>APPROVED</ipgapi:TransactionResult><ipgapi:TransactionTime>1454568270</ipgapi:TransactionTime></ipgapi:IPGApiOrderResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>)
  end

  def failed_capture_response
  end

  def successful_refund_response
  end

  def failed_refund_response
  end

  def successful_void_response
  end

  def failed_void_response
  end
end
