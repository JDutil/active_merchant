module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class FirstdataIpgGateway < Gateway
      self.test_url = 'https://test.ipg-online.com/ipgapi/services'
      self.live_url = 'https://ipg-online.com/ipgapi/services'

      self.default_currency = 978 # for EUR
      self.display_name = 'FirstData IPG'
      self.homepage_url = 'http://www.firstdata.com'
      self.money_format = :dollars
      self.ssl_version = :TLSv1 # TODO Should be updated on 1/27/2016?
      self.supported_cardtypes = [:visa, :master, :american_express, :diners_club, :jcb]
      self.supported_countries = ['GR', 'FR'] # TODO update with full list should be europe and south american countries.

      STANDARD_ERROR_CODE_MAPPING = {
        'N:-2303:Invalid credit card number' => STANDARD_ERROR_CODE[:card_declined]
      }

      def initialize(options={})
        requires! options, :user_id, :password, :pem, :pem_cert, :pem_password
        super
      end

      def purchase(money, payment, options = {})
        # post = {}
        # add_invoice(post, money, options)
        # add_payment(post, payment)
        # add_address(post, payment, options)
        # add_customer_data(post, options)

        xml = Builder::XmlMarkup.new(indent: 2)
        xml.tag! 'v1:Transaction' do
          xml.tag! 'v1:CreditCardTxType' do
            xml.tag! 'v1:Type', 'sale'
          end
          xml.tag! 'v1:CreditCardData' do
            xml.tag! 'v1:CardNumber', payment.number
            xml.tag! 'v1:ExpMonth', format(payment.month, :two_digits)
            xml.tag! 'v1:ExpYear', format(payment.year, :two_digits)
            if payment.verification_value?
              xml.tag! 'v1:CardCodeValue', payment.verification_value
            end
          end
          xml.tag! 'v1:Payment' do
            xml.tag! 'v1:ChargeTotal', amount(money)
            xml.tag! 'v1:Currency', (options[:currency] || default_currency)
          end
        end

        commit('sale', xml)
      end

      def authorize(money, payment, options={})
        # post = {}
        # add_invoice(post, money, options)
        # add_payment(post, payment)
        # add_address(post, payment, options)
        # add_customer_data(post, options)

        xml = Builder::XmlMarkup.new(indent: 2)
        xml.tag! 'v1:Transaction' do
          xml.tag! 'v1:CreditCardTxType' do
            xml.tag! 'v1:Type', 'preAuth'
          end
          xml.tag! 'v1:CreditCardData' do
            xml.tag! 'v1:CardNumber', payment.number
            xml.tag! 'v1:ExpMonth', format(payment.month, :two_digits)
            xml.tag! 'v1:ExpYear', format(payment.year, :two_digits)
            if payment.verification_value?
              xml.tag! 'v1:CardCodeValue', payment.verification_value
            end
          end
          xml.tag! 'v1:Payment' do
            xml.tag! 'v1:ChargeTotal', amount(money)
            xml.tag! 'v1:Currency', (options[:currency] || default_currency)
          end
        end

        commit('authonly', xml)
      end

      def capture(money, authorization, options={})
        xml = Builder::XmlMarkup.new(indent: 2)
        xml.tag! 'v1:Transaction' do
          xml.tag! 'v1:CreditCardTxType' do
            xml.tag! 'v1:Type', 'postAuth'
          end
          xml.tag! 'v1:Payment' do
            xml.tag! 'v1:ChargeTotal', amount(money)
            xml.tag! 'v1:Currency', (options[:currency] || default_currency)
          end
          xml.tag! 'v1:TransactionDetails' do
            # When using hosted checkout we don't have the store order id to send.
            # So IPG will generate and provide us their own order id the response[:oid].
            # We will use the IPG oid first, and we can fall back to the store order id.
            xml.tag! 'v1:OrderId', authorization || options[:order_id]
          end
        end

        commit('capture', xml)
      end

      def refund(money, authorization, options={})
        xml = Builder::XmlMarkup.new(indent: 2)
        xml.tag! 'v1:Transaction' do
          xml.tag! 'v1:CreditCardTxType' do
            xml.tag! 'v1:Type', 'return'
          end
          xml.tag! 'v1:Payment' do
            xml.tag! 'v1:ChargeTotal', amount(money)
            xml.tag! 'v1:Currency', (options[:currency] || default_currency)
          end
          xml.tag! 'v1:TransactionDetails' do
            # When using hosted checkout we don't have the store order id to send.
            # So IPG will generate and provide us their own order id the response[:oid].
            # We will use the IPG oid first, and we can fall back to the store order id.
            xml.tag! 'v1:OrderId', authorization || options[:order_id]
          end
        end

        commit('refund', xml)
      end

      def void(authorization, options={})
        xml = Builder::XmlMarkup.new(indent: 2)
        xml.tag! 'v1:Transaction' do
          xml.tag! 'v1:CreditCardTxType' do
            xml.tag! 'v1:Type', 'void'
          end
          xml.tag! 'v1:TransactionDetails' do
            # When using hosted checkout we don't have the store order id to send.
            # So IPG will generate and provide us their own order id the response[:oid].
            # We will use the IPG oid first, and we can fall back to the store order id.
            xml.tag! 'v1:OrderId', authorization || options[:order_id]
            xml.tag! 'v1:TDate', options[:tdate]
            # If you have assigned a transaction ID (MerchantTransactionId) in the original transaction,
            # you can alternatively submit this ID as ReferencedMerchantTransactionId instead of sending a TDate.'
            # xml.tag! 'v1:ReferencedMerchantTransactionId', options[:merchant_transaction_id]
          end
        end

        commit('void', xml)
      end

      def verify(credit_card, options={})
        MultiResponse.run(:use_first_response) do |r|
          r.process { authorize(100, credit_card, options) }
          r.process(:ignore_result) { void(r.authorization, options) }
        end
      end

      def supports_scrubbing?
        true
      end

      def scrub(transcript)
        transcript
          .gsub(%r((Authorization: Basic )\w+), '\1[FILTERED]')
          .gsub(%r((<v1:CardNumber>).+(</v1:CardNumber>)), '\1[FILTERED]\2')
          .gsub(%r((<v1:CardCodeValue>).+(</v1:CardCodeValue>)), '\1[FILTERED]\2')
      end

      private

      def add_customer_data(post, options)
      end

      def add_address(post, creditcard, options)
      end

      def add_invoice(post, money, options)
        post[:amount] = amount(money)
        post[:currency] = (options[:currency] || currency(money))
      end

      def add_payment(post, payment)
      end

      def amount(money)
        sprintf "%.2f", money
      end

      def parse(body)
        response = {}

        xml = REXML::Document.new(body)
        xml.each_recursive do |element|
          if element.text
            response[element.name.underscore.to_sym] = element.text
          end
        end

        response
      end

      def commit(action, parameters)
        raw = begin
          ssl_post(url, post_data(action, parameters), headers)
        rescue ResponseError => e
          e.response.body
        end

        response = begin
          parse(raw)
        rescue REXML::ParseException
          { error_message: 'This request requires HTTP authentication.' }
        end

        Response.new(
          success_from(response),
          message_from(response),
          response,
          authorization: authorization_from(response),
          avs_result: AVSResult.new(code: response[:avs_response]),
          cvv_result: CVVResult.new(response[:processor_cvv_response]),
          test: test?,
          error_code: error_code_from(response)
        )
      end

      def success_from(response)
        response[:transaction_result] == 'APPROVED'
      end

      def message_from(response)
        response[:processor_response_message] || response[:detail] || response[:error_message]
      end

      def authorization_from(response)
        response[:order_id]
      end

      def post_data(action, parameters = {})
        xml = Builder::XmlMarkup.new(indent: 2)
        xml.instruct!
        xml.soap :Envelope, 'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/' do
          xml.soap :Body do
            xml.__send__('ipgapi:IPGApiOrderRequest', 'xmlns:v1' => 'http://ipg-online.com/ipgapi/schemas/v1', 'xmlns:ipgapi' => 'http://ipg-online.com/ipgapi/schemas/ipgapi') do
              xml << parameters.target!
            end
          end
        end
        xml.target!
      end

      def error_code_from(response)
        unless success_from(response)
          STANDARD_ERROR_CODE_MAPPING[response[:approval_code]]
        end
      end

      def headers
        { 'Authorization' => basic_auth,
          'Content-Type'  => 'text/xml' }
      end

      def basic_auth
        'Basic ' + Base64.strict_encode64("#{options[:user_id]}:#{options[:password]}").chomp
      end

      def url
        test? ? test_url : live_url
      end
    end
  end
end
